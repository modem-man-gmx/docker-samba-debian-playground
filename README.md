# Samba Folder Sharing

This image allows you to easily share folders to the public using the SMB 2.x to newer protocol.

## Usage

To share a folder, bind it as a volume to the internal path `/srv` and expose the ports required by the SMB protocol. An example would be

	docker run -td \
		--publish 445:445 \
		--publish 137:137 \
		--volume /srv/samba:/srv \
		modemman/samba-dancer

**Note:** observe the `-t` parameter, which attaches a pseudo-tty. This was not required on earlier releases of `smbd`. Without attaching a tty, `smbd` will exit immediately after starting up.
If you use a docker-compose setup, you should add `tty: true` to your `docker-compose.yml`

Use the optional `workgroup` environment variable to set the workgroup:

		--env workgroup=myworkgroup
if ommitted, it is setting "home" as workgroup name, intented to use laptop.home, server.home DNS names assigned in FritzBox or PiHole or similar DNS server.

The repository contains a wrapper script to easen up sharing folders, automatically exposing the ports as needed. Pass the path as first parameter (otherwise the working directory is shared), and optionally the work group as second parameter.

	samba-publicshare [path [workgroup]]

To share `/tmp` with the default workgroup name, run `samba-publicshare /tmp`. To share the working directory, run `samba-publicshare` without any parameters.

## Read-only Volumes

By [mounting a volume read-only](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume), the share will be read-only, but simply because of Samba not being able to write to the directory and thus returning an access denied error message, not by passing correct read-only permissions to the client.

## Stopping Samba

I didn't figure out a way yet to terminate Samba in foreground mode by pressing keys. Use `docker stop [name]` instead.

## Caveats

No access restrictions are applied, the shared folder is publically readable and writable! Reconsider usage in public networks.
