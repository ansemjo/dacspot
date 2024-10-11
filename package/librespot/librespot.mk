################################################################################
#
# librespot
#
################################################################################

LIBRESPOT_LICENSE = MIT
LIBRESPOT_VERSION = $(call qstrip,$(or $(BR2_PACKAGE_LIBRESPOT_VERSION),03b547d3b3b434811225ebc153c651e5f1917b95))
LIBRESPOT_SITE = $(call github,librespot-org,librespot,$(LIBRESPOT_VERSION))
LIBRESPOT_CARGO_BUILD_OPTS = $(call qstrip,$(BR2_PACKAGE_LIBRESPOT_BUILD_OPTS))
LIBRESPOT_DEPENDENCIES += host-rust-bindgen

define LIBRESPOT_INSTALL_INIT_SYSV

	# install service file
	$(INSTALL) -D -m 0755 $(LIBRESPOT_PKGDIR)S70librespot $(TARGET_DIR)/etc/init.d/

	# create configuration file
	mkdir -p $(TARGET_DIR)/etc/default/
	echo "# librespot configuration" > $(TARGET_DIR)/etc/default/librespot
	echo "export LIBRESPOT_NAME=\"$(BR2_PACKAGE_LIBRESPOT_CONF_NAME)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "export LIBRESPOT_DEVICE_TYPE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_DEVICE_TYPE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "export LIBRESPOT_SYSTEM_CACHE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_SYSTEM_CACHE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "export LIBRESPOT_CACHE=\"/tmp/librespot\"" >> $(TARGET_DIR)/etc/default/librespot
	if [[ x$(BR2_PACKAGE_LIBRESPOT_CONF_DISABLE_DISCOVERY) == xy ]]; then \
		echo "export LIBRESPOT_DISABLE_DISCOVERY=\"on\"" >> $(TARGET_DIR)/etc/default/librespot; \
	fi
	if [[ x$(BR2_PACKAGE_LIBRESPOT_CONF_AUTOPLAY) == xy ]]; then \
		echo "export LIBRESPOT_AUTOPLAY=\"on\"" >> $(TARGET_DIR)/etc/default/librespot; \
	fi
	echo "export LIBRESPOT_VOLUME_CTRL=\"$(BR2_PACKAGE_LIBRESPOT_CONF_VOLUME_CTRL)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "export LIBRESPOT_BITRATE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_BITRATE)\"" >> $(TARGET_DIR)/etc/default/librespot

endef

$(eval $(cargo-package))
