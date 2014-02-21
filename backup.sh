#!/bin/sh
SOURCE=$HOME/
DEST=nelhage@nelhage.com:/data/backup/$(hostname)/home/nelhage
: ${SSH_AUTH_SOCK:=/tmp/ssh.nelhage/auth}
export SSH_AUTH_SOCK

VERBOSE=
EXTRAOPTS=

set -- $(getopt -o vnt: -l verbose,throttle:,dry-run -- "$@")
if [ $? -ne 0 ]
then
    echo 'Usage: backup.sh [-v -tKPBS]' 2>&1
    exit -1
fi

for opt
do
    case "$opt" in
        -v | --verbose)  shift; VERBOSE=1 ;;
        -t | --throttle )
            shift;
            LIM=$(eval echo $1);
            EXTRAOPTS="$EXTRAOPTS --bwlimit=$LIM";
            shift
            ;;
        -n | --dry-run )
            shift;
            EXTRAOPTS="$EXTRAOPTS --dry-run"
    esac
done

if [ "$VERBOSE" = "1" ]
then
    EXTRAOPTS="$EXTRAOPTS -P"
else
    EXTRAOPTS="$EXTRAOPTS -q"
fi

rsync -ax $EXTRAOPTS --rsh=ssh --delete --delete-excluded \
      --exclude-from=$HOME/.backup/excludes \
      "$SOURCE" "$DEST"

(echo -n "$? "; date ) >> ~/.backup/backups
