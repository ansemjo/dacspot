################################################################################
#
# librespot
#
################################################################################

LIBRESPOT_VERSION = $(or $(BR2_PACKAGE_LIBRESPOT_VERSION),03b547d3b3b434811225ebc153c651e5f1917b95)
LIBRESPOT_SITE = $(call github,librespot-org,librespot,$(LIBRESPOT_VERSION))
#LIBRESPOT_CARGO_BUILD_OPTS = $(BR2_PACKAGE_LIBRESPOT_BUILD_OPTS) # this passes a quoted string :(
#LIBRESPOT_CARGO_BUILD_OPTS = $(patsubst "%",%,$(BR2_PACKAGE_LIBRESPOT_BUILD_OPTS)) # https://stackoverflow.com/a/10434751
#LIBRESPOT_CARGO_BUILD_OPTS = --no-default-features --features alsa-backend
LIBRESPOT_CARGO_BUILD_OPTS = --features alsa-backend

define LIBRESPOT_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(LIBRESPOT_PKGDIR)S70librespot $(TARGET_DIR)/etc/init.d/
endef

$(eval $(cargo-package))
