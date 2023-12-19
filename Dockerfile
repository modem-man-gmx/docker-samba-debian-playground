# debian:12 is bookworm
FROM debian:12-slim

MAINTAINER Mo Demman <modem-man@gmx.net>

VOLUME /srv
EXPOSE 139 445
#EXPOSE 137 138 139 445 # skip old NETBIOS, NetBIOS over TCP (139) is enough (445 plus DNS would be sufficient too, if not needing auto detection of services)

ENV DEBIAN_FRONTEND noninteractive

RUN \
	apt update && \
	apt install --no-install-recommends -y samba && \
	apt clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# copy local copy of SMB config (general and shares definitions)
COPY smb.conf /etc/samba/smb.conf

# Pregenerate password database to prevent warning messages on container startup
RUN /usr/sbin/smbd && sleep 10 && smbcontrol smbd shutdown

# if TERM is not set, no TTY is attached to the container. A TTY should be attached for this variant of starting, so then it only print out a recommendation.
# else smbd is started with following (contradictionary and partly outdated) options:
#	/usr/sbin/smbd   old way of doint smbd, in the meantime it should be 'service smbd start' (and perhaps 'service nmbd start' before)
#		-F foreground, causes the main smbd process to not daemonize, i.e. double-fork and disassociate with the terminal. The main process does not exit. 
#		-S Option -S or --log-stdout is not supported, now use --debug-stdout or --log-basename=logdirectory
#		-D daemon, causes the server to operate as a daemon. Detaches itself and runs in the background. Operating the server as a daemon is the recommended way of running smbd
#		-d1 debug level 1 (NOT syslog numbering, but kind of verbosity 1..10)
#		--option=${workgroup} overrides compiled-in defaults and options read from the configuration file

ENTRYPOINT [ -z ${TERM} ] && echo 'Please attach a pseudo-tty (`docker run -t docker.io/modemman/samba-dancer`)' || /usr/sbin/smbd -FD -d1 --option=workgroup=${workgroup:-home}
