# Wireguard on Raspbery Pi 3B+
Wireguard on raspberry pi 3B+r

## First time configuration

Before building, make sure the package 'raspberrypi-kernel-headers' is installed
on the docker host.

To build the container simply run:

>docker-compose build 

After the container is successfully built you can start them for the first 
time with:

>docker-compose up -d

and subsequent start and stop can be done with:

>docker-compose start
>docker-compose stop

Inside the container you can execute the /etc/wireguard/add-client.sh script to 
create a configuration for a client. 
	
	./add-client.sh <name>

It will create the configuration(wg0.conf) inside the clients subdirectory.

The configuration uses the 10.8.8.0/24 subnet. If you like another one, change
it in config/wg0.conf and in config/client.conf. You also need to change the 
endpoint here. This should reflect the internet-address to which the clients 
should connect.

Note:  the iptables script uses a devicename which depends on the os you
       are using. On a Rpi 4 is was enp0s3. You will have to change it to
       your devicename (replace eth0 by enp0s3 or similar)

Note:  If the command iptables -L inside your docker reports that iptables-legacy
       is present, replace the iptables commands in addrules  and deleterules by
       iptables-legacy.
