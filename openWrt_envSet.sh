#!/usr/bin/env ash

#######################################################################
#Purpose : setup working openWRT system with all needed tools.
#created by : br0k3ngl255
#
########################################################################

##Vars /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
storage_size=1969792

##Funcs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
userSpace(){
	echo -e " 	export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\#'
			[ -x /bin/more ] || alias more=less \n
			[ -x /usr/bin/vim ] && alias vi=vim || alias vim=vi \n
			[ -x /bin/ls ] && alias l=ls || alias ls=l || alias ll='ls -l' ||alias 'ls -l'=ll \n
			[ -x /usr/bin/clear ] && alias cl=clear || alias clear=cl \n
			" >> /etc/profile
	}
	
softWare(){
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
	
gitInstall(){
	mkdir git_tools -m 777;cd git_tools;
		wget http://www.secdev.org/projects/scapy/files/scapy-latest.tar.gz
		tar xvzf scapy-latest; cd scapy* ; python setup.py install
	}

setSwap(){
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
