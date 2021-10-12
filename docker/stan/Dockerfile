FROM rocker/r-ver:4.0.4

LABEL maintainer "Vasilis F. Ntasis <vasilis.ntasis@crg.eu>" \
        description "Docker image for statistical analysis with Stan"

# Update the system and install
# ps required for tracing functionality of nextflow
RUN apt-get update --fix-missing \
	&& apt-get install -y procps \
	&& apt-get clean

# Install posterior, CmdStanR and CmdStan
RUN r -e 'install.packages("remotes"); \
	remotes::install_github("stan-dev/posterior"); \
	install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))'

RUN r -e 'cmdstanr::install_cmdstan()'

# Run Bash shell
CMD ["/bin/bash"]
