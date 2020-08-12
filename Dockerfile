FROM debian:buster

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Docker Compose version
ARG COMPOSE_VERSION=1.24.0
ARG RUBY_VERSION=2.7.1

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=idw
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install base packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    # Verify git, process tools installed
    && apt-get -y install git openssh-client less iproute2 procps lsb-release \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Docker CE CLI
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    #
    # Install Docker Compose
    && curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

#
# # Clean up
# RUN apt-get autoremove -y \
# && apt-get clean -y \
# && rm -rf /var/lib/apt/lists/*

# Get the kernel headers (some BCC tools need them)
# Note that this is not as simple as getting the headers for the container's 
# Linux version. They need to be the headers for the Docker host kernel.
COPY ./bin/install-kernel-headers.sh /root/
RUN cd /root && bash install-kernel-headers.sh 

RUN apt-get install -y man

# Investigative Debugging Tools!
RUN apt-get install -y strace
RUN apt-get install -y ltrace
RUN apt-get install -y linux-perf
RUN apt-get install -y perf-tools-unstable
RUN apt-get install -y bpfcc-tools
# We're gonna build this one from source
# RUN apt-get install -y bpftrace
RUN apt-get install -y lsof

# Prerequisites to builld Ruby with dtrace/usdt enabled
RUN apt-get install -y systemtap-sdt-dev
RUN apt-get install -y wget
RUN apt-get install -y build-essential


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

RUN ruby-install && ruby-install ruby-${RUBY_VERSION} -- --enable-dtrace

# Just some conveniences for editing Ruby files
RUN /opt/rubies/ruby-${RUBY_VERSION}/bin/gem install rufo 
RUN /opt/rubies/ruby-${RUBY_VERSION}/bin/gem install solargraph

# Deps for building bpftrace from source
RUN apt-get install -y libbpfcc-dev
RUN apt-get install -y libbpf-dev
RUN apt-get install -y llvm-dev
RUN apt-get install -y libclang-dev
RUN apt-get install -y cmake
RUN apt-get install -y binutils-dev
RUN apt-get install -y clang

# Compile BPF Compiler Collection (BCC) from source. 
# The version in Debian buster is old enough that it's missing tools such as uflow
RUN apt-add-repository non-free \
    && apt-add-repository --enable-source "deb http://httpredir.debian.org/debian/ buster main non-free" \
    && apt-get update \
    && cd ~ \
    && git clone https://github.com/iovisor/bcc.git \
    && cd bcc \
    && git checkout v0.15.0 \
    && mkdir -p build \
    && cd build \
    && cmake .. \
    && make \
    && make install

RUN cd ~ \
    && git clone https://github.com/iovisor/bpftrace.git \
    && cd bpftrace \
    && git checkout v0.11.0 \
    && mkdir -p build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release ../ \
    && make \
    && make install

# For Node 12
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global http-server

# Enable mitmproxy to proxy SSL connections
# See https://docs.mitmproxy.org/stable/concepts-certificates/
#
# This is a bunch of work to install mitmproxy's own certs as trusted.
#
# Basically:
# 1. Copy in some certificates that were auto-generated by mitmproxy and I saved
# 2. Convert the correct one (mitmproxy-ca-cert.pem) to .crt format
# 3. Add a new mitmproxy directory in the system certs tree
# 4. Copy the .crt file to the new directory
# 5. Add a line to /etc/ca-certificates.conf to stamp the new cert as approved
# 6. Run update-ca-certificates to tell the OS to update its caches of trusted
#    certificates.

# for dig
RUN apt-get install -y dnsutils \
    # for ab (apache bench), it's a web performance testing tool
    apache2-utils \ 
    # for sanity
    vim \
    # For header files, for use with bpftrace (move to that section)
    libc6-dev-i386 \
    # For Java
    default-jdk \
    # monitor dns: tcpdump -i eth0 udp port 53
    tcpdump \
    # this is important
    cowsay

##
# Set up mitmproxy
#
# Trigger a transparent proxy with bin/mitmproxy-transparent.sh
##
# Add a user for mitmproxy
RUN useradd --create-home mitmproxyuser \
    # install mitmproxy
    && apt-get install -y mitmproxy iptables \
    # force mitmproxy to generate certs in ~/.mitmproxy/
    && sudo -u mitmproxyuser -H bash -c 'mitmproxy --options' > /dev/null \
    # make a new system dir for the mitmproxy cert
    && mkdir /usr/share/ca-certificates/mitmproxy \
    # convert and copy mitmproxy cert into systemwide cert store
    && openssl x509 -in /home/mitmproxyuser/.mitmproxy/mitmproxy-ca-cert.pem -inform PEM -out /usr/share/ca-certificates/mitmproxy/mitmproxy-ca-cert.crt \
    # tell system to trust the mitmproxy cert
    && echo "mitmproxy/mitmproxy-ca-cert.crt" >> /etc/ca-certificates.conf \
    # tell system to update its cache of trusted certs
    && update-ca-certificates

COPY ./bin ~/bin

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=
# we don't have locale support in here. This makes it not complain
ENV LANG=C