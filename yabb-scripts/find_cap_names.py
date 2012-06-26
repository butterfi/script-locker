#!/usr/bin/python


#run in members directory
import os
import fnmatch
member_path="/usr/lib/cgi-bin/yabb2/Members/"
checkname=''

 #parse the naughty list and replace line with empty line
def findname(line): 
  if 'realname' in line:
    #remove line return
    line = line.strip()
    #split line to isolate name
    line = line.split(',')
    name = line[1]
    #this gets the last 4 characters. i.e. PX"\r
    name = name[-3:]
    #remove the quote
    name = name.replace("\"", "")
    #check if name is uppercase
    if name.isupper():
      line = 'remove_line'
  return line


for filename in os.listdir(member_path):
  if fnmatch.fnmatch(filename, '*.vars'):
    f=open(file, 'r')
    findlines=f.read()
    if 'realname' in findlines:
      
