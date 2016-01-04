#!/bin/bash
################################################################################
##
##	ファイル名	:	addusers.sh
##
##	機能概要	:	ユーザー追加用シェル
##
##	入出力 I/F
##		INPUT	:	
##		OUTPUT	:	
##
##	作成者		:	J.Itou
##
##	作成日付	:	2015/02/20
##
##	改訂履歴	:	
##	   日付       版         名前      改訂内容
##	---------- -------- -------------- -----------------------------------------
##	2015/02/20 000.0000 J.Itou         新規作成
##	YYYY/MM/DD 000.0000 xxxxxxxxxxxxxx 
##	---------- -------- -------------- -----------------------------------------
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

	# ワーク変数設定 -----------------------------------------------------------
	NOW_TIME=`date +"%Y%m%d%H%M%S"`
	PGM_NAME=`basename $0 | sed -e 's/\..*$//'`

	DST_NAME=`awk '/[A-Za-z]./ {print $1;}' /etc/issue | head -n 1 | tr '[A-Z]' '[a-z]'`

	DIR_WK=/work

	USR_FILE=${DIR_WK}/${PGM_NAME}.sh.usr.list
	SMB_FILE=${DIR_WK}/${PGM_NAME}.sh.smb.list

	WWW_DATA=www-data

	# ワーク・ディレクトリーの変更 --------------------------------------------
	pushd ${DIR_WK}

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

#------------------------------------------------------------------------------
# Termination
#------------------------------------------------------------------------------
	rm -f ${USR_FILE}
	rm -f ${SMB_FILE}
	popd

#------------------------------------------------------------------------------
# Exit
#------------------------------------------------------------------------------
	exit 0

#------------------------------------------------------------------------------
# End of file
#------------------------------------------------------------------------------
