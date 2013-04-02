#!/usr/bin/env python

######################################################
# Sync Exploratorium Database to Local dev environment
# 3-20-13 GB
######################################################


import MySQLdb, os
import sys, datetime
import subprocess

HOSTNAME = 'localhost'
MYSQLUSER = 'webuser'
MYSQLPASS = 'tacoshop'
DBNAME = ''


developer_databases = { 'devdrupal':'172.168.16.153',

                        }

######################################################
# Check for local MySQL, user, and DB
######################################################

def get_DB_name():
    global DBNAME
    ask_db_name = raw_input('What is the name of the database you want to update? ')
    if developer_databases.has_key(ask_db_name):
        print 'Yes, I have a record for ' + ask_db_name + ' on server ' + developer_databases[ask_db_name]
        DBNAME = ask_db_name
    else:
        print 'I\'m sorry, but this script has no knowledge of a database called "' + ask_db_name + '". Please consult a sys admin.'
        sys.exit(1)

def check_mysql_conn():
    try:
        con = MySQLdb.connect( HOSTNAME, MYSQLUSER, MYSQLPASS, DBNAME)
        print 'Database connection established'
        con.close

    except MySQLdb.Error, e:
        print "There is a problem connecting to the Database.\r"
        print "Error %d: %s" % (e.args[0], e.args[1])
        sys.exit(1)


def backup_mysqldb():
    ask_backup = raw_input('Your existing database will be erased. Would you like to back-up your existing database? (y or n) ')
    if ask_backup == 'y':
        this_time = datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
        backup_cmd = 'mysqldump -u ' + MYSQLUSER + ' -p' + MYSQLPASS + ' ' + DBNAME + ' | gzip > ~/' + DBNAME + '-' + this_time + '.sql.gz'
        pipe = subprocess.Popen(backup_cmd, shell=True)
        pipe.wait()
        print 'Existing DB has been backed up to your home directory.'
    elif ask_backup == 'n':
        print 'okay, not backing up your old database.'
    else:
        print 'Please choose \'y\' or \'n\'.'
        backup_mysqldb()


def load_mysqldb():
    ask_import = raw_input('Would you like to install the latest back-up copy of the database and replace your existing database? (y or n) ')

    if ask_import == 'y':
        #drop database and recreate
        drop_cmd = "DROP DATABASE %s" % DBNAME
        create_cmd = "CREATE DATABASE %s" % DBNAME 
        con = MySQLdb.connect(HOSTNAME, MYSQLUSER, MYSQLPASS, DBNAME)
        cursor = con.cursor()
        cursor.execute(drop_cmd)
        print 'database dropped and recreated'
        cursor.execute(create_cmd)

        import_cmd = 'mysql -u '+ MYSQLUSER + ' -p' + MYSQLPASS + ' -D ' + DBNAME + ' < /tmp/explo-drupal.sql'
        print import_cmd
        pipe = subprocess.Popen(import_cmd, shell=True)
        pipe.wait()
        print 'database imported'
        cursor.close
    elif ask_import == 'n':
        print 'okay, not importing a new copy of the database'
    else:
        print 'Please choose \'y\' or \'n\'.'
        load_mysqldb()        




if __name__ == "__main__":
    #clear terminal screen
    os.system("clear")
    get_DB_name();
    check_mysql_conn();
    #backup_mysqldb();
    load_mysqldb();



