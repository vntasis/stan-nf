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
 l   ```
## Pipeline parameters
## Pipeline input
## Pipeline output
## Running the pipeline

## Stan version

Current CmdStan version built inside the docker image 2.28.0
