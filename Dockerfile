FROM debian:bookworm-slim
# ex: MAINTAINER Jens Erat <email@jenserat.de>

VOLUME /srv
EXPOSE 139 445
#EXPOSE 137 138 139 445 # skip old NETBIOS, NetBIOS over TCP (139) is enough (445 plus DNS would be sufficient too, if not needing auto detection of services)

ENV DEBIAN_FRONTEND noninteractive

RUN \
	apt-get update && \
	apt-get install --no-install-recommends -y samba && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY smb.conf /etc/samba/smb.conf

# Pregenerate password database to prevent warning messages on container startup
RUN /usr/sbin/smbd && sleep 10 && smbcontrol smbd shutdown

ENTRYPOINT [ -z ${TERM} ] && echo 'Please attach a pseudo-tty (`docker run -t jenserat/samba-publicshare`)' || /usr/sbin/smbd -FSD -d1 --option=workgroup=${workgroup:-home}
