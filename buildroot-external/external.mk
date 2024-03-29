include $(sort $(wildcard $(BR2_EXTERNAL_LINBO_PATH)/package/*/*.mk))

# ntfs-3g: activate acls, use ntfs-3g with mount command
NTFS_3G_CONF_OPTS += --enable-posix-acls --enable-xattr-mappings --enable-extras
define NTFS_3G_MOUNT_USE_NTFS_3G
	( cd $(TARGET_DIR)/usr/sbin; ln -sf ../bin/ntfs-3g mount.ntfs )
endef
NTFS_3G_POST_INSTALL_TARGET_HOOKS += NTFS_3G_MOUNT_USE_NTFS_3G

# xkbcommon: activate german keyboard as default
LIBXKBCOMMON_CONF_OPTS += -Ddefault-layout=de -Ddefault-variant=nodeadkeys

# busybox config: redefine FIXUP_CMDS - add ntpd, use ash instead of bash
define BUSYBOX_EXTERNAL_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_NTPD,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_NTPD_CONF,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_BASH_IS_ASH,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_DISABLE_OPT,CONFIG_BASH_IS_NONE,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_VOLUMEID_BTRFS,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_VOLUMEID_LINUXSWAP,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_VOLUMEID_REISERFS,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_VOLUMEID_SQUASHFS,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_VOLUMEID_NTFS,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_VOLUMEID_XFS,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_MKSWAP_UUID,$(BUSYBOX_BUILD_CONFIG))
endef

BUSYBOX_KCONFIG_FIXUP_CMDS += $(call BUSYBOX_EXTERNAL_FIXUPS)

# ath10k-qca9377 firmware for ipad 1S AMD9
LINUX_FIRMWARE_FILES += ath10k/QCA9377/hw1.0/firmware-5.bin \
			ath10k/QCA9377/hw1.0/board-2.bin \
			ath10k/QCA9377/hw1.0/firmware-6.bin \
			ath10k/QCA9377/hw1.0/board.bin
LINUX_FIRMWARE_ALL_LICENSE_FILES += LICENCE.atheros_firmware

# realtek rtw88_8822ce firmware for ipad 1S AMD6
LINUX_FIRMWARE_FILES += rtw88/rtw8822c_fw.bin \
			rtw88/rtw8822c_wow_fw.bin
LINUX_FIRMWARE_ALL_LICENSE_FILES += LICENCE.rtlwifi_firmware.txt
