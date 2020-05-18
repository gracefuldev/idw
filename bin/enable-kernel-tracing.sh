#!/bin/sh
# Many (all?) BCC tools require access to the kernel's debug pseudo-fs
# In Docker, this grants access to the *host kernel's* debugfs, so:
# a) This will only work when running with --privileged; and
# b) Beware! This escapes from containment!
mount -t debugfs debugfs /sys/kernel/debug