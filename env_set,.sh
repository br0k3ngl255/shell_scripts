#!/usr/bin/env bash 
set -x
########################################################################
#Purpose : 
#			Create useful environment to use with you debian distio
#     created by br0k3ngl255 for linuxsystems LTD
########################################################################

		   
##vars : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : :
REPO=""
USER="br0k3ngl255" ### place your user name here
PASSWD="1"         ### palce your passwd here

###Funcs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

insert_repo(){ # case statement to choose between DEbian and KAli
		###TODO - add ubuntu
				##Future options for RPM base
	op=$1
	case $op in

		Kali) echo "
##Main
deb http://http.kali.org/ /kali main contrib non-free
deb http://http.kali.org/ /wheezy main contrib non-free
#deb http://http.kali.org/kali kali-dev main contrib non-free
#deb http://http.kali.org/kali kali-dev main/debian-installer
#deb-src http://http.kali.org/kali kali-dev main contrib non-free
deb http://http.kali.org/kali kali main contrib non-free
deb http://http.kali.org/kali kali main/debian-installer
deb-src http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
deb-src http://security.kali.org/kali-security kali/updates main contrib non-free

#out src
	
" >  /etc/apt/sources.list
;;
		Debian)	echo " 
##MAIN
deb http://http.debian.net/debian wheezy main
deb-src http://http.debian.net/debian wheezy main

deb http://http.debian.net/debian wheezy-updates main
deb-src http://http.debian.net/debian wheezy-updates main

deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main

###BackPort
deb http://http.debian.net/debian wheezy-backports main		
" > /etc/apt/sources.list
;;
		*) echo "Error getting Repo";exit 1 ;;
		
esac
	}

ps_status(){
        PSS=$1
ps_sts=`ps aux |grep -v grep|grep $PSS > /dev/null ;echo $?`
                while [ $ps_sts == 0 ];do
                        ps_sts=`ps aux |grep -v grep|grep $PSS > /dev/null ;echo $?`

                        if [ $ps_sts == 0 ];then
                                sleep 1
                        elif [ $ps_sts != 0 ];then
                                break
                        else
                                echo "problem"
                                exit 1
                        fi
                done
        }

set_services(){ #need to disable unneeded services for systems fast boot
	echo "removing unNeeded ServIce5"
	update-rc.d apache2 remove; update-rc.d mysql remove; update-rc.d arpwatch remove; 
	update-rc.d irqbalance remove;
	update-rc.d cron remove; update-rc.d cryptdisk remove; update-rc.d cryptdisk-early remove;
	update-rc.d greenbone-security-assistant remove;
	update-rc.d lvm2 remove; update-rc.d kmod remove; update-rc.d openvas-scanner remove;
	update-rc.d openvas-manager remove;
	update-rc.d rsync remove; update-rc.d speed-dispatcher remove;
	update-rc.d thin remove;update-rc.d atd remove;
	update-rc.d stunnel4 remove; update-rc.d bluetooth remove; 
	}
	
set_working_env(){
    
        useradd -m -p `mkpasswd "$PASSWD"` -s /bin/bash -G adm,sudo,www-data,root $USER
		#echo $PASSWD|passwd $USER --stdin
        ##creating aliases
        echo "alias l=ls; alias ll='ls -l'; alias la='ls -la';
        alias more=less; alias vi=vim; alias cl=clear; alias mv='mv -v'; alias cp='cp -v'; 
        alias log='cd /var/log'; alias drop_caches='echo 3 > /proc/sys/vm/drop_caches';
        alias ip_forward='echo 1 > /proc/sys/net/ipv4/ip_forward';
        alias self_destruct='dd if=/dev/zero of=/dev/sda' " >> /etc/bash.bashrc; source /etc/bash.bashrc
        #removing kali pics
				if [ `uname -a|grep kali > /dev/null;echo $?` == "0" ];then
					updatedb;locate kali |grep png > pics.txt
						while read line;do rm -rf $line;done  < pics.txt
				fi
        #arainging numbers for editor
        echo "set number" >> /etc/vim/vimrc
                set_services
         echo "installing additional software  -- > " 
        sleep 2
echo "	
#!/bin/bash 

while  [ \`ping -c 1 vk.com > /dev/null ;echo $?\` == \"0\" ];do
	sleep 1
	if [ \`ping -c 1 vk.com > /dev/null ;echo $?\` == \"0\" ];then
		apt-get install geany guake plymouth-themes-all plymouth-x11\
			linux-headers-`uname -r`  build-essential transmission debhelper\
				cmake bison flex libgtk2.0-dev libltdl3-dev libncurses-dev\
					libncurses5-dev libnet1-dev libpcre3-dev libssl-dev\
						libcurl4-openssl-dev ghostscript autoconf flashplugin-nonfree\
							gnome-tweak-tool conky-all libreoffice icedove htop ntop\
								python-software-properties mana-toolkit cookie-cadger xplico\
							debian-goodies dosbox freeglut3-dev libxmu-dev libpcap-dev\
						libglib2.0 libxml2-dev libpcap-dev\
					libtool rrdtool autoconf automake autogen redis-server\
				wget libsqlite3-dev libhiredis-dev libgeoip-dev mixxx \
			audacity  -y 
                 fi
               done
                 echo 'exit 0' > /etc/rc.local
           exit 0"  > /etc/rc.local
        }   


get_usefull_tools(){
         if [ ! -e /home/$USER/Downloads ];then
                        mkdir /home/$USER/Downloads
         fi  
           cd /home/$USER/Downloads
                    wget http://download.teamviewer.com/download/teamviewer_amd64.deb  &
                    wget http://kdl.cc.ksosoft.com/wps-community/download/a16/wps-office_9.1.0.4945~a16p3_i386.deb &
                    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb &
               ps_status wget 
                    wget https://geany-vibrant-ink-theme.googlecode.com/files/vibrant_ink_geany_filedefs_20111207.zip
               ps_status dpkg          
                   dpkg -i *deb
						apt-get install -f -y > /dev/null &
				ps_status apt-get
					echo "indiv1DuaL Loots 1NZtall3d"
                        #unzip vibrant_ink_geany_filedefs_20111207.zip
        }

test_env(){
                if [ -e /etc/debian_version ];then
                        envTest=`cat /etc/debian_version |awk {'print $1'}`
                        if [ $envTest == "Kali" ];then
                                insert_repo $envTest
                        elif [ $envTest == "Debian" ];then
                                insert_repo $envTest
                                        exit 1;
                        else
                                echo "Not Supported"
                        fi
                fi
        }
#
#Main() -_ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ 
#

if [ $UID != 0 ];then
	echo " Need Root Access"
else
    while getopts ":U:P" opt; do
  case $opt in
    U)  USER="$OPTARG" ;;
    P)  PASSWD="$OPTARG" ;;
    *)echo "Invalid option: -$OPTARG"  ;;
  esac
done

	test_env
	if [ -z /etc/apt/source.list ];then
		update_upgrade
	fi
		usr_sts=`cat /etc/passwd|grep -v grep |grep $USER > /dev/null ;echo $?`
			if [ "$user_sts" != "0" ];then
				set_working_env
			fi			
	get_usefull_tools
ps_status wget
fi

ps_status wget

reboot
