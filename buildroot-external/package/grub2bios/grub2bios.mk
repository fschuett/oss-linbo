################################################################################
#
# grub2bios
#
################################################################################

GRUB2BIOS_VERSION = 2.02
GRUB2BIOS_SOURCE = grub-$(GRUB2BIOS_VERSION).tar.gz
GRUB2BIOS_SITE = ftp://ftp.gnu.org/gnu/grub
GRUB2BIOS_LICENSE = GPLv3
GRUB2BIOS_LICENSE_FILES = COPYING

GRUB2BIOS_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
GRUB2BIOS_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --disable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=pc --target=i386
GRUB2BIOS_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

define GRUB2BIOS_CLEANUP
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/*.image
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/*.module
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/kernel.exec
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/gdb_grub
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/gmodule.pl
	rm -fv $(TARGET_DIR)/etc/bash_completion.d/grub
	rmdir -v $(TARGET_DIR)/etc/bash_completion.d/
endef
GRUB2BIOS_POST_INSTALL_TARGET_HOOKS += GRUB2BIOS_CLEANUP

ifeq ($(BR2_x86_64),y)
GRUB2BIOS_CHECK_BIN_ARCH_EXCLUSIONS = \
/usr/lib/grub/i386-pc/acpi.mod \
/usr/lib/grub/i386-pc/pxeboot.img \
/usr/lib/grub/i386-pc/tar.mod \
/usr/lib/grub/i386-pc/partmap.lst \
/usr/lib/grub/i386-pc/minix3.mod \
/usr/lib/grub/i386-pc/test.mod \
/usr/lib/grub/i386-pc/freedos.mod \
/usr/lib/grub/i386-pc/xnu_uuid.mod \
/usr/lib/grub/i386-pc/zfscrypt.mod \
/usr/lib/grub/i386-pc/part_msdos.mod \
/usr/lib/grub/i386-pc/trig.mod \
/usr/lib/grub/i386-pc/tr.mod \
/usr/lib/grub/i386-pc/cdboot.img \
/usr/lib/grub/i386-pc/gcry_dsa.mod \
/usr/lib/grub/i386-pc/bfs.mod \
/usr/lib/grub/i386-pc/mdraid09_be.mod \
/usr/lib/grub/i386-pc/gptsync.mod \
/usr/lib/grub/i386-pc/loopback.mod \
/usr/lib/grub/i386-pc/ext2.mod \
/usr/lib/grub/i386-pc/test_blockarg.mod \
/usr/lib/grub/i386-pc/keylayouts.mod \
/usr/lib/grub/i386-pc/gfxterm_background.mod \
/usr/lib/grub/i386-pc/gcry_rmd160.mod \
/usr/lib/grub/i386-pc/font.mod \
/usr/lib/grub/i386-pc/gcry_sha256.mod \
/usr/lib/grub/i386-pc/mda_text.mod \
/usr/lib/grub/i386-pc/reiserfs.mod \
/usr/lib/grub/i386-pc/cmdline_cat_test.mod \
/usr/lib/grub/i386-pc/syslinuxcfg.mod \
/usr/lib/grub/i386-pc/affs.mod \
/usr/lib/grub/i386-pc/verify.mod \
/usr/lib/grub/i386-pc/raid5rec.mod \
/usr/lib/grub/i386-pc/gdb.mod \
/usr/lib/grub/i386-pc/halt.mod \
/usr/lib/grub/i386-pc/png.mod \
/usr/lib/grub/i386-pc/exfctest.mod \
/usr/lib/grub/i386-pc/bswap_test.mod \
/usr/lib/grub/i386-pc/boot.mod \
/usr/lib/grub/i386-pc/minix2.mod \
/usr/lib/grub/i386-pc/linux.mod \
/usr/lib/grub/i386-pc/vbe.mod \
/usr/lib/grub/i386-pc/div_test.mod \
/usr/lib/grub/i386-pc/ohci.mod \
/usr/lib/grub/i386-pc/mdraid1x.mod \
/usr/lib/grub/i386-pc/hfsplus.mod \
/usr/lib/grub/i386-pc/crypto.mod \
/usr/lib/grub/i386-pc/gcry_blowfish.mod \
/usr/lib/grub/i386-pc/ntldr.mod \
/usr/lib/grub/i386-pc/search_fs_uuid.mod \
/usr/lib/grub/i386-pc/truecrypt.mod \
/usr/lib/grub/i386-pc/cmostest.mod \
/usr/lib/grub/i386-pc/tga.mod \
/usr/lib/grub/i386-pc/part_dfly.mod \
/usr/lib/grub/i386-pc/bsd.mod \
/usr/lib/grub/i386-pc/gcry_sha1.mod \
/usr/lib/grub/i386-pc/gfxterm.mod \
/usr/lib/grub/i386-pc/gfxmenu.mod \
/usr/lib/grub/i386-pc/net.mod \
/usr/lib/grub/i386-pc/aout.mod \
/usr/lib/grub/i386-pc/videotest.mod \
/usr/lib/grub/i386-pc/squash4.mod \
/usr/lib/grub/i386-pc/echo.mod \
/usr/lib/grub/i386-pc/part_bsd.mod \
/usr/lib/grub/i386-pc/cpio_be.mod \
/usr/lib/grub/i386-pc/gcry_camellia.mod \
/usr/lib/grub/i386-pc/usb_keyboard.mod \
/usr/lib/grub/i386-pc/setjmp.mod \
/usr/lib/grub/i386-pc/usbserial_pl2303.mod \
/usr/lib/grub/i386-pc/cbfs.mod \
/usr/lib/grub/i386-pc/keystatus.mod \
/usr/lib/grub/i386-pc/pata.mod \
/usr/lib/grub/i386-pc/reboot.mod \
/usr/lib/grub/i386-pc/eval.mod \
/usr/lib/grub/i386-pc/plan9.mod \
/usr/lib/grub/i386-pc/linux16.mod \
/usr/lib/grub/i386-pc/memdisk.mod \
/usr/lib/grub/i386-pc/gcry_crc.mod \
/usr/lib/grub/i386-pc/chain.mod \
/usr/lib/grub/i386-pc/bufio.mod \
/usr/lib/grub/i386-pc/minix3_be.mod \
/usr/lib/grub/i386-pc/lsmmap.mod \
/usr/lib/grub/i386-pc/xnu.mod \
/usr/lib/grub/i386-pc/luks.mod \
/usr/lib/grub/i386-pc/cryptodisk.mod \
/usr/lib/grub/i386-pc/gcry_rfc2268.mod \
/usr/lib/grub/i386-pc/zfsinfo.mod \
/usr/lib/grub/i386-pc/memrw.mod \
/usr/lib/grub/i386-pc/msdospart.mod \
/usr/lib/grub/i386-pc/uhci.mod \
/usr/lib/grub/i386-pc/archelp.mod \
/usr/lib/grub/i386-pc/legacy_password_test.mod \
/usr/lib/grub/i386-pc/terminal.mod \
/usr/lib/grub/i386-pc/hello.mod \
/usr/lib/grub/i386-pc/ntfs.mod \
/usr/lib/grub/i386-pc/hfs.mod \
/usr/lib/grub/i386-pc/pbkdf2.mod \
/usr/lib/grub/i386-pc/ahci.mod \
/usr/lib/grub/i386-pc/gcry_sha512.mod \
/usr/lib/grub/i386-pc/sfs.mod \
/usr/lib/grub/i386-pc/procfs.mod \
/usr/lib/grub/i386-pc/video_bochs.mod \
/usr/lib/grub/i386-pc/play.mod \
/usr/lib/grub/i386-pc/hdparm.mod \
/usr/lib/grub/i386-pc/offsetio.mod \
/usr/lib/grub/i386-pc/password_pbkdf2.mod \
/usr/lib/grub/i386-pc/morse.mod \
/usr/lib/grub/i386-pc/fat.mod \
/usr/lib/grub/i386-pc/usb.mod \
/usr/lib/grub/i386-pc/lvm.mod \
/usr/lib/grub/i386-pc/normal.mod \
/usr/lib/grub/i386-pc/gcry_twofish.mod \
/usr/lib/grub/i386-pc/cs5536.mod \
/usr/lib/grub/i386-pc/read.mod \
/usr/lib/grub/i386-pc/biosdisk.mod \
/usr/lib/grub/i386-pc/romfs.mod \
/usr/lib/grub/i386-pc/xfs.mod \
/usr/lib/grub/i386-pc/search.mod \
/usr/lib/grub/i386-pc/true.mod \
/usr/lib/grub/i386-pc/adler32.mod \
/usr/lib/grub/i386-pc/fshelp.mod \
/usr/lib/grub/i386-pc/videotest_checksum.mod \
/usr/lib/grub/i386-pc/lsacpi.mod \
/usr/lib/grub/i386-pc/macbless.mod \
/usr/lib/grub/i386-pc/hfspluscomp.mod \
/usr/lib/grub/i386-pc/odc.mod \
/usr/lib/grub/i386-pc/vga.mod \
/usr/lib/grub/i386-pc/backtrace.mod \
/usr/lib/grub/i386-pc/mdraid09.mod \
/usr/lib/grub/i386-pc/search_fs_file.mod \
/usr/lib/grub/i386-pc/gcry_idea.mod \
/usr/lib/grub/i386-pc/help.mod \
/usr/lib/grub/i386-pc/datehook.mod \
/usr/lib/grub/i386-pc/dm_nv.mod \
/usr/lib/grub/i386-pc/newc.mod \
/usr/lib/grub/i386-pc/mpi.mod \
/usr/lib/grub/i386-pc/cmosdump.mod \
/usr/lib/grub/i386-pc/pcidump.mod \
/usr/lib/grub/i386-pc/scsi.mod \
/usr/lib/grub/i386-pc/elf.mod \
/usr/lib/grub/i386-pc/nativedisk.mod \
/usr/lib/grub/i386-pc/terminfo.mod \
/usr/lib/grub/i386-pc/multiboot.mod \
/usr/lib/grub/i386-pc/ctz_test.mod \
/usr/lib/grub/i386-pc/part_plan.mod \
/usr/lib/grub/i386-pc/bitmap_scale.mod \
/usr/lib/grub/i386-pc/ufs1.mod \
/usr/lib/grub/i386-pc/part_dvh.mod \
/usr/lib/grub/i386-pc/gcry_md5.mod \
/usr/lib/grub/i386-pc/configfile.mod \
/usr/lib/grub/i386-pc/zfs.mod \
/usr/lib/grub/i386-pc/spkmodem.mod \
/usr/lib/grub/i386-pc/pxechain.mod \
/usr/lib/grub/i386-pc/usbtest.mod \
/usr/lib/grub/i386-pc/ufs2.mod \
/usr/lib/grub/i386-pc/macho.mod \
/usr/lib/grub/i386-pc/gcry_whirlpool.mod \
/usr/lib/grub/i386-pc/minix.mod \
/usr/lib/grub/i386-pc/part_acorn.mod \
/usr/lib/grub/i386-pc/jpeg.mod \
/usr/lib/grub/i386-pc/signature_test.mod \
/usr/lib/grub/i386-pc/minix2_be.mod \
/usr/lib/grub/i386-pc/vga_text.mod \
/usr/lib/grub/i386-pc/at_keyboard.mod \
/usr/lib/grub/i386-pc/parttool.mod \
/usr/lib/grub/i386-pc/gcry_md4.mod \
/usr/lib/grub/i386-pc/videoinfo.mod \
/usr/lib/grub/i386-pc/video_fb.mod \
/usr/lib/grub/i386-pc/cmp_test.mod \
/usr/lib/grub/i386-pc/priority_queue.mod \
/usr/lib/grub/i386-pc/kernel.img \
/usr/lib/grub/i386-pc/testload.mod \
/usr/lib/grub/i386-pc/hexdump.mod \
/usr/lib/grub/i386-pc/pbkdf2_test.mod \
/usr/lib/grub/i386-pc/part_sunpc.mod \
/usr/lib/grub/i386-pc/iorw.mod \
/usr/lib/grub/i386-pc/pci.mod \
/usr/lib/grub/i386-pc/cat.mod \
/usr/lib/grub/i386-pc/sleep_test.mod \
/usr/lib/grub/i386-pc/pxe.mod \
/usr/lib/grub/i386-pc/gzio.mod \
/usr/lib/grub/i386-pc/all_video.mod \
/usr/lib/grub/i386-pc/lsapm.mod \
/usr/lib/grub/i386-pc/serial.mod \
/usr/lib/grub/i386-pc/lzopio.mod \
/usr/lib/grub/i386-pc/date.mod \
/usr/lib/grub/i386-pc/regexp.mod \
/usr/lib/grub/i386-pc/diskfilter.mod \
/usr/lib/grub/i386-pc/usbserial_usbdebug.mod \
/usr/lib/grub/i386-pc/ufs1_be.mod \
/usr/lib/grub/i386-pc/ntfscomp.mod \
/usr/lib/grub/i386-pc/mul_test.mod \
/usr/lib/grub/i386-pc/testspeed.mod \
/usr/lib/grub/i386-pc/relocator.mod \
/usr/lib/grub/i386-pc/progress.mod \
/usr/lib/grub/i386-pc/xzio.mod \
/usr/lib/grub/i386-pc/multiboot2.mod \
/usr/lib/grub/i386-pc/ls.mod \
/usr/lib/grub/i386-pc/part_sun.mod \
/usr/lib/grub/i386-pc/gcry_serpent.mod \
/usr/lib/grub/i386-pc/time.mod \
/usr/lib/grub/i386-pc/setpci.mod \
/usr/lib/grub/i386-pc/raid6rec.mod \
/usr/lib/grub/i386-pc/mmap.mod \
/usr/lib/grub/i386-pc/sendkey.mod \
/usr/lib/grub/i386-pc/video.mod \
/usr/lib/grub/i386-pc/ata.mod \
/usr/lib/grub/i386-pc/cmp.mod \
/usr/lib/grub/i386-pc/gcry_seed.mod \
/usr/lib/grub/i386-pc/minix_be.mod \
/usr/lib/grub/i386-pc/legacycfg.mod \
/usr/lib/grub/i386-pc/exfat.mod \
/usr/lib/grub/i386-pc/btrfs.mod \
/usr/lib/grub/i386-pc/gcry_des.mod \
/usr/lib/grub/i386-pc/div.mod \
/usr/lib/grub/i386-pc/cpuid.mod \
/usr/lib/grub/i386-pc/gcry_tiger.mod \
/usr/lib/grub/i386-pc/gcry_rijndael.mod \
/usr/lib/grub/i386-pc/password.mod \
/usr/lib/grub/i386-pc/crc64.mod \
/usr/lib/grub/i386-pc/lspci.mod \
/usr/lib/grub/i386-pc/xnu_uuid_test.mod \
/usr/lib/grub/i386-pc/setjmp_test.mod \
/usr/lib/grub/i386-pc/datetime.mod \
/usr/lib/grub/i386-pc/http.mod \
/usr/lib/grub/i386-pc/part_apple.mod \
/usr/lib/grub/i386-pc/gcry_arcfour.mod \
/usr/lib/grub/i386-pc/hashsum.mod \
/usr/lib/grub/i386-pc/gfxterm_menu.mod \
/usr/lib/grub/i386-pc/video_cirrus.mod \
/usr/lib/grub/i386-pc/ldm.mod \
/usr/lib/grub/i386-pc/cbtime.mod \
/usr/lib/grub/i386-pc/minicmd.mod \
/usr/lib/grub/i386-pc/extcmd.mod \
/usr/lib/grub/i386-pc/bitmap.mod \
/usr/lib/grub/i386-pc/ehci.mod \
/usr/lib/grub/i386-pc/cpio.mod \
/usr/lib/grub/i386-pc/usbserial_common.mod \
/usr/lib/grub/i386-pc/gcry_rsa.mod \
/usr/lib/grub/i386-pc/probe.mod \
/usr/lib/grub/i386-pc/gcry_cast5.mod \
/usr/lib/grub/i386-pc/part_amiga.mod \
/usr/lib/grub/i386-pc/geli.mod \
/usr/lib/grub/i386-pc/udf.mod \
/usr/lib/grub/i386-pc/iso9660.mod \
/usr/lib/grub/i386-pc/cbmemc.mod \
/usr/lib/grub/i386-pc/cbtable.mod \
/usr/lib/grub/i386-pc/functional_test.mod \
/usr/lib/grub/i386-pc/tftp.mod \
/usr/lib/grub/i386-pc/gettext.mod \
/usr/lib/grub/i386-pc/video_colors.mod \
/usr/lib/grub/i386-pc/usbms.mod \
/usr/lib/grub/i386-pc/loadenv.mod \
/usr/lib/grub/i386-pc/disk.mod \
/usr/lib/grub/i386-pc/cbls.mod \
/usr/lib/grub/i386-pc/drivemap.mod \
/usr/lib/grub/i386-pc/random.mod \
/usr/lib/grub/i386-pc/efiemu.mod \
/usr/lib/grub/i386-pc/jfs.mod \
/usr/lib/grub/i386-pc/shift_test.mod \
/usr/lib/grub/i386-pc/file.mod \
/usr/lib/grub/i386-pc/blocklist.mod \
/usr/lib/grub/i386-pc/usbserial_ftdi.mod \
/usr/lib/grub/i386-pc/afs.mod \
/usr/lib/grub/i386-pc/sleep.mod \
/usr/lib/grub/i386-pc/search_label.mod \
/usr/lib/grub/i386-pc/part_gpt.mod \
/usr/lib/grub/i386-pc/nilfs2.mod
endif

$(eval $(autotools-package))
