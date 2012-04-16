#!/bin/sh
(
    PATH=$PATH:/usr/sbin:/sbin
    if ! flock -nx 9; then
        echo "Backup script is already running; aborting."
        exit 1;
    fi

    ip_dst=$(dig +short nelhage.com)

    [ "$ip_dst" ] || exit 0

    route=$(ip r get "$ip_dst")

    PATH=/usr/local/bin:/usr/bin:/bin
    ARGS=""

    tethering() {
        ip link ls usb0 >/dev/null 2>&1
    }

    tethering && exit 0;

#    if ! ( echo $route | grep -qF 'via 18.' ||
#            echo $route | grep -qF 'via 18.100' ||
#            echo $route | grep -qF 'via 18.101' );
#    then
    ARGS="-t 200"
#    fi

    /home/nelhage/bin/backup.sh $ARGS
) 9>/home/nelhage/.backup/lock
