#!/usr/bin/env bash
# do a full rebuild and save the resulting sdcard image
set -eux

br=buildroot-2024.02.5

# confirm that certain files exist
test -f "$br.tar.gz"
test -f "secrets.cfg"

# purge and re-extract buildroot release
rm -rf "$br/"
tar xf "$br.tar.gz"

# enter buildroot release and apply defconfig
cd "$br/"
make BR2_EXTERNAL=../ dacspot_defconfig
./support/kconfig/merge_config.sh .config ../secrets.cfg

# give the chance to interrupt for manual build
echo "Proceed to build in 5 seconds ..."
sleep 5

# let's go
make

# copy built image
rev=$(printf 'r%s-g%s\n' "$(git rev-list --count HEAD)" "$(git describe --always --abbrev=7 --match '^$')")
now=$(date +%FT%T%Z --utc)
cp -i output/images/sdcard.img ../"sdcard-$br-$rev-$now.img"
