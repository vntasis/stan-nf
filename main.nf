#!/usr/bin/env nextflow

/*
==================================================================
                            Stan-NF
==================================================================
Nextflow pipeline for performing statistical analysis with Stan
#### Homepage / Documentation
https://github.com/vntasis/stan-nf
------------------------------------------------------------------
*/

/*
 * Input parameters for the pipeline
 */

params.data               = "$launchDir/data/*.json"
params.dataExportScript   = null
params.model              = "$launchDir/models/*.stan"
params.outdir             = "$launchDir/results"
params.fittedParams      = ''
params.cmdStanHome        = "/home/docker/cmdstan-2.28.0"
params.steps              = 'build-model,sample,diagnose'
params.multithreading     = false
params.threads            = 2
params.chains             = 1
params.seed               = 1234
params.numSamples         = 1000
params.numWarmup          = 1000
params.buildModelParams   = ''
params.sampleParams       = 'adapt delta=0.8 algorithm=hmc engine=nuts max_depth=10'
params.diagnoseParams     = ''
params.summaryParams      = ''
params.help               = ''

// Other variables
multithreadParam = params.multithreading ? 'STAN_THREADS=true' : ''
threads = params.multithreading ? "num_threads=$params.threads" : ''

Steps          = params.steps.split(',').collect { it.trim() }
runBuildModel  = 'build-model' in Steps
runExportData  = 'export-data' in Steps
runSample      = 'sample' in Steps
runGenQuan     = 'generate-quantities' in Steps
runDiagnose    = 'diagnose' in Steps

// Output directory
outdir = file(params.outdir)
if (!outdir.exists()) outdir.mkdir()

/*
 * Help message
 */

/*
 * Print Initial message
 */

/*
 * Declare channels
 */
Channel.empty().into {
  model2build_ch;
  model2sample_ch;
  model_ch;
  model2gen_quan_ch;
  gen_quan_ch;
}

Channel
  .of(1..params.chains)
  .set{ chains_ch }


if (runBuildModel) {

  Channel
    .fromPath(params.model, checkIfExists: true)
    .map{ [ it.simpleName, it ] }
    .set{ model2build_ch }

}else if (runSample) {

  Channel
    .fromPath(params.model, checkIfExists: true)
    .map{ [ it.simpleName, it ] }
    .set{ model_ch }

  Channel
    .fromPath(params.data, checkIfExists: true)
    .map{ [ it.simpleName, it ] }
    .combine(model_ch)
    .combine(chains_ch)
    .set{ model2sample_ch }

}else if (runGenQuan) {

  Channel
    .fromPath(params.model, checkIfExists: true)
    .map{ [ it.simpleName, it ] }
    .set{ model_ch }

  Channel
    .fromPath(params.data, checkIfExists: true)
    .map{ [ it.simpleName, it ] }
    .combine(model_ch)
    .set{ model2gen_quan_ch }

  Channel
    .fromPath(params.fittedParams, checkIfExists: true)
    .collect()
    .map{ [ it ] }
    .combine(model2gen_quan_ch)
    .map{ [ it[3], it[1], it[4], it[2], it[0] ] }
    .set{ gen_quan_ch }
}



/*
 * Pipeline processes
 */


// Build the binary of the model
process buildingModel {
  tag "$modelName"
  publishDir "$params.outdir/models", mode: 'copy'

  input:
  tuple val(modelName), path(modelFile) from model2build_ch
  val buildParams from params.buildModelParams
  val mthreading from multithreadParam
  val stan from params.cmdStanHome

  output:
  tuple val(modelName), path(modelName) into model_built_ch

  when:
  runBuildModel

  script:
  """
  wdir="\$PWD" && \
  cd $stan && \
  make "\$wdir/$modelName" $mthreading $buildParams
  """

}



// Use the model to sample
if (runBuildModel) {
  Channel
    .fromPath(params.data, checkIfExists: true)
    .map{ [ it.simpleName, it ] }
    .combine(model_built_ch)
    .combine(chains_ch)
    .set{ model2sample_ch }
}

process sampling {
  tag "$modelName-$sampleID-$chain"
  publishDir "$params.outdir/$sampleID/samples", mode: 'copy', pattern: "*.csv"

  input:
  tuple val(sampleID), path(data), val(modelName), path(model), val(chain) from model2sample_ch
  val(sampleParams) from params.sampleParams
  val(seed) from params.seed
  val(numSamples) from params.numSamples
  val(numWarmup) from params.numWarmup
  val(threads) from threads

  output:
  tuple val(modelName), val(sampleID), path("${sampleID}_${modelName}_${chain}.csv") into samples2summary_ch
  tuple val(modelName), val(sampleID), path(model), path(data), path("${sampleID}_${modelName}_${chain}.csv") into samples2gen_quan_ch

  when:
  runSample

  script:
  """
  ./$model sample \
    num_samples=$numSamples \
    num_warmup=$numWarmup \
    $sampleParams \
    random seed=$seed \
    data file=$data \
    output file="${sampleID}_${modelName}_${chain}.csv" \
    $threads
  """
}



// Summarise data and run some diagnostics
samples2summary_ch
  .groupTuple(by: [0,1])
  .set{ summarise_ch }

process summarising {
  tag "$modelName-$sampleID"
  publishDir "$params.outdir/$sampleID/", mode: 'copy'

  input:
  tuple val(modelName), val(sampleID), path("*") from summarise_ch
  val stan from params.cmdStanHome
  val(diagnoseParams) from params.diagnoseParams
  val(summaryParams) from params.summaryParams

  output:
  file("summary_${modelName}_${sampleID}.txt")
  file("diagnostics_${modelName}_${sampleID}.txt")

  when:
  runDiagnose

  script:
  """
  $stan/bin/stansummary $summaryParams *.csv \
    > "summary_${modelName}_${sampleID}.txt" && \
    $stan/bin/diagnose $diagnoseParams *.csv \
    > "diagnostics_${modelName}_${sampleID}.txt"
  """
}



//Generate quantities process
if (runSample) {
  samples2gen_quan_ch
    .groupTuple(by: [0,1])
    .map { [ it[0], it[1], it[2][1], it[3][1], it[4] ] }
    .set{ gen_quan_ch }
}

process generating_quantities {
  tag "$modelName-$sampleID"
  publishDir "$params.outdir/$sampleID/generated_quantities/", mode: 'copy'

  input:
  tuple val(modelName), val(sampleID), path(model), path(data), path("*") from gen_quan_ch
  val(chains) from params.chains
  val(seed) from params.seed
  val(threads) from threads

  output:
  file("generated_quantities_${modelName}_${sampleID}_*.csv")

  when:
  runGenQuan

  script:
  """
  for chain in {1..$chains}
  do
    ./$model generate_quantities \
      fitted_params="${sampleID}_${modelName}_\${chain}.csv" \
      data file=$data \
      output file=generated_quantities_${modelName}_${sampleID}_\${chain}.csv \
      random seed=$seed \
      $threads
  done
  """
}


/*
 * Print message upon completion of the pipeline
 */
workflow.onComplete {
  log.info ( workflow.success ? "\nDone! Results are located in: $params.outdir\n" : "Oops .. something went wrong" )
}
