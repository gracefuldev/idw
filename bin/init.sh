#!/bin/bash -v
# TODO: can we replace perf-tools in vendor with the perf-tools-unstable package?
git submodule init
git submodule update
echo ". /workspaces/idw/bin/environment.sh" >> ~/.bashrc
echo ". /workspaces/idw/bin/environment.sh" >> ~/.profile

sh /workspaces/idw/bin/enable-kernel-tracing.sh