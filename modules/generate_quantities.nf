//Generate quantities process
process generating_quantities {
  tag "$modelName-$sampleID"
  publishDir "$params.outdir/$sampleID/generated_quantities/", mode: 'copy'

  input:
  tuple val(modelName), val(sampleID), path(model), path(data), path("*") from gen_quan_ch
  val(chains) from params.chains
  val(seed) from seed2genquan
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
      $seed \
      $threads
  done
  """
}
