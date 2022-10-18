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

## Install procps for monitoring and create docker user
RUN apt-get update -qq && \
	apt-get install -qq procps && \
	apt-get clean && \
	useradd -ms /bin/bash docker

## Copy stan environment from the builder image
COPY --from=builder /home/docker/stan/ /home/docker/stan/
RUN chown -R docker:docker /home/docker/stan/
WORKDIR /home/docker
USER docker
#RUN echo ". /home/docker/stan/bin/activate" >> /home/docker/.bashrc

## Set all the necessary environment variables
ARG base_path="/home/docker/stan"
ENV GCC_RANLIB="$base_path/bin/x86_64-conda-linux-gnu-gcc-ranlib" \
	build_alias="x86_64-conda-linux-gnu" \
	CMAKE_ARGS="-DCMAKE_AR=$base_path/bin/x86_64-conda-linux-gnu-ar -DCMAKE_CXX_COMPILER_AR=$base_path/bin/x86_64-conda-linux-gnu-gcc-ar -DCMAKE_C_COMPILER_AR=$base_path/bin/x86_64-conda-linux-gnu-gcc-ar -DCMAKE_RANLIB=$base_path/bin/x86_64-conda-linux-gnu-ranlib -DCMAKE_CXX_COMPILER_RANLIB=$base_path/bin/x86_64-conda-linux-gnu-gcc-ranlib -DCMAKE_C_COMPILER_RANLIB=$base_path/bin/x86_64-conda-linux-gnu-gcc-ranlib -DCMAKE_LINKER=$base_path/bin/x86_64-conda-linux-gnu-ld -DCMAKE_STRIP=$base_path/bin/x86_64-conda-linux-gnu-strip" \
	GPROF="$base_path/bin/x86_64-conda-linux-gnu-gprof" \
	CONDA_TOOLCHAIN_BUILD="x86_64-conda-linux-gnu" \
	_CONDA_PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata_x86_64_conda_cos6_linux_gnu" \
	CMDSTAN_OLD="" \
	STRINGS="$base_path/bin/x86_64-conda-linux-gnu-strings" \
	CPP="$base_path/bin/x86_64-conda-linux-gnu-cpp" \
	CONDA_PREFIX="$base_path" \
	CXX="$base_path/bin/x86_64-conda-linux-gnu-c++" \
	CXXFLAGS="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $base_path/include" \
	CMDSTAN="$base_path/bin/cmdstan" \
	CONDA_TOOLCHAIN_HOST="x86_64-conda-linux-gnu" \
	DEBUG_CXXFLAGS="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem $base_path/include" \
	LDFLAGS="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined -Wl,-rpath,$base_path/lib -Wl,-rpath-link,$base_path/lib -L$base_path/lib" \
	DEBUG_CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem $base_path/include" \
	CXX_FOR_BUILD="$base_path/bin/x86_64-conda-linux-gnu-c++" \
	ELFEDIT="$base_path/bin/x86_64-conda-linux-gnu-elfedit" \
	CMAKE_PREFIX_PATH="$base_path:$base_path/x86_64-conda-linux-gnu/sysroot/usr" \
	CPPFLAGS="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $base_path/include" \
	LD="$base_path/bin/x86_64-conda-linux-gnu-ld" \
	READELF="$base_path/bin/x86_64-conda-linux-gnu-readelf" \
	GXX="$base_path/bin/x86_64-conda-linux-gnu-g++" \
	GCC_AR="$base_path/bin/x86_64-conda-linux-gnu-gcc-ar" \
	ADDR2LINE="$base_path/bin/x86_64-conda-linux-gnu-addr2line" \
	GCC_NM="$base_path/bin/x86_64-conda-linux-gnu-gcc-nm" \
	SIZE="$base_path/bin/x86_64-conda-linux-gnu-size" \
	HOST="x86_64-conda-linux-gnu" \
	CC_FOR_BUILD="$base_path/bin/x86_64-conda-linux-gnu-cc" \
	AR="$base_path/bin/x86_64-conda-linux-gnu-ar" \
	AS="$base_path/bin/x86_64-conda-linux-gnu-as" \
	DEBUG_CPPFLAGS="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem $base_path/include" \
	host_alias="x86_64-conda-linux-gnu" \
	NM="$base_path/bin/x86_64-conda-linux-gnu-nm" \
	GCC="$base_path/bin/x86_64-conda-linux-gnu-gcc" \
	LD_GOLD="$base_path/bin/x86_64-conda-linux-gnu-ld.gold" \
	OBJCOPY="$base_path/bin/x86_64-conda-linux-gnu-objcopy" \
	STRIP="$base_path/bin/x86_64-conda-linux-gnu-strip" \
	OBJDUMP="$base_path/bin/x86_64-conda-linux-gnu-objdump" \
	PATH="$base_path/bin:$base_path/bin/cmdstan/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
	CC="$base_path/bin/x86_64-conda-linux-gnu-cc" \
	CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $base_path/include" \
	CXXFILT="$base_path/bin/x86_64-conda-linux-gnu-c++filt" \
	BUILD="x86_64-conda-linux-gnu" \
	RANLIB="$base_path/bin/x86_64-conda-linux-gnu-ranlib" \
	CONDA_BUILD_SYSROOT="$base_path/x86_64-conda-linux-gnu/sysroot"


# Run Bash shell
CMD ["/bin/bash"]
