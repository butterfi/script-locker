import os

rootdir='/usr/lib/cgi-bin/yabb2/Messages'


#the bad word list is case sensitive (for now)
naughtylist = ['imuran',
               'underground railway',
               'generic',
               'discount',
               'cheapest', 
               'accutane', 
               'demadex',
               'huong',
               'allianz arena',
               'ca cuoc tren mang',
               'luxury watches',
               'handbags',
               'handbag',
               'gucci',
               'gypeorierrelojx',
               'afasdfasd',
               'healthygrillusa',
               'managerlundow',
               'online betting',
               'prescription',
               'powermta',
               'xannaxnorfo',
               'dating site',
               'vkontaktecymnfm',
               'edistiluexuseii',
               'test, just a test',
               'this is just a test',
               'this is just a test!',
               'bingo',
               'jenykillaup',
               'grawerowanie',
               'free shipping',
               'tattoo',
               'gps car',
               'hedge fund',
               'univer underground',
               'online movies',
               'auto news',
               'google classifieds',
               'warez',
               'watchmaker',
               'viewsonic',
               'xrumer',
               'uggs',
               'auto',
               'to become thanks',
               'mr.shushugahjp',
               'boost your business',
               'cheap mlb jerseys',
               'burberry',
               'assusaoweriupzb',
               'hardware device wizard',
               'cardio',
               'simvastatin',
               'isotretinoin',
               'free promotion',
               'powermta',
               'kjjinshanshi1',
               'skydrive mobile',
               'ahathawayqo',
               'sexyeatz.com',
               'duloxetine',
               'tgigold',
               'gaigmapaicyvh',
               'poolitiefonmg',
               'vakImmiffkaftfu',
               'celexa',
               ]
#parse the naughty list and replace line with empty line
def removeTheNaughty(line): 
  for naughtyword in naughtylist:
    if naughtyword in line.lower():
      print naughtyword    
      line = ''
  return line

#Remove anything that isn't encoded ASCII as it tends to be spam
def makeMineAscii(line):
    try:
        line.decode('ascii')
    except UnicodeDecodeError:
        line = ''
        print 'Non ASCII line removed'
    return line


#file walking
for subdir, dirs, files in os.walk(rootdir):
  for file in files:
    f=open(file, 'r')
    lines=f.readlines()
    f.close()
    f=open(file, 'w')
    for line in lines: 
      #look for naughty words  
      newline=removeTheNaughty(line)
      f.write(newline)
    f.close()


# remove non ascii lines    
 #file walking
for subdir, dirs, files in os.walk(rootdir):
  for file in files:
    f=open(file, 'r')
    lines=f.readlines()
    f.close()
    f=open(file, 'w')
    for line in lines:
      #zap the non-ascii lines  
      newline=makeMineAscii(line)  
      f.write(newline)
    f.close()   