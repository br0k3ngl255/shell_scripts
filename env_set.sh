#!/usr/bin/env bash 

########################################################################
#Purpose : automating dev and proper working environment  installation
########################################################################
#Copyright (c) <2014-2015>, <LinuxSystems LTD>
#All rights reserved.
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <LinuxSystems LTD> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!TODO --> add uspport for RPM systems!!!!!!!!!!!!!!!!!!!!!!!!1
####will change format with python later.
	#Add support for servers : ssh,nfs,samba,ftp,web,sql,ldap,dovecot,postfix -->
			#add others if needed --> might need automation and embedded to create config files
		#Add option for display management change --> lightdm with mate or any other.

##vars : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : : :
REPO=""
USER="mobius" ### place your user name here
PASSWD="1"         ### palce your passwd here
REPONAME=`lsb_release -si`
KODENAME=`lsb_release -sc`
OS=`lsb_release -si`
ARCH=`uname -m`
VERSION=`lsb_release -sr`
INSTALL_MNGR=''
#########Funcs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
###
insert_repo(){ # case statement to choose between DEbian and KAli
		###TODO - add ubuntu
				##Future options for RPM base
	op=$1
	case $op in

		$REPONAME)	echo "
##MAIN
deb http://http.$REPONAME.net/$REPONAME $KODENAME main
deb-src http://http.$REPONAME.net/$REPONAME $KODENAME main

deb http://http.$REPONAME.net/$REPONAME $KODENAME-updates main
deb-src http://http.$REPONAME.net/$REPONAME $KODENAME-updates main

deb http://security.$REPONAME.org/ $KODENAME/updates main
deb-src http://security.$REPONAME.org/ $KODENAME/updates main

deb ftp://ftp.$REPONAME.org/$REPONAME stable main contrib non-free
###BackPort
deb http://http.$REPONAME.net/$REPONAME $KODENAME-backports main
deb http://ftp.$REPONAME.org/$REPONAME/ $KODENAME-backports main non-free contrib
" > /etc/apt/sources.list
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Debian_7.0/ /' >> /etc/apt/sources.list.d/owncloud-client.list
echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib" >> /etc/apt/sources.list
;;
		*) echo "Error getting Repo";exit 1 ;;

esac
	}

ps_status(){ #buffer functions that makes whole wait until the process provided to it will end
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
get_install_manager(){
if [ "$OS" == "Debian" ];then
    INSTALL_MNGR="apt-get"
elif [ $OS == "RedHat" ];then
    INSTALL_MNGR="yum"
else
    echo "install manager not supported --> will exit"
        exit 1
fi
}

update_upgrade(){  # designed for 64 bit systems that need  32 bit support.
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
                 apt-get intall ia32-libs  > /dev/null 2> /dev/null &
            ps_status apt-get
         fi
            sleep 2
}

install_desk_tools(){ #installing desktop/documentation files.
	apt-get install lightdm mate-desktop-environment-extras firmware-realtek\
	firmware-linux firmware-linux-free firmware-linux-nonfree vlc libreoffice\
	u-boot-tools uboot-mkimage gparted abiword transmission guake mixxx\
	culmus xfonts-efont-unicode xfonts-efont-unicode-ib xfonts-intl-european\
	msttcorefonts
	 -y > /dev/null &
	}

install_server_tools(){ #installing  servers
	apt-get install sqlite sqlite3 mysql-client mysql-server postgresql\
	 apache2 nginx-full nfs-common samba-common redis-server sysv-rc-conf -y > /dev/null &
	}

install_net_tools(){ #installing some network tools
	apt-get install wget curl nmap zenmap aircrack-ng dsniff ndiff nbtscan\
	wireshark tshark tcpdump  netcat macchanger -y > /dev/null &
	}
install_python_tools(){ #installing python devel files
	apt-get install python-scapy python-pip python-networkx python-netaddr python-netifaces python-netfilter\
	  python-gnuplot python-mako python-radix ipython  python-pycurl python-lxml python-libpcap\
	  python-nmap python-flask python-scrapy -y  > /dev/null &
	}
install_perl_libs(){
	apt-get install libpoe-component-pcap-perl libnet-pcap-perl perl-modules -y > /dev/null &
	}

install_dev_tools (){ #istalling files needed for development
        apt-get install geany linux-image-`uname -r` linux-headers-`uname -r `  build-essential debhelper\
           cmake bison flex libgtk2.0-dev libltdl3-dev libncurses-dev libusb-1.0-0-dev git-core\
           libncurses5-dev libnet1-dev libpcre3-dev libssl-dev libcurl4-openssl-dev ghostscript autoconf\
           python-software-properties debian-goodies freeglut3-dev libxmu-dev libpcap-dev\
           libglib2.0 libxml2-dev libpcap-dev libtool rrdtool autoconf automake autogen redis-server\
           wget libsqlite3-dev libhiredis-dev libgeoip-dev debootstrap qemu-user-static\
           device-tree-compiler lzma lzop u-boot-tools pixz dkms git-core gnupg flex bison gperf libesd0-dev\
	       zip curl libncurses5-dev zlib1g-dev gcc-multilib g++-multilib libusb-1.0-0 libusb-1.0-0-dev fakeroot\
	        kernel-package zlib1g-dev devscripts pbuilder dh-make mingw32 mingw32-binutils -y > /dev/null &
          #ps_status apt-get
}


set_services(){ #need to disable unneeded services for systems fast boot
	echo "removing unNeeded ServIce5"
	update-rc.d apache2 remove; update-rc.d mysql remove; update-rc.d arpwatch remove;update-rc.d irqbalance remove;
	update-rc.d cron remove; update-rc.d cryptdisk remove; update-rc.d cryptdisk-early remove;
	update-rc.d greenbone-security-assistant remove;update-rc.d openvas-manager remove;
	update-rc.d lvm2 remove; update-rc.d kmod remove; update-rc.d openvas-scanner remove;
	update-rc.d rsync remove;update-rc.d rc.local remove; update-rc.d speed-dispatcher remove;
	update-rc.d thin remove;update-rc.d atd remove;update-rc.d kbd remove;
	update-rc.d nfs-common remove;update-rc.d stunnel4 remove; update-rc.d bluetooth remove;
	update-rc.d saned remove;update-rc.d speech-dispatcher remove;
	update-rc.d rpcbind remove;update-rc.d acpid remove;update-rc.d avahi-daemon remove;
	update-rc.d cups remove;update-rc.d rsync remove;
	update-rc.d ntop remove;update-rc.d saned remove;update-rc.d procps remove;update-rc.d saned remove;
	update-rc.d acpi-fakekey remove;update-rc.d cpufrequtils remove;
	update-rc.d binfmt-support remove;update-rc.d anacron remove;update-rc.d redis-server remove;
	update-rc.d minissdpd remove;update-rc.d rcS remove;update-rc.d postgresql remove;
	update-rc.d rc.local remove;update-rc.d umountroot remove;update-rc.d rsyslog remove;
	update-rc.d kbd remove;update-rc.d nfs-common remove;
	update-rc.d bluetooth remove;update-rc.d exim4 remove;update-rc.d cron remove;
	}

git_tool_install(){ #downloading some files
	git_tool_chk=`dpkg -l |grep git|grep 'distributed revision control' > /dev/null ;echo $?`
	if [ $git_tool_chk == 0  ];then
		if [ ! -e /opt/sunxi ];then
			cd /opt
				git clone https://github.com/codebrainz/geany-themes.git &> /tmp/log.txt &
			mkdir sunxi -m 775
			cd sunxi
				git clone https://github.com/linux-sunxi/sunxi-livesuite.git &> /tmp/log.txt &
				git clone https://github.com/linux-sunxi/sunxi-tools &> /tmp/log.txt &
			cd ../
			if [ ! -e /opt/arm-tools/ ];then
				mkdir /opt/arm-tools -m 775
			cd /opt/arm-tools/
				git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7.git &> /tmp/log.txt &
				git clone https://github.com/offensive-security/kali-arm-build-scripts.git &> /tmp/log.txt &
			cd ../
				svn co svn://svn.linuxfromscratch.org/LFS/trunk/BOOK/
		fi
	fi

	}

set_working_env(){ #user env setup

        useradd -m -p `mkpasswd "$PASSWD"` -s /bin/bash -G adm,sudo,www-data,root $USER
#       echo $PASSWD|passwd $USER --stdin
        sed s/PS1/#PS1/ /etc/bash.bashrc
        ##creating aliases
        echo -e " PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[0;31m\]\$ \[\e[m\]\[\e[0;32m\]' \n
                    PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
                " >> /etc/bash.bashrc
        echo "alias l=ls; alias ll='ls -l'; alias la='ls -la';alias lh='ls -lh'
        alias more=less; alias vi=vim; alias cl=clear; alias mv='mv -v'; alias cp='cp -v';
        alias log='cd /var/log'; alias drop_caches='echo 3 > /proc/sys/vm/drop_caches';
        alias ip_forward='echo 1 > /proc/sys/net/ipv4/ip_forward';
        alias self_destruct='dd if=/dev/zero of=/dev/sda'
        export PATH=$PATH:/opt/VirtualGL/bin:/usr/local/cuda-6.5/bin;
        export CROSS_COMPILE=/opt/arm-tools/kernel/toolchains/gcc-arm-eabi-linaro-4.6.2/bin/arm-eabi-" >> /etc/bash.bashrc;
        source /etc/bash.bashrc
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
        sed -i -e 's/TIMEOUT=5/TIMEOUT=0/' /etc/default/grub
        sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub;update-grub;update-initramfs -u
        if [ -e /etc/gdm3/greeter.gsettings ];then
			sed -i -e 's/kali-dragon.png/ /g'   /etc/gdm3/greeter.gsettings
			sed -i -e 's/kali-dragon.png/ /g'   /etc/gdm3/greeter.gsettings.dpkg-new
        else
			true
        fi
        if [ -e /usr/share/gdm/dconf/10-desktop-base-settings ];then
			sed -i -e 's/kali-dragon.png/ /g'   /usr/share/gdm/dconf/10-desktop-base-settings
			sed -i -e 's/login-background.png/ /g' /usr/share/gdm/dconf/10-desktop-base-settings
        else
			true
		fi

        }   
        
Nvidia_primus_config(){ #some nvidia optimus configurations
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
	
Nvidia_optimus(){ #downloading Nvidia optimus files for later installation - if exists of course
	cd /tmp 
	
	wget http://downloads.sourceforge.net/project/virtualgl/2.4/virtualgl_2.4_amd64.deb &  > /dev/null 2> /dev/null
	wget http://us.download.nvidia.com/XFree86/Linux-x86_64/346.47/NVIDIA-Linux-x86_64-346.47.run &   > /dev/null 2> /dev/null
	wget http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run &  > /dev/null 2> /dev/null
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

get_usefull_tools(){ #downloadinf manually usefull software.
         if [ ! -e /home/$USER/Downloads ];then
                        mkdir /home/$USER/Downloads
         fi  
           cd /home/$USER/Downloads
				echo " downloading manual files to install "
                    wget http://download.teamviewer.com/download/teamviewer_amd64.deb  &  > /dev/null 2> /dev/null
                    wget http://kdl.cc.ksosoft.com/wps-community/download/a16/wps-office_9.1.0.4945~a16p3_i386.deb &  > /dev/null 2> /dev/null
                    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb &  > /dev/null 2> /dev/null
               ps_status wget 
                    wget https://geany-vibrant-ink-theme.googlecode.com/files/vibrant_ink_geany_filedefs_20111207.zip  > /dev/null 2> /dev/null
               ps_status dpkg          
                   dpkg -i *deb
						apt-get install -f -y > /dev/null &
				ps_status apt-get
					echo "indiv1DuaL Loots 1NZtall3d"
                        #unzip vibrant_ink_geany_filedefs_20111207.zip
        }

net_connect(){ #checks if network connected
	net_stat=`ping -c 1 vk.com > /dev/null 2> /dev/null ;echo $?`
		if [ $net_stat == "1" ] || [ $net_stat == "2" ];then
			echo "NO NETWORK - "
			exit
		fi
	}
test_env(){ # checking what debian flavored distro this is  - if not known then exit
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
	echo 'Get r00T'
	exit
else
	test_env
		usr_sts=`cat /etc/passwd|grep -v grep |grep $USER > /dev/null ;echo $?`
		    get_install_manager
			if [ "$user_sts" != "0" ];then

				set_working_env
			fi
				net_connect
				sleep 5
					update_upgrade; get_usefull_tools &
						install_desk_tools
					install_server_tools
						install_python_tools
					install_perl_libs
						git_tool_install
				set_services
					gui_card_test=`lspci |grep VGA|grep NVIDIA >> /dev/null ;echo $?`
						if [ "$gui_card_test" == "0" ];then
							Nvidia_optimus
								Nvidia_primus_config
						fi
			
fi
