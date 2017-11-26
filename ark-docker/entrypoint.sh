#!/bin/sh -e

# Change the UID if needed
if [ ! "$(id -u steam)" -eq "$UID" ]; then
        echo "Changing steam uid to $UID."
        usermod -o -u "$UID" steam ;
fi
# Change gid if needed
if [ ! "$(id -g steam)" -eq "$GID" ]; then
        echo "Changing steam gid to $GID."
        groupmod -o -g "$GID" steam ;
fi

if [ -d /ark/log ]; then
	mkdir -p /ark/log
fi

if [ -f /ark/log/arkserver.log ] || [ -f /ark/log/arkmanager.log ]; then
	touch /ark/log/arkserver.log
	touch /ark/log/arkmanager.log
fi
# Put steam owner of directories (if the uid changed, then it's needed)
chown -R steam:steam /ark /home/steam

# avoid error message when su -p (we need to read the /root/.bash_rc )
chmod -R 777 /root/


# Allow groups to change files.
umask 002




if [ "$@" = "run" ]
then
  exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
else
  exec "$@"
fi
