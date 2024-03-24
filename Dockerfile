FROM debian:latest
MAINTAINER Tonny Gieselaar <tgiesela@gmail.com>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="cron wget locales nano sudo net-tools iproute2 procps python3 python3-venv" \
    UPDATE="apt update && apt -y upgrade" \
    CLEANUP="apt -y autoremove && apt -y clean && rm -rf /var/lib/apt/lists"

RUN eval ${UPDATE} && \
        apt -qy install --no-install-recommends ${APTLIST} && \
    locale-gen --no-purge nl_NL.UTF-8 en_US.UTF-8 && \
    eval ${CLEANUP}

# Install python with netifaces
RUN eval ${UPDATE} && \
        apt -qy install --no-install-recommends \
                                python3-pip \
                build-essential \
                python3-dev && \
        python3 -m venv venv && \
        . venv/bin/activate && \
        pip install netifaces getmac && \
        apt -yq remove build-essential \
                       python3-dev && \
    eval ${CLEANUP}

RUN eval ${UPDATE} && \
        apt -qy install --no-install-recommends \
	        wireguard \
		iproute2 \
		iptables && \
    eval ${CLEANUP}

WORKDIR /home

RUN mkdir -p /home/config/
COPY scripts/entrypoint.sh /bin/entrypoint.sh
COPY scripts /home/config/
COPY config/ /home/config/

EXPOSE 51820
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "run-server" ]
