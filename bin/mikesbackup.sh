#!/usr/bin/env bash -x -e

# Preamble

echoerr() {
    echo "$@" 1>&2;
}

# Mount rsync target

if [ -z "$MIKESBACKUP_NFS_SOURCE" ]; then
    echoerr "Please set MIKESBACKUP_NFS_SOURCE."
    exit 1
fi

if [ -z "$MIKESBACKUP_NFS_TARGET" ]; then
    echoerr "Please set MIKESBACKUP_NFS_TARGET."
    exit 1
fi

if [ -z "$MIKESBACKUP_DIR_TARGET" ]; then
    echoerr "Please set MIKESBACKUP_DIR_TARGET."
    exit 1
fi

if [ -z "$MIKESBACKUP_HOME" ]; then
    echoerr "Please set MIKESBACKUP_HOME."
    exit 1
fi

NFS_TARGET="/Volumes/data"
MOUNT="mount -t nfs $MIKESBACKUP_NFS_SOURCE $MIKESBACKUP_NFS_TARGET"
$MOUNT

# Rsync backup script

RSYNC_TARGET="$MIKESBACKUP_NFS_TARGET/$MIKESBACKUP_DIR_TARGET"

if [[ -d $RSYNC_TARGET ]]; then
    RSYNC_EXCLUDES="$MIKESBACKUP_HOME/.rsync-filter"
    RSYNC="rsync -av --delete --delete-excluded --exclude-from="$RSYNC_EXCLUDES" $MIKESBACKUP_HOME $RSYNC_TARGET"
    sudo -u mike $RSYNC
    echo "Rsync completed"
else
    echo "Could not find directory $RSYNC_TARGET; aborting"
fi
