#!/bin/bash

#****************************************************************************** 
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#****************************************************************************** 
#  
#  Version: 2.0
#
#  Pre-requisites: 
#     HandBrakeCLI
#
#
#  Usage: 
#     'PlexPostProc.sh %1'
#
#  Description:
#
#****************************************************************************** 

#Edit this line below setting your path for for the TEMP DIR
TEMPDVRPATH=/DataDrive/Video/TEMPDVR

DATE=`date +%Y%m%d`
DATETIME=`date '+%Y%m%d-%H:%M:%S'`

TXTLog="/var/lib/plexmediaserver/Scripts/TXTLog-$DATE.txt"
# Checks to see if todays Log Files Exists if not create the new one
if [ -f $TXTLog ]; then
	echo "$DATETIME--Log File Exists" >> $TXTLog
else
	touch $TXTLog
	chown plex:plex $TXTLog
	chmod 755 $TXTLog
	echo "DATETIME--Create new Log File:#TXTLog" >> $TXTLog
fi



HANDBRAKE_CLI='taskset -c 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 HandBrakeCLI'
echo "********************************************************************************************************" >> $TXTLog
echo "$DATETIME--Plex Post Script working on FILE:$1" >> $TXTLog
FILETOPROCESS=$(echo "$1" | tr " ()" "___")

echo "$DATETIME--FILE TO PROCESS: $FILETOPROCESS" >> $TXTLog
echo "File to Process: $FILETOPROCESS"
if [ ! -z "$FILETOPROCESS" ]; then 
# The if selection statement proceeds to the script if $1 is not empty.

   FILENAME=$FILETOPROCESS

   FILE=$(basename "$FILENAME")

   extension=${FILENAME##*.}
   cp "$1" "$TEMPDVRPATH/$FILE" >> $TXTLog
   SAVEFILENAME=${1%.*}

   TEMPFILENAME="$TEMPDVRPATH/$(date +%s.mkv)"  # Temporary File for transcoding

   # Uncomment if you want to adjust the bandwidth for this thread
   #MYPID=$$	# Process ID for current script
   # Adjust niceness of CPU priority for the current process
   #renice 19 $MYPID
   echo "$DATETIME--Filename: $FILE" >> $TXTLog
   echo "$DATEITME--Extension: $extension" >> $TXTLog
   echo "$DATETIME--Savefilename: $SAVEFILENAME" >> $TXTLog
   echo "$DATETIME--Begin Handbrake line" >> $TXTLog
   echo "$DATETIME--Temp Save File for HandBrake: $TEMPFILENAME" >> $TXTLog
   echo "********************************************************"
   echo "Transcoding, Converting to H.264 w/Handbrake"
   echo "********************************************************"
  echo "$DATETIME--THIS IS WHAT WILL BE PROCESSED ON HANDBRAKE LINE" >> $TXTLog
  echo "$DATETIME--HandBrakeCLI -i $TEMPDVRPATH/$FILE -f mkv -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 -e x264 --x264-preset slow --x264-profile auto -q 22 --encoder-level=4.1 --maxHeight 1080  --decomb bob -o $TEMPFILENAME" >> $TXTLog

$HANDBRAKE_CLI -i $TEMPDVRPATH/$FILE -f av_mkv -e x264 -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 --x264-preset slow -q 22 --encoder-level="4.1" --decomb bob -o $TEMPFILENAME >> $TXTLog

   echo "********************************************************"
   echo "Cleanup / Copy $TEMPFILENAME to $FILENAME"
   echo "********************************************************"

   rm -f $TEMPDVRPATH/"$FILE" #Deletes TEMP File
   mv -f -v "$TEMPFILENAME" "$SAVEFILENAME.mkv" >> $TXTLog
   chown plex:plex "$SAVEFILENAME.mkv" # Makes Sure the FILE is owned by plex
   chmod 644 "$SAVEFILENAME.mkv" # This step may no tbe neccessary, but hey why not.
   rm -f "$1"

   echo "$DATETIME--HandBrake and Script have finsihed Congrats!" >> $TXTLog
else
   echo "$DATETIME--No FILE was passed in the aurgument" >> $TXTLog
   echo "Usage: $0 FileName"
fi
