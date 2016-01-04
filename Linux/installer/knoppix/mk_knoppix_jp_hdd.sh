#!/bin/bash
# *****************************************************************************
# ** 日本語版KNOPPIXの作成(KNOPPIX_V7.6.0DVD-2015-11-21-EN.iso対応:HDD作業版)**
# *****************************************************************************

# =============================================================================
# == KNOPPIXの準備                                                           ==
# =============================================================================

  cd ~
  wget "http://ftp.uni-kl.de/pub/linux/knoppix-dvd/KNOPPIX_V7.6.0DVD-2015-11-21-EN.iso"
  mkdir -p /media/knoppix/mounted
  mkdir -p /media/knoppix/compressed
  mount -o loop KNOPPIX_V7.6.0DVD-2015-11-21-EN.iso /media/knoppix/mounted
  losetup /dev/cloop2 /media/knoppix/mounted/KNOPPIX/KNOPPIX
  mount /dev/cloop2 /media/knoppix/compressed

# =============================================================================
# == KNOPPIXの展開                                                           ==
# =============================================================================

# -- 作業用ディレクトリの作成 -------------------------------------------------
  rm -rf ~/source
  rm -rf ~/master
  mkdir -p ~/source/KNOPPIX
  mkdir -p ~/master/KNOPPIX/KNOPPIX

# -- 展開 ---------------------------------------------------------------------
  rsync -aH                             /media/knoppix/compressed/* ~/source/KNOPPIX
  rsync -aH --exclude="KNOPPIX/KNOPPIX" /media/knoppix/mounted/*    ~/master/KNOPPIX

# =============================================================================
# == ネットワークの設定                                                      ==
# =============================================================================

# -- IPアドレスの確認 ---------------------------------------------------------
  ifconfig

# =============================================================================
# == スリム化                                                                ==
# =============================================================================

# -- ルート変更の準備 ---------------------------------------------------------
  mount --bind /dev     ~/source/KNOPPIX/dev
  mount -t proc proc    ~/source/KNOPPIX/proc
  mount -t sysfs sysfs  ~/source/KNOPPIX/sys
  mount --bind /dev/pts ~/source/KNOPPIX/dev/pts
  mount --bind /tmp     ~/source/KNOPPIX/tmp

# -- ルート変更 ---------------------------------------------------------------
  chroot ~/source/KNOPPIX

# -- apt-getの準備 ------------------------------------------------------------
  cp -p /etc/resolv.conf /etc/resolv.conf.orig
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf
  echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# -- 不要なアプリの検討 -------------------------------------------------------
  dpkg-query -W --showformat='${Installed-Size} ${Package}\n' | sort -n

# -- 不要なアプリの削除 -------------------------------------------------------
  apt-get -y remove --purge wine1.7 gcompris* linux-source-4.2.2 etoys*
  apt-get -y autoremove

# -- 不要なロケールデータの削除 -----------------------------------------------
  du -k /usr/share/locale/
  pushd /usr/share/locale/
  rm -rf be* bg* cs* da* de* es* fi* fr* he* hi* hu* it* nl* pl* ru* sk* sl* tr* zh*
  popd
  du -k /usr/share/locale/
  localedef --list-archive
  localedef --list-archive | grep -v -e ^ja -e ^en_GB -e en_US | xargs localedef --delete-from-archive
  localedef --list-archive

# =============================================================================
# == 日本語化                                                                ==
# =============================================================================

# -- 最新のパッケージリストを取得 ---------------------------------------------
  apt-get update

# -- 日本語フォントのインストール ---------------------------------------------
  apt-get -y install ttf-kochi-gothic

# -- 日本語キーボードレイアウト設定 -------------------------------------------
# cat /etc/xdg/lxsession/LXDE/autostart
  echo "@setxkbmap -layout jp -option ctrl:swapcase" >> /etc/xdg/lxsession/LXDE/autostart
# cat /etc/xdg/lxsession/LXDE/autostart

# -- 日本語入力システムのインストール -----------------------------------------
  apt-get -y install uim-anthy uim im-config
  im-config -n uim
  update-alternatives --auto uim-toolbar
  mkdir -p /home/knoppix/.xinput.d
  pushd /home/knoppix/.xinput.d
  ln -s /etc/X11/xinit/xinput.d/ja_JP ja_JP
  chown -R knoppix.knoppix /home/knoppix/.xinput.d
  popd

# -- Libreoffice日本語化 ------------------------------------------------------
  wget "http://www.nic.funet.fi/index/Debian/pool/main/libr/libreoffice/libreoffice-l10n-ja_5.0.2-1_all.deb"
  dpkg -i ./libreoffice-l10n-ja_5.0.2-1_all.deb
  rm -f ./libreoffice-l10n-ja_5.0.2-1_all.deb

# =============================================================================
# == 後片付け                                                                ==
# =============================================================================

# -- DNS参照設定を解除 --------------------------------------------------------
  mv -f /etc/resolv.conf.orig /etc/resolv.conf

# -- 不要ファイルの削除 -------------------------------------------------------
  exit
  for i in dev/pts proc sys dev tmp; do
    umount ~/source/KNOPPIX/$i
  done
  rm -f  ~/source/KNOPPIX/root/.bash_history
  rm -f  ~/source/KNOPPIX/root/.viminfo
  rm -rf ~/source/KNOPPIX/tmp/*
  rm -rf ~/source/KNOPPIX/var/cache/apt/*.bin
  rm -rf ~/source/KNOPPIX/var/cache/apt/archives/*.deb

# -- 起動オプションの修正 -----------------------------------------------------
# cat ~/master/KNOPPIX/boot/isolinux/isolinux.cfg
  cat ~/master/KNOPPIX/boot/isolinux/isolinux.cfg | sed "s/lang=en/lang=ja/" | sed "s/tz=localtime/tz=Asia\/Tokyo/" > ./isolinux.cfg.temp
  mv -f ./isolinux.cfg.temp ~/master/KNOPPIX/boot/isolinux/isolinux.cfg
# cat ~/master/KNOPPIX/boot/isolinux/isolinux.cfg

# =============================================================================
# == イメージ作成                                                            ==
# =============================================================================

# -- 圧縮ファイルの作成 -------------------------------------------------------
  mkisofs -quiet -allow-limited-size -R -U -V "KNOPPIX7.6.0JP" -hide-rr-moved -cache-inodes -no-bak -pad ~/source/KNOPPIX | create_compressed_fs -q -B 65536 -t 8 -L 9 -f ~/isotemp - ~/master/KNOPPIX/KNOPPIX/KNOPPIX
  ls -al ~/master/KNOPPIX/KNOPPIX/KNOPPIX

# -- ISOイメージの作成 --------------------------------------------------------
  pushd ~/master/KNOPPIX
  mkisofs -quiet -no-emul-boot -boot-load-size 4 -boot-info-table -l -r -J -V "KNOPPIX7.6.0JP" -hide-rr-moved -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o ../KNOPPIX_V7.6.0DVD-2015-11-21-JP.iso .
  popd

# =============================================================================
# == EOF                                                                     ==
# =============================================================================
