FROM ubuntu:20.04

ARG RUST_VERSION=1.59.0
ARG DFX_VERSION=0.10.1
ARG NODE_INSTALL_VERSION=16
ARG RUN_INTERNET_IDENTITY=true

ENV DFX_PROJECTS_DIR=/Projects \
    DFX_VERSION=${DFX_VERSION} \
    NODE_INSTALL_VERSION=${NODE_INSTALL_VERSION} \
    RUN_INTERNET_IDENTITY=${RUN_INTERNET_IDENTITY} \
    DEBIAN_FRONTEND=noninteractive \
    DEBUG=true \
    TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        ca-certificates \
        build-essential \
        cmake \
        rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install node
RUN curl  --fail -sSf "https://deb.nodesource.com/setup_${NODE_INSTALL_VERSION}.x" | bash && \
    apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo in /opt
ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    PATH=/opt/cargo/bin:$PATH

RUN curl --fail https://sh.rustup.rs -sSf \
    | sh -s -- -y --default-toolchain ${RUST_VERSION}-x86_64-unknown-linux-gnu --no-modify-path && \
    rustup default ${RUST_VERSION}-x86_64-unknown-linux-gnu

ENV CARGO_HOME=/cargo \
    CARGO_TARGET_DIR=/cargo_target \
    PATH=/cargo/bin:$PATH

# Install DFINITY SDK.
RUN sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"

# Getting internet-identity from source
RUN [ -n "${RUN_INTERNET_IDENTITY}" ] && git clone https://github.com/dfinity/internet-identity.git default_project || dfx new default_project

WORKDIR /default_project

# Adding dfxctl
COPY ./scripts/* /usr/bin/

RUN chmod +x /usr/bin/dfxctl /usr/bin/dfx_run

CMD dfx_run
