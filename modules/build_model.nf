// Build the binary of the model
process buildingModel {
  tag "$modelName"
  publishDir "$params.outdir/models", mode: 'copy'

  input:
  tuple val(modelName), path(modelFile)
  val buildParams
  val mthreading
  val stan

  output:
  tuple val(modelName), path(modelName)


  script:
  """
  wdir="\$PWD" && \
  cd $stan && \
  make "\$wdir/$modelName" $mthreading $buildParams
  """

}
