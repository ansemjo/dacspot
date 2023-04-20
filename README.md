# DACspot Buildroot customization

This README explains the steps I need to take to customize a `raspberrypi0w_defconfig` to my needs with WiFi and a SquashFS rootfs etc. for a Zero W with a HiFiBerry DAC backpack.

### 1. Download

Get a recent Buildroot release and extract it to a subdirectory (or clone the git repository). At the time of this writing, the latest release was `buildroot-2023.02` and was used for this README.

```
curl --remote-name-all https://buildroot.org/downloads/buildroot-2023.02.tar.xz{,.sign}
gpg --verify buildroot-2023.02.tar.xz.sign
sed -n 's/^SHA256: //p' *.sign | sha256sum -c
tar xf buildroot-2023.02.tar.xz
cd buildroot-2023.02/
```

### 2. Apply defconfig configuration fragments

I don't want to track the entire `.config` file because I only made a few changes. So instead I used a support script to merge the in-tree `raspberrypi0w_defconfig` with my configuration fragment:

```
support/kconfig/merge_config.sh configs/raspberrypi0w_defconfig ../fragments-buildroot
```

This should create a merged `.config`, resolve any dependencies and default values and print conflicts if any defaults change in the future. The configuration fragment assumes that the Linux kernel fragments are also available in the "top" directory as `../fragments-linux` – those are needed to enable in-kernel SquashFS support for booting.

### 3. Configure

Want to add something? Now's the time.

```
make menuconfig
```

### 4. Build the image

When you're happy with the configuration, run the build which generates `output/images/sdcard.img`.

```
make
```

The post-scripts and genimage config have been copied and modified from the in-tree files at `board/raspberrypi/`. If the build fails, you might want to check if they're still up-to-date with assumptions made by Buildroot.

### TODO

* Rewrite as a Buildroot "external" tree.
  * Generate a defconfig with `make savedefconfig`, so it can be applied easier.
  * Use `$BR2_EXTERNAL_DACSPOT_PATH` instead of hardcoded parent directory.
  * Configure SSID and PSK via `menuconfig`, so I don't need to think about secret-tracking.
* Add actual sound support, Bluetooth config and Raspotify.
* Add SSH server, just in case?

### Sources

* [The Buildroot Manual](https://buildroot.org/downloads/manual/manual.html)
* [Note on using `support/kconfig/merge_config.sh`](https://stackoverflow.com/a/72864457)
* [Buildroot Zero W wireless](https://unix.stackexchange.com/a/448501)
* [Sirsipe's Buildroot externals with `rpi-wifi`](https://github.com/sirsipe/buildroot-externals#package-raspberrypi-wifi-rpi-wifi)
* [SnapOS Guide for a Pi Zero W](https://du.nkel.dev/blog/2021-04-10_buildroot-snapos/)
* [RPiconfig reference (`config.txt` options)](https://elinux.org/RPiconfig#Boot)
* [Adjust partitions in `genimage.cfg`](https://stackoverflow.com/questions/60164914/multiple-partitions-in-buildroot)
* [Kernel config fragments](https://stackoverflow.com/a/43915427)
* ... and possibly quite a few more that I forgot to note
