include { summarising } from "$projectDir/modules/summarise"
include { diagnosing } from "$projectDir/modules/diagnose"

workflow POST {

  take:
    runDiagnose
    summarise_ch
    home
    summaryParams

  main:
    if (runDiagnose) {

      summarising(summarise_ch, home, summaryParams)
      diagnosing(summarise_ch, home)

    }

}
