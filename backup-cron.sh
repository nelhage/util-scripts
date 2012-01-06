#!/bin/sh
(
    if ! flock -nx 9; then
        echo "Backup script is already running; aborting."
        exit 1;
    fi

    PATH=/usr/local/bin:/usr/bin:/bin
    ARGS=""
    if ! /sbin/ifconfig | grep -qF addr:18. ||
        /sbin/ifconfig | grep -qF addr:18.100 ||
        /sbin/ifconfig | grep -qF addr:18.101;
    then
        ARGS="-t 200"
    fi

    /home/nelhage/bin/backup.sh $ARGS
) 9>/home/nelhage/.backup/lock
