#!/bin/bash
# Wi-Fi Connector for FreeBSD
###Functions
# Display a banner
f_banner(){
	echo "LOGO HERE "#LOGO HERE
	echo " "
}

# Check if the script is running with root/sudo priv
f_rootcheck(){
	if [ $(id -u) -gt 0 ]; then
        	echo "This script requires ROOT or SUDO privileges"
        	exit 1
	fi
}

# Turn networking on for FreeBSD
f_netifon(){
	service netif start
}

# Turn networking off for FreeBSD
f_netifoff(){
	service netif stop
}

# Filter ifconfig output and set the physical adapter
f_wlans(){
	wlansdevices=$(ifconfig | awk '{print $1}' | grep wlan | sed 's/:/ /g')
	echo $wlansdevices
	printf "Please select an interface> "
	read -r wlandev
	parent_interface=$(ifconfig | grep -A 10 $wlandev | grep parent | awk '{print $3}')
}

# Scan for wireless networks
f_wlanscan(){
	ifconfig $wlandev up
	ifconfig $wlandev scan | grep SSID
}

# Connect to a Wi-Fi network using wpa_supplicant
f_wpaconnect(){
	printf "Enter the SSID of the network: "
	read -r ssid
	printf "Enter the passphrase: "
	read -rs passphrase
	wpa_passphrase "$ssid" "$passphrase" > /etc/wpa_supplicant.conf
	ifconfig $wlandev up
	ifconfig $wlandev scan
	ifconfig $wlandev nwid "$ssid" wpakey "$passphrase"
	dhclient $wlandev
}

# Main script
f_rootcheck
f_netifon
f_wlans
f_wlanscan
f_wpaconnect
