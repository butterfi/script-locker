import fnmatch
import os

member_path="/usr/lib/cgi-bin/yabb2/Members/"
poststring='\'postcount\',\"0\"'




#search all vars files in members directory
for filename in os.listdir(member_path):
    if fnmatch.fnmatch(filename, '*.vars'):
        #find which ones have a zero post count
        f = open(filename, 'r')
        findlines=f.read()
        if poststring in findlines:
            #now that we have a list of files
            #break filename into parts and add filename without ext
            #to array
            singlefile=filename.rsplit('.vars')
            #singlefile[0] gets name without extension
            #print singlefile[0]
            #remove vars
            badvars = singlefile[0] + '.vars'
            badmsg = singlefile[0] + '.msg'
            badrlog = singlefile[0] + '.rlog'                         
            badims = singlefile[0] + '.ims'             
            badlog = singlefile[0] + '.log'
            
            #remove!
            bad_msgpath = member_path + badmsg
            bad_rlog = member_path + badrlog
            bad_ims = member_path + badims
            bad_log = member_path + badlog
            bad_vars = member_path + badvars           
            #print bad_msgpath
            if os.path.isfile(bad_msgpath):
              os.remove(bad_msgpath)
              print 'removing bad msg'
              
            if os.path.isfile(bad_rlog):
              os.remove(bad_rlog)
              print 'removing bad rlog'
              
            if os.path.isfile(bad_ims):
              os.remove(bad_ims)
              print 'removing bad ims'
              
            if os.path.isfile(bad_log):
              os.remove(bad_log)
              print 'removing bad log'            
          
            if os.path.isfile(bad_vars):
              os.remove(bad_vars)
              print 'removing bad vars'
        