#!/bin/bash
# =============================================================================
  cd ~
  rm -rf ~/glantank
  mkdir -p ~/glantank
  cd ~/glantank
# -----------------------------------------------------------------------------
  wget -O preseed.cfg "https://raw.githubusercontent.com/office-itou/lab/master/Linux/installer/glantank/preseed.cfg.standard.glantank.raid1"
# wget -O preseed.cfg "https://raw.githubusercontent.com/office-itou/lab/master/Linux/installer/glantank/preseed.cfg.standard.glantank.raid5"
  wget                "http://ftp.riken.jp/Linux/debian/debian/dists/wheezy/main/installer-armel/current/images/iop32x/network-console/glantank/initrd.gz"
# wget                "http://ftp.riken.jp/Linux/debian/debian/dists/wheezy/main/installer-armel/current/images/iop32x/network-console/glantank/preseed.cfg"
  wget                "http://ftp.riken.jp/Linux/debian/debian/dists/wheezy/main/installer-armel/current/images/iop32x/network-console/glantank/zImage"
# -----------------------------------------------------------------------------
  mkdir -p ~/glantank/install
  cd ~/glantank/install
  zcat ../initrd.gz | cpio -if -
  cp -p ~/glantank/preseed.cfg .
  find | cpio --quiet -o -H newc | gzip -9 > ../initrd
# -----------------------------------------------------------------------------
  cd ~/glantank
  ls -al
# -----------------------------------------------------------------------------
  exit 0
# = eof =======================================================================
