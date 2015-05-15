#!/usr/bin/env ash

#######################################################################
#Purpose : setup working openWRT system with all needed tools.
#created by : br0k3ngl255
#
########################################################################

##Vars /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
storage_size=1969792

##Funcs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
userSpace(){ ## adding aliases  and color via PS1 to shell
	echo -e " 	export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\#'
			[ -x /bin/more ] || alias more=less \n
			[ -x /usr/bin/vim ] && alias vi=vim || alias vim=vi \n
			[ -x /bin/ls ] && alias l=ls || alias ls=l || alias ll='ls -l' ||alias 'ls -l'=ll \n
			[ -x /usr/bin/clear ] && alias cl=clear || alias clear=cl \n
			" >> /etc/profile
	}
	
softWare(){ #installing some packages
	opkg update;
	LIST='python ipython python-bzip2 python-expat python-json python-kid python-mini python-mysql python-ncurses python-openssl python-pcap\
	      python-rsfile python-sip python-smbus python-sqlite3  python-webpy python-xapian pyusb pyyaml nmap nodogsplash sslsniff sslstrip tcpdump\
	      tar wget unzip bzip2 luci git ddns-script cshark ettercap watchcat wifidog tinyproxy iptables kmod-rtl8187  kmod-rt2x00-usb kmod-rt2800-usb\
	      nginx php5-fastcgi'
	for i in $LIST;
	do 
		opkg install $i
	done
	}
	
gitInstall(){ #installing external packages
	mkdir git_tools -m 777;cd git_tools;
		wget http://www.secdev.org/projects/scapy/files/scapy-latest.tar.gz
		tar xvzf scapy-latest; cd scapy* ; python setup.py install
	}

setSwap(){ # trying to auto set swap automatically.
		testSwap=`free|grep Swap|awk '{print $2}'`
		if [ $testSwap -gt 0 ];then
			true
		elif [ $testSwap -eq 0 ];then
			checkMount=`mount |grep sda>> /dev/null;echo $?`
				if [ $checkMount == "0" ];then
					swapon /dev/sda2
						echo -e "config 'swap' \n
									option	device	'/dev/sda2' \n
									option	enabled	'1' \n
								" >> /etc/config/fstab
				else 
					echo " no swap"
					true
				fi	
		else
			true
		fi
	}
	
expandRootfs() { ## Imported from raspi config to test on openwrt auto resize the partition.
  if ! [ -h /dev/root ]; then
    whiptail --msgbox "/dev/root does not exist or is not a symlink. Don't know how to expand" 20 60 2
    return 0
  fi

  ROOT_PART=$(readlink /dev/root)
  PART_NUM=${ROOT_PART#mmcblk0p}
  if [ "$PART_NUM" = "$ROOT_PART" ]; then
    whiptail --msgbox "/dev/root is not an SD card. Don't know how to expand" 20 60 2
    return 0
  fi

  # NOTE: the NOOBS partition layout confuses parted. For now, let's only 
  # agree to work with a sufficiently simple partition layout
  if [ "$PART_NUM" -ne 2 ]; then
    whiptail --msgbox "Your partition layout is not currently supported by this tool. You are probably using NOOBS, in which case your root filesystem is already expanded anyway." 20 60 2
    return 0
  fi

  LAST_PART_NUM=$(parted /dev/sda1 -ms unit s p | tail -n 1 | cut -f 1 -d:)

  if [ "$LAST_PART_NUM" != "$PART_NUM" ]; then
    whiptail --msgbox "/dev/root is not the last partition. Don't know how to expand" 20 60 2
    return 0
  fi

  # Get the starting offset of the root partition
  PART_START=$(parted /dev/sda1 -ms unit s p | grep "^${PART_NUM}" | cut -f 2 -d:)
  [ "$PART_START" ] || return 1
  # Return value will likely be error for fdisk as it fails to reload the
  # partition table because the root fs is mounted
  fdisk /dev/sda1 <<EOF
p
d
$PART_NUM
n
p
$PART_NUM
$PART_START

p
w
EOF
  ASK_TO_REBOOT=1

  # now set up an init.d script
cat <<\EOF > /etc/init.d/resize2fs_once &&
#!/bin/sh
### BEGIN INIT INFO
# Provides:          resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5 S
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting resize2fs_once" &&
    resize2fs /dev/root &&
    rm /etc/init.d/resize2fs_once &&
    update-rc.d resize2fs_once remove &&
    log_end_msg $?
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF
  chmod +x /etc/init.d/resize2fs_once &&
  update-rc.d resize2fs_once defaults &&
  if [ "$INTERACTIVE" = True ]; then
    whiptail --msgbox "Root partition has been resized.\nThe filesystem will be enlarged upon the next reboot" 20 60 2
  fi
}	

####
#Main - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ -
####
echo " setting up ENV:"
	userSpace
		setSwap
		net_test=`ping -c 1 8.8.8.8 >>/dev/null;echo $?`
			if [ $net_test == "0" ];then
				storage_test=`df |grep rootfs|awk {'print $2'}`
					if [ $storage_test -gt $storage_size ];then 
						echo "installing software"
						softWare
							gitInstall
					else
						exit
					fi
			else 
					echo " no network "
					exit
			fi
