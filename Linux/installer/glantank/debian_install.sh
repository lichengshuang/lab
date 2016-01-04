#!/bin/bash
################################################################################
##
##	ファイル名	:	debian_install.sh
##
##	機能概要	:	Debian Install用シェル [VMware対応]
##
##	入出力 I/F
##		INPUT	:	
##		OUTPUT	:	
##
##	作成者		:	J.Itou
##
##	作成日付	:	2014/11/02
##
##	改訂履歴	:	
##	   日付       版         名前      改訂内容
##	---------- -------- -------------- -----------------------------------------
##	2014/11/02 000.0000 J.Itou         新規作成
##	2014/11/06 000.0000 J.Itou         処理見直し
##	2014/11/17 000.0000 J.Itou         処理見直し
##	2014/12/08 000.0000 J.Itou         処理見直し(統合化)
##	2014/12/23 000.0000 J.Itou         処理見直し
##	2014/12/31 000.0000 J.Itou         処理見直し(ubuntu対応)
##	2015/01/14 000.0000 J.Itou         処理見直し(変数定義の見直し)
##	2015/01/31 000.0000 J.Itou         処理見直し(シェルの展開,cronの登録,デフォルトユーザー無効化,dhcp非自動起動化対応)
##	2015/02/09 000.0000 J.Itou         処理見直し(googole dns追加)
##	2015/02/09 000.0000 J.Itou         処理見直し(sambaユーザー登録)
##	2015/02/22 000.0000 J.Itou         処理見直し(バグ修正)
##	2015/02/24 000.0000 J.Itou         処理見直し(バグ修正)
##	2015/03/01 000.0000 J.Itou         処理見直し(crontabs見直し)
##	2015/05/08 000.0000 J.Itou         webminのバージョンアップ
##	2015/07/25 000.0000 J.Itou         処理見直し(grub更新の見直し)
##	2015/08/16 000.0000 J.Itou         処理見直し(crontabs見直し)
##	2015/08/22 000.0000 J.Itou         処理見直し(grub更新の見直し)
##	2015/08/26 000.0000 J.Itou         処理見直し(crontabs見直し)
##	2015/08/28 000.0000 J.Itou         処理見直し(Disable IPv6追加)
##	2015/09/06 000.0000 J.Itou         処理見直し(crontabs見直し)
##	2015/09/06 000.0000 J.Itou         処理見直し(webminの導入方法)
##	2015/09/06 000.0000 J.Itou         処理見直し(swatの導入中止)
##	2015/09/07 000.0000 J.Itou         処理見直し(webminの導入方法)
##	2015/09/07 000.0000 J.Itou         処理見直し(sources.listの追加更新)
##	2015/10/15 000.0000 J.Itou         webminのバージョンアップ
##	2015/11/07 000.0000 J.Itou         処理見直し(stretch対応)
##	2015/11/08 000.0000 J.Itou         処理見直し(CMDRSYNC.sh変更に伴う更新)
##	2015/11/08 000.0000 J.Itou         処理見直し(crontabs見直し)
##	2015/11/18 000.0000 J.Itou         処理見直し(freshclam.conf見直し)
##	YYYY/MM/DD 000.0000 xxxxxxxxxxxxxx 
################################################################################
#set -nvx

# Pause処理 --------------------------------------------------------------------
funcPause() {
	RET_STS=$1

	if [ ${RET_STS} -ne 0 ]; then
		echo "Enterキーを押して下さい。"
		read DUMMY
	fi
}

#-------------------------------------------------------------------------------
# Initialize
#-------------------------------------------------------------------------------
	DBG_FLAG=${DBG_FLAG:-0}
	if [ ${DBG_FLAG} -ne 0 ]; then
		set -vx
	fi

	# ユーザー環境に合わせて変更する部分 ---------------------------------------
	# SET_DIST=oldoldstable						# oldoldstable
	# SET_DIST=oldstable						# oldstable
	# SET_DIST=stable							# stable
	# SET_DIST=testing							# testing
	# SET_DIST=squeeze							# debian 6
	# SET_DIST=wheezy							# debian 7
	# SET_DIST=jessie							# debian 8
	# SET_DIST=stretch							# debian 9
	SVR_IPAD=192.168.1							# 本機の属するプライベート・アドレス
	SVR_ADDR=1									# 本機のIPアドレス
	SVR_NAME=sv-server							# 本機の名前
	GWR_ADDR=254								# ゲートウェイのIPアドレス
	GWR_NAME=gw-router							# ゲートウェイの名前
	WGP_NAME=workstation						# 本機の属するワークグループ名
	NUM_HDDS=4									# インストール先のHDD台数
	FLG_DHCP=0									# DHCP自動起動フラグ(0以外で自動起動)
	ADR_DHCP="${SVR_IPAD}.64 ${SVR_IPAD}.79"	# DHCPの提供アドレス範囲
	FLG_VMTL=0									# 0以外でVMware Toolsをインストール
	DEF_USER=master								# インストール時に作成したユーザー名
	FLG_AUTO=1									# 0以外でpreseed.cfgの環境を使う
	FLG_VIEW=0									# 0以外でデバッグ用に設定ファイルを開く
#	VER_WMIN=1.770								# webminの最新バージョンを登録
#	VGA_MODE="vga=792"							# コンソールの解像度：1024×768：1600万色
#	VGA_RESO=1024x768							#   〃              ：
	VGA_MODE="vga=795"							#   〃              ：1280×1024：1600万色
	VGA_RESO=1280x1024x32						#   〃              ：
	# ワーク変数設定 -----------------------------------------------------------
	NOW_TIME=`date +"%Y%m%d%H%M%S"`
	PGM_NAME=`basename $0 | sed -e 's/\..*$//'`

	DST_NAME=`awk '/[A-Za-z]./ {print $1;}' /etc/issue | head -n 1 | tr '[A-Z]' '[a-z]'`

	SET_DIST=""

	while read DUMMY
	do
		TARGET=`echo ${DUMMY} | awk '{print $3;}'`
		case "${TARGET}" in
			oldoldstable ) SET_DIST="${TARGET}"; break ;;	# oldoldstable
			oldstable    ) SET_DIST="${TARGET}"; break ;;	# oldstable
			stable       ) SET_DIST="${TARGET}"; break ;;	# stable
			testing      ) SET_DIST="${TARGET}"; break ;;	# testing
			squeeze      ) SET_DIST="${TARGET}"; break ;;	# debian 6
			wheezy       ) SET_DIST="${TARGET}"; break ;;	# debian 7
			jessie       ) SET_DIST="${TARGET}"; break ;;	# debian 8
			stretch      ) SET_DIST="${TARGET}"; break ;;	# debian 9
		esac;
	done < /etc/apt/sources.list

	if [ "${SET_DIST}" = "" ]; then
		echo "このシステムでは使用できません。"
		uname -a
		cat /etc/apt/sources.list
		exit 1
	fi

	if [ "${VER_WMIN}" = "" ]; then
		SET_WMIN="webmin-current.deb"
	else
		SET_WMIN="webmin_${VER_WMIN}_all.deb"
	fi

	MNT_FD=/media/floppy0
	MNT_CD=/media/cdrom0

	DIR_WK=/work
	LOG_FILE=${DIR_WK}/${PGM_NAME}.sh.${NOW_TIME}.log
	TGZ_WORK=${DIR_WK}/${PGM_NAME}.sh.tgz
	CRN_FILE=${DIR_WK}/${PGM_NAME}.sh.crn
	USR_FILE=${DIR_WK}/${PGM_NAME}.sh.usr.list
	SMB_FILE=${DIR_WK}/${PGM_NAME}.sh.smb.list
	SMB_WORK=${DIR_WK}/${PGM_NAME}.sh.smb.work
	SMB_CONF=/etc/samba/smb.conf
	SMB_BACK=${SMB_CONF}.orig

	DEV_NUM1=sda
	DEV_NUM2=sdb
	DEV_NUM3=sdc
	DEV_NUM4=sdd
	DEV_NUM5=sde
	DEV_NUM6=sdf
	DEV_NUM7=sdg
	DEV_NUM8=sdh

	case "${NUM_HDDS}" in
		# HDD 1台 --------------------------------------------------------------
		1 )	DEV_HDD1=/dev/${DEV_NUM1}
			DEV_HDD2=
			DEV_HDD3=
			DEV_HDD4=

			DEV_USB1=/dev/${DEV_NUM2}
			DEV_USB2=/dev/${DEV_NUM3}
			DEV_USB3=/dev/${DEV_NUM4}
			DEV_USB4=/dev/${DEV_NUM5}
			;;
		# HDD 2台 --------------------------------------------------------------
		2 )	DEV_HDD1=/dev/${DEV_NUM1}
			DEV_HDD2=/dev/${DEV_NUM2}
			DEV_HDD3=
			DEV_HDD4=

			DEV_USB1=/dev/${DEV_NUM3}
			DEV_USB2=/dev/${DEV_NUM4}
			DEV_USB3=/dev/${DEV_NUM5}
			DEV_USB4=/dev/${DEV_NUM6}
			;;
		# HDD 4台 ~ ------------------------------------------------------------
		* )	DEV_HDD1=/dev/${DEV_NUM1}
			DEV_HDD2=/dev/${DEV_NUM2}
			DEV_HDD3=/dev/${DEV_NUM3}
			DEV_HDD4=/dev/${DEV_NUM4}

			DEV_USB1=/dev/${DEV_NUM5}
			DEV_USB2=/dev/${DEV_NUM6}
			DEV_USB3=/dev/${DEV_NUM7}
			DEV_USB4=/dev/${DEV_NUM8}
			;;
	esac

	DEV_RATE="${DEV_USB1} ${DEV_USB2} ${DEV_USB3} ${DEV_USB4}"
	DEV_TEMP="${DEV_HDD1} ${DEV_HDD2} ${DEV_HDD3} ${DEV_HDD4} ${DEV_RATE}"

	WWW_DATA=www-data

	CMD_AGET="apt-get -y -q"
#	CMD_AGET="aptitude -y"

#-------------------------------------------------------------------------------
# Make work dir
#-------------------------------------------------------------------------------
	mkdir -p ${DIR_WK}
#	chmod 700 ${DIR_WK}
	pushd ${DIR_WK}

#-------------------------------------------------------------------------------
# System Update
#-------------------------------------------------------------------------------
	if [ ! -f /etc/apt/sources.list.orig ]; then
		cp -p /etc/apt/sources.list /etc/apt/sources.list.orig
		sed "s/^deb/# deb/" < /etc/apt/sources.list.orig > /etc/apt/sources.list

		cat <<- _EOT_ >> /etc/apt/sources.list
			#-------------------------------------------------------------------------------
			deb     http://security.debian.org/      ${SET_DIST}/updates                   main contrib non-free
			deb-src http://security.debian.org/      ${SET_DIST}/updates                   main contrib non-free

			deb     http://ftp.jp.debian.org/debian/ ${SET_DIST}                           main contrib non-free
			deb-src http://ftp.jp.debian.org/debian/ ${SET_DIST}                           main contrib non-free

			deb     http://ftp.jp.debian.org/debian/ ${SET_DIST}-updates                   main contrib non-free
			deb-src http://ftp.jp.debian.org/debian/ ${SET_DIST}-updates                   main contrib non-free

			# deb     http://ftp.jp.debian.org/debian/ ${SET_DIST}-proposed-updates          main contrib non-free
			# deb-src http://ftp.jp.debian.org/debian/ ${SET_DIST}-proposed-updates          main contrib non-free

			# deb     http://ftp.jp.debian.org/debian/ ${SET_DIST}-backports                 main contrib non-free
			# deb-src http://ftp.jp.debian.org/debian/ ${SET_DIST}-backports                 main contrib non-free

			# deb     http://ftp.jp.debian.org/debian/ ${SET_DIST}-kfreebsd                  main contrib non-free
			# deb-src http://ftp.jp.debian.org/debian/ ${SET_DIST}-kfreebsd                  main contrib non-free

			# deb     http://ftp.jp.debian.org/debian/ ${SET_DIST}-kfreebsd-proposed-updates main contrib non-free
			# deb-src http://ftp.jp.debian.org/debian/ ${SET_DIST}-kfreebsd-proposed-updates main contrib non-free
			#-------------------------------------------------------------------------------
_EOT_
	fi

	${CMD_AGET} update
	${CMD_AGET} upgrade
	${CMD_AGET} dist-upgrade

#-------------------------------------------------------------------------------
# Make User List File
#-------------------------------------------------------------------------------
	cat <<- _EOT_ > ${USR_FILE}
		Administrator:Administrator:1001:
_EOT_

#-------------------------------------------------------------------------------
# Make Samba User List File (pdbedit -L -w にて出力されたもの)
#-------------------------------------------------------------------------------
	cat <<- _EOT_ > ${SMB_FILE}
		administrator:1001:E52CAC67419A9A224A3B108F3FA6CB6D:8846F7EAEE8FB117AD06BDD830B7586C:[U          ]:LCT-5451C9F9:
_EOT_

#-------------------------------------------------------------------------------
# Locale Setup
#-------------------------------------------------------------------------------
	if [ ! -f /root/.bashrc.orig ]; then
		${CMD_AGET} install locales
		funcPause $?
		dpkg-reconfigure locales
		funcPause $?
		#-----------------------------------------------------------------------
		cp -p /root/.bashrc /root/.bashrc.orig
		cat <<- _EOT_ >> /root/.bashrc
			#
			case "\${TERM}" in
			    "linux" )
			        LANG=C
			        ;;
			    * )
			        LANG=ja_JP.UTF-8
			        ;;
			esac
			export LANG
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /root/.bashrc
		fi
		. ~/.profile
	fi

#-------------------------------------------------------------------------------
# Network Setup
#-------------------------------------------------------------------------------
	# hostname -----------------------------------------------------------------
	if [ ! -f /etc/hostname.orig ]; then
		cp -p /etc/hostname /etc/hostname.orig

		if [ ${FLG_AUTO} -eq 0 ]; then
			cat <<- _EOT_ > /etc/hostname
				${SVR_NAME}
_EOT_
			if [ ${FLG_VIEW} -ne 0 ]; then
				vi -c "set list" -c "set listchars=tab:>_" /etc/hostname
			fi
			hostname -b ${SVR_NAME}
			# hosts --------------------------------------------------------------------
			if [ ! -f /etc/hosts.orig ]; then
				cp -p /etc/hosts /etc/hosts.orig
				cat <<- _EOT_ > /etc/hosts
					${SVR_IPAD}.${SVR_ADDR}	${SVR_NAME}.${WGP_NAME}	${SVR_NAME}
					#---------------------------------------------------------------------------
					# 127.0.1.1	${SVR_NAME}.${WGP_NAME}	${SVR_NAME}
_EOT_
				cat /etc/hosts.orig >> /etc/hosts
				vi -c "set list" -c "set listchars=tab:>_" /etc/hosts
			fi
			# interfaces ---------------------------------------------------------------
			if [ ! -f /etc/network/interfaces.orig ]; then
				cp -p /etc/network/interfaces /etc/network/interfaces.orig
				cat <<- _EOT_ >> /etc/network/interfaces
					#---------------------------------------------------------------------------
					# The primary network interface
					# allow-hotplug eth0
					# iface eth0 inet dhcp
					#---------------------------------------------------------------------------
					# The primary network interface
					# allow-hotplug eth0
					# iface eth0 inet static
					#	address ${SVR_IPAD}.${SVR_ADDR}
					#	netmask 255.255.255.0
					#	network ${SVR_IPAD}.0
					#	broadcast ${SVR_IPAD}.255
					#	gateway ${SVR_IPAD}.${GWR_ADDR}
					#	# dns-* options are implemented by the resolvconf package, if installed
					#	dns-nameservers ${SVR_IPAD}.${SVR_ADDR} ${SVR_IPAD}.${GWR_ADDR} 8.8.8.8 8.8.4.4
					#	dns-search ${WGP_NAME}
					#---------------------------------------------------------------------------
_EOT_
				vi -c "set list" -c "set listchars=tab:>_" /etc/network/interfaces
			fi
			# networks -----------------------------------------------------------------
			if [ ! -f /etc/networks.orig ]; then
				cp -p /etc/networks /etc/networks.orig
				cat <<- _EOT_ >> /etc/networks
					localnet	${SVR_IPAD}.0
_EOT_
				vi -c "set list" -c "set listchars=tab:>_" /etc/networks
			fi
		fi
	fi
	# resolv.conf --------------------------------------------------------------
	if [ ! -f /etc/resolv.conf.orig ]; then
		cp -p /etc/resolv.conf /etc/resolv.conf.orig
		if [ ${FLG_AUTO} -eq 0 ]; then
			cat <<- _EOT_ >> /etc/resolv.conf
				domain ${WGP_NAME}
				search ${WGP_NAME}
				nameserver ${SVR_IPAD}.${SVR_ADDR}
				nameserver ${SVR_IPAD}.${GWR_ADDR}
				nameserver 8.8.8.8
				nameserver 8.8.4.4
_EOT_
		else
			cat <<- _EOT_ > /etc/resolv.conf
				domain ${WGP_NAME}
_EOT_
			cat /etc/resolv.conf.orig >> /etc/resolv.conf
		fi
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/resolv.conf
		fi
	fi
	# hosts.allow --------------------------------------------------------------
	if [ ! -f /etc/hosts.allow.orig ]; then
		cp -p /etc/resolv.conf /etc/hosts.allow.orig
		cat <<- _EOT_ >> /etc/hosts.allow
			ALL: 127.0.0.1 ${SVR_IPAD}.
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/hosts.allow
		fi
	fi
	# hosts.deny ---------------------------------------------------------------
	if [ ! -f /etc/hosts.deny.orig ]; then
		cp -p /etc/resolv.conf /etc/hosts.deny.orig
		cat <<- _EOT_ >> /etc/hosts.deny
			ALL: ALL
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/hosts.deny
		fi
	fi

#-------------------------------------------------------------------------------
# Make Samba Configure File
#-------------------------------------------------------------------------------
	cat <<- _EOT_ > ${SMB_WORK}
		# Samba config file created using SWAT
		# from UNKNOWN (${SVR_IPAD}.${SVR_ADDR})
		# Date: `date +"%Y/%m/%d/ %H:%M:%S"`

		[global]
		 	dos charset = CP932
		 	workgroup = ${WGP_NAME}
		 	server string = Samba Server
		 	map to guest = Bad User
		 	obey pam restrictions = Yes
		 	pam password change = Yes
		 	passwd program = /usr/bin/passwd %u
		 	passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
		 	unix password sync = Yes
		 	lanman auth = Yes
		 	client NTLMv2 auth = No
		 	client lanman auth = Yes
		 	client plaintext auth = Yes
		 	syslog = 0
		 	log file = /var/log/samba/log.%m
		 	max log size = 1000
		 	unix extensions = No
		 	logon script = logon.bat
		 	logon drive = U:
		 	domain logons = Yes
		 	dns proxy = No
		 	usershare allow guests = Yes
		 	panic action = /usr/share/samba/panic-action %d
		 	idmap config * : range = 
		 	idmap config * : backend = tdb
		 	force create mode = 01770
		 	force directory mode = 01770
		 	wide links = Yes

		[homes]
		 	comment = Home Directories
		 	valid users = %S
		 	browseable = No

		[printers]
		 	comment = All Printers
		 	path = /var/spool/samba
		 	create mask = 0700
		 	printable = Yes
		 	print ok = Yes
		 	browseable = No

		[print$]
		 	comment = Printer Drivers
		 	path = /var/lib/samba/printers
		 	browseable = No

		[sambadoc]
		 	comment = Samba Documents
		 	path = /usr/share/doc/samba-doc/htmldocs
		 	browseable = No

		[netlogon]
		 	comment = Network Logon Service
		 	path = /share/data/adm/netlogon
		 	force user = www-data

		[profiles]
		 	comment = Users profiles
		 	path = /share/data/adm/profiles
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[cdrom]
		 	comment = Samba server's CD-ROM
		 	path = /mnt/cdrom
		 	force user = www-data
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/cdrom
		 	postexec = /bin/umount /mnt/cdrom

		[share]
		 	comment = Shared directories
		 	path = /share
		 	force user = www-data
		 	browseable = No

		[data]
		 	comment = Data directories
		 	path = /share/data
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[usb]
		 	comment = USB devices directories
		 	path = /share/usb
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[wizd]
		 	comment = Wizd directories
		 	path = /share/wizd
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[pub]
		 	comment = Public directories
		 	path = /share/data/pub
		 	force user = www-data

		[web]
		 	comment = User Directries (web files)
		 	path = /share/data/usr/%U/web
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[app]
		 	comment = User Directries (applications)
		 	path = /share/data/usr/%U/app
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[dat]
		 	comment = User Directries (data files)
		 	path = /share/data/usr/%U/dat
		 	force user = www-data
		 	read only = No
		 	browseable = No

		[usb1]
		 	comment = Samba server's USB1
		 	path = /mnt/usb1
		 	force user = www-data
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb1
		 	postexec = /bin/umount /mnt/usb1

		[usb2]
		 	comment = Samba server's USB2
		 	path = /mnt/usb2
		 	force user = www-data
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb2
		 	postexec = /bin/umount /mnt/usb2

		[usb3]
		 	comment = Samba server's USB3
		 	path = /mnt/usb3
		 	force user = www-data
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb3
		 	postexec = /bin/umount /mnt/usb3

		[usb4]
		 	comment = Samba server's USB4
		 	path = /mnt/usb4
		 	force user = www-data
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb4
		 	postexec = /bin/umount /mnt/usb4
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" ${SMB_WORK}
	fi

#-------------------------------------------------------------------------------
# Make share dir
#-------------------------------------------------------------------------------
	mkdir -p /share
	mkdir -p /share/data
	mkdir -p /share/data/adm
	mkdir -p /share/data/adm/netlogon
	mkdir -p /share/data/adm/profiles
	mkdir -p /share/data/bak
	mkdir -p /share/data/pub
	mkdir -p /share/data/usr
	mkdir -p /share/usb
	mkdir -p /share/wizd
	mkdir -p /share/wizd/movies
	mkdir -p /share/wizd/others
	mkdir -p /share/wizd/sounds
#	touch -f /share/data/adm/netlogon/logon.bat

#-------------------------------------------------------------------------------
# Move home dir
#-------------------------------------------------------------------------------
	id ${WWW_DATA}
	if [ $? -ne 0 ]; then
		useradd -c "${WWW_DATA}" ${WWW_DATA}
	fi

	mv /home/* /share/data/usr/
	useradd -D -b /share/data/usr
#	usermod -g "${WWW_DATA}" ${DEF_USER}
	usermod -d /share/data/usr/${DEF_USER} ${DEF_USER}
	usermod -L ${DEF_USER}
	rmdir /home

#-------------------------------------------------------------------------------
# Make usb dir
#-------------------------------------------------------------------------------
	mkdir -p /mnt/cdrom
	mkdir -p /mnt/floppy
	mkdir -p /mnt/usb1
	mkdir -p /mnt/usb2
	mkdir -p /mnt/usb3
	mkdir -p /mnt/usb4

	ln -s /mnt/usb1 /share/usb
	ln -s /mnt/usb2 /share/usb
	ln -s /mnt/usb3 /share/usb
	ln -s /mnt/usb4 /share/usb
	#---------------------------------------------------------------------------
	if [ ! -f /etc/fstab.orig ]; then
		cp -p /etc/fstab /etc/fstab.orig
		unexpand -a /etc/fstab.orig > /etc/fstab
		cat <<- _EOT_ >> /etc/fstab
			# additional devices
			# <file system>					<mount point>	<type>		<options>		<dump>	<pass>
			# /dev/sr0					/media/cdrom0	udf,iso9660	rw,user,noauto		0	0
			# /dev/fd0					/media/floppy0	auto		rw,user,noauto		0	0
			# /dev/sr0					/mnt/cdrom	udf,iso9660	rw,user,noauto		0	0
			# /dev/fd0					/mnt/floppy	auto		rw,user,noauto		0	0
			# ${DEV_USB1}1					/mnt/usb1	auto		rw,user,noauto		0	0
			# ${DEV_USB2}1					/mnt/usb2	auto		rw,user,noauto		0	0
			# ${DEV_USB3}1					/mnt/usb3	auto		rw,user,noauto		0	0
			# ${DEV_USB4}1					/mnt/usb4	auto		rw,user,noauto		0	0
_EOT_
		vi -c "set list" -c "set listchars=tab:>_" /etc/fstab
	fi

#-------------------------------------------------------------------------------
# Make floppy dir
#-------------------------------------------------------------------------------
	if [ ! -d /media/floppy0 ]; then
		pushd /media
		mkdir floppy0
		ln -s floppy0 floppy
		popd
	fi

#-------------------------------------------------------------------------------
# Make cd-rom dir
#-------------------------------------------------------------------------------
	if [ ! -d /media/cdrom0 ]; then
		pushd /media
		mkdir cdrom0
		ln -s cdrom0 cdrom
		popd
	fi

#-------------------------------------------------------------------------------
# Setup share dir
#-------------------------------------------------------------------------------
	chmod -R 1770 /share/*
	chown -R ${WWW_DATA}:${WWW_DATA} /share/*

#-------------------------------------------------------------------------------
# Make shell dir
#-------------------------------------------------------------------------------
	mkdir -p /usr/sh
	mkdir -p /var/log/sh

	cat <<- _EOT_ > /usr/sh/USRCOMMON.def
		#!/bin/bash
		################################################################################
		##
		##	ファイル名	:	USRCOMMON.def
		##
		##	機能概要	:	ユーザー環境共通処理
		##
		##	入出力 I/F
		##		INPUT	:	
		##		OUTPUT	:	
		##
		##	作成者		:	J.Itou
		##
		##	作成日付	:	2014/10/27
		##
		##	改訂履歴	:	
		##	   日付       版         名前      改訂内容
		##	---------- -------- -------------- -----------------------------------------
		##	2013/10/27 000.0000 J.Itou         新規作成
		##	2014/11/04 000.0000 J.Itou         4HDD版仕様変更
		##	2014/12/22 000.0000 J.Itou         処理見直し
		##	`date +"%Y/%m/%d"` 000.0000 J.Itou         自動作成
		##	YYYY/MM/DD 000.0000 xxxxxxxxxxxxxx 
		##	---------- -------- -------------- -----------------------------------------
		################################################################################

		#-------------------------------------------------------------------------------
		# ユーザー変数定義
		#-------------------------------------------------------------------------------

		# USBデバイス変数定義
		APL_MNT_DV1="${DEV_USB1}1"
		APL_MNT_DV2="${DEV_USB2}1"
		APL_MNT_DV3="${DEV_USB3}1"
		APL_MNT_DV4="${DEV_USB4}1"

		SYS_MNT_DV1="/sys/block/`echo ${DEV_USB1} | awk -F/ '{print $3}'`/device/scsi_disk/*/cache_type"
		SYS_MNT_DV2="/sys/block/`echo ${DEV_USB2} | awk -F/ '{print $3}'`/device/scsi_disk/*/cache_type"
		SYS_MNT_DV3="/sys/block/`echo ${DEV_USB3} | awk -F/ '{print $3}'`/device/scsi_disk/*/cache_type"
		SYS_MNT_DV4="/sys/block/`echo ${DEV_USB4} | awk -F/ '{print $3}'`/device/scsi_disk/*/cache_type"
_EOT_

	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /usr/sh/USRCOMMON.def
	fi

#-------------------------------------------------------------------------------
# Install kernel compilers
#-------------------------------------------------------------------------------
	${CMD_AGET} install build-essential kernel-package libncurses5-dev fuse uuid-runtime
	funcPause $?

#-------------------------------------------------------------------------------
# Install clamav
#-------------------------------------------------------------------------------
	${CMD_AGET} install clamav
	funcPause $?

	if [ ! -f /etc/clamav/freshclam.conf.orig ]; then
		cp -p /etc/clamav/freshclam.conf /etc/clamav/freshclam.conf.orig

		sed "s/Checks\ 24/Checks\ 12/" < /etc/clamav/freshclam.conf.orig > /etc/clamav/freshclam.conf

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/clamav/freshclam.conf
		fi
	fi

	freshclam -d

#-------------------------------------------------------------------------------
# Install ntpdate
#-------------------------------------------------------------------------------
	${CMD_AGET} install ntpdate
	funcPause $?

#-------------------------------------------------------------------------------
# Install ssh
#-------------------------------------------------------------------------------
#	${CMD_AGET} install ssh
#	funcPause $?
	#---------------------------------------------------------------------------
	if [ ! -f /etc/ssh/sshd_config.orig ]; then
		cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
		cat <<- _EOT_ >> /etc/ssh/sshd_config
			UseDNS no
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/ssh/sshd_config
		fi
	fi

	/etc/init.d/ssh restart

#-------------------------------------------------------------------------------
# Install apache2
#-------------------------------------------------------------------------------
	${CMD_AGET} install apache2
	funcPause $?

	if [ ! -f /etc/apache2/mods-available/userdir.conf.orig ]; then
		cp -p /etc/apache2/mods-available/userdir.conf /etc/apache2/mods-available/userdir.conf.orig
		cat <<- _EOT_ > /etc/apache2/mods-available/userdir.conf
			<IfModule mod_userdir.c>
			 	UserDir web/public_html
			 	UserDir disabled root

			 	<Directory /share/data/usr/*/web/public_html>
			 		AllowOverride FileInfo AuthConfig Limit Indexes
			 		Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
			 		<Limit GET POST OPTIONS>
			 			Order allow,deny
			 			Allow from all
			 		</Limit>
			 		<LimitExcept GET POST OPTIONS>
			 			Order deny,allow
			 			Deny from all
			 		</LimitExcept>
			 	</Directory>
			</IfModule>
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/apache2/mods-available/userdir.conf
		fi
	fi

	a2enmod userdir
	/etc/init.d/apache2 restart

#-------------------------------------------------------------------------------
# Install proftpd
#-------------------------------------------------------------------------------
	${CMD_AGET} install proftpd
	funcPause $?
	#---------------------------------------------------------------------------
	if [ ! -f /etc/proftpd/proftpd.conf.orig ]; then
		cp -p /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.orig
		cat <<- _EOT_ >> /etc/proftpd/proftpd.conf
			TimesGMT off
			<Global>
			 	RootLogin on
			 	UseFtpUsers on
			</Global>
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/proftpd/proftpd.conf
		fi
	fi
	#---------------------------------------------------------------------------
	if [ ! -f /etc/ftpusers.orig ]; then
		cp -p /etc/ftpusers /etc/ftpusers.orig
		cat <<- _EOT_ >> /etc/ftpusers
			master
_EOT_
		sed 's/root/#\ root/' < /etc/ftpusers.orig > /etc/ftpusers

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/ftpusers
		fi
	fi

	/etc/init.d/proftpd restart

#-------------------------------------------------------------------------------
# Install samba
#-------------------------------------------------------------------------------
	${CMD_AGET} install samba samba-doc
	funcPause $?

#	${CMD_AGET} install swat
#	funcPause $?

#-------------------------------------------------------------------------------
# Install rsync
#-------------------------------------------------------------------------------
	${CMD_AGET} install rsync
	funcPause $?

#-------------------------------------------------------------------------------
# Install FDclone
#-------------------------------------------------------------------------------
	${CMD_AGET} install fdclone
	funcPause $?
	#---------------------------------------------------------------------------
	cat <<- _EOT_ > .fd2rc
		LANGUAGE="utf8"
		DEFKCODE="utf8"
		INPUTKCODE="utf8"
		PTYINKCODE="utf8"
		PTYOUTKCODE="utf8"
		FNAMEKCODE="utf8"
		MESSAGE="JP"
_EOT_

	cp -p .fd2rc ~/

#-------------------------------------------------------------------------------
# Install gufw
#-------------------------------------------------------------------------------
	${CMD_AGET} install gufw
	funcPause $?

#-------------------------------------------------------------------------------
# Install mrtg
#-------------------------------------------------------------------------------
	${CMD_AGET} install mrtg hddtemp
	funcPause $?
	#---------------------------------------------------------------------------
	mkdir -p /var/www/mrtg
	touch /var/www/mrtg/index.html
	#---------------------------------------------------------------------------
	cat <<- _EOT_ > /var/www/mrtg/index.html
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<META http-equiv="Content-Style-Type" content="text/css">
		<META http-equiv="Expires" content="0">
		<META http-equiv="Pragma" content="no-cache">
		<META name="robots" content="noindex,nofollow">
		<TITLE>MRTG</TITLE>
		</HEAD>
		  <BODY>
		    <DIV><A href="diskuserate1.html">diskuserate1[rootfs]</A></DIV>
		    <DIV><A href="diskuserate2.html">diskuserate2[/share]</A></DIV>
_EOT_
	#---------------------------------------------------------------------------
	i=2
	for str in ${DEV_RATE}
	do
		i=`expr $i + 1`
		cat <<- _EOT_ >> /var/www/mrtg/index.html
			    <DIV><A href="diskuserate${i}.html">diskuserate${i}[${str}1]</A></DIV>
_EOT_
	done
	#---------------------------------------------------------------------------
	i=0
	for str in ${DEV_TEMP}
	do
		i=`expr $i + 1`
		cat <<- _EOT_ >> /var/www/mrtg/index.html
			    <DIV><A href="hdtemp${i}.html">hdtemp${i}[${str}]</A></DIV>
_EOT_
	done
	#---------------------------------------------------------------------------
	cat <<- _EOT_ >> /var/www/mrtg/index.html
		  </BODY>
		</HTML>
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /var/www/mrtg/index.html
	fi
	#---------------------------------------------------------------------------
	if [ ! -f /etc/mrtg.cfg.orig ]; then
		#-----------------------------------------------------------------------
		cp -p /etc/mrtg.cfg /etc/mrtg.cfg.orig
		cat <<- _EOT_ >> /etc/mrtg.cfg

			Target[diskuserate1]: \`/bin/df | /bin/grep rootfs | /usr/bin/awk '{print \$5}' | /usr/bin/awk -F% '{print \$1}'\`
			MaxBytes[diskuserate1]: 100
			WithPeak[diskuserate1]: ymw
			Title[diskuserate1]: Hard Drive Use Rate
			PageTop[diskuserate1]: <H1>Hard Drive Use Rate [rootfs]</H1>
			Options[diskuserate1]: gauge, absolute, growright, noo
			Unscaled[diskuserate1]: dwmy
			YLegend[diskuserate1]: %
			ShortLegend[diskuserate1]: %
			Legend1[diskuserate1]: Hard Drive Use Rate
			Legend2[diskuserate1]:
			LegendI[diskuserate1]: Use Rate :
			LegendO[diskuserate1]:

_EOT_
		#-----------------------------------------------------------------------
		cp -p /etc/mrtg.cfg /etc/mrtg.cfg.orig
		cat <<- _EOT_ >> /etc/mrtg.cfg

			Target[diskuserate2]: \`/bin/df | /bin/grep '/share' | /usr/bin/awk '{print \$5}' | /usr/bin/awk -F% '{print \$1}'\`
			MaxBytes[diskuserate2]: 100
			WithPeak[diskuserate2]: ymw
			Title[diskuserate2]: Hard Drive Use Rate
			PageTop[diskuserate2]: <H1>Hard Drive Use Rate [/share]</H1>
			Options[diskuserate2]: gauge, absolute, growright, noo
			Unscaled[diskuserate2]: dwmy
			YLegend[diskuserate2]: %
			ShortLegend[diskuserate2]: %
			Legend1[diskuserate2]: Hard Drive Use Rate
			Legend2[diskuserate2]:
			LegendI[diskuserate2]: Use Rate :
			LegendO[diskuserate2]:

_EOT_
		#-----------------------------------------------------------------------
		i=2
		for str in ${DEV_RATE}
		do
			i=`expr $i + 1`
			cat <<- _EOT_ >> /etc/mrtg.cfg
				Target[diskuserate${i}]: \`/bin/df | /bin/grep ${str}1 | /usr/bin/awk '{print \$5}' | /usr/bin/awk -F% '{print \$1}'\`
				MaxBytes[diskuserate${i}]: 100
				WithPeak[diskuserate${i}]: ymw
				Title[diskuserate${i}]: Hard Drive Use Rate
				PageTop[diskuserate${i}]: <H1>Hard Drive Use Rate [${str}1}</H1>
				Options[diskuserate${i}]: gauge, absolute, growright, noo
				Unscaled[diskuserate${i}]: dwmy
				YLegend[diskuserate${i}]: %
				ShortLegend[diskuserate${i}]: %
				Legend1[diskuserate${i}]: Hard Drive Use Rate
				Legend2[diskuserate${i}]:
				LegendI[diskuserate${i}]: Use Rate :
				LegendO[diskuserate${i}]:

_EOT_
		done
		#-----------------------------------------------------------------------
		i=0
		for str in ${DEV_TEMP}
		do
			i=`expr $i + 1`
			cat <<- _EOT_ >> /etc/mrtg.cfg
				Target[hdtemp${i}]: \`/usr/sbin/hddtemp ${str} | /usr/bin/awk '{print \$3}'\`
				MaxBytes[hdtemp${i}]: 65
				WithPeak[hdtemp${i}]: ymw
				Title[hdtemp${i}]: Hard Drive Temperature
				PageTop[hdtemp${i}]: <H1>Hard Drive Temperature [${str}]</H1>
				Options[hdtemp${i}]: nopercent, gauge, absolute, unknaszero, growright, noo
				Unscaled[hdtemp${i}]: dwmy
				YLegend[hdtemp${i}]: Celcius
				ShortLegend[hdtemp${i}]: C
				Legend1[hdtemp${i}]: Hard Drive Temperature in Degrees Celcius
				Legend2[hdtemp${i}]:
				LegendI[hdtemp${i}]: Temp :
				LegendO[hdtemp${i}]:

_EOT_
		done
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi -c "set list" -c "set listchars=tab:>_" /etc/mrtg.cfg
		fi
	fi

#-------------------------------------------------------------------------------
# Install bind9
#-------------------------------------------------------------------------------
	${CMD_AGET} install bind9
	funcPause $?
	#---------------------------------------------------------------------------
	cat <<- _EOT_ > /var/cache/bind/${WGP_NAME}.zone
		\$TTL 3600
		\$ORIGIN ${WGP_NAME}.
		@				IN	SOA	${SVR_NAME}. root.${SVR_NAME}. (
		 					1
		 					1800
		 					900
		 					86400
		 					1200 )
		 				IN	NS	${SVR_NAME}
		 				IN	NS	${GWR_NAME}
		 				IN	NS	google-public-dns-a.google.com
		 				IN	NS	google-public-dns-b.google.com
		${SVR_NAME}			IN	A	${SVR_IPAD}.${SVR_ADDR}
		${GWR_NAME}			IN	A	${SVR_IPAD}.${GWR_ADDR}
		google-public-dns-a.google.com	IN	A	8.8.8.8
		google-public-dns-b.google.com	IN	A	8.8.4.4
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /var/cache/bind/${WGP_NAME}.zone
	fi
	#---------------------------------------------------------------------------
	cat <<- _EOT_ > /var/cache/bind/${WGP_NAME}.rev
		\$TTL 3600
		\$ORIGIN 1.168.192.in-addr.arpa.
		@				IN	SOA	${SVR_NAME}.${WGP_NAME}. root.${SVR_NAME}.${WGP_NAME}. (
		 					1
		 					1800
		 					900
		 					86400
		 					1200 )
		 				IN	NS	${SVR_NAME}.${WGP_NAME}.
		 				IN	NS	${GWR_NAME}.${WGP_NAME}.
		 				IN	NS	google-public-dns-a.google.com
		 				IN	NS	google-public-dns-b.google.com
		${SVR_ADDR}			IN	PTR	${SVR_NAME}.${WGP_NAME}.
		${GWR_ADDR}			IN	PTR	${GWR_NAME}.${WGP_NAME}.
		8.8.8.8				IN	PTR	google-public-dns-a.google.com
		8.8.4.4				IN	PTR	google-public-dns-b.google.com
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /var/cache/bind/${WGP_NAME}.rev
	fi
	#---------------------------------------------------------------------------
	cat <<- _EOT_ >> /etc/bind/named.conf.local
		zone "${WGP_NAME}" {
		 	type master;
		 	file "${WGP_NAME}.zone";
		 	allow-update { lan; };
		};

		zone "1.168.192.in-addr.arpa" {
		 	type master;
		 	file "${WGP_NAME}.rev";
		 	allow-update { lan; };
		};
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /etc/bind/named.conf.local
	fi
	#---------------------------------------------------------------------------
	cat <<- _EOT_ >> /etc/bind/named.conf.options
		acl lan {
		 	127.0.0.1;
		 	${SVR_IPAD}.0/24;
		};
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /etc/bind/named.conf.options
	fi
	/etc/init.d/bind9 restart

#-------------------------------------------------------------------------------
# Install dhcp
#-------------------------------------------------------------------------------
	${CMD_AGET} install isc-dhcp-server
	funcPause $?
	#---------------------------------------------------------------------------
	cat <<- _EOT_ > /etc/dhcp/dhcpd.conf
		subnet ${SVR_IPAD}.0 netmask 255.255.255.0 {
		 	option time-servers ntp.nict.jp;
		 	option domain-name-servers ${SVR_IPAD}.${SVR_ADDR}, ${SVR_IPAD}.${GWR_ADDR}, 8.8.8.8, 8.8.4.4;
		 	option domain-name "${WGP_NAME}";
		 	range ${ADR_DHCP};
		 	option routers ${SVR_IPAD}.${GWR_ADDR};
		 	option subnet-mask 255.255.255.0;
		 	option broadcast-address ${SVR_IPAD}.255;
		 	option netbios-dd-server ${SVR_IPAD}.${SVR_ADDR};
		 	default-lease-time 3600;
		 	max-lease-time 86400;
		}

_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi -c "set list" -c "set listchars=tab:>_" /etc/dhcp/dhcpd.conf
	fi

	if [ ${FLG_DHCP} -ne 0 ]; then
		insserv -d isc-dhcp-server
		/etc/init.d/isc-dhcp-server start
	else
		/etc/init.d/isc-dhcp-server stop
		insserv -r isc-dhcp-server
	fi

#-------------------------------------------------------------------------------
# Install Webmin
#-------------------------------------------------------------------------------
	${CMD_AGET} install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
	funcPause $?

	while :
	do
		if [ -f "${DIR_WK}/${SET_WMIN}" ]; then
			break
		fi

		if [ "${SET_WMIN}" = "webmin-current.deb" ]; then
			wget "http://www.webmin.com/download/deb/webmin-current.deb"
		else
			wget "http://prdownloads.sourceforge.net/webadmin/${SET_WMIN}"
		fi
		sleep 1s
	done

	if [ "${SET_WMIN}" = "webmin-current.deb" ]; then
		dpkg -i webmin-current.deb
	else
		dpkg -i webmin_${VER_WMIN}_all.deb
	fi
	#---------------------------------------------------------------------------
	if [ ! -f /etc/webmin/config.orig ]; then
		cp -p /etc/webmin/config /etc/webmin/config.orig
		cat <<- _EOT_ >> /etc/webmin/config
			webprefix=
			lang_root=ja_JP.UTF-8
_EOT_
#		vi -c "set list" -c "set listchars=tab:>_" /etc/webmin/config
	fi
	#---------------------------------------------------------------------------
	if [ ! -f /etc/webmin/time/config.orig ]; then
		cp -p /etc/webmin/time/config /etc/webmin/time/config.orig
		cat <<- _EOT_ >> /etc/webmin/time/config
			timeserver=ntp.nict.jp
_EOT_
#		vi -c "set list" -c "set listchars=tab:>_" /etc/webmin/time/config
	fi

	/etc/init.d/webmin restart

#------------------------------------------------------------------------------
# Setup Login User
#------------------------------------------------------------------------------
	while read LINE
	do
		USERNAME=`echo ${LINE} | awk -F : '{print $1;}' | tr '[A-Z]' '[a-z]'`
		FULLNAME=`echo ${LINE} | awk -F : '{print $2;}'`
		USERIDNO=`echo ${LINE} | awk -F : '{print $3;}'`
		PASSWORD=`echo ${LINE} | awk -F : '{print $4;}'`
		# Account name to be deleted ------------------------------------------
		id ${USERNAME}
		if [ $? -eq 0 ]; then
			chown -R ${USERNAME}:${USERNAME} /share/data/usr/${USERNAME}
			userdel -r ${USERNAME}
			rm -Rf /share/data/usr/${USERNAME}
		fi
		# Add users -----------------------------------------------------------
		useradd -m -c "${FULLNAME}" -G ${WWW_DATA} -u ${USERIDNO} ${USERNAME}
		# Make user dir -------------------------------------------------------
		mkdir -p /share/data/usr/${USERNAME}
		mkdir -p /share/data/usr/${USERNAME}/app
		mkdir -p /share/data/usr/${USERNAME}/dat
		mkdir -p /share/data/usr/${USERNAME}/web
		mkdir -p /share/data/usr/${USERNAME}/web/public_html
		touch -f /share/data/usr/${USERNAME}/web/public_html/index.html
		# Change user dir mode ------------------------------------------------
		chmod -R 1770 /share/data/usr/${USERNAME}
		chown -R ${WWW_DATA}:${WWW_DATA} /share/data/usr/${USERNAME}
	done < ${USR_FILE}

#-------------------------------------------------------------------------------
# Setup Samba User
#-------------------------------------------------------------------------------
	SMB_PWDB=`find /var/lib/samba/ -name passdb.tdb -print`
	USR_LIST=`pdbedit -L | awk -F : '{print $1;}'`
	for USR_NAME in ${USR_LIST}
	do
		pdbedit -x -u ${USR_NAME}
	done
	pdbedit -i smbpasswd:${SMB_FILE} -e tdbsam:${SMB_PWDB}

#-------------------------------------------------------------------------------
# Add smb.conf
#-------------------------------------------------------------------------------
	if [ ! -f ${SMB_BACK} ]; then
		cp -p ${SMB_CONF} ${SMB_BACK}
		cat ${SMB_WORK} > ${SMB_CONF}
	fi

	/etc/init.d/samba restart

#-------------------------------------------------------------------------------
# Install VMware Tools
#-------------------------------------------------------------------------------
	if [ ${FLG_VMTL} -ne 0 ]; then
		${CMD_AGET} install linux-headers-`uname -r`
		funcPause $?
		#-----------------------------------------------------------------------
		VMW_CD=${MNT_CD}/VMwareTools-*.tar.gz
		while :
		do
			umount ${MNT_CD}
			echo "VMware Toolsディスクを挿入しEnterキーを押して下さい。"
			read DUMMY
			mount ${MNT_CD}
			sleep 1

			if [ -f ${VMW_CD} ]; then
				tar -xzf ${VMW_CD}
				if [ $? -eq 0 ]; then
					umount ${MNT_CD}
					break
				fi
			fi
		done
		#-----------------------------------------------------------------------
#		ORG_CC=${CC}
#		ORG_CXX=${CXX}
#		export CC=gcc-4.3
#		export CXX=cpp-4.3

		${DIR_WK}/vmware-tools-distrib/vmware-install.pl -d -f
		funcPause $?

#		export CC=${ORG_CC}
#		export CXX=${ORG_CXX}
	fi

#-------------------------------------------------------------------------------
# Cron
#-------------------------------------------------------------------------------
	cat <<- _EOT_ > ${TGZ_WORK}
		1f8b080013ee4c560003ed1c6b73d35696afd6afb815c902ed38b2649bb4
		306627c48104a284899d7619ca04632bb187c4ce587280b29e21f6268457
		cbb634b4257d2c851496e5b58502e5f55f50e424ff62cfd5c39664c99183
		1d93599d6188747deeb9e79e7befb9e76577b3e1bd5ddd07870f75f0c92d
		4d021f40672020ff0530fda57d0cc36ca1994030e8f777ee64a09da603be
		9d5b90af590ce921c70bb12c425bb2998c500b6fadcf37296cfd803a9e4a
		53c7637c92d8da6020e47f1eb1f8ad58f89758b82916ef4a572e7b7679ba
		759b4e452addf979a5f8aab45858599c060cb1f0542c3c178bb362f1177d
		7f71fabe58bc22168b62e18158b8811f8ad75412d2cc2de9dc9fd285eba8
		8fda871b3c7d038786a3404d7e191c8e96df70c3d2ab85d2dc9595b3331e
		683bd0d1276472864f4ad76e2dbdf80e3e637cb49ff27d4c31018dd7abcf
		576e17a447b74af71eabd411420a3e5260f9fc1cd200e62c9dbfac3cab5d
		6767a4fbcf713f6f1950d583e56b0dc0f42abc22385a1df87c21656e6576
		4af30f5716bf52e6a8760950b4af5617e9dce2f295d995c58bcbd71f8bd3
		d70cbd3aebef4553be7ac70a523e9aa21df7da2edd3c5ffaf6a174ff87e5
		d777caad3b30b1c30014cb52e17085d82903a0262c4c830f16b115bdbd7a
		e9edd5b31bfc4f1eb720cdfd585af859ba34af485d6ebcda0266880e742c
		91caa663131c6af31da340ad740fb2ece000562ba3b974bc2f9d12501bdd
		627189454579fdde6a716d458a7e9466e6c4e239b1f0ab58fc0fd6a34578
		fd37d652f27121408623e1bea111aca243d4c94cf604d57606371e18dc3b
		d217ce83743b9486eee1a191c30136dccb46f2987cb56a56a78c1783e578
		3e36c621924511b49f44a41d3649101327605d91771229e368dce4d11e44
		25b8292a9d1b1f47cc9ebfd0c4504fb43b1c6afb2b41a446d111c0971bf2
		c89b863d71263a34dc934747770b492e4d780c5cf4a02134045cd41089a2
		2397418f3c7bb6fca4b0f4e7ec768dfe0e92f06427907754e5b0bffbe0c8
		bebefe1e0b0e3ddc29bc0bcfecebea8ff4e489d114414ce6f8640251d5b8
		20c3ba447504eeeea324f4922f716cc878e35f8c22d22436eaf8891140e8
		10c6be203d1e121ee10f1e10fd1d091c87bc316d1a83fb956910f52dd911
		4e88031f6b7301782a171e129ed766a35e812433139c438960d43233f8a5
		f1dc8ca78e3b640630b5e581c7c6739299141c7202981a27f0d8e88d82cd
		68473b0523965707bf345e26bcf3d3c3eb8e0fefe8fcd4cd0c379e4ae74e
		39e547c1565822d537b2e13c256359a7a749c62d8b08bf344146d929a7dc
		64a7cabc64a79ac0c969de2927a7f93227a7f9c67392e3b30e39014c8d13
		786cf4c10692149f7474b40115b68b8e17e8d8f0bd3b15732a17c0d47881
		c7b5e53299994c585cdd0ed9530c09b2c536a9c245ab0d522cb29e748250
		2d24d95a235a1d11f9ff02bdcfd4ac31d688ffd14c305015fff377baf1bf
		8d8056c5ff2a8eba65fc4f9a79b47af6074d3f353bbca7c6bf364978af76
		acce36bc576fa0ce0db919f632b1d5f1e04e5944ea2ed709aef1a3c8511f
		bc52cb4fae947e5a5087c1576dc847c8318910130c62b4dec14874a08bed
		91be9a975e5f93c3405a53e85832c30b38d0764c89f358458f2addb079d5
		170ee98373b8db81c1bda82facc353024aa163a07d381511ec2e9e4b202f
		87b6f1d4e71d1d1fb651d436b9f7f257afa585db700c4bdf17141adbf1c6
		62d970b8b7976523911d842926050cc40430c63e6a3fdc3ed19e68ef6d67
		db23642d62ea2eededddc5b2bbf414c35dd19e91681f96449926d53e41b5
		27507befae76769789f0f505a0fdf61ff3bac962329ff5f41c1c1918ac10
		3949aa020539be94a5b9765ceeb3c1a183214a9898c43dbb0ef58bc57baa
		8da957b4f544fafa71a00f6c5f6a3c133f01c6784dc286de5adc2ba433ac
		fbb15d5d1531c4a4491de1c2c3fa581cdcafb13866e4b0f0b0067baad56e
		606f70bf057bd5014de0784c667838b2177308963c8c50786e38aec0c308
		3b101de91fa04324359116a81c7f9c2675ed4ca59dd1b7fb2bed7e7d7ba0
		d21e2095bdb128ef8d3fe0ffe5af1f4a378a86cbd114031f8e0ca9576b82
		1b6da2d25a9dbfd15ca585a3e678f3bd9027ff4cdd2cf29c9d5f0316a475
		6edaf61de80ce1818d191b476c64ff48241a09b5d1fa96e8dfa2a1368620
		3c561a435d0015bd4e4de1e1e2c98ce68e1afae5916173ca416d95bb3c3a
		8a76a9afc05a9eb4f752658fd994a87917b919e487f32a7ae145fa0f61d6
		b1f0b0a856e72f4abf5d342da029fc1e89760d45e5f03be64ce941cabd85
		6c6c52132d7e46db94403b698ab493553ef86ea43a94bb9129d43f80c278
		ac974fa5b93f54077c3732c4e5b7211a31c88fe8a0cc8474f387d5739757
		9e3c952e7e2b16a7c5c26f8a26243c729ac1929da3bb919267b04934e848
		6a41008f2939e0c1d9010fdefc169a57b5e93ce5e48849e7560b040498c9
		c5930e4447782a8914cfda9914eb19d6e0da3689e2388ba2494ae95a9694
		b2536aef352d18b33afda5f4e50bf5f2397f61f5fb9be58413505a7a73bf
		74ef5738e0e2f4257af5eca3d5f96f965edc5a7a7601ac7bb9ec40578550
		f85ae94f78281cbec21ed4682a9d40a66b8604e161c54c565d371fcab70b
		f24e0829f8fca320183ca7b8b812ac522472268f3edfdd9c75aa9683edf2
		a852fe2c9612b433298f0a33520f3d4cf28310226db7bf26fc4a0730f0e2
		d2eb19f0f8f0faf3e31c87f37cdaa7bc1d01657c69f632280b8db32c27e4
		b2e972e848567afad05623349eaaf340ad282acfe6746a1bc2a9b2522e15
		99d7dabbb7acbd542b5e0d1f42efd2dc0bb170413a7bd35a106c2697161a
		2807e5eac444f5ba5fb35cc23d9fea2ecf8a3d7350b94015b5299f10dd67
		7930e778e1a351209a70b083f43d95e9959ecd89d36f603b70e33c071d8f
		8f9f48190601b62cd59dfe1cd53c481a4b4e7812a71f48f7be0333013c5f
		71fab5387d5d2c7c239e2d18359ecaaaf34956b494c733811b9009cb627a
		86f939d11436bac28a1f7b655e9e9bf3c955ae427ca495ff8c675bd5f86e
		64b819d0cd86f70df5447abbfbbbd86685806bc77f7d411f439be3bf9d01
		b7fe7343a055f15ffda6b32b01bd21167f978def45393c701757848221a6
		65d264a7fca5589cdb8800b16f27e5fb643304887d1f53be20c57cfcbed6
		7fba6165c311712b39dfba959c758b0b7c10c7dab16609669d54c006a538
		214ea560393a12547c3c36119bf28e66393e899f112f642651edf289772e
		d8b4e4599a5e28ddbb6167982a56a97309a8d454cb145ba31537bf3cd78d
		98a66109d63b3b2311fda46a2f652c2bb4662d67b52859a39673d61476c3
		9377cb6fdcf21b17b0ffc70e0e0f449b58feb396ff1760fc55fe9fdff5ff
		36065ae5ff699bceb6fca7b4705ecd0b834552782047e07fc25a1dabf7b9
		0dad0ca2776e06c74fe3f57d75fca01743318ceb2ebecb8972ddc5b7aebb
		58b7b8d42a78b9e4609bc04d4c66b2b1ec6974329b12382424b399dc5872
		1bda83b37087234adae4533abfae6eccfabaf9d7d72d604e745572548624
		10ccc6947e80063b5cc68ccbd8e3facdb87e7bdc8019171a5c3fc4f5435a
		0aa03a87228707ba5b68ff77d2413fd8ff3b193f43770634fbdfe7daff1b
		01adb2ffb54de7c0fed7d585b6e6e73fd4944ae766f002d691fef17da264
		b76cbb28779958fc51b166b0fb0556f6f5c7e5eed8b0b77707ecba5362e1
		8d5cf1f25f791dadca8075c3c018be4e8a0eda0e23ef633e89bc7b50794b
		8bd3770d34fc940fdc10bf2d8d406f38bc7cf5b6653786b677426caa0557
		debc922efc5221125cafafb5813fcd42db6f9d667b683231fceb308e59d8
		9ee54fa7e362f19f62f18e5c4505bbe98debf635d84a74ddbebac4f51eb9
		7deaf705acbeb180ebf5cc2e12a12fdbab7297f01bae6c8d0c7587484af9
		8a7fb9311c8986ccb57d2aca3b7868ea97be1dfa68b6d8965e9a2db6b59f
		2667b83e705cc26899ee5a7af323ae0f9c999347150bb765b5f5121db1a5
		78f49d7e67061735ab235ad852c5978a15a0ae8ba942535dd4bcdd9c8c35
		7d1a36627171ba569559235167d5ad52e7a82f713732d39482682b66d6aa
		587752536f59b3ee581cc66ca5d18abe841572cddf56b2c62675a9ec5426
		9d8a73c81b477e546e549ad288fea4d2265fb2c81b9b42de5eb80513dc38
		270092973b151fcf25b850d522e93ed21f0e1d1ee8903c55356fd2946f26
		4d0967b20119e72ac1ac27cb5c4dc4cd2ceb6f1e37a2b359006ca8e143f8
		bb672dfbfd075f20d889e33fc140e74e3a10d07eff21e8c67f36025a15ff
		296f3abbe2dfa795df7f6d4dcd6f508e37f83643d047e3d571d0c7758adf
		f9a2759de2bac4f51e39c56bea96da15b38e3aebedecd8a4e01de304949b
		94bf10bee175a3478c0c1c6d481d691551ab62590dc77b1ad0c6b2b1446b
		672f73d0f0e9ab54d7987f22c50bded60b41cf4683256124edfa437aa5e3
		fa432eb8e0820b2eb8e0820b2eb8e0820b2eb8e0820b2eb8e0820b2e6c2c
		fc0f3c98eb9900780000
_EOT_

	pushd /usr/sh
	xxd -r -p ${TGZ_WORK} | tar -xz
	funcPause $?
	ls -al
	popd

#-------------------------------------------------------------------------------
# Cron
#-------------------------------------------------------------------------------
	cat <<- _EOT_ > ${CRN_FILE}
		SHELL = /bin/bash
		PATH = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		# @reboot /sbin/sysctl -p
		0 0,3,6,9,12,15,18,21 * * * /usr/sbin/ntpdate -s ntp.nict.jp
		# @reboot /usr/sh/CMDMOUNT.sh
		@reboot /usr/sh/CMDBACKUP.sh
		0 1 * * * /usr/sh/CMDUPDATE.sh
		# 0 2 * * * /usr/sh/CMDFRESHCLAM.sh
		# 0 3 * * * /usr/sh/CMDRSYNC.sh
_EOT_

	crontab ${CRN_FILE}

#-------------------------------------------------------------------------------
# GRUB
#-------------------------------------------------------------------------------
	if [ ! -f /etc/default/grub.orig ]; then
		cp -p /etc/default/grub /etc/default/grub.orig

#		sed "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"${VGA_MODE}\"/" < /etc/default/grub.orig > /etc/default/grub.temp
#		sed "s/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=${VGA_RESO}/" < /etc/default/grub.temp > /etc/default/grub
#		rm /etc/default/grub.temp

		sed "s/#GRUB_GFXMODE=640x480/GRUB_GFXPAYLOAD_LINUX=${VGA_RESO}\nGRUB_GFXMODE=${VGA_RESO}/" < /etc/default/grub.orig > /etc/default/grub

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/default/grub
		fi

		update-grub
	fi

#-------------------------------------------------------------------------------
# Disable IPv6
#-------------------------------------------------------------------------------
	if [ ! -f /etc/sysctl.conf.orig ]; then
		cp -p /etc/sysctl.conf /etc/sysctl.conf.orig

		cat <<- _EOT_ >> /etc/sysctl.conf
			# -----------------------------------------------------------------------------
			# Disable IPv6
			net.ipv6.conf.all.disable_ipv6 = 1
			net.ipv6.conf.default.disable_ipv6 = 1
			net.ipv6.conf.lo.disable_ipv6 = 1
			# -----------------------------------------------------------------------------
_EOT_
	fi

	sysctl -p
	ifconfig

#-------------------------------------------------------------------------------
# Backup
#-------------------------------------------------------------------------------
	pushd /
	tar -czf /work/bk_etc.tgz    etc
#	tar -czf /work/bk_home.tgz   home
	tar -czf /work/bk_share.tgz  share
	tar -czf /work/bk_usr_sh.tgz usr/sh
	tar -czf /work/bk_cron.tgz   var/spool/cron/crontabs
	popd

#-------------------------------------------------------------------------------
# RADI Status
#-------------------------------------------------------------------------------
	if [ -f /proc/mdstat ]; then
		cat /proc/mdstat
	fi

#-------------------------------------------------------------------------------
# Termination
#-------------------------------------------------------------------------------
	rm -f ${TGZ_WORK}
	rm -f ${CRN_FILE}
	rm -f ${USR_FILE}
	rm -f ${SMB_FILE}
	rm -f ${SMB_WORK}
	popd

#-------------------------------------------------------------------------------
# Exit
#-------------------------------------------------------------------------------
	exit 0

#-------------------------------------------------------------------------------
# End of file
#-------------------------------------------------------------------------------
