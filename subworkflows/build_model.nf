include { buildingModel } from "$projectDir/modules/build_model"


workflow BUILD {
  take:
    runBuildModel
    build_ch
    buildParams
    threadParam
    home

  main:
    if (runBuildModel) {

      buildingModel(build_ch, buildParams, threadParam, home)

    }

  emit:
    buildingModel.out

}
