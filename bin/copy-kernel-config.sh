#!/bin/sh
# Fedora does not make the kernel config of the
# running kernel available at /proc/config.gz, so it
# is not accessible when building the image without
# doing something manually.
#
# This copies the kernel config to a file in the
# current directory in a (hopefully) cross-distro way,
# and that file is then copied into the image in the
# Dockerfile.
#
# https://blog.fpmurphy.com/2015/10/what-is-procconfig-gz.html
if [ -f /proc/config.gz ]; then
  zcat /proc/config.gz > kernelconfig
elif [ -f /boot/config-$(uname -r) ]; then
  cp /boot/config-$(uname -r) kernelconfig
else
  echo "Could not find kernel configuration!"
  exit 1
fi
