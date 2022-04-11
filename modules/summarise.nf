// Summarise output
process summarising {
  tag "$modelName-$sampleID"
  publishDir "$params.outdir/$sampleID/summaries", mode: 'copy', pattern: 'summary_*.txt'

  input:
  tuple val(modelName), val(sampleID), path("*")
  val stan
  val(summaryParams)

  output:
  file("summary_${modelName}_${sampleID}.txt")

  script:
  """
  $stan/bin/stansummary $summaryParams *.csv \
    > "summary_${modelName}_${sampleID}.txt"
  """
}
