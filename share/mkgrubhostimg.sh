#!/bin/sh
#
# creates host specific image for grub network boot
# stored in $LINBODIR/boot/grub/hostcfg/<hostname>.img
#
# thomas@linuxmuster.net
# 20171107
# GPL V3
#

# read linuxmuster environment
. /etc/linbo/linbo.conf
. $ENVDEFAULTS || exit 1
. $HELPERFUNCTIONS || exit 1


## functions

# usage info
usage(){
 echo
 echo "Usage: `basename $0` <options>"
 echo
 echo "Options:"
 echo
 echo " -h             Show this help."
 echo " -s             Set filename option in dhcpd configuration and"
 echo "                workstations file."
 echo " -n <hostname>  Set hostname to process."
 exit 1
}

# set filename in workstations
set_filename_option(){
  # strip linbodir from image filename
  local filename="${IMG/$LINBODIR\//}"
  ## workstations stuff
  # get host's line from workstations
  local old_line="$(grep ^[a-zA-Z0-9-].*\;$HOSTNAME\; $WIMPORTDATA)"
  # get option string from field 8
  local old_opt="$(echo "$old_line" | awk -F\; '{ print $8 }')"
  # create new option string with new filename
  local new_opt='filename "'"$filename"'"'
  # if field 8 was not empty merge new filename option with old ones
  if [ -n "$old_opt" ]; then
    # change separator to ','
    OIFS="$IFS"
    IFS=','
    local i
    for i in $old_opt; do
      # skip old filename option
      echo "$i" | grep -q ^filename && continue
      # dhcp options have to be longer than 5 characters
      [ ${#i} -lt 5 ] && continue
      new_opt="$new_opt,$i"
    done
    IFS="$OIFS"
  fi
  # replace field 8 with new option string
  local new_line="$(echo "$old_line" | sed -e 's|[^;]*|'"$new_opt"'|'8)"
  # escape double quotes
  new_line="$(echo "$new_line" | sed -e 's|\"|\\\\\"|g')"
  # backup workstations file
  backup_file "$WIMPORTDATA"
  local tmpfile="/tmp/$(basename $0).$$"
  cp "$WIMPORTDATA" "$tmpfile" || return 1
  # replace host's line in workstations
  if ! sed -e 's|^[a-zA-Z0-9-].*\;'"$HOSTNAME"'\;.*|'"$new_line"'|' "$tmpfile" > "$WIMPORTDATA"; then
    # restore workstations file if sed fails
    mv "$tmpfile" "$WIMPORTDATA"
    return 1
  fi
  ## dhcp stuff
  # get host parameters
  local ip="$(echo "$new_line" | awk -F \; '{ print $5 }')"
  local mac="$(echo "$new_line" | awk -F \; '{ print $4 }')"
  local group="$(echo "$new_line" | awk -F \; '{ print $3 }')"
  # remove host entry from dhcp configuration
  backup_file "$DHCPDCONF"
  cp "$DHCPDCONF" "$tmpfile" || return 1
  if ! sed -e "/host $ip {/,/}/d" "$tmpfile" > "$DHCPDCONF"; then
    # restore dhcp config if sed fails
    mv "$tmpfile" "$DHCPDCONF"
    return 1
  fi
  # write new dhcp host entry first to tmpfile
  echo "host $ip {" > "$tmpfile"
  echo "  hardware ethernet $mac;" >> "$tmpfile"
  echo "  fixed-address $ip;" >> "$tmpfile"
  echo "  option host-name \"$HOSTNAME\";" >> "$tmpfile"
  echo "  option extensions-path \"$group\";" >> "$tmpfile"
  OIFS="$IFS"
  IFS=','
  local i
  for i in $new_opt; do
    echo "  $i;" >> "$tmpfile"
  done
  IFS="$OIFS"
  echo "}" >> "$tmpfile"
  # write tmpfile into place
  cat "$tmpfile" "$DHCPDCONF" >> "$DHCPDCONF.new" || return 1
  rm -f "$tmpfile"
  cp "$DHCPDCONF" "$DHCPDCONF.bak" || return 1
  if ! mv "$DHCPDCONF.new" "$DHCPDCONF"; then
    mv "$DHCPDCONF.bak" "$DHCPDCONF"
    return 1
  fi
  service isc-dhcp-server stop &> /dev/null
  service isc-dhcp-server start || return 1
}


# process cmdline
while getopts ":hn:s" opt; do
  case $opt in
    s) SETOPT="yes" ;;
    n) HOSTNAME="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2
       usage ;;
  esac
done

# test options
[ -z "$HOSTNAME" ] && usage
get_hostname "$HOSTNAME"
[ -z "$RET" ] && usage

# required modules
# common modules
GRUB_COMMON_MODULES="all_video boot chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm gzio http \
ntfs linux linux16 loadenv minicmd net part_gpt part_msdos png progress read reiserfs search sleep terminal test tftp xfs"

# arch specific netboot modules
GRUB_EFI32_MODULES="$GRUB_COMMON_MODULES efi_gop efi_uga efinet linuxefi"
GRUB_EFI64_MODULES="$GRUB_COMMON_MODULES efi_gop efi_uga efinet linuxefi"
GRUB_I386_MODULES="$GRUB_COMMON_MODULES biosdisk gfxterm_background normal ntldr pxe"

# architectures
I386="i386-pc-pxe"
EFI32="i386-efi"
EFI64="x86_64-efi"

# dirs
SUBDIR="/boot/grub"
GRUBDIR="$LINBODIR$SUBDIR"
IMGDIR="$GRUBDIR/hostcfg"
HOSTCFG="$IMGDIR/$HOSTNAME.cfg"
I386_DIR="$GRUBDIR/${I386/-pxe/}"
EFI32_DIR="$GRUBDIR/$EFI32"
EFI64_DIR="$GRUBDIR/$EFI64"

# host.cfg template
TEMPLATE="$LINBOTPLDIR/host.cfg.pxe"

# fonts
FONTS="unicode"

# tools
MKIMAGE="$LINBOSHAREDIR/grub-mkimage"
MKSTANDALONE="$LINBOSHAREDIR/grub-mkstandalone"

# get host parameters
# ip
get_ip "$HOSTNAME"
IP="$RET"
# mac
get_mac "$HOSTNAME"
MAC="$RET"
# group
GROUP="$(get_group "$HOSTNAME")"
GROUPCFG="$GRUBDIR/$GROUP.cfg"
# systemtype
SYSTEMTYPE="$(grep -i ^systemtype "$LINBODIR/start.conf.$GROUP" | awk -F\= '{ print $2 }' | awk '{ print $1 }' | tr A-Z a-z)"

# define image options
IMG="$IMGDIR/$HOSTNAME.img"
NORMAL=""
case "$SYSTEMTYPE" in
  bios*) DIR="$I386_DIR" ; FORMAT="$I386" ; IFACE="pxe" ; MODULES="$GRUB_I386_MODULES" ; NORMAL="normal" ;;
  efi32) DIR="$EFI32_DIR" ; FORMAT="$EFI32" ; IFACE="efinet0" ; MODULES="$GRUB_EFI32_MODULES" ;;
  efi64) DIR="$EFI64_DIR" ; FORMAT="$EFI64" ; IFACE="efinet0" ; MODULES="$GRUB_EFI64_MODULES" ;;
  *) echo "Cannot get Systemtype of $HOSTNAME!"
     exit 1 ;;
esac

# create config
RC=0
CFG="/var/tmp/$HOSTNAME.cfg.$$"
sed -e "/^#/d
        s|@@normal@@|$NORMAL|
        s|@@serverip@@|$serverip|g
        s|@@iface@@|$IFACE|g
        s|@@hostip@@|$IP|g
        s|@@mac@@|$MAC|g
        s|@@domainname@@|$domainname|g
        s|@@group@@|$GROUP|g
        s|@@hostname@@|$HOSTNAME|g" "$TEMPLATE" > "$CFG" || RC=1
# append host/group specific cfg
if [ -e "$HOSTCFG" ]; then
  APPENDCFG="$HOSTCFG"
else
  APPENDCFG="$GROUPCFG"
fi
cat "$APPENDCFG" >> "$CFG" || RC=1

# create image
if [ "$RC" = "0" ]; then
  if [ "$FORMAT" = "$I386" ]; then
    "$MKIMAGE" -d "$DIR" -O "$FORMAT" -o "$IMG" -c "$CFG" $MODULES || RC=1
  else
    "$MKSTANDALONE" -d "$DIR" -O "$FORMAT" -o "$IMG" --modules="$MODULES" --install-modules="$MODULES" /boot/grub/grub.cfg="$CFG" || RC=1
  fi
fi
rm -f "$CFG"

# set filename in workstations
if [ "$RC" = "0" -a -n "$SETOPT" ]; then
  set_filename_option || RC=1
fi

# final message
if [ "$RC" = "0" ]; then
  echo "Successfully created grub netboot image $IMG."
else
  echo "Failed to create grub netboot image for host $HOSTNAME!"
  rm -f "$IMG"
fi

exit $RC
