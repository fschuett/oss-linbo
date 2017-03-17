#
# Spec file for oss-linbo
# Copyright (c) 2016 Frank Schütte <fschuett@gymhim.de> Hildesheim, Germany.  All rights reserved.
#
# gcc 4.8 is needed, replace links gcc, g++, cpp
# don't clean buil dir
Name:		oss-linbo
Summary:	OSS linux installation and boot environment
Version:	3.0.0
Release:	1.1
License:	GPLv3
Vendor:		openSUSE Linux
Distribution:	SLE11
Packager:	fschuett@gymhim.de
Group:		Productivity/
Source:		%{name}-%{version}.tar.gz
Source121:	ipxe.efi
Source122:	ipxe.lkrn
# source archives, because build cannot download them created by list_sources.sh
Source1:	acl-2.2.52.src.tar.gz
Source2:	attr-2.4.47.src.tar.gz
Source3:	autoconf-2.69.tar.xz
Source4:	automake-1.15.tar.xz
Source5:	bc-1.06.95.tar.bz2
Source6:	binutils-2.27.tar.bz2
Source7:	bison-3.0.4.tar.xz
Source8:	busybox-1.25.1.tar.bz2
Source9:	bvi-1.4.0.src.tar.gz
Source10:	chntpw-source-140201.zip
Source11:	cloop_3.14.1.2.tar.xz
Source12:	ctorrent-dnh3.3.2.tar.gz
Source13:	dosfstools-4.0.tar.xz
Source14:	dropbear-2016.74.tar.bz2
Source15:	e2fsprogs-1.43.3.tar.xz
Source16:	efibootmgr-14.tar.gz
Source17:	efivar-28.tar.gz
Source18:	ethtool-4.8.tar.xz
Source19:	eudev-3.2.tar.gz
Source20:	expat-2.2.0.tar.bz2
Source21:	fakeroot_1.20.2.orig.tar.bz2
Source22:	flex-2.5.37.tar.gz
Source23:	fuse-2.9.7.tar.gz
Source24:	gawk-4.1.4.tar.xz
Source25:	gcc-5.4.0.tar.bz2
Source26:	gettext-0.19.8.1.tar.xz
Source27:	glibc-2.24.tar.xz
Source28:	gmp-6.1.1.tar.xz
Source29:	gperf-3.0.4.tar.gz
Source30:	gptfdisk-1.0.0.tar.gz
Source31:	grub-2.02~rc1.tar.gz
Source32:	inputproto-2.3.2.tar.bz2
Source33:	intltool-0.51.0.tar.gz
Source34:	kbproto-1.0.7.tar.bz2
Source35:	kmod-23.tar.xz
Source36:	libevdev-1.5.4.tar.xz
Source37:	libinput-1.5.0.tar.xz
Source38:	libpng-1.6.25.tar.xz
Source39:	libpthread-stubs-0.3.tar.bz2
Source40:	libtool-2.4.6.tar.xz
Source41:	libX11-1.6.4.tar.bz2
Source42:	libXau-1.0.8.tar.bz2
Source43:	libxcb-1.12.tar.bz2
Source44:	libXdmcp-1.1.2.tar.bz2
Source45:	libxkbcommon-0.6.1.tar.xz
Source46:	libxkbfile-1.0.9.tar.bz2
Source47:	libxml2-2.9.4.tar.gz
Source48:	libxslt-1.1.29.tar.gz
Source49:	linux-4.8.11.tar.xz
Source50:	m4-1.4.17.tar.xz
Source51:	mpc-1.0.3.tar.gz
Source52:	mpfr-3.1.5.tar.xz
Source53:	ms-sys-2.4.1.tar.gz
Source54:	mtdev-1.1.4.tar.bz2
Source55:	ncurses-5.9.tar.gz
Source56:	ntfs-3g_ntfsprogs-2016.2.22.tgz
Source57:	parted-3.1.tar.xz
Source58:	pcre-8.39.tar.bz2
Source59:	pkgconf-0.9.12.tar.bz2
Source60:	popt-1.16.tar.gz
Source61:	Python-2.7.12.tar.xz
Source62:	qtbase-opensource-src-5.6.2.tar.xz
Source63:	reiserfsprogs-3.6.24.tar.xz
Source64:	rsync-3.1.2.tar.gz
Source65:	udpcast-20120424.tar.gz
Source66:	util-linux-2.28.2.tar.xz
Source67:	util-macros-1.19.0.tar.bz2
Source68:	xcb-proto-1.12.tar.bz2
Source69:	xextproto-7.3.0.tar.bz2
Source70:	xf86bigfontproto-1.2.0.tar.bz2
Source71:	xkbcomp-1.3.1.tar.bz2
Source72:	xkeyboard-config-2.19.tar.bz2
Source73:	XML-Parser-2.41.tar.gz
Source74:	xproto-7.0.31.tar.bz2
Source75:	xtrans-1.3.5.tar.bz2
Source76:	xz-5.2.2.tar.bz2
Source77:	zlib-1.2.8.tar.xz

BuildRequires:	unzip openschool-base
BuildRequires:	gcc48 gcc48-32bit gcc48-c++ glibc glibc-32bit glibc-devel glibc-devel-32bit
BuildRequires:	autoconf >= 2.69 automake >= 1.15 bc bison cpio
%if 0%{?sles_version} == 11
BuildRequires:  openssl-certs
%endif
BuildRequires:	flex gettext git freetype2-devel libtool 
BuildRequires:	ncurses-devel  python rsync texinfo makeinfo unzip wget efont-unicode

BuildRoot:    %{_tmppath}/%{name}-root
Requires:	logrotate
Requires(post):	%insserv_prereq %fillup_prereq dropbear pwgen

PreReq: %insserv_prereq openschool-base


%description
This package provides a boot environment based on linux installation and boot environment (linbo) for cloning clients.

Authors:
--------
        see readme

%prep
%setup -D
ln -sf /usr/bin/gcc-4.8 %{_builddir}/gcc
ln -sf /usr/bin/gcc-ar-4.8 %{_builddir}/gcc-ar
ln -sf /usr/bin/gcc-nm-4.8 %{_builddir}/gcc-nm
ln -sf /usr/bin/gcc-ranlib-4.8 %{_builddir}/gcc-ranlib
ln -sf /usr/bin/gcc-4.8 %{_builddir}/cc
ln -sf /usr/bin/g++-4.8 %{_builddir}/g++
ln -sf /usr/bin/cpp-4.8 %{_builddir}/cpp
ln -sf /usr/bin/gcov-4.8 %{_builddir}/gcov

%build

OPATH=$PATH
export PATH=%{_builddir}:${OPATH%:.}
export BR2_DL_DIR=%{_sourcedir}
make -f debian/rules build

export PATH=$OPATH

%install
# install files and directories
mkdir -p %{buildroot}/var/adm/fillup-templates
install rpm/sysconfig.oss-linbo %{buildroot}/var/adm/fillup-templates/sysconfig.oss-linbo
mkdir -p %{buildroot}/etc/sysconfig/linbo
install etc/ssh_config %{buildroot}/etc/sysconfig/linbo/ssh_config
install etc/start.conf.default.in %{buildroot}/etc/sysconfig/linbo/start.conf.default.in
mkdir -p %{buildroot}/srv/tftp
cp -r var/* %{buildroot}/srv/tftp
pushd %{buildroot}/srv/tftp/boot/grub/
ln -sf ../../icons/linbo_wallpaper_1024x768.png linbo_wallpaper.png
popd
install buildroot-external/board/rootfs_overlay/etc/linbo-version %{buildroot}/srv/tftp
mkdir -p %{buildroot}/srv/tftp/boot/grub
install %{S:121} %{buildroot}/srv/tftp/boot/grub/
install %{S:122} %{buildroot}/srv/tftp/boot/grub/
cp -r build/boot/grub/* %{buildroot}/srv/tftp/boot/grub/
mkdir -p %{buildroot}/usr/share/oss-linbo
cp -r share/* %{buildroot}/usr/share/oss-linbo/
mkdir -p %{buildroot}/var/cache/oss-linbo
mkdir -p %{buildroot}/var/adm/fillup-templates
install debian/linbo-bittorrent.default %{buildroot}/var/adm/fillup-templates/sysconfig.linbo-bittorrent
mkdir -p %{buildroot}/etc/init.d
install debian/linbo-bittorrent.init %{buildroot}/etc/init.d/linbo-bittorrent
install debian/linbo-multicast.init %{buildroot}/etc/init.d/linbo-multicast
install share/templates/grub.cfg.pxe %{buildroot}/srv/tftp/boot/grub/grub.cfg
install build/build-i386/images/bzImage %{buildroot}/srv/tftp/linbo
install build/build-i386/images/bzImage.md5 %{buildroot}/srv/tftp/linbo.md5
install build/build-i386/images/rootfs.cpio.lz %{buildroot}/srv/tftp/linbofs.lz
install build/build-i386/images/rootfs.cpio.lz.md5 %{buildroot}/srv/tftp/linbofs.lz.md5
install build/build-x86_64/images/bzImage %{buildroot}/srv/tftp/linbo64
install build/build-x86_64/images/bzImage.md5 %{buildroot}/srv/tftp/linbo64.md5
install build/build-x86_64/images/rootfs.cpio.lz %{buildroot}/srv/tftp/linbofs64.lz
install build/build-x86_64/images/rootfs.cpio.lz.md5 %{buildroot}/srv/tftp/linbofs64.lz.md5
mkdir -p %{buildroot}/srv/tftp/boot/grub/fonts
install buildroot-external/board/rootfs_overlay/usr/share/grub/unicode.pf2 %{buildroot}/srv/tftp/boot/grub/fonts
mkdir -p %{buildroot}/var/log/oss-linbo
pushd %{buildroot}/srv/tftp/
ln -sf ../../var/log/oss-linbo log
popd
mkdir -p %{buildroot}/usr/sbin
pushd %{buildroot}/usr/sbin/
ln -sf ../share/oss-linbo/linbo-ssh.sh linbo-ssh
ln -sf ../share/oss-linbo/linbo-scp.sh linbo-scp
ln -sf ../share/oss-linbo/linbo-remote.sh linbo-remote
ln -sf ../share/oss-linbo/update-linbofs.sh update-linbofs
popd
mkdir -p %{buildroot}/usr/share/doc/packages/oss-linbo
pushd %{buildroot}/usr/share/doc/packages/oss-linbo/
ln -sf ../../../../../srv/tftp/examples examples
popd
mkdir -p %{buildroot}/etc/logrotate.d
install debian/logrotate %{buildroot}/etc/logrotate.d/oss-linbo
mkdir -p %{buildroot}/srv/tftp/{linbocmd,torrentadds,winact,tmp,backup}
mkdir -p %{buildroot}/srv/tftp/boot/grub/spool
# rsyncd conf
install etc/rsyncd.conf.in %{buildroot}/etc/rsyncd.conf.in
install etc/rsyncd.secrets.in %{buildroot}/etc/rsyncd.secrets.in
# bittorrent
install rpm/bittorrent.init %{buildroot}/etc/init.d/bittorrent
mkdir -p %{buildroot}/var/adm/fillup-templates
install rpm/sysconfig.bittorrent %{buildroot}/var/adm/fillup-templates/sysconfig.bittorrent
mkdir -p %{buildroot}/var/lib/bittorrent
mkdir -p %{buildroot}/var/log/bittorrent

mkdir -p %{buildroot}/etc/sysconfig/linbo/import-workstations.d
mkdir -p %{buildroot}/usr/sbin
cp -r sbin/* %{buildroot}/usr/sbin

%pre
if ! grep -qw ^bittorrent /etc/passwd; then
    useradd -r -g nogroup -c "BitTorrent User" -d /var/lib/bittorrent -s /bin/false bittorrent
fi

%post
# setup rights
if [ -d /home/sysadmins/admin ]
then
   DATE=`date +%Y-%m-%d:%H-%M`
   FILE=/etc/rsyncd.conf
   if [ -e $FILE ]
   then
     cp $FILE $FILE.$DATE
   fi
   cp $FILE.in $FILE
   FILE=/etc/rsyncd.secrets
   if [ ! -e $FILE ]
   then
     cp $FILE.in $FILE
     LINBOPW="$(pwgen -1)"
     sed s/#LINBOPW#/$LINBOPW/ -i $FILE
   fi
   FILE=/etc/sysconfig/linbo/start.conf.default
   if [ -e $FILE ]; then
     cp $FILE $FILE.$DATE
   fi
   cp $FILE.in $FILE
   FILE=/etc/sysconfig/linbo/workstations
   if [ ! -e $FILE ]
   then
     cp $FILE.in $FILE
   fi
   SCHOOL_SERVER=10.0.0.2
   [ -e /etc/sysconfig/schoolserver ] && . /etc/sysconfig/schoolserver
   sed -i s@#SCHOOL_SERVER#@$SCHOOL_SERVER@g $FILE
   [ -e /srv/tftp/start.conf ] || ln -sf $FILE /srv/tftp/start.conf
   
   # create dropbear ssh keys
   if [ ! -s "/etc/sysconfig/linbo/ssh_host_rsa_key" ]; then
     ssh-keygen -t rsa -N "" -f /etc/sysconfig/linbo/ssh_host_rsa_key
     dropbearconvert openssh dropbear /etc/sysconfig/linbo/ssh_host_rsa_key /etc/sysconfig/linbo/dropbear_rsa_host_key
   fi
   if [ ! -s "/etc/sysconfig/linbo/ssh_host_dsa_key" ]; then
     ssh-keygen -t dsa -N "" -f /etc/sysconfig/linbo/ssh_host_dsa_key
     dropbearconvert openssh dropbear /etc/sysconfig/linbo/ssh_host_dsa_key /etc/sysconfig/linbo/dropbear_dsa_host_key
   fi
   if [ ! -s "/etc/sysconfig/linbo/ssh_host_ecdsa_key" ]; then
     ssh-keygen -t ecdsa -N "" -f /etc/sysconfig/linbo/ssh_host_ecdsa_key
     dropbearconvert openssh dropbear /etc/sysconfig/linbo/ssh_host_ecdsa_key /etc/sysconfig/linbo/dropbear_ecdsa_host_key
   fi
   # create missing ecdsa ssh key
   rootkey="/root/.ssh/id_ecdsa"
   if [ ! -e "$rootkey" ]; then
     echo -n "Creating ssh key $rootkey ... "
     ssh-keygen -N "" -q -t ecdsa -f "$rootkey"
     echo "Done!"
   fi
   update-linbofs
fi
%fillup_only
%{fillup_and_insserv -yn bittorrent}
%{fillup_and_insserv -yn linbo-bittorrent}
%{fillup_and_insserv -f -y linbo-multicast}
%{fillup_and_insserv -f -Y rsyncd}

%postun
%restart_on_update bittorrent linbo-bittorrent linbo-multicast rsyncd
%insserv_cleanup

%files
%defattr(-,root,root)
%dir /etc/sysconfig/linbo
%dir /etc/sysconfig/linbo/import-workstations.d
%config /etc/sysconfig/linbo/ssh_config
%config /etc/sysconfig/linbo/start.conf.default.in
%config /etc/sysconfig/linbo/workstations.in
%config /etc/logrotate.d/oss-linbo
%attr(-,nobody,root) %dir /var/log/oss-linbo
%dir /var/cache/oss-linbo
%dir /srv/tftp
%dir /srv/tftp/log
%dir /srv/tftp/linbocmd
%dir /srv/tftp/torrentadds
%dir /srv/tftp/winact
%dir /srv/tftp/boot/grub
%dir /srv/tftp/boot/grub/spool
%dir /srv/tftp/tmp
%dir /srv/tftp/backup
%attr(0755,bittorrent,root) /var/lib/bittorrent
%attr(0755,bittorrent,root) /var/log/bittorrent
/etc/init.d/bittorrent
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.bittorrent
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.linbo-bittorrent
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.oss-linbo
/etc/init.d/linbo-bittorrent
/etc/init.d/linbo-multicast
%attr(0640,root,root) /etc/rsyncd.conf.in
%attr(0600,root,root) /etc/rsyncd.secrets.in
/srv/tftp/boot/grub/ipxe.lkrn
/srv/tftp/boot/grub/ipxe.efi
/srv/tftp/boot/grub/grub.cfg
/srv/tftp/boot/grub/locale
/srv/tftp/boot/grub/i386-pc
/srv/tftp/boot/grub/i386-efi
/srv/tftp/boot/grub/x86_64-efi
/srv/tftp/boot/grub/fonts
/srv/tftp/boot/grub/linbo_wallpaper.png
/srv/tftp/boot/grub/themes
/srv/tftp/icons
/srv/tftp/linbo
/srv/tftp/linbo.md5
/srv/tftp/linbofs.lz
/srv/tftp/linbofs.lz.md5
/srv/tftp/linbo64
/srv/tftp/linbo64.md5
/srv/tftp/linbofs64.lz
/srv/tftp/linbofs64.lz.md5
/srv/tftp/examples
/srv/tftp/linuxmuster-win
/srv/tftp/linbo-version
/usr/share/oss-linbo
/usr/share/doc/packages/oss-linbo/examples
%defattr(0755,root,root)
/usr/sbin/linbo-ssh
/usr/sbin/linbo-scp
/usr/sbin/linbo-remote
/usr/sbin/update-linbofs
/usr/sbin/import_workstations

%changelog

