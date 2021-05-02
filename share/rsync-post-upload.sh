#!/bin/bash
#
# thomas@linuxmuster.net
# 20200721
#

# read in specific environment
source /etc/linbo/linbo.conf || exit 1
source $ENVDEFAULTS || exit 1
source $HELPERFUNCTIONS || exit 1
[ "$FLAVOUR" = "lmn6" ] && source "$LINBOSHAREDIR/lmn6helperfunctions.sh"
[ -n "$LINBODIR" ] || LINBOLOGDIR="/var/log"
[ -n "$LINBOLOGDIR" ] || LINBOLOGDIR="$LINBODIR/log"

LOGFILE="$LINBOLOGDIR/rsync-post-upload.log"

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync post upload begin: $(date) ###"

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

PIDFILE="/tmp/rsync.$RSYNC_PID"

# Check for pidfile, exit if nothing to do
[ -s "$PIDFILE" ] || exit 0

FILE="$(<$PIDFILE)"
rm -f "$PIDFILE"
BACKUP="${FILE}.BAK"
FTYPE="$(echo $FILE | grep -o '\.[^.]*$')"

# fetch host & domainname
do_rsync_hostname

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "IP: $RSYNC_HOST_ADDR"
echo "RSYNC_REQUEST: $RSYNC_REQUEST"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

# Check for backup file that should have been created by pre-upload script
if [ -s "$BACKUP" ]; then
 if [ "$RSYNC_EXIT_STATUS" = "0" ]; then
  echo "Upload of ${FILE##*/} was successful." >&2
  DATE="$(date +'%Y-%m-%d-%H%M')" # YYYY-MM-DD-hhmm
  BASE="${FILE##*/}" ; EXT="$BASE"; BASE="${BASE%%.*}" ; EXT="${EXT##$BASE}" # File Extension
  ARCHIVE="${FILE%%$EXT}-$DATE$EXT"
  mv -fv "$BACKUP" "$ARCHIVE"
  echo "Archive file ${ARCHIVE##*/} created." >&2
  # backup macct, opsi, reg, postsync files
  case "$FTYPE" in
   *.cloop|*.rsync)
    for i in macct opsi reg postsync; do
     if [ -e "${FILE}.$i" ];then
      cp -fv "${FILE}.$i" "${ARCHIVE}.$i"
      echo "$(basename ${ARCHIVE}.$i) created."
      case "$i" in
        macct|opsi) chmod 600 "${ARCHIVE}.$i" ;;
      esac
     fi
    done
   ;;
  esac
 else
 # If upload failed, move old file back from backup.
  echo "Upload of ${FILE##*/} failed." >&2
  mv -fv "$BACKUP" "$FILE"
  echo "Recovered ${FILE##*/} from backup." >&2
 fi
fi

# do something depending on file type
case "$FTYPE" in

 *.cloop|*.rsync)
  image="${FILE##*/}"
  # restart multicast service if image file was uploaded.
  echo "Image file $image detected. Restarting multicast service if enabled." >&2
  /etc/init.d/linbo-multicast restart >&2

  # save samba passwords of host we made the new image
  save_image_macct $compname $image

  # update opsi settings if host is managed
  if ([ -n "$opsiip" ] && opsimanaged "$compname"); then
   clientini="${opsiip}:$OPSICLIENTDIR/${RSYNC_HOST_NAME}.ini"
   imageini="$LINBODIR/$image.opsi"
   rsync "$clientini" "$imageini" ; RC="$?"
   if [ "$RC" = "0" ]; then
    chmod 600 "$imageini"
    echo "$(basename "$clientini") successfully downloaded to $(basename "$imageini")."
   else
    rm -f "$imageini"
    echo "Download of $(basename "$clientini") to $(basename "$imageini") failed!"
   fi
  fi

 ;;

 *.torrent)
  # restart torrent service if torrent file was uploaded.
  echo "Torrent file ${FILE##*/} detected. Restarting bittorrent service." >&2
  /etc/init.d/linbo-bittorrent restart >&2
 ;;
 *.new)
  # make row lmn7 compatible
  search=";;;;;1;1"
  replace=";;;;classroom-studentcomputer;;1;;;;;"
  ROW="$(sed -e "s|$search|$replace|" $FILE)"
  # add row with new host data to devices file
  if [ -e "$WIMPORTDATA" ]; then
   if grep -i "$ROW" $WIMPORTDATA | grep -qv ^#; then
    echo "$ROW"
    echo "is already present in workstations file. Skipped!" >&2
   else
    echo "Adding row to $WIMPORTDATA." >&2
    echo "$ROW" >> $WIMPORTDATA
    # save last registered host
    echo "$ROW" > "$LINBODIR/last_registered"
   fi
  else
   echo "Adding row to $WIMPORTDATA." >&2
   echo "$ROW" >> $WIMPORTDATA
   # save last registered host
   echo "$ROW" > "$LINBODIR/last_registered"
  fi
  rm $FILE
 ;;
 *) ;;
esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync post upload end: $(date) ###"

exit $RSYNC_EXIT_STATUS
