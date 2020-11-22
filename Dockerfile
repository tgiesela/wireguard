FROM debian:stretch
MAINTAINER Tonny Gieselaar <tonny@devosverzuimbeheer.nl>

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/etc/wireguard"]

# Setup ssh and install some additional tools
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
	net-tools \
	nano \
	apt-utils \
	wget \
	dnsutils \
	iputils-ping \
	git \
	gnupg \
	iproute2 \
	iptables \
	ifupdown \
	iputils-ping \
	libmnl-dev \
	libelf-dev \
	make \
	gcc \
	cpp \
	binutils \
	dkms \
	software-properties-common \
	kmod &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install wireguard and its dependencies
RUN echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
#RUN add-apt-repository ppa:wireguard/wireguard
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get upgrade -y gcc-8-base && \
#    apt-get install -y linux-headers-$(uname -r) &&\
#    apt-get install -y linux-headers-generic && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 
#    dkms uninstall wireguard/$(dkms status | awk -F ', ' '{ print $2 }')

WORKDIR /home
RUN git clone https://git.zx2c4.com/WireGuard

RUN mkdir -p /home/config/
COPY scripts/entrypoint.sh /bin/entrypoint.sh
COPY scripts /home/config/
COPY config/ /home/config/

EXPOSE 22 51820
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "run-server" ]
