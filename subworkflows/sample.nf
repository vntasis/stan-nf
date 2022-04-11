include { sampling } from "$projectDir/modules/sample"

workflow SAMPLE {

  take:
    runSample
    sample_ch
    sampleParams
    seed
    numSamples
    numWarmup
    threads

  main:
    if (runSample) {

      sampling(sample_ch, sampleParams, seed, numSamples, numWarmup, threads)

    }

  emit:
    samples2summary = sampling.out.samples2summary
    samples2gen_quan = sampling.out.samples2gen_quan


}
