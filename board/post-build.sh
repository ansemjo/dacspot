#!/usr/bin/env bash
# modified from buildroot-2023.02/board/raspberrypi/post-build.sh

set -eu

# load buildroot config (without makefile variable syntax values)
source <(grep -v '\$\(.\+\)' "${BR2_CONFIG}")


# add inittab entries
inittab="${TARGET_DIR}/etc/inittab"
if [[ -e ${inittab} ]]; then

  # add a console on tty1
  grep -qE '^tty1::' "${inittab}" || \
  sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' "${inittab}"

  # load the kernel module for wifi
  if [[ ${BR2_PACKAGE_BRCMFMAC_SDIO_FIRMWARE_RPI} == y ]]; then
  grep -qE 'modprobe brcmfmac$' "${inittab}" || \
  sed -i '/# now run any rc scripts/i\
::sysinit:/sbin/modprobe brcmfmac' "${inittab}"
  fi

fi


# write wpa_supplicant.conf and network/interfaces files
if [[ ${DACSPOT_USE_WIRELESS} == y ]]; then
  # /etc/wpa_supplicant.conf
  mkdir -p "${TARGET_DIR}/etc"
  cat >"${TARGET_DIR}/etc/wpa_supplicant.conf" <<EOF
country=${DACSPOT_USE_WIRELESS_COUNTRY}
update_config=1
ap_scan=1

network={
    ssid="${DACSPOT_USE_WIRELESS_SSID}"
    psk="${DACSPOT_USE_WIRELESS_PSK}"
}
EOF
  chmod 600 "${TARGET_DIR}/etc/wpa_supplicant.conf"
  # /etc/network/interfaces
  mkdir -p "${TARGET_DIR}/etc/network"
  cat >"${TARGET_DIR}/etc/network/interfaces" <<EOF
auto lo
iface lo inet loopback

auto wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant.conf
EOF
fi


# write an ntpd config
if [[ ${DACSPOT_USE_NTP} ]]; then
  # /etc/default/ntpd
  mkdir -p "${TARGET_DIR}/etc/default"
  cat >"${TARGET_DIR}/etc/default/ntpd" <<EOF
NTPDATE=yes
NTPSERVERS=${DACSPOT_USE_NTP_SERVERS}
EOF
fi
