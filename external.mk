# Write the generated image to SD card in my UGREEN reader.
write-sdcard:
	sudo dd if=$(BINARIES_DIR)/sdcard.img of=/dev/disk/by-id/usb-Generic_MassStorageClass_000000001538-0:1 bs=256K status=progress
	sync


# Run the generated image in a virtual machine with QEMU.
# https://gitlab.com/qemu-project/qemu/-/issues/448#note_726580305
emulate:
	@echo "Truncating sdcard image to next-largest power-of-two."
	stat -c %s $(BINARIES_DIR)/sdcard.img \
	| awk 'function ceil(v) { return (v == int(v)) ?v :int(v)+1 } { print 2**ceil(log($$1)/log(2)) }' \
	| xargs -I{} truncate -s {} $(BINARIES_DIR)/sdcard.img
	@echo "***Press Ctrl-A X to exit the console!***"
	qemu-system-arm -M raspi0 -nographic \
		-kernel $(BINARIES_DIR)/zImage \
		-dtb $(BINARIES_DIR)/bcm2708-rpi-zero-w.dtb \
		-drive file=$(BINARIES_DIR)/sdcard.img,format=raw,if=sd \
		-append "earlyprintk earlycon=pl011,0x20201000 initcall_blacklist=bcm2835_pm_driver_init $(file < $(BINARIES_DIR)/rpi-firmware/cmdline.txt)"
