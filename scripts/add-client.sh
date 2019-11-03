#!/bin/bash
configdir=/etc/wireguard/
FQDN=<your-external-hostname>
if [ $# -eq 0 ]
then
	echo "must pass a client name as an arg: $0 new-client"
else
	echo "Creating client config for: $1"

	mkdir -p ${configdir}/clients/$1

	wg genkey | tee ${configdir}/clients/$1/key.priv | wg pubkey > ${configdir}/clients/$1/key.pub
	key=$(cat ${configdir}/clients/$1/key.priv) 
	serverkey=$(cat ${configdir}/server/key.pub)

	ip="10.8.8."$(expr $(cat last-ip.txt | tr "." " " | awk '{print $4}') + 1)
	FQDN=gieselaar.ddns.net
	cat client.conf | sed -e 's/:CLIENT_IP:/'"$ip"'/' | \
			  sed -e 's|:CLIENT_KEY:|'"$key"'|' | \
			  sed -e 's|:SERVER_PUBKEY:|'"$serverkey"'|' | \
			  sed -e 's|:SERVER_ADDRESS:|'"$FQDN"'|' > clients/$1/wg0.conf
	echo $ip > last-ip.txt

 	echo "Created config!"
	echo "Adding peer"
	wg set wg0 peer $(cat ${configdir}/clients/$1/key.pub) allowed-ips $ip/32
	wg show
fi
