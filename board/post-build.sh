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
tty1::respawn:/sbin/getty    -L      tty1 0 vt100 # HDMI console' "${inittab}"

  # load the kernel module for wifi
  if [[ ${BR2_PACKAGE_BRCMFMAC_SDIO_FIRMWARE_RPI:-n} == y ]]; then
  grep -qE 'modprobe brcmfmac$' "${inittab}" || \
  sed -i '/# now run any rc scripts/i\
::sysinit:/sbin/modprobe brcmfmac' "${inittab}"
  fi

  # load the kernel modules for hifiberry dac sound device
  if [[ ${DACSPOT_USE_HIFIBERRY_DAC:-n} == y ]]; then
  grep -qE 'modprobe .* snd_soc_pcm5102a' "${inittab}" || \
  sed -i '/# now run any rc scripts/i\
::sysinit:/sbin/modprobe -a snd_soc_bcm2835_i2s snd_soc_pcm5102a snd_soc_rpi_simple_soundcard' "${inittab}"
  fi

  # load the kernel modules and start a getty for serial on usb otg port
  if [[ ${DACSPOT_USE_USB_GSERIAL:-n} == y ]]; then
  grep -qE 'modprobe .* dwc2' "${inittab}" || \
  sed -i '/# now run any rc scripts/i\
::sysinit:/sbin/modprobe -a dwc2 g_serial' "${inittab}"
  grep -qE '^ttyGS0::' "${inittab}" || \
  sed -i '/GENERIC_SERIAL/a\
ttyGS0::respawn:/sbin/getty  -L   ttyGS0 0 vt100 # USB gadget' "${inittab}"
  fi

fi


# write wpa_supplicant.conf and network/interfaces files
if [[ ${DACSPOT_USE_WIRELESS:-n} == y ]]; then
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
if [[ ${DACSPOT_USE_NTP:-n} == y ]]; then
  # /etc/default/ntpd
  mkdir -p "${TARGET_DIR}/etc/default"
  cat >"${TARGET_DIR}/etc/default/ntpd" <<EOF
NTPDATE=yes
NTPSERVERS=${DACSPOT_USE_NTP_SERVERS}
EOF
fi


# write authorized ssh key and generate host identity
if [[ -n ${DACSPOT_SSH_AUTHORIZED_KEY} ]]; then
  # /root/.ssh/authorized_keys
  mkdir -p "${TARGET_DIR}/root/.ssh/"
  echo -e "${DACSPOT_SSH_AUTHORIZED_KEY}" >"${TARGET_DIR}/root/.ssh/authorized_keys"
  chmod 700 "${TARGET_DIR}/root/.ssh/"
  chmod 644 "${TARGET_DIR}/root/.ssh/authorized_keys"
fi

# generate a host identity, if none exists
if [[ ${DACSPOT_SSH_GENERATE_ED25519_HOSTKEY:-n} == y ]]; then
  # /etc/ssh/ssh_host_ed25519_key
  if [[ -f "${TARGET_DIR}/etc/ssh/ssh_host_ed25519_key" ]]; then
    echo "key exists, skipping hostkey generation" >&2
  else
    ssh-keygen -t ed25519 -C "${BR2_TARGET_GENERIC_HOSTNAME}" -N '' \
      -f "${TARGET_DIR}/etc/ssh/ssh_host_ed25519_key";
  fi
  chmod 600 "${TARGET_DIR}/etc/ssh/ssh_host_ed25519_key";
fi


# add an entry for /boot in fstab
fstab="${TARGET_DIR}/etc/fstab"
if [[ ${DACSPOT_MOUNT_BOOT:-n} == y ]]; then
  mkdir -p "${TARGET_DIR}/boot"
  ro=$([[ ${DACSPOT_MOUNT_BOOT_RO:-n} == y ]] && echo ",ro")
  grep -qE '^/dev/mmcblk0p1' "${fstab}" || \
  echo "/dev/mmcblk0p1 /boot vfat defaults$ro 0 2" >> "$fstab"
fi
