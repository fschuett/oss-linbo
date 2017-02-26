#!/bin/bash
#
# creating/updating linbofs.lz with linbo password and ssh keys
# 
# thomas@linuxmuster.net
# GPL V3
# 20161207
#

# read environment
. /usr/share/oss-linbo/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

# check & set lockfile
locker=/tmp/.update-linbofs.lock
if [ -e "$locker" ]; then
	echo "Caution! Probably there is another update-linbofs process running!"
	echo "If this is not the case you can safely remove the lockfile $locker"
	echo "and give update-linbofs another try."
	echo "update-linbofs is locked! Exiting!"
	exit 1
fi
touch $locker || exit 1
chmod 400 "$locker"
curdir=`pwd`

# clean tmpdir and exit with error
bailout() {
 echo "$1"
 cd "$curdir"
 [ -n "$locker" -a -e "$locker" ] && rm -f "$locker"
 exit 1
}

update_linbofs() {
 local suffix=$1
 local linbofscachedir="/var/cache/oss-linbo/linbofs$suffix"
 local linbofs="$LINBODIR/linbofs${suffix}.lz"
 local linbofs_md5="$linbofs".md5
 rm -f "$linbofs_md5"
 rm -rf "$linbofscachedir"
 mkdir -p "$linbofscachedir"

 # check for default linbofs${suffix}.lz
 [ ! -s "$LINBODIR/linbofs${suffix}.lz" ] && bailout "Error: $LINBODIR/linbofs${suffix}.lz not found!"

 # grep linbo rsync password to sync it with linbo account
 [ ! -s /etc/rsyncd.secrets ] && bailout "/etc/rsyncd.secrets not found!"
 local linbo_passwd="$(grep ^linbo /etc/rsyncd.secrets | awk -F\: '{ print $2 }')"
 if [ -z "$linbo_passwd" ]; then
  bailout "Cannot read linbo password from /etc/rsyncd.secrets!"
 else
  # md5sum of linbo password goes into ramdisk
  local linbo_md5passwd=`echo -n $linbo_passwd | md5sum | awk '{ print $1 }'`
 fi

 # begin to process linbofs${suffix}.lz
 echo "Processing linbofs${suffix} update ..."

 # unpack linbofs.lz to cache dir
 cd "$linbofscachedir" || bailout "Cannot change to $linbofscachedir!"
 xzcat "$linbofs" | cpio -i -d -H newc --no-absolute-filenames &> /dev/null ; RC=$?
 [ $RC -ne 0 ] && bailout " Failed to unpack $(basename "$linbofs")!"

 # store linbo md5 password
 [ -n "$linbo_md5passwd" ] && echo -n "$linbo_md5passwd" > etc/linbo_passwd

 # provide dropbear ssh host key
 mkdir -p etc/dropbear
 cp $SYSCONFDIR/linbo/dropbear_*_host_key etc/dropbear
 mkdir -p etc/ssh
 cp $SYSCONFDIR/linbo/ssh_host_*_key* etc/ssh
 mkdir -p root/.ssh
 cat /root/.ssh/id_{ec,}dsa.pub > root/.ssh/authorized_keys
 mkdir -p var/log
 touch var/log/lastlog

 # copy default start.conf
 cp -f $LINBODIR/start.conf .

 # pack default linbofs${suffix}.lz again
 find . | cpio --quiet -o -H newc | lzma -zcv > "$linbofs" ; RC="$?"
 [ $RC -ne 0 ] && bailout "failed!"
 # create md5sum file
 md5sum "$linbofs"  | awk '{ print $1 }' > "$linbofs_md5"

 cd "$curdir"

 echo "Ok!"

}

# create download links for linbo kernel and initrd so it can be downloaded per http
create_www_links(){
 [ -d /srv/www ] || return
 for i in linbo linbo64 linbofs.lz linbofs64.lz linbo.iso; do
  ln -sf "$LINBODIR/$i" /srv/www/
 done
}

# avoid linbo password being set multiple times
LINBOPW=false

update_linbofs
update_linbofs 64

# create iso files
"$LINBOSHAREDIR"/make-linbo-iso.sh

create_www_links

rm -f "$locker"
