################################################################################
#
# librespot
#
################################################################################

LIBRESPOT_LICENSE = MIT
LIBRESPOT_VERSION = $(call qstrip,$(or $(BR2_PACKAGE_LIBRESPOT_VERSION),03b547d3b3b434811225ebc153c651e5f1917b95))
LIBRESPOT_SITE = $(call github,librespot-org,librespot,$(LIBRESPOT_VERSION))
LIBRESPOT_CARGO_BUILD_OPTS = $(call qstrip,$(BR2_PACKAGE_LIBRESPOT_BUILD_OPTS))

define LIBRESPOT_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(LIBRESPOT_PKGDIR)S70librespot $(TARGET_DIR)/etc/init.d/
endef

$(eval $(cargo-package))
