# Stan-NF

A nextflow pipeline for performing statistical analysis with Stan. 

## Introduction

Stan-NF is using CmdStan to draw samples from a posterior.

[Stan](https://mc-stan.org/) is a state-of-the-art platform for statistical modeling and high-performance statistical computation. It uses Markov chain Monte Carlo (MCMC) sampling, in order to get full Bayesian statistical inference. For more information check Stan's [documentation](https://mc-stan.org/user/documentation/).

[CmdStan](https://mc-stan.org/users/interfaces/cmdstan) is the command-line interface to Stan. It taskes as input a statistical model written in Stan probabilistic programming language and compiles it to a C++ executable, which can then be used to draw samples from the posterior. It also offers tools for generating quantities of interest from an existing estimate, as well as evaluating and summarizing the produced outputs.

Stan-NF uses [Nextflow](http://www.nextflow.io) as the execution backend. It ensures scalability and automation. It makes trivial the deployment of a pipeline in a high performance computing or cloud environment. Please check [Nextflow documentation](http://www.nextflow.io/docs/latest/index.html) for more information. 

The user may provide multiple Stan models and/or datasets. Stan-NF will execute different processes in parallel to compile the different models, and then sample from the posteriors of those models based on every different dataset. So, the number of output files depends on `M x D`, where `M` is the number of model files provided and `D` the number of data files provided.


## Requirements

- Unix-like operationg system (Linux, MacOS, etc)
- Nextflow (Stan-NF was created and tested with nextflow version 20.10.0.5430)
- [Docker](https://www.docker.com/) or [Singularity](http://singularity.lbl.gov) engine

## Pipeline summary

1. Compile Stan model(s) into executable(s)
2. Run MCMC in order to sample from the posterior distribution
3. Summarize the results per sample (and per model)
4. Calculate basic diagnostic metrics for the MCMC run(s)
5. Standalone generate quantities of interest from a fitted model

## Quickstart

1. Install Nextflow by using the following command:

    ```
    curl -s https://get.nextflow.io | bash
    ```

2. Fetch the pipeline and print help information about it:

    ```
    ./nextflow run vntasis/stan-nf --help
    ```

## Pipeline parameters

### General

The following parameters are required for every run of the pipeline, but all of them have default values. In most cases, there is no reason changing them.

`--data DATA_PATH`
- Input data file(s) for the model in json format. By defualt, Stan-NF will look for json files inside a directory named `data` located in the current working directory (Default: './data/*.json').
- Note: The content of the json file has to match the structure of the data as declared in the `data` section of the provided stan model. For more information, check CmdStan's documentation on [JSON Format for CmdStan](https://mc-stan.org/docs/2_28/cmdstan-guide/json.html).

`--outdir OUTPUT_PATH`
- Output directory where all the results are going to be saved. By default, output is saved in a directory with the name `results` located in the current working directory (Default: './results').
- Stan-NF is going to extract the dataset name from the name of the input json file and use it to create a directory for the results specific to this dataset inside the `results` directory. For instance, if the input is `sample1.json` and `sample2.json`, `results/sample1` and `results/sample2` directories are going to be created by the pipeline.

`--steps STEPS_STR`
- Comma-separated character string declaring the steps of the pipeline to run (Default: 'build-model,sample,diagnose').
- Possible steps: 
  * `build-model`: Compile Stan model(s) into executable(s)
  * `sample` : Run MCMC in order to sample from the posterior distribution
  * `diagnose`: Summarize results and calculate basic diagnostic metrics
  * `generate-quantities`: Standalone generate quantities of interest from a fitted model


`--model MODEL_PATH`
- File(s) describing a model in Stan probabilistic language, or
- Model executable(s) that has already been generated. In this case the `build-model` step should be omitted. 
- By default, Stan-NF will look for model files in a directory named `model` located in the current working directory (Default: './models/*.stan').

`--chains CHAIN_NUMBER`
- Number of chains to run (or read). It will be used for sampling, and for standalone generating quantities (Default: 1).

`--seed SEED`
- Number to be used as a seed for sampling and(or) generating quantities (Default: 1234).

`--cmdStanHome STAN_HOME_PATH`
- Path of the CmdStan home directory containing Stan executables (Default (for use with docker): '/home/docker/cmdstan-2.28.0').


### Building a model

`--buildModelParams PARAM_STR`
- String containing parameters to be concatenated on the command that builds the model (Default: '').
- For more information, please check CmdStan's documentation on [C++ compilation and linking flags](https://mc-stan.org/docs/2_28/cmdstan-guide/compiling-a-stan-program.html#c-compilation-and-linking-flags) and on [The Stan compiler program](https://mc-stan.org/docs/2_28/cmdstan-guide/stanc.html#the-stan-compiler-program).


### Sampling
`--numSamples SAMPLES_NUMBER`
- Number of samples to be drawn from the posterior (Default: 1000).

`--numWarmup WARMUP_NUMBER`
- Number of samples (separate from the ones above) to be used for the Warmup phase (Default: 1000).

`--sampleParams PARAM_STR`
- String containing extra parameters to be concatenated on the command that performs the sampling (Default: 'adapt delta=0.8 algorithm=hmc engine=nuts max_depth=10').
- For more information, please check CmdStan's documentation on [Command-Line Interface Overview](https://mc-stan.org/docs/2_28/cmdstan-guide/command-line-interface-overview.html) and on [MCMC Sampling using Hamiltonian Monte Carlo](https://mc-stan.org/docs/2_28/cmdstan-guide/mcmc-config.html).


### Summarize results

`--summaryParams PARAM_STR`
- String containing parameters to be concatenated on the command that will summarise the posterior samples (Default: '-s 3').
- For more information, including a full list of the options, please check CmdStan's documentation on [stansummary: MCMC Output Analysis](https://mc-stan.org/docs/2_28/cmdstan-guide/stansummary.html).


### Generating quantities

`--fittedParams SAMPLES_PATH`
- CSV file(s) containing samples drawn from a posterior. They will be used for standalone generating quantities of interest from a model, when a model has already been fitted (Default: '').
- For more information, please check CmdStan's documentation on [Standalone Generate Quantities](https://mc-stan.org/docs/2_28/cmdstan-guide/standalone-generate-quantities.html).


### Other
`--multithreading`
- Option for multithreaded models. This will add the right flags during the compilation of the model (Default: false)
- This feature is still experimental. Currently only multi-threading with Intel Threading Building Blocks (TBB) is included in the pipeline. For more information, please check CmdStan's documentation on [Parallelization](https://mc-stan.org/docs/2_28/cmdstan-guide/parallelization.html)

`--threads THREAD_NUMBER`
- Number of threads to be used for sampling and generating quantities in case of multithreaded models (Default: 2)

`--help`
- Print help message and exit

## Pipeline input
## Pipeline output
## Running the pipeline

## Stan version

The current CmdStan version built inside the docker image is 2.28.0
