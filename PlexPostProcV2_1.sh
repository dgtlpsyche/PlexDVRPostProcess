#!/bin/bash

#****************************************************************************** 
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#****************************************************************************** 
#  
#  Version: 2.1
#
#  Written by: Dgtlpsyche
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

#Edit this line below setting your path for for the TEMP DIR were HandBrakeCLI copies its input file to
TEMPDVRPATH=/DataDrive/Video/TEMPDVR

#Edit the two lines below to set an archive directory of the original files
ARCHIVEYES=TRUE  # Set to FALSE to turn off or TRUE to turn on
ARCHIVELENGTH=4 # Set to the number of days to keep archived TS files
ARCHIVETSDIR=/DataDrive/Video/DVRArchive

#Edit the line below to change how long it keeps log files
LOGFILEAGE=7 #number is days

DATE=`date +%Y%m%d`
DATETIME=`date '+%Y%m%d-%H:%M:%S'`

#Edit Line Below to change path of SCRIPT LOG FILE
TXTLogPATH="/var/lib/plexmediaserver/Scripts"

TXTLog="$TXTLogPATH/TXTLog-$DATE.txt"

# Checks to see if todays Log Files Exists if not create the new one
if [ -f $TXTLog ]; then
	echo "$DATETIME--Log File Exists" >> $TXTLog
else
	touch $TXTLog
	chown plex:plex $TXTLog
	chmod 755 $TXTLog
	echo "$DATETIME--Create new Log File:$TXTLog" >> $TXTLog
fi

#Old Log Removal
echo "$DATETIME--THE NEXT LINES ARE LOG FILES THAT WILL BE DELETED" >> $TXTLog
find .$TXTLogPATH/TXTL*.txt -mtime +$LOGFILEAGE -type f -delete -print >> $TXTLog
echo "$DATETIME--END OF LOG FILE REMOVAL" >> $TXTLog

#Handbrake CLI 
HANDBRAKE_CLI=HandBrakeCLI

echo "$DATETIME--Plex Post Script working on FILE:$1" >> $TXTLog

#This line Removes the spaces and () from the file and replaces them with underscores
#Issues early on with puncuation and quotes caused me to remove the need to worry about them in the script
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
   	if [ $ARCHIVEYES="TRUE" ]; then
		echo "$DATETIME--Achrive was set to TRUE!" >> $TXTLog
		cp "$1" "$ARCHIVETSDIR/$FILE" >> $TXTLog
                echo "$DATETIME--Files Listed in DVR Archive after this are older than $ARCHIVELENGTH they will be deleted" >> $TXTLog
		find .$ARCHIVETSDIR/ -mtime +$ARCHIVELENGTH -type f -delete -print >> $TXTLog
		echo "$DATETIME--End of Archive Delete Line" >> $TXTLog 
	fi
   TEMPFILENAME="$TEMPDVRPATH/$(date +%s.mkv)"  # Temporary File for transcoding

   echo "$DATETIME--Filename: $FILE" >> $TXTLog
   echo "$DATEITME--Extension: $extension" >> $TXTLog
   echo "$DATETIME--Savefilename: $SAVEFILENAME" >> $TXTLog
   echo "$DATETIME--Begin Handbrake line" >> $TXTLog
   echo "$DATETIME--Temp Save File for HandBrake: $TEMPFILENAME" >> $TXTLog
   echo "********************************************************"
   echo "Transcoding, Converting to H.264 w/Handbrake"
   echo "********************************************************"
   echo "$DATETIME--THIS IS WHAT WILL BE PROCESSED ON HANDBRAKE LINE" >> $TXTLog
   echo "$DATETIME--HandBrakeCLI -i $TEMPDVRPATH/$FILE -f mkv -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 -e x264 --x264-preset slow --x264-profile auto -q 23 --encoder-level=4.1 --maxHeight 1080  --decomb bob -o $TEMPFILENAME" >> $TXTLog

   # Handbrake Processing Line currently H264 in Original Resolution with 1 Audio track ACC 160Kbps, slow Q=22
   $HANDBRAKE_CLI -i $TEMPDVRPATH/$FILE -f av_mkv -e x264 -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 --x264-preset slow -q 23 --encoder-level="4.1" --decomb bob -o $TEMPFILENAME >> $TXTLog

   echo "********************************************************" >> $TXTLog
   echo "Cleanup / Copy $TEMPFILENAME to $FILENAME"                >> $TXTLog
   echo "********************************************************" >> $TXTLog

   rm -f $TEMPDVRPATH/"$FILE" #Deletes TEMP File from the TEMP DIR

   # Moves HandBrake Output File to Original Path
   mv -f -v "$TEMPFILENAME" "$SAVEFILENAME.mkv" >> $TXTLog

   chown plex:plex "$SAVEFILENAME.mkv" # Makes Sure the FILE is owned by plex
   chmod 644 "$SAVEFILENAME.mkv" # This step may not be neccessary, but hey why not.
   rm -f "$1" # Removes the file passed to the script --DVR RAW FILE

   echo "$DATETIME--HandBrake and Script have finsihed Congrats!" >> $TXTLog
else
   echo "$DATETIME--No FILE was passed in the aurgument" >> $TXTLog
   echo "Usage: $0 FileName"
fi
