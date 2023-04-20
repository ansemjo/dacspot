#!/bin/sh
# modified from buildroot-2023.02/board/raspberrypi/post-build.sh

set -eu

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
  grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# load the kernel module for wifi
if [ -e ${TARGET_DIR}/etc/inittab ]; then
  grep -qE 'modprobe brcmfmac' ${TARGET_DIR}/etc/inittab || \
	sed -i '/# now run any rc scripts/i\
::sysinit:/sbin/modprobe brcmfmac' ${TARGET_DIR}/etc/inittab
fi

# TODO: use BR2_CONFIG for conditionals
#env
#printf "PRE-BUILD ARG: %s\n" "$@"
# CONFIG_DIR=/home/ansemjo/src/extern/buildroot/dacspot/overlay/buildroot-2023.02
# PRE-BUILD ARG: /home/ansemjo/src/extern/buildroot/dacspot/overlay/buildroot-2023.02/output/target