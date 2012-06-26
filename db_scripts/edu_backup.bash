#!/bin/bash 
#  Modified from:   http://sourceforge.net/projects/automysqlbackup/ 
#  Dan Shumaker 9/9/08
# updated: 1/10/2011
# updated: 8/11/2011  Added --ignore-table options
# updated: 12/21/2011 Added schema dump with -d and --databases

STORAGE="/data/backups"
LOGDIR="${STORAGE}/logs"
USERNAME=webuser
PASSWORD=tacoshop
DBHOST=localhost
DBNAMES="drupal"
MAXATTSIZE="4000"
MAILADDR="dan.shumaker@edutopia.org,geoff.butterfi@edutopia.org"
#TBEXCLUDE="drupal.notifications drupal.notifications_event drupal.notifications_fields drupal.notificiations_queue drupal.notifications_sent drupal.sessions drupal.accesslog drupal.cache drupal.cache_form drupal.cache_apachesolr drupal.cache_block drupal.cache_content drupal.cache_filter drupal.cache_menu drupal.cache_page drupal.cache_update drupal.cache_views drupal.cache_views_data"
TBEXCLUDE="drupal.sessions drupal.accesslog drupal.cache drupal.cache_form drupal.cache_apachesolr drupal.cache_block drupal.cache_content drupal.cache_filter drupal.cache_menu drupal.cache_page drupal.cache_update drupal.cache_views drupal.cache_views_data"
MDBNAMES="$DBNAMES"
DBEXCLUDE=""
CREATE_DATABASE=yes
SEPDIR=yes
DOWEEKLY=6
COMP=gzip
COMMCOMP=no
LATEST=yes
MAX_ALLOWED_PACKET=
SOCKET=
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/mysql/bin 
DATE=`date +%m-%d-%Y_%Hh%Mm`				# Datestamp e.g 9-03-2008_15:45 
DOW=`date +%A`							# Day of the week e.g. Monday
DNOW=`date +%u`						# Day number of the week 1 to 7 where 1 represents Monday
DOM=`date +%d`							# Date of the Month e.g. 27
M=`date +%B`							# Month e.g January
W=`date +%V`							# Week Number e.g 37
KEEP_HISTORY=no
LOGFILE=$LOGDIR/backup-${DATE}.log		# Logfile Name
LOGERR=$LOGDIR/backup_ERRORS_-${DATE}.log		# Logfile Name
OPTIMIZE=yes

#OPT="--quote-names --add-drop-database --opt"			# OPT string for use with mysqldump ( see man mysqldump )
OPT="--quote-names --opt"			# OPT string for use with mysqldump ( see man mysqldump )
OOPT="--quote-names --opt"			# This string is for the schema dump


for exclude in $TBEXCLUDE
do
    OPT="$OPT --ignore-table=$exclude"
done
addschema=0
if [ "$TBEXCLUDE" != "" ]; then
    addschema=1
fi

if [ "$KEEP_HISTORY" = "no" ]; then
	rm -rf $STORAGE/daily
	rm -rf $STORAGE/weekly
	rm -rf $STORAGE/monthly
fi

if [ ! -e "$STORAGE" ]		# Check Backup Directory exists.
	then
	mkdir -p "$STORAGE"
fi
if [ ! -e "$LOGDIR" ]		# Check Log Directory exists.
	then
	mkdir -p "$LOGDIR"
fi
if [ "$COMMCOMP" = "yes" ];
	then
		OPT="$OPT --compress"
	fi
if [ "$MAX_ALLOWED_PACKET" ];
	then
		OPT="$OPT --max_allowed_packet=$MAX_ALLOWED_PACKET"
	fi
if [ ! -e "$STORAGE" ]		# Check Backup Directory exists.
	then
	mkdir -p "$STORAGE"
fi
if [ ! -e "$STORAGE/daily" ]		# Check Daily Directory exists.
	then
	mkdir -p "$STORAGE/daily"
fi
if [ ! -e "$STORAGE/weekly" ]		# Check Weekly Directory exists.
	then
	mkdir -p "$STORAGE/weekly"
fi
if [ ! -e "$STORAGE/monthly" ]	# Check Monthly Directory exists.
	then
	mkdir -p "$STORAGE/monthly"
fi


touch $LOGFILE
exec 6>&1           # Link file descriptor #6 with stdout.  Saves stdout.
exec > $LOGFILE     # stdout replaced with file $LOGFILE.
touch $LOGERR
exec 7>&2           # Link file descriptor #7 with stderr.  Saves stderr.
exec 2> $LOGERR     # stderr replaced with file $LOGERR.


dbdump () {
    if [ $addschema ]; then
        # This dumps just the schema so that ignored tables get re-created when the backup file is imported.
        mysqldump --user=$USERNAME --password=$PASSWORD --host=$DBHOST -d $OOPT --databases $1 > $2
        echo "mysqldump --user=$USERNAME --password=$PASSWORD --host=$DBHOST $OPT $1 > $2"
        # Change to concat instead of redirect/overwrite
        mysqldump --user=$USERNAME --password=$PASSWORD --host=$DBHOST $OPT $1 >> $2
    else
        echo "mysqldump --user=$USERNAME --password=$PASSWORD --host=$DBHOST $OPT $1 > $2"
        mysqldump --user=$USERNAME --password=$PASSWORD --host=$DBHOST $OPT $1 > $2
    fi
	# used sed before we were using --ignore-table
	#sed -f /data/backups/deleteinserts.sed $2 > $2.sedified
	#mv $2.sedified $2
	return 0
}

SUFFIX=""
compression () {
	if [ "$COMP" = "gzip" ]; then
		gzip -f "$1"
		echo
		echo Backup Information for "$1"
		gzip -l "$1.gz"
		SUFFIX=".gz"
	elif [ "$COMP" = "bzip2" ]; then
		echo Compression information for "$1.bz2"
		bzip2 -f -v $1 2>&1
		SUFFIX=".bz2"
	else
		echo "No compression option set, check advanced settings"
	fi
	if [ "$LATEST" = "yes" ]; then
		rm -fv "$STORAGE/latest.gz"
		ln -s $1$SUFFIX "$STORAGE/latest.gz"
	fi	
	return 0
}


if [ "$SEPDIR" = "yes" ]; then # Check if CREATE DATABSE should be included in Dump
	if [ "$CREATE_DATABASE" = "no" ]; then
		OPT="$OPT --no-create-db"
	else
		OPT="$OPT --databases"
	fi
else
	OPT="$OPT --databases"
fi
if [ "$DBHOST" = "localhost" ]; then
	HOST=`hostname`
	if [ "$SOCKET" ]; then
		OPT="$OPT --socket=$SOCKET"
	fi
else
	HOST=$DBHOST
fi
if [ "$DBNAMES" = "all" ]; then
        DBNAMES="`mysql --user=$USERNAME --password=$PASSWORD --host=$DBHOST --batch --skip-column-names -e "show databases"| sed 's/ /%/g'`"
	# If DBs are excluded
	for exclude in $DBEXCLUDE
	do
		DBNAMES=`echo $DBNAMES | sed "s/\b$exclude\b//g"`
	done
        MDBNAMES=$DBNAMES
fi
	
echo ======================================================================
echo Backup of Database Server - $HOST
echo ======================================================================
if [ "$SEPDIR" = "yes" ]; then
echo Backup Start Time `date`
echo ======================================================================
	# Monthly Full Backup of all Databases
	if [ $DOM = "01" ]; then
		for MDB in $MDBNAMES
		do
 
			 # Prepare $DB for using
		        MDB="`echo $MDB | sed 's/%/ /g'`"
			echo Monthly Backup of $MDB...
				dbdump "$MDB" "$STORAGE/monthly/${MDB}_$DATE.$M.$MDB.sql"
				compression "$STORAGE/monthly/${MDB}_$DATE.$M.$MDB.sql"
			echo ----------------------------------------------------------------------
		done
	fi
	for DB in $DBNAMES
	do
	# Prepare $DB for using
	DB="`echo $DB | sed 's/%/ /g'`"
	
	# Weekly Backup
	if [ $DNOW = $DOWEEKLY ]; then
		echo Weekly Backup of Database \( $DB \)
		echo Rotating 5 weeks Backups...
			if [ "$W" -le 05 ];then
				REMW=`expr 48 + $W`
			elif [ "$W" -lt 15 ];then
				REMW=0`expr $W - 5`
			else
				REMW=`expr $W - 5`
			fi
		eval rm -fv "$STORAGE/weekly/$DB_week.$REMW.*" 
		echo
			dbdump "$DB" "$STORAGE/weekly/${DB}_week.$W.$DATE.sql"
			compression "$STORAGE/weekly/${DB}_week.$W.$DATE.sql"
		echo ----------------------------------------------------------------------
	
	# Daily Backup
	else
		echo Daily Backup of Database \( $DB \)
		echo Rotating last weeks Backup...
		eval rm -fv "$STORAGE/daily/*.$DOW.sql.*" 
		echo
			dbdump "$DB" "$STORAGE/daily/${DB}_$DATE.$DOW.sql"
			compression "$STORAGE/daily/${DB}_$DATE.$DOW.sql"
		echo ----------------------------------------------------------------------
	fi
	done
      echo Backup End `date`
      echo ======================================================================
else # One backup file for all DBs
      echo Backup Start `date`
      echo ======================================================================
	# Monthly Full Backup of all Databases
	if [ $DOM = "01" ]; then
		echo Monthly full Backup of \( $MDBNAMES \)...
			dbdump "$MDBNAMES" "$STORAGE/monthly/$DATE.$M.all-databases.sql"
			compression "$STORAGE/monthly/$DATE.$M.all-databases.sql"
		echo ----------------------------------------------------------------------
	fi
	# Weekly Backup
	if [ $DNOW = $DOWEEKLY ]; then
		echo Weekly Backup of Databases \( $DBNAMES \)
		echo
		echo Rotating 5 weeks Backups...
			if [ "$W" -le 05 ];then
				REMW=`expr 48 + $W`
			elif [ "$W" -lt 15 ];then
				REMW=0`expr $W - 5`
			else
				REMW=`expr $W - 5`
			fi
		eval rm -fv "$STORAGE/weekly/week.$REMW.*" 
		echo
			dbdump "$DBNAMES" "$STORAGE/weekly/week.$W.$DATE.sql"
			compression "$STORAGE/weekly/week.$W.$DATE.sql"
		echo ----------------------------------------------------------------------
		
	# Daily Backup
	else
		echo Daily Backup of Databases \( $DBNAMES \)
		echo
		echo Rotating last weeks Backup...
		eval rm -fv "$STORAGE/daily/*.$DOW.sql.*" 
		echo
			dbdump "$DBNAMES" "$STORAGE/daily/$DATE.$DOW.sql"
			compression "$STORAGE/daily/$DATE.$DOW.sql"
		echo ----------------------------------------------------------------------
	fi
    echo Backup End Time `date`
    echo ======================================================================
fi
if [ "$OPTIMIZE" == "yes" ]; then
    echo ======================================================================
	echo "Optimizing Database"
	mysqloptimize -u $USERNAME -p$PASSWORD $DBNAMES
    echo ======================================================================
fi
echo Total disk space used for backup storage..
echo Size - Location
du -hs "$STORAGE"
echo 
echo Total space left on disk.
echo ----------------------------------------------------------------------
df -h "$STORAGE" | awk '{ printf("%s\t%s\n", $4, $5) }'
echo ======================================================================

echo ======================================================================
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ -s "$LOGERR" ]
    then
      cat "$LOGERR" | mail -s "ERRORS REPORTED: Website Backup error Log for $HOST - $DATE" $MAILADDR
      cat "$LOGFILE" | mail -s "Website Backup Log for $HOST - $DATE" $MAILADDR
      echo
      echo "###### WARNING ######"
      echo "Errors reported during website_backup.sh execution.. "
      echo "Error log below.."
      cat "$LOGERR"
else
    cat "$LOGFILE"
    cat "$LOGFILE" | mail -s "Website Backup Log for $HOST - $DATE" $MAILADDR
fi
