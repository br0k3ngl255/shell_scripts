#!/bin/sh
#######################################################################
#Created by : br0k3ngl255
#Inspired by : Alex Bradbury|asb --> raspi_config script creator
#Purpose --> automate openWRT initial & deploy processes
#######################################################################

###Vars +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ASK_TO_REBOOT=0
FREQ=""
#ret_val=""

###Funcs/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
userSpace(){
	echo -e "export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\#'
			 [ -x /bin/more ] || alias more=less
			 [ -x /usr/bin/vim ] && alias vi=vim || alias vim=vi
			 [ -x /bin/ls ] && alias l=ls || alias ls=l
			 [ -x /bin/ls ] && alias ll='ls -l' ||alias 'ls -l'=ll
			 [ -x /usr/bin/clear ] && alias cl=clear || alias clear=cl
			 alias self_destruct=$(dd if=/dev/zero of=/dev/)
			" >> /etc/profile
	}

install_prerequisites(){
userSpace
	netTest=$(ping -c 1 8.8.8.8 >> /dev/null;echo $?)
	if  [ "$netTest" == "0" ];then
		opkg update ;opkg install whiptail kmod-usb-storage block-mount kmod-fs-ext4 block-mount\
						terminfo fdisk kmod-fs-nfs kmod-fs-ext4  libmount
	else
		echo  " network is not available |script will not work as needed --> exiting " 20 60 2
		sleep 5; exit
	fi
	}

disable_openWRT_config_at_boot(){
	if [ -e /etc/profile.d/openWRT_config.sh ]; then
		rm -f /etc/profile.d/openWRT_config.sh
		sed -i /etc/inittab -e "s/^#\(.*\)#\s*RPICFG_TO_ENABLE\s*/\1/" \
		-e "/#\s*RPICFG_TO_DISABLE/d"
		telinit q
	fi
	}

wdth_hght(){ #implemented from raspi_config, to calc the the window size for whiptail--> openWRT doesn't have tput utility,
			# thus, if not manully compiled for your system, we provided value for script not to fail.
	WT_HEIGHT=17
	if  [ -e /usr/bin/tput ];then
		WT_WIDTH=$(tput cols)
	else
		WT_WIDTH=168
	fi
	if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
		WT_WIDTH=80
	fi
	if [ "$WT_WIDTH" -gt 178 ]; then
		WT_WIDTH=120
	fi
		WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
	}

	}

usbRootFS(){
		strgTest=$( fdisk -l |grep sda > /dev/null;echo $?)
		if  [ $"strgTest" == "0" ];then
			mkdir -p /tmp/cproot
			mount --bind / /tmp/cproot
			tar -C /tmp/cproot -cvf - . | tar -C /mnt/sda1 -x
			umount /tmp/cproot
			
			echo "	config 'mount'
						option  target  '/'
						option  device  '/dev/sda1'
						option  enabled '1'

					config 'swap'
						option  device  '/dev/sda2'
						option  enabled '1" >> /etc/config/fstab
			whiptail --msgbox " Moved all the data to usb & need to reboot to complete "
		else
			whiptail --msgbox " Tere no external drives||no usb device found"
		fi
	}

changePaswd(){ ##function used to change root passwd
	whiptail --msgbox "You will now be asked to enter a new password for the pi user" 20 60 1
		passwd  &&
			whiptail --msgbox "Password changed successfully" 20 60 1
	}

webInterFaceChange(){
	opkg install luci-i18n-
	}

overClock(){
	whiptail --msgbox " WARNING!!!! ensure that you have good cooling system on the cpu or it might burn the cpu " 20 60 1
			nvram set clkfreq=$FREQ
			nvram commit
			reboot
	}

about(){
	whiptail --msgbox " Welcome to openWRT_config script. This Script initial was inspired by raspi_config script for RPI devices.
		We just have recreated it for openWRT OS & continue to upgrade it with time
		--created by br0k3ngl255"
	}
finish(){
	disable_openWRT_config_at_boot
		if [ $ASK_TO_REBOOT -eq 1 ]; then
			whiptail --yesno "Would you like to reboot now?" 20 60 2
				if [ $? -eq 0 ]; then # yes
					sync
					reboot
				fi
		fi
	exit 0
	}
###
#Main-_ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ -
###

install_prerequisites # install needed tools
	wdth_hght ## calculate width & height


while true; do ### main loop for option choise
query=$(whiptail --title "Raspberry Pi Software Configuration Tool (openWRT_config)" \
--menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
"1 Move Filesystem to USB" "Moves & expands that all of the USB card storage is available to the OS" \
"2 Change Root Password" "Change password for Root user for ssh connection" \
"3 Internationalisation Options" "Set up Web Interface language" \
"4 Overclock" "Configure overclocking for your openWRT device" \
"5 Advanced Options" "Configure advanced settings" \
"6 About openWRT-config" "Information about this configuration tool" \
3>&1 1>&2 2>&3)
ret_val=$?
	if [ $ret_val -eq 1 ]; then
		finish
	elif [ $ret_val -eq 0 ]; then
		case "$query" in
			1\ *) usbRootFS ;;
			2\ *) changePaswd
			3\ *) disable_openWRT_config_at_bootz
			4\ *) webInterFaceChange
			5\ *) 
			6\ *) about

			  *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
		esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	else
		exit 1
	fi
done
