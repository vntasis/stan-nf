// Use the model to sample
process sampling {
  tag "$modelName-$sampleID-$chain"
  publishDir "$params.outdir/$sampleID/samples", mode: 'copy', pattern: "*.csv"

  input:
  tuple val(sampleID), path(data), val(modelName), path(model), val(chain)
  val(sampleParams)
  val(seed)
  val(numSamples)
  val(numWarmup)
  val(threads)

  output:
  tuple val(modelName), val(sampleID), path("${sampleID}_${modelName}_${chain}.csv"), emit: samples2summary
  tuple val(modelName), val(sampleID), path(model), path(data), path("${sampleID}_${modelName}_${chain}.csv"), emit: samples2gen_quan

  script:
  """
  ./$model sample \
    num_samples=$numSamples \
    num_warmup=$numWarmup \
    $sampleParams \
    random seed=$seed id=$chain \
    data file=$data \
    output file="${sampleID}_${modelName}_${chain}.csv" \
    $threads
  """
}
