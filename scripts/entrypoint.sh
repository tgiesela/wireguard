#!/bin/bash
#set -e
wgdir=/etc/wireguard
if [ "$1" = "run-server" ]; then


    if [ ! -f ${wgdir}/.alreadyconfigured ] ; then
	echo "Configuring server"
	cp -r /home/config/. /etc/wireguard/

	cd /home/WireGuard/src
	make && make install
	cp -r /home/config/* ${wgdir}/
	mkdir -p ${wgdir}/server
        wg genkey | tee ${wgdir}/server/key.priv | wg pubkey > ${wgdir}/server/key.pub
	key=$(cat ${wgdir}/server/key.priv)
	sed -i 's|:SERVER_PRIVKEY:|'"$key"'|' ${wgdir}/wg0.conf

	touch ${wgdir}/.alreadyconfigured
    fi
    echo "Server configured"

    config=$(ls ${wgdir}/wg0.conf | head -1)
    if ip a | grep -q $(basename $config | cut -f 1 -d '.'); then
        echo "Stopping existing interface"
        wg-quick down $config
    fi

    echo "Starting wireguard using $config"
    wg-quick up $config
    echo "Running config:"
    wg

    shutdown() {
        echo "Stopping wireguard"
        wg-quick down $config
        rmmod wireguard
        echo "Uninstalling dkms module"
        dkms uninstall wireguard/$MODULE_VERSION
        exit 0
    }
    trap shutdown SIGINT SIGTERM SIGQUIT

    sleep infinity &
    wait

elif [ "$1" = "gen-key" ]; then
    PRIVATE_KEY=$(wg genkey)
    PUBLIC_KEY=$(echo ${PRIVATE_KEY} | wg pubkey)
    echo "Private key: ${PRIVATE_KEY}"
    echo "Public key: ${PUBLIC_KEY}"
    exit 0
else
    exec $@
fi
