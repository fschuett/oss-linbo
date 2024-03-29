################################################################################
#
# bvi
#
################################################################################

BVI_VERSION = 1.4.0
BVI_SOURCE = bvi-$(BVI_VERSION).src.tar.gz
BVI_SITE = https://sourceforge.net/projects/bvi/files/bvi/$(BVI_VERSION)
BVI_LICENSE = GPLv2
BVI_LICENSE_FILES = COPYING
BVI_DEPENDENCIES = ncurses

define BVI_CLEANUP
	rm -rfv $(TARGET_DIR)/usr/share/bvi/
endef
BVI_POST_INSTALL_TARGET_HOOKS += BVI_CLEANUP

$(eval $(autotools-package))
