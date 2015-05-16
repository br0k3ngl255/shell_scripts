#!/bin/sh
#######################################################################
#Created by : br0k3ngl255
#Inspired by : Alex Bradbury|asb --> raspi_config script creator
#Purpose --> automate openWRT initial and deploy processes
#######################################################################

###Vars +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Reboot=0

###Funcs/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
userSpace(){
	echo -e " 	export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\#'
			[ -x /bin/more ] || alias more=less \n
			[ -x /usr/bin/vim ] && alias vi=vim || alias vim=vi \n
			[ -x /bin/ls ] && alias l=ls || alias ls=l || alias ll='ls -l' ||alias 'ls -l'=ll \n
			[ -x /usr/bin/clear ] && alias cl=clear || alias clear=cl \n
			" >> /etc/profile
	}

install_prerequisites(){
userSpace
	netTest=$(ping -c 1 >> /dev/null;echo $?)
	if  [ "$netTest" == "0"];then 
		opkg install whiptail kmod-usb-storage block-mount kmod-fs-ext4 block-mount
	else
		echo  " network is not available |script will not work as needed --> exiting " 20 60 2
		sleep 5; exit
	fi
	}
	
wdth_hght(){
	
	}

expandFS(){
	if ! [ -h /dev/sda ]; then
		whiptail --msgbox "/dev/sda (external device) does not exist or is not connected. Can't expand what does not exits" 20 60 2
		return 0
	fi
		ROOT_PART=$(readlink /dev/root)
		PART_NUM=${ROOT_PART#sda}
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
	
	LAST_PART_NUM=$(parted /dev/mmcblk0 -ms unit s p | tail -n 1 | cut -f 1 -d:)
	if [ "$LAST_PART_NUM" != "$PART_NUM" ]; then
		whiptail --msgbox "/dev/root is not the last partition. Don't know how to expand" 20 60 2
		return 0
	fi
# Get the starting offset of the root partition
	PART_START=$(parted /dev/mmcblk0 -ms unit s p | grep "^${PART_NUM}" | cut -f 2 -d:)
		[ "$PART_START" ] || return 1
# Return value will likely be error for fdisk as it fails to reload the
# partition table because the root fs is mounted
	fdisk /dev/sda <<EOF
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

	if [ "$INTERACTIVE" = True ]; then
		whiptail --msgbox "Root partition has been resized.\nThe filesystem will be enlarged upon the next reboot" 20 60 2	
	fi
	}

usbRootFS(){
		strgTest=$( fdisk -l |grep sda > /dev/null;echo $?)
		if  [ $strgTest == "0" ];then
			mkdir -p /tmp/cproot
			mount --bind / /tmp/cproot
			tar -C /tmp/cproot -cvf - . | tar -C /mnt/sda1 -x
			umount /tmp/cproot
		else
			whiptail --msgbox " there no external drives||no usb device found"
		fi
	}

changePaswd(){ ##function used to change root passwd
	whiptail --msgbox "You will now be asked to enter a new password for the pi user" 20 60 1
		passwd  &&
			whiptail --msgbox "Password changed successfully" 20 60 1
	}
	
webInterFaceChange(){
	
	}

overClock(){
	whiptail --msgbox " WARNING!!!! ensure that you have good cooling system on the cpu or it might burn the cpu " 20 60 1
			nvram set clkfreq=
			nvram commit
	}

about(){
	whiptail --msgbox " Welcome to openWRT_config created by br0k3ngl255
		This Script initial was inspired by raspi_config script for RPI devices.
		We just have recreated it for openWRT OS and continue to upgrade it with time"
	}

###
#Main-_ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ -
###

install_prerequisites
