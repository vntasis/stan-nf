// Run diagnostics
process diagnosing {
  tag "$modelName-$sampleID"
  publishDir "$params.outdir/$sampleID/diagnostics", mode: 'copy', pattern: 'diagnostics_*.txt'

  input:
  tuple val(modelName), val(sampleID), path("*")
  val stan

  output:
  file("diagnostics_${modelName}_${sampleID}.txt")

  script:
  """
  $stan/bin/diagnose *.csv \
    > "diagnostics_${modelName}_${sampleID}.txt"
  """
}

