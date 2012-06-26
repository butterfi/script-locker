<?php
//  Execute with:
//
//			drush scr generate_presets.php
//
//  Author: Eric London
//  http://thedrupalblog.com/programmatically-generate-all-images-each-imagecache-preset-using-drush-php-script
//
//  Modified: Dan Shumaker
//  Date : 5/20/2011 
//
// store original working directory
//
//define('ORIGINAL_DIRECTORY', getcwd());

// define site http host
//define('HTTP_HOST','edutopia.org');
//define('HTTP_HOST','staging.edutopia.org');
//define('HTTP_HOST','einstein.edutopia.org');
define('HTTP_HOST','ldev');

// get imagecache presets data
/*$presets_data = imagecache_presets();

// loop through presets data and collect preset names
$presets = array();
foreach ($presets_data as $key => $value) {
  $presets[] = $value['presetname'];
	print $value['presetname'] . "\n";
}
 */
// get a list of pictures
//chdir('/data/www/files/missplaced/profile');
$other = 'admin.jpg
RubyRose.jpg
applegroup_0.jpg
applegroup_8.jpg
applegroup.jpg
art_music_drama.jpg
audrey_hepburn.jpg
autism.jpg
boy-with-butterfly_iStock_000006783061.jpg
charter_schools.jpg
classroom_libraries.jpg
collab.jpg
Digital_media.jpg
DSC_0399.JPG
ed_future.jpg
Education_Events.jpg
Elementary_Ed_final.jpg
emotional_intelligence.jpg
ent_ed2.jpg
foreign_language.jpg
Freedom_Project3_0.jpg
fun.jpg
Future_Education4.jpg
Get_Support.jpg
gogglessquare.jpg
group_careertech_tech_0.jpg
Growing_PLN.jpg
HiRes.jpg
holiday_slate.jpg
holiday_slate_type_0.jpg
holiday_slate_type.jpg
imagesCAKG3LDS.jpg
IMG_0434.JPG
IMG_0581.JPG
iStock_000006336788XSmall.jpg
iStock_000008189720XSmall.jpg
Lake Jackson 042.jpg
LearnMeProhect B Card 2.jpg
leu.jpg
literacy.jpg
logo.gif
multi_writing.jpg
NCS-3C.jpg
New_Project.jpg
news.jpg
new_teacher_connections.jpg
on_the_road.jpg
parents.jpg
PL_DI_group.jpg
pro_learn.jpg
race_money.jpg
resolving_conflict_415.jpg
respect.jpg
sel.jpg
Service_Learning_0.jpg
special_ed.jpg
Staff_Picks.jpg
stem_1.jpg
STEMposium Edutopia.jpg
summer_school_0.jpg
tech_9_12.jpg
tech_k_6.jpg
teenboywitheyes.jpg
tutoring_businesscard1.jpg
twittering.jpg
welcome2_0.jpg
ye09_siglucas.gif
your_intentions.jpg';
$profile = 'akevygreenblatt.jpg
alphoto.jpg
AYW Pic - Copy.jpg
betty_pink_sm.jpg
BoroughMarket.jpg
bronn.jpg
carolynhalloween2007 180.JPG
Close-Up_0.jpg
Cranbourne Jim.jpg
cropVineReserv.jpg
Danny.jpg
Derek McCoy.JPG
DSC05037.JPG
DSCN1159.JPG
edeede.JPG
elspeth.JPG
Head Shots - Milan Rose 001.jpg
IMG_1135.JPG
IMG_3961.JPG
IMG_4109.jpg
IMG_7627-1.JPG
in office.jpg
JPG 1114.JPG
just me 002.jpg
Kay_headshot_BW_xsm.jpg
Laura.gif
Leadership_Ten_0.jpg
library_media.jpg
linked in.jpg
Lisa 2010.jpg
LWolf.jpg
Manga.jpg
marianna_53.jpg
me_0.jpg
me_1.jpg
Me and the Little Ol\' Man-do-linfabk.jpg
me.jpg
nancyayers.jpg
new photo.jpg
P4230217.JPG
passport.png
payton.jpg
Photo 18.jpg
Photo 9.jpg
Photo on 2010-10-26 at 08.45.jpg
Picture 1.jpg
Picture 1.png
Picture.jpg
Picture of Brian.jpg
PORTZBYU.gif
pro_dev.jpg
Professional Pic 001.jpg
profile pic.jpg
RachelRudwall_IceRoadTruckers.jpg
rescued pics 021.jpg
Rob 2.jpg
rojame....jpg
RVD_0.jpg
school pic.jpg
shaun2.jpg
Sjs photos 193.jpg
sue.jpg
T-8 Dec.15 09.JPG
tara.jpg
tumblr_lc037kzHjE1qenaglo1_400_large.jpg
u3.jpg
val_lovelace.jpeg
vcasas.2010-12-22 at 12.28.jpg
Vera Mosley.jpg
vern-1.jpg
Webcam photo.jpg
xmas2010 015.JPG';


// NOTE: the following line uses find, grep, and sed to generate a list of image files.
// It will vary depending on which file extensions to include and which directories to ignore
//$command = 'find . -type f | egrep -ir "\.(gif|jpeg|jpg|png)$" | sed "s/^\.\///" | egrep -iv "^(imagecache|imagefield_thumbs)\/"';
//$output = `$command`;
//$files = explode("\n", trim($output));
//chdir(ORIGINAL_DIRECTORY);
//
//
// clean up file name 
//
function moveitmoveit( $list, $presets, $subdir ) {
		$files = explode("\n", trim($list));
		//$files = explode("\n", trim($profile));
		$newfiles = array();
		foreach ($files as $file) {
				$name = ereg_replace("[^a-z0-9._]", '', str_replace(' ', '_', str_replace("%20", '_', str_replace("'", "_", strtolower($file))))); 
				$newfiles[] = $name;
		}
		//print_r($files);
		//print_r($newfiles);
		$srcdir = '/data/www/files';

		if (!file_exists( $srcdir . $subdir )){
				if (!mkdir( $srcdir . $subdir )) {
						print "Was not able to make the directory " . $srcdir . $subdir;
						exit();
				}
		}

		// loop through file list
		foreach ($files as $key => $file) {
				$path_parts = pathinfo($file);
				$result = db_query('SELECT {fid} from files where filepath like "files/%s%%"', $path_parts['filename']);
				$file_id = db_fetch_array($result);
				if ($file_id) {
						$newfile = $srcdir . $subdir . $newfiles[$key];
						$dbfile = file_directory_path() . $subdir . $newfiles[$key];
						$orig = $srcdir . '/' . $file;
						//print "Moving " . $orig . " to " . $newfile . "\n";
						$success = file_move($orig, $newfile );    // This function modifies the $orig string to contain the actual file name that file_move came up with incase of collision
																												// So use the $orig after this.
						if ($orig !== $newfile ) {
								print "\nCOLLISION WARNING \n";
								print "\t " . $newfile  . " should equal " . $orig . "\n";
								print "\t acutally moved it to " . $orig . "\n";
								$movedfile = str_replace($srcdir, file_directory_path(), $orig);
						} else {
								$movedfile = $dbfile; 
						}

						if ($success){
								$result = db_query('UPDATE {files} SET filepath = "%s" WHERE fid = %d', $movedfile, $file_id['fid']);
								print $file_id['fid'] . " " . $movedfile . "\n";
								if ($result) {
										foreach ($presets as $preset) {
												$url = 'http://' . HTTP_HOST . '/' . file_directory_path() . '/imagecache/' . $preset . $subdir . $newfiles[$key];
												$http_request_data = drupal_http_request($url);
												$log_entry = $http_request_data->code . " " . $http_request_data->status_message . " " . $url;
												file_put_contents('ic_preset_log.txt', $log_entry . "\n", FILE_APPEND);
										}
								} else {
										print "Unable to set filepath of " . $file . "\n";
								}
						} else {
								print "Unable to move the file " . $file . "\n";
						}
				} else {
						print "Unable to get the file id of " . $file . "\n";
				}
				print "\n";
		}

}
$presets = array('profile_picture_list');
$subdir = '/profile_pictures/';
moveitmoveit( $profile, $presets, $subdir );
$presets = array('profile_picture_28x32', 'group_images_directory_list', 'group_image_full', 'featured_community_60' );
$subdir = '/groups/';
moveitmoveit( $other , $presets, $subdir );
?>

