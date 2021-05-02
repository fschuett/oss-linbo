# group specific grub.cfg template for linbo net boot, should work with linux and windows operating systems
# thomas@linuxmuster.net
# 20201126
#

# start "@@osname@@" directly
menuentry '@@osname@@ (Start)' --class @@ostype@@_start {

 set oslabel="@@oslabel@@"
 if [ -n "$oslabel" ]; then
  search --label "$oslabel" --set osroot
 fi
 if [ -n "$osroot" ]; then
  set root="$osroot"
 else
  set root="@@osroot@@"
 fi
 set win_efiloader="/EFI/Microsoft/Boot/bootmgfw.efi"

 terminal_output console
 if [ -e /boot/vmlinuz -a -e /boot/initrd.img ]; then
  linux /boot/vmlinuz @@append@@
  initrd /boot/initrd.img
 elif [ -e /vmlinuz -a -e /initrd.img ]; then
  linux /vmlinuz @@append@@
  initrd /initrd.img
 elif [ -e /boot/vmlinuz -a -e /boot/initrd ]; then
  linux /boot/vmlinuz @@append@@
  initrd /boot/initrd
 elif [ -e /vmlinuz -a -e /initrd ]; then
  linux /vmlinuz @@append@@
  initrd /initrd
 elif [ -e /@@kernel@@ -a -e /@@initrd@@ ]; then
  linux /@@kernel@@ @@append@@
  initrd /@@initrd@@
 elif [ -e /@@kernel@@ ]; then
  linux /@@kernel@@ @@append@@
 elif [ -s /boot/grub/grub.cfg ] ; then
  configfile /boot/grub/grub.cfg
 elif [ "$grub_platform" = "pc" ]; then
  if [ -s /bootmgr ] ; then
   ntldr /bootmgr
  elif [ -s /ntldr ] ; then
   ntldr /ntldr
  elif [ -s /grldr ] ; then
   ntldr /grldr
  else
   chainloader +1
  fi
 elif [ -e "$win_efiloader" ]; then
  chainloader $win_efiloader
  boot
 fi
 terminal_output gfxterm

}

# boot LINBO and start "@@osname@@"
menuentry '@@osname@@ (Linbo-Start)' --class @@ostype@@_start {

 if [ -e "$linbo_kernel" -a -e "$linbo_initrd" ]; then
  set bootflag=localboot
 elif [ -n "$pxe_default_server" ]; then
  set root="(tftp)"
  set bootflag=netboot
 fi

 if [ -n "$bootflag" ]; then
  echo LINBO $bootflag for group @@group@@
  echo
  echo -n "Loading $linbo_kernel ..."
  linux $linbo_kernel @@kopts@@ linbocmd=start:@@osnr@@ $bootflag
  echo
  echo -n "Loading $linbo_initrd ..."
  initrd $linbo_initrd
  boot
 fi

}

# boot LINBO, sync and start "@@osname@@"
menuentry '@@osname@@ (Sync+Start)' --class @@ostype@@_syncstart {

 if [ -e "$linbo_kernel" -a -e "$linbo_initrd" ]; then
  set bootflag=localboot
 elif [ -n "$pxe_default_server" ]; then
  set root="(tftp)"
  set bootflag=netboot
 fi

 if [ -n "$bootflag" ]; then
  echo LINBO $bootflag for group @@group@@
  echo
  echo -n "Loading $linbo_kernel ..."
  linux $linbo_kernel @@kopts@@ linbocmd=sync:@@osnr@@,start:@@osnr@@ $bootflag
  echo
  echo -n "Loading $linbo_initrd ..."
  initrd $linbo_initrd
  boot
 fi

}

# boot LINBO, format os partition, sync and start "@@osname@@"
menuentry '@@osname@@ (Neu+Start)' --class @@ostype@@_newstart {

 if [ -e "$linbo_kernel" -a -e "$linbo_initrd" ]; then
  set bootflag=localboot
 elif [ -n "$pxe_default_server" ]; then
  set root="(tftp)"
  set bootflag=netboot
 fi

 if [ -n "$bootflag" ]; then
  echo LINBO $bootflag for group @@group@@
  echo
  echo -n "Loading $linbo_kernel ..."
  linux $linbo_kernel @@kopts@@ linbocmd=format:@@partnr@@,sync:@@osnr@@,start:@@osnr@@ $bootflag
  echo
  echo -n "Loading $linbo_initrd ..."
  initrd $linbo_initrd
  boot
 fi

}
