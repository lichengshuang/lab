#!/bin/bash
# =============================================================================
mkdir x
cd x
zcat ../initrd.gz | cpio -if -
# -----------------------------------------------------------------------------
mv preseed.cfg preseed.cfg.orig
cat <<- _EOT_ > preseed.cfg
	# *****************************************************************************
	# Contents of the preconfiguration file (for wheezy) : GLANTANK
	# *****************************************************************************
	  d-i lowmem/low note
	# d-i debconf/priority select high
	# == Network configuration ====================================================
	  d-i netcfg/choose_interface select eth0
	  d-i netcfg/use_autoconfig boolean false
	  d-i netcfg/disable_autoconfig boolean true
	  d-i netcfg/disable_dhcp boolean true
	# -- IPv4 ---------------------------------------------------------------------
	  d-i netcfg/get_ipaddress string 192.168.1.1
	  d-i netcfg/get_netmask string 255.255.255.0
	  d-i netcfg/get_gateway string 192.168.1.254
	  d-i netcfg/get_nameservers string 192.168.1.1 192.168.1.254 8.8.8.8 8.8.4.4
	  d-i netcfg/confirm_static boolean true
	# -- IPv6 ---------------------------------------------------------------------
	# d-i netcfg/get_ipaddress string fc00::2
	# d-i netcfg/get_netmask string ffff:ffff:ffff:ffff::
	# d-i netcfg/get_gateway string fc00::1
	# d-i netcfg/get_nameservers string fc00::1
	# d-i netcfg/confirm_static boolean true
	# -- Host name and Domain name ------------------------------------------------
	  d-i netcfg/get_hostname string sv-server
	  d-i netcfg/get_domain string workgroup
	# == Network console ==========================================================
	  d-i network-console/password string install
	  d-i network-console/password-again string install
	# == Mirror settings ==========================================================
	# d-i mirror/protocol string ftp
	  d-i mirror/country string JP
	  d-i mirror/http/hostname string ftp.jp.debian.org
	  d-i mirror/http/directory string /debian/
	  d-i mirror/http/proxy string
	# -- Suite to install. --------------------------------------------------------
	# d-i mirror/suite string testing
	# d-i mirror/udeb/suite string testing
	# == Localization =============================================================
	  d-i debian-installer/language string ja
	  d-i debian-installer/locale string ja_JP.UTF-8
	  d-i debian-installer/country string JP
	# == Account setup ============================================================
	  d-i passwd/root-login boolean true
	  d-i passwd/make-user boolean true
	# -- Root password, either in clear text --------------------------------------
	  d-i passwd/root-password password root
	  d-i passwd/root-password-again password root
	# d-i passwd/root-password-crypted password [MD5 hash]
	# -- To create a normal user account. -----------------------------------------
	  d-i passwd/user-fullname string Master
	  d-i passwd/username string master
	# -- Normal user's password, either in clear text -----------------------------
	  d-i passwd/user-password password master
	  d-i passwd/user-password-again password master
	# d-i passwd/user-password-crypted password [MD5 hash]
	# -- Create the first user with the specified UID instead of the default. -----
	# d-i passwd/user-uid string 1010
	# -- The user account will be added to some standard initial groups. ----------
	# d-i passwd/user-default-groups string audio cdrom video
	# == Clock and time zone setup ================================================
	  d-i clock-setup/utc boolean true
	  d-i time/zone string Asia/Tokyo
	# -- Controls whether to use NTP to set the clock during the install ----------
	  d-i clock-setup/ntp boolean true
	# -- NTP server to use. The default is almost always fine here. ---------------
	  d-i clock-setup/ntp-server string ntp.nict.jp
	# == Partitioning =============================================================
	# d-i partman-auto/init_automatically_partition select biggest_free
	# -----------------------------------------------------------------------------
	  d-i partman-auto/disk string /dev/sda
	# d-i partman-auto/disk string /dev/sda /dev/sdb
	# d-i partman-auto/disk string /dev/sda /dev/sdb /dev/sdc /dev/sdd
	# -----------------------------------------------------------------------------
	  d-i partman-auto/method string regular
	# d-i partman-auto/method string lvm
	# d-i partman-auto/method string crypto
	# d-i partman-auto/method string raid
	# -----------------------------------------------------------------------------
	  d-i partman-lvm/device_remove_lvm boolean true
	  d-i partman-md/device_remove_md boolean true
	  d-i partman-lvm/confirm boolean true
	  d-i partman-lvm/confirm_nooverwrite boolean true
	# -----------------------------------------------------------------------------
	# d-i partman-auto/choose_recipe select atomic
	# d-i partman-auto/choose_recipe select home
	# d-i partman-auto/choose_recipe select multi
	# -----------------------------------------------------------------------------
	# d-i partman-auto/expert_recipe_file string /hd-media/recipe
	# -- Partitioning using RAID --------------------------------------------------
	#   /boot  :  256MB : ext2 : /dev/sda1 : ext2  : /dev/sd[a  ]1
	#   swap   :  512MB : swap : /dev/sda5 : swap  : /dev/sd[a  ]5
	#   /      :  ~ end : ext4 : /dev/sda6 : raid1 : /dev/sd[a-b]6
	  d-i partman-auto/expert_recipe string \\
	    boot-root :: \\
	        256 1   256 ext2 \$primary{ } \$bootable{ } method{ format } format{ } use_filesystem{ } filesystem{ ext2 } mountpoint{ /boot  } . \\
	        512 2  300% swap \$logical{ }              method{ swap   } format{ }                                                           . \\
	      10240 3    -1 ext4 \$logical{ }              method{ format } format{ } use_filesystem{ } filesystem{ ext4 } mountpoint{ /      } .
	# d-i partman-auto/expert_recipe string \
	#   multiraid :: \\
	#       256 1   256 ext2 \$primary{ } \$bootable{ } method{ format } format{ } use_filesystem{ } filesystem{ ext2 } mountpoint{ /boot  } . \\
	#       512 2  300% swap \$logical{ }              method{ swap   } format{ }                                                           . \\
	#     10240 3    -1 raid \$logical{ }              method{ raid   } format{ } use_filesystem{ } filesystem{ ext4 } mountpoint{ /      } .
	# d-i partman-auto-raid/recipe string \\
	#   1 2 0 ext2 /boot  /dev/sda1#/dev/sdb1 .
	#   1 2 0 swap -      /dev/sda5#/dev/sdb5 . \\
	#   1 2 0 ext4 /      /dev/sda6#/dev/sdb6 .
	# d-i partman-md/confirm boolean true
	# -- This makes partman automatically partition without confirmation. ---------
	  d-i partman-partitioning/confirm_write_new_label boolean true
	  d-i partman/choose_partition select finish
	  d-i partman/confirm boolean true
	  d-i partman/confirm_nooverwrite boolean true
	# -- Controlling how partitions are mounted -----------------------------------
	# d-i partman/mount_style select uuid
	# == Base system installation =================================================
	# d-i base-installer/install-recommends boolean false
	# d-i base-installer/kernel/image string linux-image-amd64
	# == Apt setup ================================================================
	# d-i apt-setup/non-free boolean true
	# d-i apt-setup/contrib boolean true
	# d-i apt-setup/use_mirror boolean false
	# d-i apt-setup/services-select multiselect security, updates
	# d-i apt-setup/security_host string security.debian.org
	# -- Additional repositories, local[0-9] available ----------------------------
	# d-i apt-setup/local0/repository string http://local.server/debian stable main
	# d-i apt-setup/local0/comment string local server
	# d-i apt-setup/local0/source boolean true
	# d-i apt-setup/local0/key string http://local.server/key
	# -----------------------------------------------------------------------------
	# d-i debian-installer/allow_unauthenticated boolean true
	# == Package selection ========================================================
	# tasksel tasksel/first multiselect standard, web-server
	# tasksel tasksel/desktop multiselect kde, xfce
	  tasksel tasksel/first multiselect standard
	  d-i pkgsel/include string openssh-server
	# -- Individual additional packages to install --------------------------------
	  d-i pkgsel/upgrade select none
	# -----------------------------------------------------------------------------
	  popularity-contest popularity-contest/participate boolean false
	# =============================================================================
	# d-i grub-installer/skip boolean true
	# d-i lilo-installer/skip boolean true
	  d-i grub-installer/only_debian boolean true
	# d-i grub-installer/with_other_os boolean true
	# d-i grub-installer/only_debian boolean false
	# d-i grub-installer/with_other_os boolean false
	# d-i grub-installer/bootdev string (hd0,0)
	# d-i grub-installer/bootdev string (hd0,0) (hd1,0) (hd2,0)
	# d-i grub-installer/bootdev string /dev/sda
	# d-i grub-installer/bootdev string /dev/sda /dev/sdb
	# d-i grub-installer/bootdev string /dev/sda /dev/sdb /dev/sdc /dev/sdd
	# d-i grub-installer/password password r00tme
	# d-i grub-installer/password-again password r00tme
	# d-i grub-installer/password-crypted password [MD5 hash]
	# d-i debian-installer/add-kernel-opts string nousb
	# == Finishing up the installation ============================================
	# d-i finish-install/keep-consoles boolean true
	  d-i finish-install/reboot_in_progress note
	  d-i cdrom-detect/eject boolean true
	  d-i debian-installer/exit/halt boolean false
	  d-i debian-installer/exit/poweroff boolean false
	# == Preseeding other packages ================================================
	# d-i debhelper debconf-utils
	#   debconf-get-selections --installer > file.txt
	#   debconf-get-selections >> file.txt
	# == Advanced options =========================================================
	# d-i preseed/early_command string anna-install some-udeb
	# d-i partman/early_command string debconf-set partman-auto/disk "\$(list-devices disk | head -n1)"
	# d-i preseed/late_command string apt-install zsh; in-target chsh -s /bin/zsh
	# == End Of File ==============================================================
_EOT_
vi preseed.cfg
cp -p preseed.cfg ..
# -----------------------------------------------------------------------------
find | cpio --quiet -o -H newc > ../i
cd ..
gzip -9 i
mv i.gz initrd
ls -l
# -----------------------------------------------------------------------------
# umount /dev/sda1
# mkfs.ext2 /dev/sda1
# -----------------------------------------------------------------------------
# mount /dev/sda1 /mnt
# cp -p initrd      /mnt
# cp -p preseed.cfg /mnt
# cp -p zImage      /mnt
# ls -l /mnt
# umount /dev/sda1
# -----------------------------------------------------------------------------
# reboot
# =============================================================================
