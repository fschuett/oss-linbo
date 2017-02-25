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
Source121:	grub-2.02~rc1.tar.gz
Source122:	ipxe.efi
Source123:	ipxe.lkrn
Source131:	netbsd-queue-1.70.h
# source archives, because build cannot download them
Source1:	rsync-3.1.2.tar.gz
Source2:	libpthread-stubs-0.3.tar.bz2
Source3:	bc-1.06.95.tar.bz2
Source4:	xextproto-7.3.0.tar.bz2
Source5:	ms-sys-2.4.1.tar.gz
Source7:	mpc-1.0.3.tar.gz
Source8:	kbproto-1.0.7.tar.bz2
Source9:	binutils-2.26.tar.bz2
Source10:	xcb-proto-1.11.tar.bz2
Source11:	xf86bigfontproto-1.2.0.tar.bz2
Source12:	chntpw-source-140201.zip
Source13:	fakeroot_1.20.2.orig.tar.bz2
Source14:	util-macros-1.19.0.tar.bz2
Source15:	XML-Parser-2.41.tar.gz
Source16:	xtrans-1.3.5.tar.bz2
Source17:	mtdev-1.1.4.tar.bz2
Source18:	pkgconf-0.9.12.tar.bz2
Source19:	flex-2.5.37.tar.gz
Source20:	gperf-3.0.4.tar.gz
Source21:	xz-5.2.2.tar.bz2
Source22:	intltool-0.51.0.tar.gz
Source23:	gcc-5.3.0.tar.bz2
Source24:	libxslt-1.1.29.tar.gz
Source25:	ctorrent-dnh3.3.2.tar.gz
Source26:	ncurses-5.9.tar.gz
Source27:	ntfs-3g_ntfsprogs-2016.2.22.tgz
Source28:	pcre-8.38.tar.bz2
Source29:	efibootmgr-efibootmgr-0.12.tar.gz
Source30:	attr-2.4.47.src.tar.gz
Source31:	libxkbfile-1.0.9.tar.bz2
Source32:	libxml2-2.9.4.tar.gz
Source33:	xkeyboard-config-2.17.tar.bz2
Source34:	fuse-2.9.6.tar.gz
Source35:	popt-1.16.tar.gz
Source36:	eudev-3.1.5.tar.gz
Source37:	libXau-1.0.8.tar.bz2
Source38:	libX11-1.6.3.tar.bz2
Source39:	gptfdisk-1.0.0.tar.gz
Source40:	v1.0.tar.gz
Source41:	udpcast-20120424.tar.gz
Source42:	dropbear-2016.73.tar.bz2
Source43:	libxcb-1.11.1.tar.bz2
Source44:	acl-2.2.52.src.tar.gz
Source45:	xproto-7.0.28.tar.bz2
Source46:	xkbcomp-1.3.1.tar.bz2
Source47:	inputproto-2.3.2.tar.bz2
Source48:	bvi-1.4.0.src.tar.gz
Source49:	expat-2.1.1.tar.bz2
Source50:	musl-1.1.14.tar.gz
Source51:	busybox-1.24.2.tar.bz2
Source52:	libXdmcp-1.1.2.tar.bz2
Source53:	efivar-0.23.tar.gz
Source54:	autoconf-2.69.tar.xz
Source55:	e2fsprogs-1.42.13.tar.xz
Source56:	libevdev-1.4.6.tar.xz
Source57:	linux-4.4.15.tar.xz
Source58:	qtbase-opensource-src-5.6.0.tar.xz
Source59:	automake-1.15.tar.xz
Source60:	ethtool-4.5.tar.xz
Source61:	libinput-1.2.4.tar.xz
Source62:	m4-1.4.17.tar.xz
Source63:	reiserfsprogs-3.6.24.tar.xz
Source64:	bison-3.0.4.tar.xz
Source65:	gettext-0.19.7.tar.xz
Source66:	libpng-1.6.21.tar.xz
Source67:	mpfr-3.1.4.tar.xz
Source68:	util-linux-2.28.tar.xz
Source69:	cloop_3.14.1.2.tar.xz
Source70:	gmp-6.1.0.tar.xz
Source71:	libtool-2.4.6.tar.xz
Source72:	parted-3.1.tar.xz
Source74:	zlib-1.2.8.tar.xz
Source75:	dosfstools-3.0.28.tar.xz
Source76:	kmod-22.tar.xz
Source77:	libxkbcommon-0.6.1.tar.xz
Source78:	Python-2.7.11.tar.xz

BuildRequires:	unzip openschool-base md5sum
BuildRequires:	gcc48 gcc48-32bit gcc48-c++ glibc glibc-32bit glibc-devel glibc-devel-32bit
BuildRequires:	autoconf >= 2.69 automake >= 1.15 bc bison openssl-certs cpio
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

pushd %{_builddir}/%{name}-%{version}
mkdir -p buildroot/dl
cp %{S:1} %{S:2} %{S:3} %{S:4} %{S:5} %{S:7} %{S:8} %{S:9} \
   %{S:10} %{S:11} %{S:12} %{S:13} %{S:14} %{S:15} %{S:16} %{S:17} %{S:18} %{S:19} \
   %{S:20} %{S:21} %{S:22} %{S:23} %{S:24} %{S:25} %{S:26} %{S:27} %{S:28} %{S:29} \
   %{S:30} %{S:31} %{S:32} %{S:33} %{S:34} %{S:35} %{S:36} %{S:37} %{S:38} %{S:39} \
   %{S:40} %{S:41} %{S:42} %{S:43} %{S:44} %{S:45} %{S:46} %{S:47} %{S:48} %{S:49} \
   %{S:50} %{S:51} %{S:52} %{S:53} %{S:54} %{S:55} %{S:56} %{S:57} %{S:58} %{S:59} \
   %{S:60} %{S:61} %{S:62} %{S:63} %{S:64} %{S:65} %{S:66} %{S:67} %{S:68} %{S:69} \
   %{S:70} %{S:71} %{S:72} %{S:74} %{S:75} %{S:76} %{S:77} %{S:78} \
   buildroot/dl
# special file name, no archive
install %{S:131} "buildroot/dl/queue.h?rev=1.70"
# put grub stuff in place
mkdir -p build
cp %{S:121} %{S:122} %{S:123} build

popd


%build

OPATH=$PATH
export PATH=%{_builddir}:${OPATH%:.}

make -f debian/rules build

export PATH=$OPATH

%install
# install files and directories
mkdir -p %{buildroot}/var/adm/fillup-templates
install -m 644 -o root -g root rpm/sysconfig.oss-linbo %{buildroot}/var/adm/fillup-templates/sysconfig.oss-linbo
mkdir -p %{buildroot}/etc/sysconfig/linbo
install etc/ssh_config %{buildroot}/etc/sysconfig/linbo/ssh_config
install etc/start.conf.default.in %{buildroot}/etc/sysconfig/linbo/start.conf.default.in
mkdir -p %{buildroot}/srv/tftp
rm -f var/boot/grub/themes/linbo/linbo_wallpaper.png
cp -r var/* %{buildroot}/srv/tftp
pushd %{buildroot}/srv/tftp/boot/grub/themes/linbo/
ln -sf ../../../../icons/linbo_wallpaper_800x600.png linbo_wallpaper.png
popd
pushd %{buildroot}/srv/tftp/boot/grub/
ln -sf ../../icons/linbo_wallpaper_800x600.png linbo_wallpaper.png
popd
install buildroot-external/board/rootfs_overlay/etc/linbo-version %{buildroot}/srv/tftp
mkdir -p %{buildroot}/srv/tftp/boot/grub
install build/ipxe.lkrn %{buildroot}/srv/tftp/boot/grub/
install build/ipxe.efi %{buildroot}/srv/tftp/boot/grub/
mkdir -p %{buildroot}/usr/share/oss-linbo
cp -r share/* %{buildroot}/usr/share/oss-linbo/
cp -r build/boot/grub/* %{buildroot}/srv/tftp/boot/grub/
mkdir -p %{buildroot}/var/cache/oss-linbo
mkdir -p %{buildroot}/var/adm/fillup-templates
install -m 644 -o root -g root debian/linbo-bittorrent.default %{buildroot}/var/adm/fillup-templates/sysconfig.linbo-bittorrent
mkdir -p %{buildroot}/etc/init.d
install debian/linbo-bittorrent.init %{buildroot}/etc/init.d/linbo-bittorrent
install debian/linbo-multicast.init %{buildroot}/etc/init.d/linbo-multicast
install share/templates/grub.cfg.pxe %{buildroot}/srv/tftp/boot/grub/grub.cfg
install build/build-i386/images/bzImage %{buildroot}/srv/tftp/linbo
md5sum %{buildroot}/srv/tftp/linbo >%{buildroot}/srv/tftp/linbo.md5
install build/build-i386/images/rootfs.cpio.lz %{buildroot}/srv/tftp/linbofs.lz
md5sum %{buildroot}/srv/tftp/linbofs.lz >%{buildroot}/srv/tftp/linbofs.lz.md5
install build/build-x86_64/images/bzImage %{buildroot}/srv/tftp/linbo64
md5sum %{buildroot}/srv/tftp/linbo64 >%{buildroot}/srv/tftp/linbo64.md5
install build/build-x86_64/images/rootfs.cpio.lz %{buildroot}/srv/tftp/linbofs64.lz
md5sum %{buildroot}/srv/tftp/linbofs64.lz >%{buildroot}/srv/tftp/linbofs64.lz.md5
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
ln -sf ../share/oss-linbo/make-linbo-media.sh make-linbo-media
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
install -m 0640 -o root -g root etc/rsyncd.conf.in %{buildroot}/etc/rsyncd.conf.in
install -m 0600 -o root -g root etc/rsyncd.secrets.in %{buildroot}/etc/rsyncd.secrets.in
# bittorrent
install -m 755 -o root -g root rpm/bittorrent.init %{buildroot}/etc/init.d/bittorrent
mkdir -p %{buildroot}/var/adm/fillup-templates
install -m 644 -o root -g root rpm/sysconfig.bittorrent %{buildroot}/var/adm/fillup-templates/sysconfig.bittorrent
mkdir -p %{buildroot}/var/lib/bittorrent
mkdir -p %{buildroot}/var/log/bittorrent

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
     dropbearconvert openssh dropbear /etc/sysconfig/linbo/ssh_host_dsa_key /etc/sysconfig/linbo/dropbear_dss_host_key
   fi
   update-linbofs
fi

%fillup_only
%{fillup_and_insserv -yn bittorrent}
%{fillup_and_insserv -yn linbo-bittorrent}
%{fillup_and_insserv -f -y linbo-multicast}
%{fillup_and_insserv -f -y rsyncd}
exit 0

%postun
%restart_on_update bittorrent linbo-bittorrent linbo-multicast rsyncd
%insserv_cleanup

%files
%defattr(-,root,root)
%dir /etc/sysconfig/linbo
%config /etc/sysconfig/linbo/ssh_config
%config /etc/sysconfig/linbo/start.conf.default.in
%config /etc/logrotate.d/oss-linbo
%attr(-,nobody,-) %dir /var/log/oss-linbo
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
%attr(0755,bittorrent,-) /var/lib/bittorrent
%attr(0755,bittorrent,-) /var/log/bittorrent
/etc/init.d/bittorrent
/var/adm/fillup-templates/sysconfig.bittorrent
/var/adm/fillup-templates/sysconfig.linbo-bittorrent
/var/adm/fillup-templates/sysconfig.oss-linbo
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
/usr/sbin/linbo-ssh
/usr/sbin/linbo-scp
/usr/sbin/linbo-remote
/usr/sbin/make-linbo-media
/usr/sbin/update-linbofs

%changelog

