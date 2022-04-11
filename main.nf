#!/usr/bin/env nextflow

/*
==================================================================
                            Stan-NF
==================================================================
Nextflow pipeline for performing statistical analysis with Stan
#### Homepage / Documentation
https://github.com/vntasis/stan-nf
==================================================================

Copyright (C) 2021  Vasileios F. Ntasis

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.
If not, see <https://www.gnu.org/licenses/>.
*/

nextflow.enable.dsl=2


// Required variables
multithreadParam = params.multithreading ? 'STAN_THREADS=true' : ''
threads = params.multithreading ? "num_threads=$params.threads" : ''
seed2genquan = params.seedToGenQuan ? "random seed=$params.seed" : ''

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
if (params.help) {
  log.info"""
  Stan-NF PIPELINE
  ================
  Stan-NF will produce samples from a posterior using CmdStan,
  given one or more models and some data. For more information
  check out documentation at https://github.com/vntasis/stan-nf

  Current CmdStan version utilized: 2.28.0
  Note: Users are highly advised to read the documentation of CmdStan
        (https://mc-stan.org/users/interfaces/cmdstan)

  Usage:
    nextflow run vntasis/stan-nf --data DATA_PATH --outdir OUTPUT_PATH

  Options:
    General
      --data DATA_PATH              Input data for the model (Default: './data/*.json')
      --outdir OUTPUT_PATH          Output directory where all the results are going to be saved (Default: './results')
      --steps STEPS_STR             Comma-separated Character string declaring the steps of the pipeline to be
                                    implemented (Default: 'build-model,sample,diagnose')
      --model MODEL_PATH            File(s) describing the stan model(s) of interest (Default: './models/*.stan')
      --chains CHAIN_NUMBER         Number of chains. It will be used for sampling, and for standalone generating
                                    quantities (Default: 1)
      --seed  SEED                  Number to be used as a seed for sampling and generating quantities (Default: 1234)
      --cmdStanHome STAN_HOME_PATH  Path of the CmdStan home directory containing Stan executables
                                    (Default (for use with docker): '/home/docker/cmdstan-2.28.0')

    Building-Model
      --buildModelParams PARAM_STR  String containing parameters to be concatenated on the command that builds the model
                                    (Default: '')

    Sampling
      --numSamples SAMPLES_NUMBER   Number of samples to be drawn from the posterior (Default: 1000)
      --numWarmup WARMUP_NUMBER     Number of samples to be used for the Warmup phase (Default: 1000)
      --sampleParams PARAM_STR      String containing parameters to be concatenated on the command that performs the
                                    sampling (Default: 'adapt delta=0.8 algorithm=hmc engine=nuts max_depth=10')

    Generating-Quantities
      --fittedParams SAMPLES_PATH   CSV files containing Samples drawn from a posterior. They will be used for
                                    standalone generating quantities of interest from a model, when samples have already
                                    been drawn (Default: '')
      --seedToGenQuan               By default, generating quantities is run without a seed. This option will
                                    pass the provided seed to generating quantities (Default: false)

    Summarize-output
      --summaryParams PARAM_STR     String containing parameters to be concatenated on the command that will summarise
                                    the posterior samples (Default: '-s 3')
    Other
      --multithreading              Option for multithreaded models. This will add the right flags during the
                                    compilation of the model (Default: false)
      --threads THREAD_NUMBER       Number of threads to be used for sampling and generating quantities in case of
                                    multithreaded models (Default: 2)
      --help                        Print this help message and exit

  """
  .stripIndent()

  exit 0
}

/*
 * Print Initial message
 */
log.info ""
log.info "Stan-NF PIPELINE"
log.info "================"
log.info "Steps:                                    ${params.steps}"
log.info "Ouput directory:                          ${params.outdir}"
log.info "Model file(s):                            ${params.model}"
log.info "Stan home directory:                      ${params.cmdStanHome}"
if (runBuildModel) {
  log.info "Extra parameters for Building the model:  ${params.buildModelParams}"
}
if (runSample) {
  log.info "Input Data:                               ${params.data}"
  log.info "Number of chains:                         ${params.chains}"
  log.info "Number of samples for Output:             ${params.numSamples}"
  log.info "Number of samples for Warmup:             ${params.numWarmup}"
  log.info "Extra parameters for Sampling:            ${params.sampleParams}"
  log.info "Seed:                                     ${params.seed}"
}
if (runDiagnose) {
  log.info "Extra parameters for Summary:             ${params.summaryParams}"
}
if (runGenQuan && !(runSample)) {
  log.info "Input Data:                               ${params.data}"
  log.info "Number of chains:                         ${params.chains}"
  log.info "Fitted parameters file(s):                ${params.fittedParams}"
  if (params.seedToGenQuan) log.info "Seed:                                     ${params.seed}"
}
if (params.multithreading) {
  log.info "Multithreading:                           ${params.multithreading}"
  log.info "Number of threads:                        ${params.threads}"
}
log.info ""


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

include { BUILD } from "$projectDir/subworkflows/build_model"
include { SAMPLE } from "$projectDir/subworkflows/sample"
include { POST } from "$projectDir/subworkflows/post_processing"


workflow {

  BUILD(runBuildModel, model2build_ch, params.buildModelParams, multithreadParam, params.cmdStanHome)

  if (runBuildModel && runSample) {
    Channel
      .fromPath(params.data, checkIfExists: true)
      .map{ [ it.simpleName, it ] }
      .combine(BUILD.out)
      .combine(chains_ch)
      .set{ model2sample_ch }
  }


  SAMPLE(runSample, model2sample_ch, params.sampleParams, params.seed, params.numSamples, params.numWarmup, threads)


  SAMPLE.out.samples2summary
    .groupTuple(by: [0,1])
    .set{ summarise_ch }

  POST(runDiagnose, summarise_ch, params.cmdStanHome, params.summaryParams)

  if (runSample) {
    SAMPLE.out.samples2gen_quan
      .groupTuple(by: [0,1])
      .map { [ it[0], it[1], it[2][1], it[3][1], it[4] ] }
      .set{ gen_quan_ch }
  }

}





/*
 * Print message upon completion of the pipeline
 */
workflow.onComplete {
  log.info ( workflow.success ? "\nDone! Results are located in: $params.outdir\n" : "Oops .. something went wrong" )
}
