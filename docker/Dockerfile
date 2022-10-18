FROM mambaorg/micromamba:0.27.0 AS builder

LABEL authors="Vasilis Ntasis <vasilis.ntasis@crg.eu>" \
	description="Docker image for statistical analysis with Stan"

# Change user name
ARG NEW_MAMBA_USER=docker
ARG NEW_MAMBA_USER_ID=1000
ARG NEW_MAMBA_USER_GID=1000
USER root
RUN usermod "--login=${NEW_MAMBA_USER}" \
	"--home=/home/${NEW_MAMBA_USER}" \
	--move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
	groupmod "--new-name=${NEW_MAMBA_USER}" \
	"-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
	# Update the expected value of MAMBA_USER for the
	# _entrypoint.sh consistency check.
	echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
	:
ENV MAMBA_USER=$NEW_MAMBA_USER
USER $MAMBA_USER

# Install necessary tools and pack stan environment
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN micromamba install -n base -y -c conda-forge conda-pack && \
	micromamba create -n stan -c conda-forge cmdstan=2.30.0 && \
	conda-pack -p /opt/conda/envs/stan -o /tmp/env.tar && \
	micromamba remove -p /opt/conda/envs/stan --all -y && \
	micromamba clean --all --yes && \
	mkdir /home/docker/stan

# Unpack stan environment
WORKDIR /home/docker/stan
RUN tar xf /tmp/env.tar && \
	rm /tmp/env.tar && \
	/home/docker/stan/bin/conda-unpack

# Build final, Slim image.
FROM debian:bullseye-slim
RUN apt-get update -qq && \
	apt-get install -qq procps && \
	apt-get clean && \
	useradd -ms /bin/bash docker

COPY --from=builder /home/docker/stan/ /home/docker/stan/
RUN chown -R docker:docker /home/docker/stan/
WORKDIR /home/docker
USER docker
ENV PATH="/home/docker/stan/bin/cmdstan/bin:$PATH"
RUN echo ". /home/docker/stan/bin/activate" >> /home/docker/.bashrc

# Run Bash shell
CMD ["/bin/bash"]
