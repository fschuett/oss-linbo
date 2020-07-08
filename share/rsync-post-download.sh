#!/bin/bash
#
# Post-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 20200414
#

# read in specific environment
source /etc/linbo/linbo.conf || exit 1
source $ENVDEFAULTS || exit 1
source $HELPERFUNCTIONS || exit 1
[ -n "$LINBODIR" ] || LINBOLOGDIR="/var/log"
[ -n "$LINBOLOGDIR" ] || LINBOLOGDIR="$LINBODIR/log"
LOGFILE="$LINBOLOGDIR/rsync-post-download.log"

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync post download begin: $(date) ###"

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

PIDFILE="/tmp/rsync.$RSYNC_PID"

# Check for pidfile, exit if nothing to do
[ -s "$PIDFILE" ] || exit 0

# read file created by pre-upload script
FILE="$(<$PIDFILE)"
EXT="$(echo $FILE | grep -o '\.[^.]*$')"

# fetch host & domainname
do_rsync_hostname

# handle request for obsolete menu.lst
if stringinstring "menu.lst." "$FILE"; then
 GROUP="${EXT/./}"
 CACHE="$(grep -i ^cache "$LINBODIR/start.conf.$GROUP" | awk -F\= '{ print $2 }' | awk '{ print $1 }' | tail -1)"
 [ -n "$CACHE" ] && EXT="upgrade"
fi

# recognize download request of local grub.cfg
stringinstring ".grub.cfg" "$FILE" && EXT="grub-local"

if [ "$FLAVOUR" = "oss" ]; then
 # recognize download request of start.conf-ip
 [[ ${FILE##$RSYNC_MODULE_PATH/} =~ start\.conf-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] && EXT="start.conf.gruppe"
fi

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "IP: $RSYNC_HOST_ADDR"
echo "RSYNC_REQUEST: $RSYNC_REQUEST"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

case $EXT in

 # remove linbocmd file after download
 *.cmd)
  echo "Removing onboot linbocmd file $FILE."
  rm -f "$FILE"
 ;;

 # remove dummy logfile after download
 *.log)
  echo "Removing dummy logfile $FILE."
  rm -f "$FILE"
 ;;

 # machine password file
 *.mpw)
  if [ -e "$FILE" ]; then
   echo "Removing machine password file $FILE."
   rm -f "$FILE"
  fi
 ;;

 # update host's opsi ini, invoked by linbo_cmd on postsync
 *.opsi)
  # take requested file from pre-download script
  imageini="$FILE"
  # if opsi server is configured and host is opsimanaged
  if ([ -n "$opsiip" -a -s "$imageini" ] && opsimanaged "$compname"); then
   # get host's inifile from opsi server
   clientini_local="$OPSICLIENTDIR/${RSYNC_HOST_NAME}.ini"
   clientini="${opsiip}:$clientini_local"
   origini="/var/tmp/$(basename "$clientini")"
   newini="/var/tmp/$(basename "$clientini").new"
   echo "clientini: $clientini"
   echo "origini: $origini"
   echo "newini: $newini"
   rsync "$clientini" "$origini"
   # if download of inifile was successful
   if [ -s "$origini" ]; then
    echo "$origini successfully downloaded!"
    # get windows keys from file if any
    licensekey="$(grep ^poolid-or-licensekey "$origini" | awk -F\" '{ print $2 }')"
    productkey="$(grep ^productkey "$origini" | awk -F\" '{ print $2 }')"
    # copy header from original ini to new ini
    sed -n '/^\[info\]/,/^\[localboot_product_states\]/p' "$origini" | sed -n '/^\[localboot_product_states\]/!p' > "$newini"
    # take opsi product states from image ini 
    sed -n '/^\[localboot_product_states\]/,$p' "$imageini" >> "$newini"
    # patch license keys
    [ -n "$licensekey" ] && sed -e "s|^poolid-or-licensekey.*|poolid-or-licensekey = \[\"$licensekey\"\]|" -i "$newini"
    [ -n "$productkey" ] && sed -e "s|^productkey.*|productkey = \[\"$productkey\"\]|" -i "$newini"
    # should opsi products be restored after sync?
    restoreopsistate_res="$(restoreopsistate "$compname" "$(basename "$imageini")")"
    forceopsisetup_res="$(forceopsisetup "$compname" "$(basename "$imageini")")"
    # backup current inifile
    [ "$restoreopsistate_res" = "yes" ] && ssh "$opsiip" cp "$clientini_local" "$clientini_local".bak
    # upload the new inifile
    rsync "$newini" "$clientini" ; RC="$?"
    [ "$RC" = "0" ] || echo "Upload of $(basename "$newini") to opsi failed!"
    # restore opsi product status
    if [ "$restoreopsistate_res" = "yes" ]; then
      ssh "$opsiip" /usr/share/linuxmuster-opsi/opsiSetup.py "$RSYNC_HOST_NAME" "$forceopsisetup_res"
    else
      # repair opsi's file permissions
      [ -z "$opsisetrights" ] && ssh "$opsiip" opsi-setup --set-rights "$OPSICLIENTDIR"
    fi
   fi
   rm -f "$origini" "$newini"
  fi
 ;;

 *.opsikey)
  if [ -e "$FILE" ]; then
   echo "Removing opsi key file $FILE."
   rm -f "$FILE"
  fi
 ;;

 *.winkey)
  if [ -e "$FILE" ]; then
   echo "Removing windows product key file $FILE."
   rm -f "$FILE"
  fi
 ;;

 *.gz)
  # repair old linbofs filename
  if [ "$(basename "$FILE")" = "linbofs.gz" ]; then
   linbo-scp "$LINBODIR/linbofs.lz" "${RSYNC_HOST_NAME}:/cache"
   linbo-ssh "$RSYNC_HOST_NAME" /bin/rm /cache/linbofs.gz /cache/linbo*.info
  fi
  # repair old linbofs64 filename
  if [ "$(basename "$FILE")" = "linbofs64.gz" ]; then
   linbo-scp "$LINBODIR/linbofs64.lz" "${RSYNC_HOST_NAME}:/cache"
   linbo-ssh "$RSYNC_HOST_NAME" /bin/rm /cache/linbofs64.gz /cache/linbo64*.info
  fi
 ;;
 
 # handle server based grub reboot in case of remote cache
 *.reboot)
  # get reboot parameters from filename
  rebootstr="$(echo "$FILE" | sed -e "s|^$LINBODIR/||")"
  bootpart="$(echo "$rebootstr" | awk -F\# '{ print $1 }' )"
  kernel="$(echo "$rebootstr" | awk -F\# '{ print $2 }' )"
  initrd="$(echo "$rebootstr" | awk -F\# '{ print $3 }' )"
  append="$(echo "$rebootstr" | awk -F\# '{ print $4 }' )"
  # grubenv template
  grubenv_tpl="$LINBOTPLDIR/grubenv.reboot"
  # create fifo socket
  fifo="$LINBODIR/boot/grub/spool/${compname}.reboot"
  rm -f "$fifo"
  mkfifo "$fifo"
  # create screen session
  screen -dmS "${compname}.reboot" "$LINBOSHAREDIR/reboot_pipe.sh" "$bootpart" "$kernel" "$initrd" "$append" "$grubenv_tpl" "$fifo"
 ;;

 upgrade)
  if [ "$FLAVOUR" != "oss" ]; then
   # update old 2.2 client
   LINBOFSCACHE="$LINBOCACHEDIR/linbofs"
   linbo-ssh "$RSYNC_HOST_NAME" 'echo -e "#!/bin/sh\necho \"Processing LINBO upgrade ... waiting for reboot ...\"\nsleep 120\n/sbin/reboot" > /linbo.sh'
   linbo-ssh "$RSYNC_HOST_NAME" chmod +x /linbo.sh
   linbo-scp --exclude start.conf --exclude linbo.sh -a "$LINBOFSCACHE/" "${RSYNC_HOST_NAME}:/"
   for i in linbo64 linbofs64.lz; do
    linbo-scp "$LINBODIR/$i" "${RSYNC_HOST_NAME}:/cache"
   done
   linbo-ssh "$RSYNC_HOST_NAME" /usr/bin/linbo_cmd update "$SCHOOL_SERVER" "$CACHE"
  fi
 ;;

 grub-local)
  if [ -e "$FILE" ]; then
   echo "Removing $FILE."
   rm -f "$FILE"
  fi
 ;;

 # remove download link start.conf-ip
 start.conf.gruppe)
  if [ "$FLAVOUR" = "oss" ]; then
    echo "remove link to $FILE"
    [[ -L $FILE ]] && rm -f "$FILE"
  fi
 ;;

 *) ;;

esac

rm -f "$PIDFILE"
