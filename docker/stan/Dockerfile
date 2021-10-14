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

# Create a docker user and set home as the working directory
RUN useradd -ms /bin/bash docker && \
	mv /root/.cmdstanr/cmdstan-2.28.0/ /home/docker
WORKDIR /home/docker
USER docker

# Run Bash shell
CMD ["/bin/bash"]
