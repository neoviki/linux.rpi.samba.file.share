dhcp_conf="/etc/dhcpcd.conf"
dhcp_conf_bkup="/etc/dhcpcd_orig.conf"
dns_masq="/etc/dnsmasq.conf"
dns_masq_bkup="/etc/dnsmasq_orig.conf"
ap_conf="/etc/hostapd/hostapd.conf"
ap_conf_bkup="/etc/hostapd/hostapd_backup.conf"
default_hostap="/etc/default/hostapd"
default_hostap_bkup="/etc/default/.hostapd_bkup"

sudo apt-get update

sudo apt-get upgrade

echo "Installing DNS and DHCP packages"
sudo apt-get -y install dnsmasq 

echo "Installing WiFi Access Point packages"
sudo apt-get -y install hostapd

echo "Stopping DNS and DHCP Services"
sudo systemctl stop dnsmasq

echo "Stopping WiFi Access Point Service"
sudo systemctl stop hostapd

echo "Assigning Static IP to WiFi Interface"
sudo cp $dhcp_conf $dhcp_conf_bkup  
echo "   -> Modifying /etc/dhcpcd.conf"
    echo "interface wlan0" | sudo tee -a $dhcp_conf > /dev/null
    echo "   static ip_address=192.168.6.1/24" | sudo tee -a $dhcp_conf > /dev/null
    echo "   nohook wpa_supplicant" | sudo tee -a $dhcp_conf > /dev/null


echo "Restarting DHCP Service"
sudo service dhcpcd restart

echo "Configuring DHCP Server"
sudo mv $dns_masq $dns_masq_bkup

echo "interface=wlan0" | sudo tee -a $dns_masq > /dev/null
echo "dhcp-range=192.168.6.2,192.168.6.10,255.255.255.0,24h" | sudo tee -a $dns_masq > /dev/null


echo "Configuring WiFi Access Point"
sudo cp $ap_conf $ap_conf_bkup

#Tested
#[ hw_mode : channel ]
# [g, 1, 2, 3, 5]
#[b, 1, 2, 3, 4]
#a, n, ac are not working

echo "interface=wlan0" | sudo tee -a $ap_conf > /dev/null
echo "driver=nl80211" | sudo tee -a $ap_conf > /dev/null
echo "ssid=RPI_AP" | sudo tee -a $ap_conf > /dev/null
echo "hw_mode=g" | sudo tee -a $ap_conf > /dev/null
echo "channel=1" | sudo tee -a $ap_conf > /dev/null
echo "wmm_enabled=0" | sudo tee -a $ap_conf > /dev/null
echo "macaddr_acl=0" | sudo tee -a $ap_conf > /dev/null
echo "auth_algs=1" | sudo tee -a $ap_conf > /dev/null
echo "ignore_broadcast_ssid=0" | sudo tee -a $ap_conf > /dev/null
echo "wpa=2" | sudo tee -a $ap_conf > /dev/null
echo "wpa_passphrase=raspberry" | sudo tee -a $ap_conf > /dev/null
echo "wpa_key_mgmt=WPA-PSK" | sudo tee -a $ap_conf > /dev/null
echo "wpa_pairwise=TKIP" | sudo tee -a $ap_conf > /dev/null
echo "rsn_pairwise=CCMP" | sudo tee -a $ap_conf > /dev/null


sudo cp $default_hostap $default_hostap_bkup
sudo sed -i "/#DAEMON_CONF.*/c DAEMON_CONF\=\"\/etc\/hostapd\/hostapd.conf\"" $default_hostap

echo "Restart DNS & DHCP Service"
sudo systemctl start dnsmasq

echo "Restart WiFi Access Point Service"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

echo "Enable IP Forwarding"
sudo sed -i "/net.ipv4.ip_forward.*/c  net.ipv4.ip_forward=1" /etc/sysctl.conf

echo "Masquerade outbount traffic [ eth0 ]"
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

echo "Save iptables rules"
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo sed -i "/exit 0/i iptables-restore < /etc/iptables.ipv4.nat" /etc/rc.local

