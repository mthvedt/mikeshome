#!/bin/sh -x

# Rsync backup script

RSYNC_SOURCE="/Users/mike/"
RSYNC_TARGET="/Volumes/data/docs/mba1"
if [[ -d $RSYNC_TARGET ]]; then
RSYNC_EXCLUDES="/Users/mike/.rsync-filter"
RSYNC="rsync -av --delete --delete-excluded --exclude-from="$RSYNC_EXCLUDES" $RSYNC_SOURCE $RSYNC_TARGET"
echo "$RSYNC"
sudo -u mike $RSYNC
echo "Rsync completed"
else
echo "Could not find directory $RSYNC_TARGET; aborting"
fi

# Tarsnap backup script
# Written by Tim Bishop, 2009; Mike Thvedt, 2012.

### CONFIG

# Directories to backup
#DIRS="/home /etc /usr/local/etc"
DIRS="/Users/mike/Documents /Users/mike/Dropbox /Users/mike/programming"

# Number of daily/weekly/etc backups to keep
DAILY=21
WEEKLY=12
# Which day to do weekly backups on 1-7, Monday = 1
WEEKLY_DAY=1
MONTHLY=9
# 01-31 (leading 0 is important)
MONTHLY_DAY=01

# Path to tarsnap
TARSNAP=/usr/local/bin/tarsnap

### END CONFIG

# Give the mac time to acquire network connection
sleep 60

# date variables
DOW=`date +%u`
DOM=`date +%d`
MOY=`date +%m`
YEAR=`date +%Y`
TIME=`date +%H%M%S`

TMPFILE=/tmp/tarsnap.archives.$$
$TARSNAP --list-archives > $TMPFILE
# Backup name
# TODO: instead check if tmpfile contains backups.
if [ X"$DOM" = X"$MONTHLY_DAY" ]; then
	# monthly backup
	BACKUPS="$YEAR$MOY$DOM-$TIME-monthly"
fi
if [ X"$DOW" = X"$WEEKLY_DAY" ]; then
	# weekly backup
	BACKUPS="$YEAR$MOY$DOM-$TIME-weekly $BACKUPS"
fi
# daily backup
BACKUPS="$YEAR$MOY$DOM-$TIME-daily $BACKUPS"

# Do backups
for dir in $DIRS; do
#EXTRA_FLAGS="--lowmem"
EXTRA_FLAGS=""

	for backup in $BACKUPS; do
		echo "==> create $backup-$dir"
		$TARSNAP $EXTRA_FLAGS -c -f $backup-$dir $dir
	done
done
rm $TMPFILE

# Backups done, time for cleaning up old archives

# using tail to find archives to delete, but its
# +n syntax is out by one from what we want to do
# (also +0 == +1, so we're safe :-)
DAILY=`expr $DAILY + 1`
WEEKLY=`expr $WEEKLY + 1`
MONTHLY=`expr $MONTHLY + 1`

# Do deletes
TMPFILE=/tmp/tarsnap.archives.$$
$TARSNAP --list-archives > $TMPFILE
for dir in $DIRS; do
	for i in `grep -E "^[[:digit:]]{8}-[[:digit:]]{6}-daily-$dir" $TMPFILE | sort -rn | tail -n +$DAILY`; do
		echo "==> delete $i"
		$TARSNAP -d -f $i
	done
	for i in `grep -E "^[[:digit:]]{8}-[[:digit:]]{6}-weekly-$dir" $TMPFILE | sort -rn | tail -n +$WEEKLY`; do
		echo "==> delete $i"
		$TARSNAP -d -f $i
	done
	for i in `grep -E "^[[:digit:]]{8}-[[:digit:]]{6}-monthly-$dir" $TMPFILE | sort -rn | tail -n +$MONTHLY`; do
		echo "==> delete $i"
		$TARSNAP -d -f $i
	done
done
rm $TMPFILE # todo: trap

