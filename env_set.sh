#!/usr/bin/env bash 
set -x
########################################################################
#Purpose : 
#			Recreate working env as painless and as fast as possible to 
#		continure working in new and fresh env
########################################################################


#!!!!!!!!!!!!!!!!!!!!!!!!!TODO --> add uspport for RPM systems
	#Add support for servers : ssh,nfs,samba,ftp,web,sql,ldap,dovecot,postfix -->
			#add others if needed --> might need automation and embedded to create config files
		#Add option for display management change --> lightdm with mate or any other.
		   
##vars : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : :
REPO=""
USER="br0k3ngl255" ### place your user name here
PASSWD="1"         ### palce your passwd here

#########Funcs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
###
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

update_upgrade(){ # designed for 64 bit systems that need  32 bit support.
        echo " Upgrading"
                ps_status apt-get
        apt-get update  > /dev/null 2> /dev/null &
                 ps_status apt-get
        apt-get upgrade -y  > /dev/null 2> /dev/null &
                 ps_status apt-get
        apt-get dist-upgrade -y > /dev/null 2> /dev/null &
                 ps_status apt-get
#       process_wait apt-get
		if [ "`uname -m`" == "x86_64" ];then 
          echo " adding support 4 32Bit"
              dpkg --add-architecture i386
                 apt-get update > /dev/null 2> /dev/null &
            ps_status apt-get
                 apt-get intall -f  > /dev/null 2> /dev/null &
            ps_status apt-get
         fi
            sleep 2
        apt-get install geany guake plymouth-themes-all plymouth-x11\
           linux-headers-`uname -r`  build-essential transmission debhelper\
           cmake bison flex libgtk2.0-dev libltdl3-dev libncurses-dev\
           libncurses5-dev libnet1-dev libpcre3-dev libssl-dev\
           libcurl4-openssl-dev ghostscript autoconf flashplugin-nonfree\
           gnome-tweak-tool conky-all libreoffice icedove htop ntop\
           python-software-properties mana-toolkit cookie-cadger xplico\
           debian-goodies dosbox freeglut3-dev libxmu-dev libpcap-dev\
           python-yowsup yowsup-cli libglib2.0 libxml2-dev libpcap-dev\
           libtool rrdtool autoconf automake autogen redis-server\
           wget libsqlite3-dev libhiredis-dev libgeoip-dev mixxx 
           audacity git-core  debootstrap qemu-user-static\
           device-tree-compiler lzma lzop u-boot-tools libncurses5:i386\
           pixz dkms git-core gnupg flex bison gperf libesd0-dev\
		   zip curl libncurses5-dev zlib1g-dev gcc-multilib g++-multilib -y > /dev/null &
          #ps_status apt-get
}

set_services(){ #need to disable unneeded services for systems fast boot
	echo "removing unNeeded ServIce5"
	update-rc.d apache2 remove; update-rc.d mysql remove; update-rc.d arpwatch remove; 
	update-rc.d irqbalance remove;
	update-rc.d cron remove; update-rc.d cryptdisk remove; update-rc.d cryptdisk-early remove;
	update-rc.d greenbone-security-assistant remove;
	update-rc.d lvm2 remove; update-rc.d kmod remove; update-rc.d openvas-scanner remove;
	update-rc.d openvas-manager remove;
	update-rc.d rsync remove;update-rc.d rc.local remove; update-rc.d speed-dispatcher remove;
	update-rc.d thin remove;update-rc.d atd remove;update-rc.d kbd remove;
	update-rc.d nfs-common remove;update-rc.d stunnel4 remove; update-rc.d bluetooth remove; 
	update-rc.d saned remove;update-rc.d speech-dispatcher remove;
	}
	
set_working_env(){
    
        useradd -m -p `mkpasswd "$PASSWD"` -s /bin/bash -G adm,sudo,www-data,root $USER
#       echo $PASSWD|passwd $USER --stdin
        ##creating aliases
        echo "alias l=ls; alias ll='ls -l'; alias la='ls -la';alias lh='ls -lh'
        alias more=less; alias vi=vim; alias cl=clear; alias mv='mv -v'; alias cp='cp -v'; 
        alias log='cd /var/log'; alias drop_caches='echo 3 > /proc/sys/vm/drop_caches';
        alias ip_forward='echo 1 > /proc/sys/net/ipv4/ip_forward';
        alias self_destruct='dd if=/dev/zero of=/dev/sda'
        export PATH=$PATH:/opt/VirtualGL/bin:/usr/local/cuda-6.5/bin;
        export CROSS_COMPILE=/opt/arm-tools/kernel/toolchains/gcc-arm-eabi-linaro-4.6.2/bin/arm-eabi-" >> /etc/bash.bashrc; source /etc/bash.bashrc
        #removing kali pics
				if [ `uname -a|grep kali > /dev/null;echo $?` == "0" ];then
					updatedb;locate kali |grep png > pics.txt
						while read line;do rm -rf $line;done  < pics.txt
				fi
        #arainging numbers for editor
        echo "set number" >> /etc/vim/vimrc
				rm -rf /usr/share/kali-defaults/bookmarks.html
				rm -rf /usr/share/kali-defaults/web
				rm -rf /usr/share/kali-defaults/localstore.rdf
           set_services
        sed -i -e 's/TIMEOUT=5/TIMEOUT=0/' /etc/default/grub
        sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub;update-grub;update-initramfs -u
        sed -i -e 's/kali-dragon.png/ /g'   /etc/gdm3/greeter.gsettings
        sed -i -e 's/kali-dragon.png/ /g'   /etc/gdm3/greeter.gsettings.dpkg-new
        sed -i -e 's/kali-dragon.png/ /g'   usr/share/gdm/dconf/10-desktop-base-settings
        sed -i -e 's/login-background.png/ /g' usr/share/gdm/dconf/10-desktop-base-settings


        }   
        
Nvidia_primus_config(){
	if [  ];then 
		if [ -e /etc/ld.so.conf ];then
			echo  "" >> /etc/ld.so.conf
				ldconfig
				
			if [ -e /etc/bumblebee/xorg.conf.nvidia ];then
				 grep BusID "PCI:01:00:0";sed -i -e
			fi
		fi
	fi
	}
	
Nvidia_optimus(){
	cd /tmp 
	
	wget http://downloads.sourceforge.net/project/virtualgl/2.4/virtualgl_2.4_amd64.deb &
	wget http://us.download.nvidia.com/XFree86/Linux-x86_64/346.47/NVIDIA-Linux-x86_64-346.47.run &
	wget http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run &
	ps_status wget
		
		 if [ `ls -l  > /dev/null;echo $?` == "0" ];then
			dpkg -i virtualgl_2.4_amd64.deb
					down_sts=`ps aux |grep -v grep |grep wget > /dev/null;echo $?`
				if [ "$down_sts" == "0" ];then
					chomd +x *run	
				fi
			apt-get install bumblebee primus -y
		 fi
	
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

arm_env_setup(){
	toolCheck=`dpkg -l|grep git-core > /dev/null ;echo $?` 
	if [ $toolCheck == "0" ];then
		if [ ! -e /opt/sunxi-livesuite ]
			cd /opt
			git clone https://github.com/linux-sunxi/sunxi-livesuite.git
			if [ ! -e /opt/arm-tools/kernel/toolchains ];then
				mkdir /opt/arm-tools -m 775
			cd /opt/arm-tools/kernel/toolchains
				git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7.git
			cd /opt/arm-tools
				git clone https://github.com/offensive-security/kali-arm-build-scripts.git
			fi
			cd ~
		fi
		
	fi
	}

net_connect(){
	net_stat=`ping -c 1 vk.com > /dev/null 2> /dev/null ;echo $?`
		if [ $net_stat == "1" ] || [ $net_stat == "2" ];then
			echo "NO NETWORK - "
			exit
		fi
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
                                echo "N0T SuPP07T3d"
                        fi
                fi
        }
#
#Main() -_ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ -
#

if [ $UID != 0 ];then
	echo "Get r00T"
	exit
else
	test_env
		usr_sts=`cat /etc/passwd|grep -v grep |grep $USER > /dev/null ;echo $?`
			if [ "$user_sts" != "0" ];then
				set_working_env
			fi
			if [ -z /etc/apt/sources.list ];then
				net_connect
					update_upgrade
				arm_env_setup
					get_usefull_tools
				gui_card_test=`lspci |grep VGA|grep NVIDIA >> /dev/null ;echo $`
					if [ "$gui_card_test" == "0" ];then
						Nvidia_optimus
							Nvidia_primus_config
					fi
			fi
fi
