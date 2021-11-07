FROM rocker/r-ver:4.0.4 AS builder

LABEL maintainer "Vasilis F. Ntasis <vasilis.ntasis@crg.eu>" \
        description "Docker image for statistical analysis with Stan - slim version"

# Update the system and install
RUN apt-get update -qq \
	&& apt-get clean

# Install posterior, CmdStanR and CmdStan
RUN r -e 'install.packages("remotes"); \
	remotes::install_github("stan-dev/posterior"); \
	install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))'

RUN r -e 'cmdstanr::install_cmdstan(version = "2.28.0")'

# Final image
FROM debian:buster-slim

RUN apt-get update -qq \
	&& apt-get install -y procps \
	&& apt-get clean

# Create a docker user and set home as the working directory
RUN useradd -ms /bin/bash docker
COPY --from=builder /root/.cmdstanr/cmdstan-2.28.0/ /home/docker/cmdstan-2.28.0/
WORKDIR /home/docker
USER docker

# Run Bash shell
CMD ["/bin/bash"]

