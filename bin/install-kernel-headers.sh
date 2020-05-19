#!/bin/bash

# Get the kernel headers for this linux version
# Yoinked from https://github.com/iovisor/bpftrace/blob/master/INSTALL.md#kernel-headers-install

set -ex

KERNEL_VERSION="${KERNEL_VERSION:-$(uname -r)}"
kernel_version="$(echo "${KERNEL_VERSION}" | awk -vFS=- '{ print $1 }')"
major_version="$(echo "${KERNEL_VERSION}" | awk -vFS=. '{ print $1 }')"

apt-get install -y build-essential bc curl flex bison libelf-dev libssl-dev

mkdir -p /usr/src/linux
curl -sL "https://www.kernel.org/pub/linux/kernel/v${major_version}.x/linux-$kernel_version.tar.gz"     | tar --strip-components=1 -xzf - -C /usr/src/linux
cd /usr/src/linux

# Fedora doesn't have kernel config available at
# /proc/config.gz
# zcat /proc/config.gz > .config
cat /root/kernelconfig > .config
make ARCH=x86 oldconfig
make ARCH=x86 prepare
mkdir -p /lib/modules/$(uname -r)
ln -sf /usr/src/linux /lib/modules/$(uname -r)/source
ln -sf /usr/src/linux /lib/modules/$(uname -r)/build
