#!/usr/bin/env ash
###########################################################################
#created by : Michael
#             property of linuxsystems.rocks LTD
#
###########################################################################

###Vars
installMngr=''

###Funcs+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
install_Depends(){
	echo "Dependencies install ";sleep 2;
            $installMngr install firmware-linux* firmware-atheros firmware-iwlwifi firmware-ralink firmware-realtek openssh-server dnsmasq ntp network-manager proftpd apache2 python3 resolvconf -y
             echo "[-OK] - Dependencies installed "
}

setUp_Static_Network(){
	echo 'Setting up STATIC Interface'; sleep 2;
        echo -e " auto eth0 \n
                  iface eth0 inet static\n
                  address 192.168.1.1 \n
                  netmask 255.255.255.0 \n
                  iface wlan0 inet static \n " >> /etc/network/interfaces
     echo '[-OK] - STATIC interface set '
}
setUp_network_creattion_Script(){
	echo" deploying wiireless setup script";sleep
	
echo -e ' #!/usr/bin/env python3\n\n\n\n
 \n
 import sys\n
 import os\n
 import time\n
 
 from subprocess import (\n
     check_call,\n
     check_output,\n
     CalledProcessError,\n
     )\n
 
 from uuid import uuid4 \n
 from argparse import ArgumentParser \n
 \n
 CONNECTIONS_PATH = "/etc/NetworkManager/system-connections/"\n
 
 \n
 def connection_section(ssid, uuid):\n
 \n
     if not uuid:\n
         uuid = uuid4()\n
 
     connection = """\n
 [connection] \n
 id=%s \n
 uuid=%s\n
 type=802-11-wireless\n
 autoconnect=false\n
     """ % (ssid, uuid) \n
\n
     wireless = """\n
 [802-11-wireless]\n
 ssid=%s \n
 mode=infrastructure""" % (ssid)\n
 \n
     return connection + wireless \n
 
 
 def security_section(security, key):\n
     # Add security field to 802-11-wireless section\n
     wireless_security = """ \n
 security=802-11-wireless-security \n
 \n
 [802-11-wireless-security]\n
     """\n
 
     if security.lower() == "wpa": \n
         wireless_security += """ \n
 key-mgmt=wpa-psk \n
 auth-alg=open \n
 psk=%s \n
         """ % key \n
 
     elif security.lower() == "wep": \n
         wireless_security += """ \n
 key-mgmt=none \n
 wep-key=%s \n
         """ % key \n
 
     return wireless_security  \n
 
 
 def ip_sections(): \n
     ip = """ \n
 [ipv4] \n
 method=auto  \n
 
 [ipv6]  \n
 method=auto \n
     """ \n
 
     return ip \n
 
 
 def block_until_created(connection, retries, interval): \n
 
     while retries > 0: \n
         nmcli_con_list = check_output(["nmcli", "con", "list"], universal_newlines=True) \n
 
         if connection in nmcli_con_list:\n
             print("Connection %s registered" % connection) \n
             break\n
 
         time.sleep(interval) \n
         retries = retries - 1 \n
 \n
     if retries <= 0: \n
         print("Failed to register %s." % connection, file=sys.stderr) \n
         sys.exit(1) \n
     else: \n
         try: \n
             nmcli_con_up = check_call(["nmcli", "con", "up", "id",  connection]) \n
             print("Connection %s activated." % connection) \n
         except CalledProcessError as error: \n
             print("Failed to activate %s." % connection, file=sys.stderr) \n
             sys.exit(error.returncode) \n
 \n
 def main(): \n
     parser = ArgumentParser()  \n
 \n
     parser.add_argument("ssid",
                       help="The SSID to connect to.")\n
     parser.add_argument("-S", "--security", \n
                       help=("The type of security to be used " \n
                             "by the connection. One of wpa and wep. " \n
                             "No security will be used " \n
                             "if nothing is specified.")) \n
     parser.add_argument("-K", "--key", \n
                       help="The encryption key required by the router.") \n
     parser.add_argument("-U", "--uuid", \n
                       help="""The uuid to assign to the connection for use by \n
                             NetworkManager. One will be generated if not \n
                             specified here.""") \n
     parser.add_argument("-R", "--retries", \n
                       help="""The number of times to attempt bringing up the \n
                               connection until it is confirmed as active.""", \n
                       default=5) \n
     parser.add_argument("-I", "--interval", \n
                       help=("The time to wait between attempts to detect the " \n
                             "registration of the connection."), \n
                       default=2)\n
 
     args = parser.parse_args() \n
 
     connection_info = connection_section(args.ssid, args.uuid) \n
 
     if args.security: \n
         # Set security options \n
         if not args.key: \n
             print("You need to specify a key using --key " \n
                   "if using wireless security.", file=sys.stderr) \n
             sys.exit(1) \n
 
         connection_info += security_section(args.security, args.key)\n
     elif args.key: \n
         print("You specified an encryption key " \n
               "but did not give a security type using --security.", file=sys.stderr) \n
         sys.exit(1) \n
 \n
     try: \n
         check_call(["rfkill","unblock","wlan","wifi"]) \n
     #except CalledProcessError: \n
     except: \n
         print("Could not unblock wireless devices with rfkill.", file=sys.stderr) \n
         # Dont fail the script if unblock didnt work though\n
 
     connection_info += ip_sections() \n
 
     # NetworkManager replaces forward-slashes in SSIDs with asterisks
     connection_file = args.ssid.replace('/', '*') \n
     try: \n
         connection_file = open(CONNECTIONS_PATH + connection_file, 'w') \n
         connection_file.write(connection_info) \n
         os.fchmod(connection_file.fileno(), 0o600) \n
         connection_file.close()\n
     except IOError: \n
         print("Cant write to " + CONNECTIONS_PATH + args.ssid \n
               + ". Is this command being run as root?", file=sys.stderr) \n
         sys.exit(1) \n
 \n
     block_until_created(args.ssid, args.retries, args.interval) \n
 \n
 if __name__ == "__main__":\n
     main() \n' >> /etc/init.d/wireless_setUp.py
 chmod 755  /etc/init.d/wireless_setUp.py
 chown root:root /etc/init.d/wireless_setUp.py
 
 echo " [-OK] - Scripts Deployed"
}

setUp_firewall(){
	
	echo "setting firewall and redirecting rules"; sleep
if [ ! -e /etc/network/if-pre-up.d ];then 
    mkdir -p /etc/network/if-pre-up.d
fi 
 touch /etc/network/if-pre-up.d/iptables
 chmod 755 /etc/network/if-pre-up.d/iptables

echo -e "
 #!/bin/bash \n
 ethif=eth0 \n
 wlanif=wlan1 \n
 pppif=ppp0 \n
 \n
 ## disabling IP forwarding \n
 echo 0 > /proc/sys/net/ipv4/ip_forward \n
 \n
 ## flushing iptables\n
 chains=`cat /proc/net/ip_tables_names` \n
 for i in $chains; do \n
   iptables -t $i -F \n
   iptables -t $i -X \n
   iptables -t $i -Z \n
 done\n
 \n
 ## setting default policy for INPUT,OUTPUT,FORWARD \n
 iptables -P INPUT DROP \n
 iptables -P OUTPUT ACCEPT \n
 iptables -P FORWARD DROP \n
 \n
 ## setting up NAT \n
 iptables -t nat -A POSTROUTING -o $wlanif -j MASQUERADE \n
 iptables -t nat -A POSTROUTING -o $pppif -j MASQUERADE \n 
 \n
 ## FORWARD chain \n
 # allow forwarding coming from lan interface and subnet \n
 iptables -A FORWARD -i $ethif -j ACCEPT \n
 # allow forwarding of established incoming traffic from outside  \n
 iptables -A FORWARD -i $wlanif -m state --state ESTABLISHED,RELATED -j ACCEPT \n
 iptables -A FORWARD -i $pppif -m state --state ESTABLISHED,RELATED -j ACCEPT \n
 \n
 ## INPUT chain \n
 # allow loopback traffic \n
 iptables -A INPUT -i lo -j ACCEPT \n
 # allow internal traffic  \n
 iptables -A INPUT -i $ethif -j ACCEPT \n
 # allow established incoming traffic from outside  \n
 iptables -A INPUT -i $wlanif -m state --state ESTABLISHED,RELATED -j ACCEPT \n
 iptables -A INPUT -i $pppif -m state --state ESTABLISHED,RELATED -j ACCEPT \n
 \n
 ## enabling IP forwarding \n
 echo 1 > /proc/sys/net/ipv4/ip_forward \n
\n 
" >>  /etc/network/if-pre-up.d/iptables

echo "[-OK] - firewall and redirections setup"
}

setUp_dnsmasq(){
	echo " setting up DHCP "; sleep 2
echo -e "  
 domain-needed \n
 local=/lan/ \n
 interface=eth0 \n
 interface=lo \n
 dhcp-range=192.168.1.100,192.168.1.199,12h \n " >> /etc/dnsmasq.conf
 
 echo " [ -OK] - DHCP set "
}
setUp_alias(){
echo "alias l=ls; alias ll='ls -l'; alias la='ls -la'; alias mv='mv -v'; alias cp='cp -v'; alias cl=clear; alias vi=vim; alias less=more" >> /etc/bash.bashrc
source /etc/bash.bashrc
}
setUp_motd(){
echo "" > /etc/motd
echo -e "
  _________.__.__                 __        _____        ___.   .__              \n
 /   _____/|__|  |   ____   _____/  |_     /     \   ____\_ |__ |__|__ __  ______\n
 \_____  \ |  |  | _/ __ \ /    \   __\   /  \ /  \ /  _ \| __ \|  |  |  \/  ___/\n
 /        \|  |  |_\  ___/|   |  \  |    /    Y    (  <_> ) \_\ \  |  |  /\___ \ \n
/_______  /|__|____/\___  >___|  /__|____\____|__  /\____/|___  /__|____//____  >\n
        \/              \/     \/  /_____/       \/           \/              \/ \n
" > /etc/motd

}


main(){
    cmd=`ls /etc/debian_version >> /dev/null;echo $?`
     if [ $cmd == "0" ];then
      installMngr="apt-get"
     else echo " not supported"; exit
    fi
    
    echo "This script will set up ROUTER on this server- Are you Sure you want to install  these settings ? (N/y)"
    read ans
    if [ "$ans" == "y" ] || [ "$ans" == "Y" ]; then 
    
    setUp_motd
     setUp_alias
       install_Depends            
          setUp_Static_Network
             setUp_network_creattion_Script
                setUp_dnsmasq
                   setUp_firewall
                   
     else
          exit 
      fi
}
###Main - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ -
if [ $EUID != 0 ];then
    echo "run as root";exit
else 
    main
fi

