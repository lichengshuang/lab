#!/bin/bash
###############################################################################
##
##	ファイル名	:	install.sh
##
##	機能概要	:	Debian & Ubuntu Install用シェル [VMware対応]
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
##	---------- -------- -------------- ----------------------------------------
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
##	2015/12/26 000.0000 J.Itou         処理見直し(locale-gen見直し)
##	2016/01/03 000.0000 J.Itou         処理見直し(freshclam.conf,crontabs見直し)
##	2016/01/05 000.0000 J.Itou         処理見直し(DNSにOPEN DNSを追加)
##	2016/01/13 000.0000 J.Itou         処理見直し(clamav-freshclam見直し)
##	2016/02/10 000.0000 J.Itou         処理見直し(samba見直し)
##	2016/02/11 000.0000 J.Itou         処理見直し(ユーザー登録ファイル見直し)
##	2016/02/12 000.0000 J.Itou         処理見直し(debian版とubuntu版、各vnware版の統合)
##	2016/02/17 000.0000 J.Itou         処理見直し(apt-get installの一括処理)
##	2016/02/25 000.0000 J.Itou         処理見直し(sed見直し)
##	2016/03/03 000.0000 J.Itou         処理見直し(色々と見直し)
##	2016/03/14 000.0000 J.Itou         処理見直し(色々と見直し)
##	YYYY/MM/DD 000.0000 xxxxxxxxxxxxxx 
###############################################################################
#set -nvx

# Pause処理 -------------------------------------------------------------------
funcPause() {
	RET_STS=$1

	if [ ${RET_STS} -ne 0 ]; then
		echo "Enterキーを押して下さい。"
		read DUMMY
	fi
}

#------------------------------------------------------------------------------
# Initialize
#------------------------------------------------------------------------------
	DBG_FLAG=${DBG_FLAG:-0}
	if [ ${DBG_FLAG} -ne 0 ]; then
		set -vx
	fi

	# ユーザー環境に合わせて変更する部分 --------------------------------------
	SVR_IPAD=192.168.1							# 本機の属するプライベート・アドレス
	SVR_ADDR=1									# 本機のIPアドレス
	SVR_NAME=`hostname`							# 本機の名前
	GWR_ADDR=254								# ゲートウェイのIPアドレス
	GWR_NAME=gw-router							# ゲートウェイの名前
	WGP_NAME=workgroup							# 本機の属するワークグループ名
	NUM_HDDS=1									# インストール先のHDD台数
	FLG_DHCP=0									# DHCP自動起動フラグ(0以外で自動起動)
	ADR_DHCP="${SVR_IPAD}.64 ${SVR_IPAD}.79"	# DHCPの提供アドレス範囲
#	FLG_VMTL=1									# 0以外でVMware Toolsをインストール
	DEF_USER=master								# インストール時に作成したユーザー名
	FLG_AUTO=1									# 0以外でpreseed.cfgの環境を使う
	FLG_VIEW=0									# 0以外でデバッグ用に設定ファイルを開く
	FLG_SVER=1									# 0以外でサーバー仕様でセッティング
#	VER_WMIN=1.791								# webminの最新バージョンを登録
#	VGA_MODE="vga=792"							# コンソールの解像度：1024×768：1600万色
#	VGA_RESO=1024x768							#   〃              ：
	VGA_MODE="vga=795"							#   〃              ：1280×1024：1600万色
	VGA_RESO=1280x1024x32						#   〃              ：
	# ワーク変数設定 ----------------------------------------------------------
	NOW_TIME=`date +"%Y%m%d%H%M%S"`
	PGM_NAME=`basename $0 | sed -e 's/\..*$//'`

	DST_NAME=`awk '/[A-Za-z]./ {print $1;}' /etc/issue | head -n 1 | tr '[A-Z]' '[a-z]'`

	if [ ${SVR_NAME} = "" ]; then
		if [ ${FLG_SVER} -ne 0 ]; then
			SVR_NAME=sv-${DST_NAME}
		else
			SVR_NAME=ws-${DST_NAME}
		fi
	fi

	if [ "`echo ${PGM_NAME} | grep -i vmware`" = "" ]; then
		FLG_VMTL=0								# 0以外でVMware Toolsをインストール
	else
		FLG_VMTL=1								# 0以外でVMware Toolsをインストール
	fi

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
			lucid        ) SET_DIST="${TARGET}"; break ;;	# ubuntu 10.04
			precise      ) SET_DIST="${TARGET}"; break ;;	# ubuntu 12.04
			trusty       ) SET_DIST="${TARGET}"; break ;;	# ubuntu 14.04
			utopic       ) SET_DIST="${TARGET}"; break ;;	# ubuntu 14.10
			vivid        ) SET_DIST="${TARGET}"; break ;;	# ubuntu 15.04
			wily         ) SET_DIST="${TARGET}"; break ;;	# ubuntu 15.10
			xenial       ) SET_DIST="${TARGET}"; break ;;	# ubuntu 16.04
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
	LST_USER=${DIR_WK}/addusers.txt
	LOG_FILE=${DIR_WK}/${PGM_NAME}.sh.${NOW_TIME}.log
	TGZ_WORK=${DIR_WK}/${PGM_NAME}.sh.tgz
	CRN_FILE=${DIR_WK}/${PGM_NAME}.sh.crn
	USR_FILE=${DIR_WK}/${PGM_NAME}.sh.usr.list
	SMB_FILE=${DIR_WK}/${PGM_NAME}.sh.smb.list
	SMB_WORK=${DIR_WK}/${PGM_NAME}.sh.smb.work
	SMB_CONF=/etc/samba/smb.conf
	SMB_BACK=${SMB_CONF}.orig
	SMB_USER=sambauser
	SMB_GRUP=sambashare

	DEV_NUM1=sda
	DEV_NUM2=sdb
	DEV_NUM3=sdc
	DEV_NUM4=sdd
	DEV_NUM5=sde
	DEV_NUM6=sdf
	DEV_NUM7=sdg
	DEV_NUM8=sdh

	case "${NUM_HDDS}" in
		# HDD 1台 -------------------------------------------------------------
		1 )	DEV_HDD1=/dev/${DEV_NUM1}
			DEV_HDD2=
			DEV_HDD3=
			DEV_HDD4=

			DEV_USB1=/dev/${DEV_NUM2}
			DEV_USB2=/dev/${DEV_NUM3}
			DEV_USB3=/dev/${DEV_NUM4}
			DEV_USB4=/dev/${DEV_NUM5}
			;;
		# HDD 2台 -------------------------------------------------------------
		2 )	DEV_HDD1=/dev/${DEV_NUM1}
			DEV_HDD2=/dev/${DEV_NUM2}
			DEV_HDD3=
			DEV_HDD4=

			DEV_USB1=/dev/${DEV_NUM3}
			DEV_USB2=/dev/${DEV_NUM4}
			DEV_USB3=/dev/${DEV_NUM5}
			DEV_USB4=/dev/${DEV_NUM6}
			;;
		# HDD 4台 ~ -----------------------------------------------------------
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

	CMD_AGET="apt-get -y -q"
#	CMD_AGET="aptitude -y"

#------------------------------------------------------------------------------
# Make work dir
#------------------------------------------------------------------------------
	mkdir -p ${DIR_WK}
	chmod 700 ${DIR_WK}
	pushd ${DIR_WK}

#------------------------------------------------------------------------------
# System Update
#------------------------------------------------------------------------------
	if [ ! -f /etc/apt/sources.list.orig ]; then
		sed -i.orig /etc/apt/sources.list \
			-e 's/^deb/# deb/'

		case "${DST_NAME}" in
			debian )
				cat <<- _EOT_ >> /etc/apt/sources.list
					#------------------------------------------------------------------------------
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
					#------------------------------------------------------------------------------
_EOT_
				;;
			ubuntu )
				cat <<- _EOT_ >> /etc/apt/sources.list
					#------------------------------------------------------------------------------
					deb     http://security.ubuntu.com/ubuntu    ${SET_DIST}-security  main restricted universe multiverse
					deb-src http://security.ubuntu.com/ubuntu    ${SET_DIST}-security  main restricted universe multiverse

					deb     http://jp.archive.ubuntu.com/ubuntu/ ${SET_DIST}           main restricted universe multiverse
					deb-src http://jp.archive.ubuntu.com/ubuntu/ ${SET_DIST}           main restricted universe multiverse

					deb     http://jp.archive.ubuntu.com/ubuntu/ ${SET_DIST}-updates   main restricted universe multiverse
					deb-src http://jp.archive.ubuntu.com/ubuntu/ ${SET_DIST}-updates   main restricted universe multiverse

					deb     http://jp.archive.ubuntu.com/ubuntu/ ${SET_DIST}-backports main restricted universe multiverse
					deb-src http://jp.archive.ubuntu.com/ubuntu/ ${SET_DIST}-backports main restricted universe multiverse
					#------------------------------------------------------------------------------
_EOT_
				;;
		esac
	fi

	${CMD_AGET} update
	${CMD_AGET} upgrade
	${CMD_AGET} dist-upgrade

#------------------------------------------------------------------------------
# Application Install
#------------------------------------------------------------------------------
	${CMD_AGET} install	locales \
						build-essential kernel-package libncurses5-dev fuse uuid-runtime \
						clamav \
						ntpdate \
						ssh \
						apache2 \
						proftpd \
						samba smbclient \
						rsync \
						fdclone \
						gufw \
						mrtg hddtemp \
						bind9 \
						isc-dhcp-server \
						perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python \
						linux-headers-`uname -r`

	funcPause $?
#
#------------------------------------------------------------------------------
# Make User file (${DIR_WK}/addusers.txtが有ればそれを使う)
#------------------------------------------------------------------------------
	rm -f ${USR_FILE}
	rm -f ${SMB_FILE}
	touch ${USR_FILE}
	touch ${SMB_FILE}

	if [ ! -f ${LST_USER} ]; then
		# Make User List File -------------------------------------------------
		cat <<- _EOT_ > ${USR_FILE}
			Administrator:Administrator:1001:
_EOT_

		# Make Samba User List File (pdbedit -L -w にて出力されたもの) --------
		cat <<- _EOT_ > ${SMB_FILE}
			administrator:1001:E52CAC67419A9A224A3B108F3FA6CB6D:8846F7EAEE8FB117AD06BDD830B7586C:[U          ]:LCT-56BC0BA1:
_EOT_
	else
		while read LINE
		do
			USERNAME=`echo ${LINE} | awk -F : '{print $1;}' | tr '[A-Z]' '[a-z]'`
			FULLNAME=`echo ${LINE} | awk -F : '{print $2;}'`
			USERIDNO=`echo ${LINE} | awk -F : '{print $3;}'`
			PASSWORD=`echo ${LINE} | awk -F : '{print $4;}'`
			LMPASSWD=`echo ${LINE} | awk -F : '{print $5;}'`
			NTPASSWD=`echo ${LINE} | awk -F : '{print $6;}'`
			ACNTFLAG=`echo ${LINE} | awk -F : '{print $7;}'`
			CHNGTIME=`echo ${LINE} | awk -F : '{print $8;}'`

			echo "${USERNAME}:${FULLNAME}:${USERIDNO}:${PASSWORD}"                          >> ${USR_FILE}
			echo "${USERNAME}:${USERIDNO}:${LMPASSWD}:${NTPASSWD}:${ACNTFLAG}:${CHNGTIME}:" >> ${SMB_FILE}
		done < ${LST_USER}
	fi

#------------------------------------------------------------------------------
# Locale Setup
#------------------------------------------------------------------------------
	if [ ! -f ~/.vimrc ]; then
		cat <<- _EOT_ > ~/.vimrc
			set number
			set tabstop=4
			set list
			set listchars=tab:>_
_EOT_
	fi

	if [ ! -f ~/.bashrc.orig ]; then
#		${CMD_AGET} install locales
#		funcPause $?
#		dpkg-reconfigure locales
#		funcPause $?
#		locale-gen
#		funcPause $?
#		update-locale LANG=ja_JP.UTF-8
#		funcPause $?
		timedatectl set-timezone "Asia/Tokyo"
		funcPause $?
		localectl set-locale LANG="ja_JP.utf8" LANGUAGE="ja:en"
		funcPause $?
		localectl set-x11-keymap "jp" "jp106" "" "terminate:ctrl_alt_bksp"
		funcPause $?
		locale | sed -e 's/LANG=C/LANG=ja_JP.UTF-8/' \
					 -e 's/LANGUAGE=$/LANGUAGE=ja:en/' \
					 -e 's/"C"/"ja_JP.UTF-8"/' > /etc/locale.conf
		funcPause $?
		#----------------------------------------------------------------------
		cp -p ~/.bashrc ~/.bashrc.orig
		cat <<- _EOT_ >> ~/.bashrc
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
			vi ~/.bashrc
		fi
		. ~/.profile
	fi

#------------------------------------------------------------------------------
# Network Setup
#------------------------------------------------------------------------------
	# hostname ----------------------------------------------------------------
	if [ ! -f /etc/hostname.orig ]; then
		cp -p /etc/hostname /etc/hostname.orig

		if [ ${FLG_AUTO} -eq 0 ]; then
			cat <<- _EOT_ > /etc/hostname
				${SVR_NAME}
_EOT_
			if [ ${FLG_VIEW} -ne 0 ]; then
				vi /etc/hostname
			fi
			hostname -b ${SVR_NAME}
			# hosts -----------------------------------------------------------
			if [ ! -f /etc/hosts.orig ]; then
				cp -p /etc/hosts /etc/hosts.orig
				cat <<- _EOT_ > /etc/hosts
					${SVR_IPAD}.${SVR_ADDR}	${SVR_NAME}.${WGP_NAME}	${SVR_NAME}
					#------------------------------------------------------------------------------
					# 127.0.1.1	${SVR_NAME}.${WGP_NAME}	${SVR_NAME}
_EOT_
				cat /etc/hosts.orig >> /etc/hosts
				vi /etc/hosts
			fi
			# interfaces ------------------------------------------------------
			if [ ! -f /etc/network/interfaces.orig ]; then
				cp -p /etc/network/interfaces /etc/network/interfaces.orig
				cat <<- _EOT_ >> /etc/network/interfaces
					#------------------------------------------------------------------------------
					# The primary network interface
					# allow-hotplug eth0
					# iface eth0 inet dhcp
					#------------------------------------------------------------------------------
					# The primary network interface
					# allow-hotplug eth0
					# iface eth0 inet static
					#	address ${SVR_IPAD}.${SVR_ADDR}
					#	netmask 255.255.255.0
					#	network ${SVR_IPAD}.0
					#	broadcast ${SVR_IPAD}.255
					#	gateway ${SVR_IPAD}.${GWR_ADDR}
					#	# dns-* options are implemented by the resolvconf package, if installed
					#	dns-nameservers ${SVR_IPAD}.${SVR_ADDR} ${SVR_IPAD}.${GWR_ADDR} 8.8.8.8 8.8.4.4 208.67.222.123 208.67.220.123
					#	dns-search ${WGP_NAME}
					#------------------------------------------------------------------------------
_EOT_
				vi /etc/network/interfaces
			fi
			# networks --------------------------------------------------------
			if [ ! -f /etc/networks.orig ]; then
				cp -p /etc/networks /etc/networks.orig
				cat <<- _EOT_ >> /etc/networks
					localnet	${SVR_IPAD}.0
_EOT_
				vi /etc/networks
			fi
		fi
	fi
	# resolv.conf -------------------------------------------------------------
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
				nameserver 208.67.222.123
				nameserver 208.67.220.123
_EOT_
		else
			cat <<- _EOT_ > /etc/resolv.conf
				domain ${WGP_NAME}
_EOT_
			cat /etc/resolv.conf.orig >> /etc/resolv.conf
		fi
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/resolv.conf
		fi
	fi
	# hosts.allow -------------------------------------------------------------
	if [ ! -f /etc/hosts.allow.orig ]; then
		cp -p /etc/resolv.conf /etc/hosts.allow.orig
		cat <<- _EOT_ >> /etc/hosts.allow
			ALL: 127.0.0.1 ${SVR_IPAD}.
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/hosts.allow
		fi
	fi
	# hosts.deny --------------------------------------------------------------
	if [ ! -f /etc/hosts.deny.orig ]; then
		cp -p /etc/resolv.conf /etc/hosts.deny.orig
		cat <<- _EOT_ >> /etc/hosts.deny
			ALL: ALL
_EOT_
		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/hosts.deny
		fi
	fi

#------------------------------------------------------------------------------
# Make Samba Configure File
#------------------------------------------------------------------------------
	cat <<- _EOT_ > ${SMB_WORK}
		# Samba config file created using SWAT
		# from ${SVR_NAME} (${SVR_IPAD}.${SVR_ADDR})
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
		 	logon script = logon.bat
		 	logon drive = U:
		 	domain logons = Yes
		 	dns proxy = No
		 	usershare allow guests = Yes
		 	panic action = /usr/share/samba/panic-action %d
		 	idmap config * : backend = tdb
		 	force user = ${SMB_USER}
		 	force group = ${SMB_GRUP}
		 	create mask = 0770
		 	force create mode = 0770
		 	directory mask = 0770
		 	force directory mode = 0770
		 	hosts allow = 127., ${SVR_IPAD}.
		 	hosts deny = ALL

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

		[netlogon]
		 	comment = Network Logon Service
		 	path = /share/data/adm/netlogon

		[profiles]
		 	comment = Users profiles
		 	path = /share/data/adm/profiles
		 	read only = No
		 	browseable = No

		[cdrom]
		 	comment = Samba server's CD-ROM
		 	path = /mnt/cdrom
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/cdrom
		 	postexec = /bin/umount /mnt/cdrom

		[share]
		 	comment = Shared directories
		 	path = /share
		 	browseable = No

		[data]
		 	comment = Data directories
		 	path = /share/data
		 	read only = No
		 	browseable = No

		[usb]
		 	comment = USB devices directories
		 	path = /share/usb
		 	read only = No
		 	browseable = No

		[wizd]
		 	comment = Wizd directories
		 	path = /share/wizd
		 	read only = No
		 	browseable = No

		[pub]
		 	comment = Public directories
		 	path = /share/data/pub

		[web]
		 	comment = User Directries (web files)
		 	path = /share/data/usr/%U/web
		 	read only = No
		 	browseable = No

		[app]
		 	comment = User Directries (applications)
		 	path = /share/data/usr/%U/app
		 	read only = No
		 	browseable = No

		[dat]
		 	comment = User Directries (data files)
		 	path = /share/data/usr/%U/dat
		 	read only = No
		 	browseable = No

		[usb1]
		 	comment = Samba server's USB1
		 	path = /mnt/usb1
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb1
		 	postexec = /bin/umount /mnt/usb1

		[usb2]
		 	comment = Samba server's USB2
		 	path = /mnt/usb2
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb2
		 	postexec = /bin/umount /mnt/usb2

		[usb3]
		 	comment = Samba server's USB3
		 	path = /mnt/usb3
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb3
		 	postexec = /bin/umount /mnt/usb3

		[usb4]
		 	comment = Samba server's USB4
		 	path = /mnt/usb4
		 	read only = No
		 	browseable = No
		 	locking = No
		 	preexec = /bin/mount /mnt/usb4
		 	postexec = /bin/umount /mnt/usb4
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi ${SMB_WORK}
	fi

#	touch -f /share/data/adm/netlogon/logon.bat

#------------------------------------------------------------------------------
# Make share dir
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Move home dir
#------------------------------------------------------------------------------
	cat /etc/group | grep ${SMB_GRUP}
	if [ $? -ne 0 ]; then
		groupadd --system "${SMB_GRUP}"
	fi

	id ${SMB_USER}
	if [ $? -ne 0 ]; then
		useradd --system "${SMB_USER}" --groups "${SMB_GRUP}"
	fi

	mv /home/* /share/data/usr/

	useradd -D -b /share/data/usr
	usermod -d /share/data/usr/${DEF_USER} ${DEF_USER}
	usermod ${DEF_USER} -G sambashare
	usermod -L ${DEF_USER}

	usermod root -G sambashare

#	rmdir /home

#------------------------------------------------------------------------------
# Make usb dir
#------------------------------------------------------------------------------
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
	#--------------------------------------------------------------------------
	if [ ! -f /etc/fstab.orig ]; then
		cp -p /etc/fstab /etc/fstab.orig
		unexpand -a -t 4 /etc/fstab.orig > /etc/fstab
		cat <<- _EOT_ >> /etc/fstab
			# additional devices --------------------------------------------------------------------------------------------------
			# <file system>									<mount point>	<type>			<options>				<dump>	<pass>
			# /dev/sr0										/media/cdrom0	udf,iso9660		rw,user,noauto			0		0
			# /dev/fd0										/media/floppy0	auto			rw,user,noauto			0		0
			# /dev/sr0										/mnt/cdrom		udf,iso9660		rw,user,noauto			0		0
			# /dev/fd0										/mnt/floppy		auto			rw,user,noauto			0		0
			# ${DEV_USB1}1										/mnt/usb1		auto			rw,user,noauto			0		0
			# ${DEV_USB2}1										/mnt/usb2		auto			rw,user,noauto			0		0
			# ${DEV_USB3}1										/mnt/usb3		auto			rw,user,noauto			0		0
			# ${DEV_USB4}1										/mnt/usb4		auto			rw,user,noauto			0		0
_EOT_
		vi /etc/fstab
	fi

#------------------------------------------------------------------------------
# Make floppy dir
#------------------------------------------------------------------------------
	if [ ! -d /media/floppy0 ]; then
		pushd /media
		mkdir floppy0
		ln -s floppy0 floppy
		popd
	fi

#------------------------------------------------------------------------------
# Make cd-rom dir
#------------------------------------------------------------------------------
	if [ ! -d /media/cdrom0 ]; then
		pushd /media
		mkdir cdrom0
		ln -s cdrom0 cdrom
		popd
	fi

#------------------------------------------------------------------------------
# Setup share dir
#------------------------------------------------------------------------------
	chmod -R 770 /share/.
	chown -R ${SMB_USER}:${SMB_GRUP} /share/.

#------------------------------------------------------------------------------
# Make shell dir
#------------------------------------------------------------------------------
	mkdir -p /usr/sh
	mkdir -p /var/log/sh

	cat <<- _EOT_ > /usr/sh/USRCOMMON.def
		#!/bin/bash
		###############################################################################
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
		##	---------- -------- -------------- ----------------------------------------
		##	2013/10/27 000.0000 J.Itou         新規作成
		##	2014/11/04 000.0000 J.Itou         4HDD版仕様変更
		##	2014/12/22 000.0000 J.Itou         処理見直し
		##	`date +"%Y/%m/%d"` 000.0000 J.Itou         自動作成
		##	YYYY/MM/DD 000.0000 xxxxxxxxxxxxxx 
		##	---------- -------- -------------- ----------------------------------------
		###############################################################################

		#------------------------------------------------------------------------------
		# ユーザー変数定義
		#------------------------------------------------------------------------------

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
		vi /usr/sh/USRCOMMON.def
	fi

#------------------------------------------------------------------------------
# Install kernel compilers
#------------------------------------------------------------------------------
#	${CMD_AGET} install build-essential kernel-package libncurses5-dev fuse uuid-runtime
#	funcPause $?
#
#------------------------------------------------------------------------------
# Install clamav
#------------------------------------------------------------------------------
#	${CMD_AGET} install clamav
#	funcPause $?
#
	if [ ! -f /etc/clamav/freshclam.conf.orig ]; then
		sed -i.orig /etc/clamav/freshclam.conf \
			-e 's/# Check for new database 24 times a day/# Check for new database 4 times a day/' \
			-e 's/Checks 24/Checks 4/' \
			-e 's/^NotifyClamd/#&/'

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/clamav/freshclam.conf
		fi
	fi

	/etc/init.d/clamav-freshclam stop
	freshclam -d
	freshclam
	/etc/init.d/clamav-freshclam start

#	service clamav-freshclam stop
#	/etc/init.d/clamav-freshclam stop
#	update-rc.d clamav-freshclam disable
#	service --status-all | grep clamav-freshclam

#------------------------------------------------------------------------------
# Install ntpdate
#------------------------------------------------------------------------------
#	${CMD_AGET} install ntpdate
#	funcPause $?
#
#------------------------------------------------------------------------------
# Install ssh
#------------------------------------------------------------------------------
#	${CMD_AGET} install ssh
#	funcPause $?
	#---------------------------------------------------------------------------
	if [ ! -f /etc/ssh/sshd_config.orig ]; then
		sed -i.orig /etc/ssh/sshd_config \
			-e '$a UseDNS no'

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/ssh/sshd_config
		fi
	fi

	/etc/init.d/ssh restart

#------------------------------------------------------------------------------
# Install apache2
#------------------------------------------------------------------------------
#	${CMD_AGET} install apache2
#	funcPause $?
#
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
			vi /etc/apache2/mods-available/userdir.conf
		fi
	fi

	a2enmod userdir
	/etc/init.d/apache2 restart

#------------------------------------------------------------------------------
# Install proftpd
#------------------------------------------------------------------------------
#	${CMD_AGET} install proftpd
#	funcPause $?
	#--------------------------------------------------------------------------
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
			vi /etc/proftpd/proftpd.conf
		fi
	fi
	#--------------------------------------------------------------------------
	if [ ! -f /etc/ftpusers.orig ]; then
		sed -i.orig /etc/ftpusers \
			-e 's/root/# &/' \
			-e '$a master'

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/ftpusers
		fi
	fi

	/etc/init.d/proftpd restart

#------------------------------------------------------------------------------
# Install samba
#------------------------------------------------------------------------------
#	${CMD_AGET} install samba samba-doc
#	funcPause $?
#
#	${CMD_AGET} install swat
#	funcPause $?
#
#------------------------------------------------------------------------------
# Install rsync
#------------------------------------------------------------------------------
#	${CMD_AGET} install rsync
#	funcPause $?
#
#------------------------------------------------------------------------------
# Install FDclone
#------------------------------------------------------------------------------
#	${CMD_AGET} install fdclone
#	funcPause $?
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

#------------------------------------------------------------------------------
# Install gufw
#------------------------------------------------------------------------------
#	${CMD_AGET} install gufw
#	funcPause $?
#
#------------------------------------------------------------------------------
# Install mrtg
#------------------------------------------------------------------------------
#	${CMD_AGET} install mrtg hddtemp
#	funcPause $?
	#--------------------------------------------------------------------------
	mkdir -p /var/www/mrtg
	touch /var/www/mrtg/index.html
	#--------------------------------------------------------------------------
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
	#--------------------------------------------------------------------------
	i=2
	for str in ${DEV_RATE}
	do
		i=`expr $i + 1`
		cat <<- _EOT_ >> /var/www/mrtg/index.html
			    <DIV><A href="diskuserate${i}.html">diskuserate${i}[${str}1]</A></DIV>
_EOT_
	done
	#--------------------------------------------------------------------------
	i=0
	for str in ${DEV_TEMP}
	do
		i=`expr $i + 1`
		cat <<- _EOT_ >> /var/www/mrtg/index.html
			    <DIV><A href="hdtemp${i}.html">hdtemp${i}[${str}]</A></DIV>
_EOT_
	done
	#--------------------------------------------------------------------------
	cat <<- _EOT_ >> /var/www/mrtg/index.html
		  </BODY>
		</HTML>
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi /var/www/mrtg/index.html
	fi
	#--------------------------------------------------------------------------
	if [ ! -f /etc/mrtg.cfg.orig ]; then
		#----------------------------------------------------------------------
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
		#----------------------------------------------------------------------
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
		#----------------------------------------------------------------------
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
		#----------------------------------------------------------------------
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
			vi /etc/mrtg.cfg
		fi
	fi

#------------------------------------------------------------------------------
# Install bind9
#------------------------------------------------------------------------------
#	${CMD_AGET} install bind9
#	funcPause $?
	#--------------------------------------------------------------------------
	cat <<- _EOT_ > /var/cache/bind/${WGP_NAME}.zone
		\$TTL 3600
		\$ORIGIN ${WGP_NAME}.
		@								IN		SOA		${SVR_NAME}. root.${SVR_NAME}. (
		 										1
		 										1800
		 										900
		 										86400
		 										1200 )
		 								IN		NS		${SVR_NAME}
		 								IN		NS		${GWR_NAME}
		 								IN		NS		google-public-dns-a.google.com
		 								IN		NS		google-public-dns-b.google.com
		 								IN		NS		resolver1-fs.opendns.com
		 								IN		NS		resolver2-fs.opendns.com
		${SVR_NAME}						IN		A		${SVR_IPAD}.${SVR_ADDR}
		${GWR_NAME}						IN		A		${SVR_IPAD}.${GWR_ADDR}
		google-public-dns-a.google.com	IN		A		8.8.8.8
		google-public-dns-b.google.com	IN		A		8.8.4.4
		resolver1-fs.opendns.com		IN		A		208.67.222.123
		resolver2-fs.opendns.com		IN		A		208.67.220.123
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi /var/cache/bind/${WGP_NAME}.zone
	fi
	#--------------------------------------------------------------------------
	cat <<- _EOT_ > /var/cache/bind/${WGP_NAME}.rev
		\$TTL 3600
		\$ORIGIN 1.168.192.in-addr.arpa.
		@								IN		SOA		${SVR_NAME}.${WGP_NAME}. root.${SVR_NAME}.${WGP_NAME}. (
		 										1
		 										1800
		 										900
		 										86400
		 										1200 )
		 								IN		NS		${SVR_NAME}.${WGP_NAME}.
		 								IN		NS		${GWR_NAME}.${WGP_NAME}.
		 								IN		NS		google-public-dns-a.google.com
		 								IN		NS		google-public-dns-b.google.com
		 								IN		NS		resolver1-fs.opendns.com
		 								IN		NS		resolver2-fs.opendns.com
		${SVR_ADDR}								IN		PTR		${SVR_NAME}.${WGP_NAME}.
		${GWR_ADDR}								IN		PTR		${GWR_NAME}.${WGP_NAME}.
		8.8.8.8							IN		PTR		google-public-dns-a.google.com
		8.8.4.4							IN		PTR		google-public-dns-b.google.com
		208.67.222.123					IN		PTR		resolver1-fs.opendns.com
		208.67.220.123					IN		PTR		resolver2-fs.opendns.com
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi /var/cache/bind/${WGP_NAME}.rev
	fi
	#--------------------------------------------------------------------------
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
		vi /etc/bind/named.conf.local
	fi
	#--------------------------------------------------------------------------
	cat <<- _EOT_ >> /etc/bind/named.conf.options
		acl lan {
		 	127.0.0.1;
		 	${SVR_IPAD}.0/24;
		};
_EOT_
	if [ ${FLG_VIEW} -ne 0 ]; then
		vi /etc/bind/named.conf.options
	fi
	/etc/init.d/bind9 restart

#------------------------------------------------------------------------------
# Install dhcp
#------------------------------------------------------------------------------
#	${CMD_AGET} install isc-dhcp-server
#	funcPause $?
	#--------------------------------------------------------------------------
	cat <<- _EOT_ > /etc/dhcp/dhcpd.conf
		subnet ${SVR_IPAD}.0 netmask 255.255.255.0 {
		 	option time-servers ntp.nict.jp;
		 	option domain-name-servers ${SVR_IPAD}.${SVR_ADDR}, ${SVR_IPAD}.${GWR_ADDR}, 8.8.8.8, 8.8.4.4, 208.67.222.123, 208.67.220.123;
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
		vi /etc/dhcp/dhcpd.conf
	fi

	if [ ${FLG_DHCP} -ne 0 ]; then
#		insserv -d isc-dhcp-server
		/etc/init.d/isc-dhcp-server start
	else
		/etc/init.d/isc-dhcp-server stop
		insserv -r isc-dhcp-server
	fi

#------------------------------------------------------------------------------
# Install Webmin
#------------------------------------------------------------------------------
#	${CMD_AGET} install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
#	funcPause $?
#
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
	#--------------------------------------------------------------------------
	if [ ! -f /etc/webmin/config.orig ]; then
		cp -p /etc/webmin/config /etc/webmin/config.orig
		cat <<- _EOT_ >> /etc/webmin/config
			webprefix=
			lang_root=ja_JP.UTF-8
_EOT_
#		vi /etc/webmin/config
	fi
	#--------------------------------------------------------------------------
	if [ ! -f /etc/webmin/time/config.orig ]; then
		cp -p /etc/webmin/time/config /etc/webmin/time/config.orig
		cat <<- _EOT_ >> /etc/webmin/time/config
			timeserver=ntp.nict.jp
_EOT_
#		vi /etc/webmin/time/config
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
		useradd -m -c "${FULLNAME}" -G ${SMB_GRUP} -u ${USERIDNO} ${USERNAME}
		# Make user dir -------------------------------------------------------
		mkdir -p /share/data/usr/${USERNAME}
		mkdir -p /share/data/usr/${USERNAME}/app
		mkdir -p /share/data/usr/${USERNAME}/dat
		mkdir -p /share/data/usr/${USERNAME}/web
		mkdir -p /share/data/usr/${USERNAME}/web/public_html
		touch -f /share/data/usr/${USERNAME}/web/public_html/index.html
		# Change user dir mode ------------------------------------------------
		chmod -R 770 /share/data/usr/${USERNAME}
		chown -R ${SMB_USER}:${SMB_GRUP} /share/data/usr/${USERNAME}
	done < ${USR_FILE}

#------------------------------------------------------------------------------
# Setup Samba User
#------------------------------------------------------------------------------
	SMB_PWDB=`find /var/lib/samba/ -name passdb.tdb -print`
	USR_LIST=`pdbedit -L | awk -F : '{print $1;}'`
	for USR_NAME in ${USR_LIST}
	do
		pdbedit -x -u ${USR_NAME}
	done
	pdbedit -i smbpasswd:${SMB_FILE} -e tdbsam:${SMB_PWDB}

#------------------------------------------------------------------------------
# Add smb.conf
#------------------------------------------------------------------------------
	if [ ! -f ${SMB_BACK} ]; then
		cp -p ${SMB_CONF} ${SMB_BACK}
		cat ${SMB_WORK} > ${SMB_CONF}
	fi

	/etc/init.d/samba restart

#------------------------------------------------------------------------------
# Install VMware Tools
#------------------------------------------------------------------------------
	if [ ${FLG_VMTL} -ne 0 ]; then
#		${CMD_AGET} install linux-headers-`uname -r`
#		funcPause $?
		#----------------------------------------------------------------------
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
		#----------------------------------------------------------------------
#		ORG_CC=${CC}
#		ORG_CXX=${CXX}
#		export CC=gcc-4.3
#		export CXX=cpp-4.3

		${DIR_WK}/vmware-tools-distrib/vmware-install.pl -d -f
		funcPause $?

#		export CC=${ORG_CC}
#		export CXX=${ORG_CXX}
	fi

#------------------------------------------------------------------------------
# Cron (xxd -ps にて出力されたもの)
#------------------------------------------------------------------------------
	cat <<- _EOT_ > ${TGZ_WORK}
		1f8b0800f5cc88560003ed5c7b73d35616e75feb53dc8a6481761c59b29d
		b4306627c481a44409133bed329409c656620f899db1e440ca7a86d81b08
		af966d69680b7d2c8594b6cb6bfb00caebbba0c849bec59eab872dc99223
		073fc8aece3044ba3ef7e8778fee3df79c738fddc786f7f5f61d1c3bd4c5
		27b735897c403d8180fc17c8f497f6310cb38d6602c1a0dfdfd3cd403b4d
		077cdddb90af5980f494e3855816a16dd94c46a8c5b7d1e75b94b6bf451d
		4fa5a9e3313e496c6f3011f23f8f58fc422cfc4b2cdc128bbf48572e7b76
		7bfa74934e652afdf4dd5af17969b9b0b63c0f1c62e19158782216cf8ac5
		eff5fdc5f97b62f18a582c8a85fb62e126be285e5345480bb7a5737f4a17
		aea3416a3f6ef00c0e1f1a8b8234f966642c5abec30d2bcf6f9416afac9d
		59f040dbfb5d83422667f8a474edf6cad32fe133c647fb29dfbb1413d0b0
		5e7db276a7203dbc5dbafb9b2a1d21a4f0238556cf2f228d60ccd2f9cbca
		b5daf5ec8274ef09eee72d13aabab0bcad41585e052b82a5d585d71752c6
		5686535a7ab0b6fca93246b54b80a27db5ba48e79657af9c5d5bbeb87afd
		3771fe9aa1574ffdbd68ca57efb382948fa668c7bd764ab7ce97be7820dd
		fb7af5c54fe5d65d58d861208a65a970b822ec948150135e4c831716b11d
		bdba7ae9d5d5332dfe273fb7202d7e53baf19d746949d1badc78b50d6088
		2e742c91caa663d31ceaf01da3c0acf48db0ecc830362b13b9747c309d12
		5007dd66758945c578fdda6e756d478a7d941616c5e239b1f08358fc37b6
		a345b8fd195b2979b910a0c3f1f0e0e83836d121ea64267b82ea388d1bdf
		1fd9373e18ce8376bb9486beb1d1f1c301363cc046f2587cb56956878c5f
		06cbf17c6c9243248b22e80089483b6e9220a64fc07b45de19a43c474393
		477b1195e066a9746e6a0a317bff4213a3fdd1be70a8e3af04919a404780
		5f6ec8236f1ae6c4e9e8e8587f1e1ddd2324b934e131a0e847a3681450d4
		5089622357c18e3c7ebcfa7b61e5cfb33b35f9bb48c2939d46de0915e150
		dfc1f1fd8343fd16083ddc293c0b4fefef1d8af4e789891441cce4f86402
		51d5bca0c3ba547504f6eea324f4923771ecc878e31f4f20d2a436eaf889
		7160e812263f263d1e122ee10f7e20fa3b12380e7963da30460e28c320ea
		7b654738210e383646017c2a0a0f09d71bc3a85721c9cc34e7502398b50c
		06df341ecd54eab84330c0a9bd1eb86c3c92cc8ce01009706a48e0b2d113
		05bbd18e660a662cbf1d7cd3789df0ce570faf5b3ebca3f55337186e2a95
		ce9d728a47e1562091ea1dd9704cc958d6e96a9279cb2ac2374dd05176d6
		299aec6c194b76b60948e678a748e6f8329239bef148727cd62112e0d490
		c065a3173688a4f8a4a3a50dac305d7458a063c3e7ee6ccca95e8053c302
		971beb65263393b0d8ba1dc2531c09b2cd3ea982a2dd0e2956597f3a41a8
		1e92ecad11edce88fc7f913e666ad63336c8ffd14c305095fff3f7b8f9bf
		5650bbf27f9540dd32ff272d3c5c3ff3b5669f9a9dde53f35f5b24bd573b
		57679bdeab3751e7a6dc0c7399d8eef8e14e21227596eb14d7f8a7c8591f
		fca6567fbf52faf686fa18bcd5867c849c930831c120661b188944877bd9
		7ee9d325e9c535390da435858e2533bc80136dc7943c8f55f6a8d20dbb57
		83e1903e3987bbbd3fb20f0d86757c4a4229740cac0fa73282dfc57309e4
		e5d00e9efaa8abebed0e8ada21f75efdf48574e30e2cc3d2570545c64e3c
		b158361c1e1860d948641761ca4901809800ced83b9d873ba73b139d039d
		6c6784ac254c9da50303bb5976b75e62b837da3f1e1dc49a28cba43aa7a9
		ce04ea1cd8ddc9ee3609be7e0364bffac7926eb058cc87fdfd07c787472a
		424e92aa42418fcf646d6e9c97fb7064f4608812a66770cfde434362f1ae
		ea63ea0d6d3d99be219ce803df979acac44f80335e53b0a1b796f70ae91c
		eb21ec5757650cb1685227b8f0a03e8823073488934684850735e0a95ebb
		01dec8010b78d5094d403c29031e8becc308c1938727149e18962b601867
		87a3e343c37488a4a6d30295e38fd3a4ae9da9b433fa767fa5ddaf6f0f54
		da03a4323796e5b9f107fcbffad903e966d1b0399a72e0639151756b4d70
		134d345aeb4b379b6bb470d61c4fbea7f2e01fab93451eb3f36dc042b42e
		4cdbb90b9d263c30316353888d1c188f4423a10e5adf12fd5b34d4c11084
		c7ca62a82f4065afd35278b87832a385a3867e7964989c72525b45974747
		d16ef516a0e549fb28558e984d0735afa33783fef0b98a5e7991a143183a
		561e56d5fad245e9c78ba617684abf47a2bda35139fd8e91293d48b9b790
		8dcd68aac5d768879268274d9976b22a06df83d480720f32a5fa8751183f
		ebd92369f10f3500df830c79f91d88460cf2233a2883906e7dbd7eeef2da
		ef8fa48b5f88c579b1f0a36209098f7ccc6009e7e81ea49c33d81c34e844
		6a49008fe970c0834f073c78f25b585ed5a7f3940f474c36b75a21a0c04c
		2e9e74a03ac2533948f16c7c92623dc21aa86d0f511c9fa2689a52ba9635
		a5cc94da734d4bc6accf7f227df254dd7cce5f58ffea56f9c00924adbcbc
		57bafb032c7071fe12bd7ee6e1fad2e72b4f6faf3cbe00debd5c76a0ab42
		287ca6f4273c144e5fe1086a22954e20d3364382f2b06126abb69bb7e5dd
		0579a785147cfe4e101c9e535c5c4956291a399d471fed69ce7baad683ed
		eb51b5fc612c25686b527e2a8c485df430c8b74288b49dfe9af22b1dc0c1
		8b4b2f1620e2c3ef9f9fe2387ccea77dcadb09509e2f9dbd0cc6424396e5
		845c365d4e1dc9464f9fda6a84c5536d1e9815c5e4d9ac4e6d42383556ca
		a62263ad3d7bcbd64bf5e2d5f421f42e2d3e150b17a433b7ac15c1667269
		a1817a50b64e2c546ffb35cf25dcff816ef3acf83307950d54319bf20ad1
		7d9607778e17de9900a109073348df53195ee9f1a238ff12a60337c573d0
		f1f8d48994e12100cbd2dce9d751cd85a4417282499cbf2fddfd12dc0488
		7cc5f917e2fc75b1f0b978a660b4782a54e783ac58298f671a37201397c5
		f00ce37362296c6c85151e7b635e1e9bf3c155b642bca495ff8c6b5bb5f8
		6e66b819d4c786f78ff64706fa867ad966a5806be77f7d01a69bde4633dd
		01860e04193a88f3bf3d01b7feb325d4aefcaf7ed2d99580de148bbfcace
		f7b29c1ef80557848223a69da4c941f933b1b8d88a04b1af9bf2bdb71512
		c4be77295f9062de7d53eb3f1b97560661dd5898cf5f0f84ff9164743b0f
		8fddfacfbad4f506d57f3ab7a9350b37eb94029e6b394c4e65d2a93887bc
		71e447e546a5298de8f72a6d13598e4fc6a762104e7913316e3a93f6a633
		426a620eee2176ae2483314f6cb6c28f236b54bb84e3b58b46ab476ae713
		2b0eb1bd1a8d42545f18fbbf6e79885b1ed202029bc98e8c0d479b58feb1
		b1ffefa7cdf51f7ed7ff6f0db5cbffd7269d6df947e9c679f55c10f696c2
		7d3903fb2dde70f0ceb3d8d2ca10ba7b2b38fe1ad637d5f1875e0cc5306e
		15caebac28d7f17fe53afe75ab4bad82968f9c7708dcf44c261bcbcea193
		d994c0212199cde426933bd05e7c0a7338a2a4cd3fa0f39beac66cae9b7f
		73dd02e6838eca1985e1100046634a3f43831d2f63e665ec79fd665ebf3d
		6fc0cc0b0dae9feffaf96d25309da391c3c37d6df4ff7be8a01fe7ff193f
		43f70434ffdfe7faffada076f9ffdaa473e0ffebea02dbf3f30f6a4abd67
		2b44019b48fffbde534e376cbb287b9958fc46f16670f8055ef6f5dfcadd
		b1636f1f0ed875a7c4c24bb9e2e13ff27bb42a03d53d069ee1eba1e8a0ed
		63e479cc2791772f2a4f6971fe17830c3fe58330c4febc2030100eaf5ebd
		63d98da1ed83109b6ab1b597cfa50bdf578404371b6bb5f0a73968fba9d3
		82039da0fceb208e21ecccf273e9b858fca758fc49aea281d9f4d20dfb1a
		ec25ba615f5dea7a83c23eb55edcaa621dd76b994324425fb655152ee13b
		5cd91819ed0b9194f215ef726338120d996bbb5496d788d0d42ffd3a8cd1
		6cb92da3345b6eeb384d3e297acb71099be5b1d1cacb6f707dd8c2a2fc54
		b17047365bcfd0115b89475feb77467051abfa440b5faaf84cf102d4f762
		aad0535f6ade6e4cc69a2e8d1bb1b83859abcaab71f865d5ad52e7a62f71
		3682694a41ac15988d2a969dd4545bd62c3b5687f134d0e8455fc206b9e6
		6feb58736fea2856de649137368bbc03f834969be20460f272a7e253b904
		17aa7a49ba8ff48b43c70736244f558d9b349ddb92a6835bb20127b7558a
		d9ccc96db510f7e456bff3b8199dad42e0438d1dc2df3d6adbf7ff7d8160
		0fceff04033ddd7420a07dff3fe8e67f5a41edcaff94279d5df1e7a3caef
		7fb6a7e63328e71b7c5b21e9a361759cf47183e2d7de68dda0b82e75bd41
		41f186b6a576eda3a3ce7a3f3b362378273901e566e42f04b7bc34f18811
		c0d186942a5609d539c05523f7ce01db64369668efe865040d1fbe2a7583
		f12752bce06dbf12f4301aac09a368371ed21b1d371e72c925975c72c925
		975c72c925975c72c925975c72c925975c72c925975a47ff05d0e9b16c00
		780000
_EOT_

	pushd /usr/sh
	xxd -r -p ${TGZ_WORK} | tar -xz
	funcPause $?
	ls -al
	popd

#------------------------------------------------------------------------------
# Cron
#------------------------------------------------------------------------------
	cat <<- _EOT_ > ${CRN_FILE}
		SHELL = /bin/bash
		PATH = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		# @reboot /sbin/sysctl -p
		0 0,3,6,9,12,15,18,21 * * * /usr/sbin/ntpdate -s ntp.nict.jp
		# @reboot /usr/sh/CMDMOUNT.sh
		# @reboot /usr/sh/CMDBACKUP.sh
		# 0 1 * * * /usr/sh/CMDUPDATE.sh
		# 0 2 * * * /usr/sh/CMDFRESHCLAM.sh
		# 0 3 * * * /usr/sh/CMDRSYNC.sh
_EOT_

	crontab ${CRN_FILE}

#------------------------------------------------------------------------------
# GRUB
#------------------------------------------------------------------------------
	if [ ! -f /etc/default/grub.orig ]; then
		sed -i.orig /etc/default/grub \
			-e 's/^GRUB_CMDLINE_LINUX_DEFAULT/#&/' \
			-e "s/#GRUB_GFXMODE=640x480/GRUB_GFXPAYLOAD_LINUX=${VGA_RESO}\nGRUB_GFXMODE=${VGA_RESO}/"

		if [ ${FLG_VIEW} -ne 0 ]; then
			vi /etc/default/grub
		fi

		update-grub
	fi

#------------------------------------------------------------------------------
# Disable IPv6
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Backup
#------------------------------------------------------------------------------
	pushd /
	tar -czf /work/bk_etc.tgz    etc
#	tar -czf /work/bk_home.tgz   home
	tar -czf /work/bk_share.tgz  share
	tar -czf /work/bk_usr_sh.tgz usr/sh
	tar -czf /work/bk_cron.tgz   var/spool/cron/crontabs
	popd

#------------------------------------------------------------------------------
# RADI Status
#------------------------------------------------------------------------------
	if [ -f /proc/mdstat ]; then
		cat /proc/mdstat
	fi

#------------------------------------------------------------------------------
# Termination
#------------------------------------------------------------------------------
	rm -f ${TGZ_WORK}
	rm -f ${CRN_FILE}
	rm -f ${USR_FILE}
	rm -f ${SMB_FILE}
	rm -f ${SMB_WORK}
	popd

#------------------------------------------------------------------------------
# Exit
#------------------------------------------------------------------------------
	exit 0

###############################################################################
# memo                                                                        #
###############################################################################
# for %I in (*.*) do fc /b "%~nxI" "V:\Application\FreeWare\win32\%~nxI"
# for /d %I in ("r:\My Documents\Download\dlc\*.*") do robocopy /l /mov /xo "%~fI" "r:\My Documents\Download\update"
# apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade
#==============================================================================
# End of file                                                                 =
#==============================================================================
