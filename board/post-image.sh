#!/usr/bin/env bash
# modified from buildroot-2023.02/board/raspberrypi/post-image.sh

set -eu

# load buildroot config (without makefile variable syntax values)
source <(grep -v '\$\(.\+\)' "${BR2_CONFIG}")

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

# configure the genimage.cfg with selected rootfs
rootfs="ext4"
if [[ ${DACSPOT_USE_SQUASHFS_ROOT:-n} == y ]]; then
	rootfs="squashfs"
fi

# uncomment selected rootfs line
sed "s/#${rootfs}: //" "${GENIMAGE_CFG}" > "${BUILD_DIR}/genimage.cfg"


genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${BUILD_DIR}/genimage.cfg"

exit $?
