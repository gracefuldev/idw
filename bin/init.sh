#!/bin/bash -v
# TODO: can we replace perf-tools in vendor with the perf-tools-unstable package?
git submodule init
git submodule update
echo ". /workspaces/idw/bin/environment.sh" >> ~/.bashrc
echo ". /workspaces/idw/bin/environment.sh" >> ~/.profile

# Many (all?) BCC tools require access to the kernel's debug pseudo-fs
# In Docker, this grants access to the *host kernel's* debugfs, so:
# a) This will only work when running with --privileged; and
# b) Beware! This escapes from containment!
mount -t debugfs debugfs /sys/kernel/debug