#!/bin/sh

# Tarsnap backup script
# Written by Tim Bishop, 2009; Mike Thvedt, 2012.

### CONFIG

# Directories to backup
#DIRS="/home /etc /usr/local/etc"
DIRS="/home"

# Number of daily/weekly/etc backups to keep
DAILY=7
WEEKLY=4
# Which day to do weekly backups on 1-7, Monday = 1
WEEKLY_DAY=1
MONTHLY=3
# 01-31 (leading 0 is important)
MONTHLY_DAY=01

# Path to tarsnap
TARSNAP=`which tarsnap`

### END CONFIG

# date variables
DOW=`date +%u`
DOM=`date +%d`
MOY=`date +%m`
YEAR=`date +%Y`
TIME=`date +%H%M%S`

# Backup name
if [ X"$DOM" = X"$MONTHLY_DAY" ]; then
	# monthly backup
	BACKUP="$YEAR$MOY$DOM-$TIME-monthly"
elif [ X"$DOW" = X"$WEEKLY_DAY" ]; then
	# weekly backup
	BACKUP="$YEAR$MOY$DOM-$TIME-weekly"
else
	# daily backup
	BACKUP="$YEAR$MOY$DOM-$TIME-daily"
fi

# Do backups
for dir in $DIRS; do
	EXTRA_FLAGS="--lowmem"

	echo "==> create $BACKUP-$dir"
	$TARSNAP $EXTRA_FLAGS -c -f $BACKUP-$dir $dir
done

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
rm $TMPFILE

