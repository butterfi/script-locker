#!/usr/bin/env python

###############################
# Sync Edutopia servers
# run this from the command line: sudo ./sync_server
# Geoff B, 4/2010
###############################

import socket, sys, getpass, os,pysvn
import base64, urllib2, shutil, datetime
import time, pwd, httplib
import subprocess

os.system("clear")

##############################################################
# Set up dictionaries for hosting info
##############################################################

# the target servers hostname, followed by the name used by server_path
server_hostname = { 'GLUCAS-web1.edutopia.org': 'production',
                   'staging': 'staging',
                   'dev': 'dev',
                   'bubu.local': 'Geoff laptop',
                   'einstein': 'einstein',
                   'debian': 'debian',
                   'ldev': 'ldev',
                   }
                   
# the target servers path to the web directory. Note: trailing slash and do not include the actual web directory name
server_path = { 'production': '/usr/',
               'staging': '/var/',
               'dev': '/var/',
               'Geoff laptop': '/Users/butterfi/websites/Web/',
               'einstein': '/var/',
               'debian': '/var/',
               'ldev': '/var/',
}

# the target servers root web directory
server_webdirectory = {'production': 'www',
                       'staging': 'www',
                       'dev': 'www',
                       'Geoff laptop': 'test',
                       'einstein': 'www',
                       'debian': 'www',
                       'ldev': 'www',
                       }


#Soft link creation
softlinks = {'/files/existing/images': '/images',
             '/files/existing/enews': '/enews',
             '/files/existing/media': '/media',
             '/files/existing/slates': '/slates',
             '/files/existing/pdfs': '/pdfs',
             '/files/existing/pdf': '/pdf',
             '/files/existing/ppt': '/ppt',
             '/files/existing/teachingmodules': '/teachingmodules',
            }

HOSTNAME = None

# Idenitify name of logged in user
USERNAME = os.getlogin()

log = '/var/log/sync_server.log'

#############################################################################################
# Discovery: identify server, set proper path variables, check w/user to continue
#############################################################################################

def discovery():
  global HOSTNAME
  try:
    host = socket.gethostname()
  except Exception, e:
    print "An unexpected exception was encountered: %s" % str(e)
    sys.exit(1)
  
  if server_hostname.has_key(host):
    HOSTNAME = server_hostname[host]
  else:
    print 'This script is not configured for this server. Please contact your sys admin for assistance.'
    sys.exit(1)
  
  #Remind user which server they're on.
  print '#############################################'
  print "## You are on the %s server." % str(HOSTNAME)
  print '#############################################'
  
  
  #check for pre-existing directory and exit if found
  if os.path.isdir(server_path[HOSTNAME] + 'html-new'):
    print 'Installation directory already exists. Program exiting.'
    sys.exit(1)
  
  #check for files directory
  if os.path.isdir(server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '/files'):
    pass
  else:
    print server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '/files directory is missing. Program exitiing.'
    sys.exit(1)  
  
  #test that user has permissions to write to directory  
  PATH_CHECK = os.access(server_path[HOSTNAME], os.W_OK)
  if PATH_CHECK is 'False':
    print 'This user does not have permission to write to write to the ' + server_path[HOSTNAME] + ' directory.'
    print 'Program exiting.'
    sys.exit(1)    

  return True
  
###############################
# Export from Git
# Note: Unfuddle reuires a key-gen pair for authorization. This script will not work without it.
###############################

def setup_git():

  global HOSTNAME
  #set the variables
  clone_path = 'git@edutopia.unfuddle.com:edutopia/production.git'
  clone_cmd = 'git clone ' + clone_path + ' ' + server_path[HOSTNAME] + 'html-new'
  #run the command
  pipe = subprocess.Popen(clone_cmd, shell=True)
  pipe.wait()
  print 'Git Clone completed'
  
  #remove .git directory
  remove_git = 'rm -r ' + server_path[HOSTNAME] + 'html-new/.git'
  pipe = subprocess.Popen(remove_git, shell=True)
  pipe.wait()
  print server_path[HOSTNAME] + 'html-new/.git has been removed.'
  
  return True
  

###############################
# Deploy Files
###############################

def deploy_files():
  
  this_time = datetime.datetime.now().strftime('%Y-%m-%d-%H-%M')
  
  #Check that html-new directory is in place
  if os.path.isdir(server_path[HOSTNAME] + 'html-new'):
    print 'Git Export directory is in place... Check!'
  else:
    print 'The Git Export directory is not where I expect it -- program exiting.'
    sys.exit(1)

  #Check that live web directory is in place
  if os.path.isdir(server_path[HOSTNAME] + server_webdirectory[HOSTNAME]):
    print 'Web directory is in place... Check!'
  else:
    print 'The web directory is not where I expect it -- program exiting.'
    sys.exit(1)


  #Move current live web directory to a safe place
  print 'Moving web directory to back-up location...'
  shutil.move(server_path[HOSTNAME] + server_webdirectory[HOSTNAME], server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '-' + this_time)
  
  #Move new directory into place
  shutil.move(server_path[HOSTNAME] + 'html-new', server_path[HOSTNAME] + server_webdirectory[HOSTNAME])
  
  #Move files directory from backup folder to live folder
  print 'Moving files directory...'
  shutil.move(server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '-' + this_time + '/files', server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '/files')
  print server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '-' + this_time + '/files', server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + '/files'
  
  #create symbolic links
  print 'Creating aliases...'
  for link in softlinks:
    os.symlink(server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + link, server_path[HOSTNAME] + server_webdirectory[HOSTNAME] + softlinks[link])
  
  # Change permissions on staging, dev, and debian (vmware diskimage)
  
  if HOSTNAME == "staging" or HOSTNAME == "dev" or HOSTNAME == "debian" or HOSTNAME == "einstein":
     #identify uid and gid for user
    pw = pwd.getpwnam(USERNAME)
    uid = pw.pw_uid
    gid = pw.pw_gid

    #get server path
    path = server_path[HOSTNAME] + server_webdirectory[HOSTNAME]
    
    
    #set owner and group privilleges on root level www directory
    os.chmod(path, 0775)
    os.chown(path, uid, gid)
    
    #now set owner and  group for the interior files
    #change owner/group
    for root, dirs, files in os.walk(path):  
      for momo in dirs:  
        os.chown(os.path.join(root, momo), uid, gid)
        os.chmod(os.path.join(root, momo), 0775)       
      for momo in files:
        os.chown(os.path.join(root, momo), uid, gid)
        os.chmod(os.path.join(root, momo), 0775)
       
    
    #finally, set files directory to be world writable
    
    filesdir = path + '/files'
    os.chmod(filesdir, 0777)
    
    #now set owner and  group for the interior files
    #change owner/group
    for root, dirs, files in os.walk(filesdir):  
      for momo in dirs:  
        os.chmod(os.path.join(root, momo), 0777)
      for momo in files:
        os.chmod(os.path.join(root, momo), 0777)     
    
    
    
    print 'File Owner/Group Updated.'

  
  return True

###############################
# Main program 
###############################

if __name__ == "__main__":
  if os.geteuid() != 0:
    print "sorry, you need to run this as root"
    sys.exit(1)
  
  log_fo = open(log, 'a+')
  if discovery() == True:
    print 'Preparing to set-up Git Clone...'
    if setup_git() == True:
      print 'Preparing to move directories...'
      if deploy_files() == True:
        print 'Operation is complete! Remember to flush the caches!'
        log_fo.write("%s Successful SUBVERSION EDUTOPIA UNFUDDLE sync of server %s to %s \n" % ( time.strftime("%b %d %Y %H:%M:%S ", time.localtime()), HOSTNAME, server_path[HOSTNAME] + server_webdirectory[HOSTNAME] ))
  log_fo.close()
