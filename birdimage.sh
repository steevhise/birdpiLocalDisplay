#!/usr/bin/env bash
# assumes birdnet-pi package is installed in usual place. Also depends on being online enough to get the bird photo via the Ornithophile API.
# also depends on the perl script, framebuf.pl for actually writing the image to the screen.

OLDIFS=$IFS
IFS=\|

cd ~/BirdNET-Pi/scripts/

# read data from database about last detection.
most_recent_results=($(sqlite3 ~/BirdNET-Pi/scripts/birds.db \
  "SELECT Com_Name, Time, Date, Confidence*100 FROM detections
   WHERE date || ' ' ||  time > datetime('now', 'localtime', '-1 minute')
   ORDER BY Date DESC, Time DESC
   LIMIT 1"))

# assumes this runs as a cronjob every minute.
if [ ${#most_recent_results[*]} -lt 1 ]
then
	echo "no bird detections in last minute"
	exit
fi 


TIMEDATE=`date -d "${most_recent_results[2]} ${most_recent_results[1]}" "+%a %d %b %Y %H:%M %p"`
CONFIDENCE="${most_recent_results[3]}%"
NAME=${most_recent_results[0]}
NAMEENC=`echo $NAME | sed "s/ /%20/g"`  #TODO: do a better job of url-escaping
# echo $NAMEENC $TIMEDATE

# get data about the bird.
IMGURL=`lwp-request https://ornithophile.vercel.app/api/birds?common_name=$NAMEENC | jq '.[] | .male_image' | sed 's/\"//g'`
echo $IMGURL

# download the bird's photo.
curl -s https:$IMGURL > $NAMEENC.jpg

# now composite the image with some info
CMD1="convert -size 720x480 xc:yellow -box yellow -pointsize 64 -gravity northeast -font NimbusSans-Bold -draw 'text 10,50 \"NAME\"' -font AvantGarde-Demi -pointsize 22 -draw 'text 10,140 \"CONFIDENCE confidence\"' -pointsize 30 -font URWBookman-Demi -draw 'text 10,110 \"TIMEDATE\"'  birdcomp-intermediate.jpg"

CMD2=`echo $CMD1 | sed "s/NAME/$NAME/" | sed "s/CONFIDENCE/$CONFIDENCE/" | sed "s/TIMEDATE/$TIMEDATE/"`
# echo $CMD2

# actually run it.
eval "$CMD2"

# stick the actual bird photo on
# TODO: there's a bug that sometimes puts the wrong bird photo. need to track that down.
# also TODO: the graphic design needs some tweaking to make it smarter so that the text never overlaps with the photo.
convert -size 720x480 birdcomp-intermediate.jpg \( $NAMEENC.jpg -resize 400x400 \) -gravity SouthWest -geometry +5+5 -composite finalbirdcomp.pnm

# feh -F finalbirdcomp.jpg

# on the pi it will be 
# fim -w finalbirdcomp.jpg

# or we use perl with Graphics::Framebuffer module.
./framebuf.pl


IFS=$OLDIFS
echo "done"
