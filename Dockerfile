FROM debian:buster

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Docker Compose version
ARG COMPOSE_VERSION=1.24.0

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=idw
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    # Verify git, process tools installed
    && apt-get -y install git openssh-client less iproute2 procps lsb-release \
    #
    # Install Docker CE CLI
    && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    #
    # Install Docker Compose
    && curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME
#
# # Clean up
# && apt-get autoremove -y \
# && apt-get clean -y \
# && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y man

# Investigative Debugging Tools!
RUN apt-get install -y strace
RUN apt-get install -y ltrace
RUN apt-get install -y linux-perf
RUN apt-get install -y perf-tools-unstable
RUN apt-get install -y bpfcc-tools
RUN apt-get install -y bpftrace
# needed to compile ruby with --enable-dtrace
RUN apt-get install -y systemtap-sdt-dev
RUN apt-get install -y wget
RUN apt-get install -y build-essential

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

RUN cd ~ \
    && wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz \
    && tar -xzvf ruby-install-0.7.0.tar.gz \
    && cd ruby-install-0.7.0/ \
    && sudo make install

RUN cd ~ \ 
    && wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz \
    && tar -xzvf chruby-0.3.9.tar.gz \
    && cd chruby-0.3.9/ \
    && sudo make install

RUN ruby-install && ruby-install ruby-2.7.1 -- --enable-dtrace