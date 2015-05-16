#!/bin/sh
#######################################################################
#
#
#
#######################################################################

###Vars +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Reboot=0

###Funcs/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
do_install prerequisites(){
	opkg install whiptail fdisk
	}
	
do_calc_wdth_hght(){
	
	}

do_expandFS(){
	
	}

do_changePaswd(){ ##function used to change root passwd
	whiptail --msgbox "You will now be asked to enter a new password for the pi user" 20 60 1
		passwd  &&
			whiptail --msgbox "Password changed successfully" 20 60 1
	}
	
do_webInterFaceChange(){
	
	}

do_overClock(){
	
	}

do_about(){
	
	}

###
#Main-_ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ -
###

