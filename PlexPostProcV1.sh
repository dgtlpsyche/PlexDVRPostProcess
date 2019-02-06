#!/bin/bash

#****************************************************************************** 
#****************************************************************************** 
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#****************************************************************************** 
#****************************************************************************** 
#  
#  Version: 1.0
#
#  Pre-requisites: 
#     HandBrakeCLI
#
#
#  Usage: 
#     'PlexPostProc.sh %1'
#
#  Description:
#      My script is currently pretty simple.  Here's the general flow:
#
#      1. Creates a temporary directory in the home directory for 
#      the show it is about to transcode.
#
#      2. Uses Handbrake (could be modified to use ffmpeg or other transcoder, 
#      but I chose this out of simplicity) to transcode the original, very 
#      large MPEG2 format file to a smaller, more manageable H.264 mp4 file 
#      (which can be streamed to my Roku boxes).
#
#	   3. Copies the file back to the original filename for final processing
#
#****************************************************************************** 

#****************************************************************************** 
#  Do not edit below this line
#****************************************************************************** 
TXTLog=/var/lib/plexmediaserver/Scripts/TXTLog.txt
HANDBRAKE_CLI=HandBrakeCLI
echo "********************************************************************************************************" >> $TXTLog
echo "TimeStamp:$(date) with FILE:$1" >> $TXTLog
FILETOPROCESS=$(echo "$1" | tr " ()" "___")

echo "FILE TO PROCESS: $FILETOPROCESS" >> $TXTLog
echo "File to Process: $FILETOPROCESS"
if [ ! -z "$FILETOPROCESS" ]; then 
# The if selection statement proceeds to the script if $1 is not empty.

   FILENAME=$FILETOPROCESS

   FILE=$(basename "$FILENAME")

   extension=${FILENAME##*.}
   cp "$1" "/var/lib/plexmediaserver/Scripts/TEMP/$FILE" >> $TXTLog
   SAVEFILENAME=${1%.*}

   TEMPFILENAME="/var/lib/plexmediaserver/Scripts/TEMP/$(date +%s.mkv)"  # Temporary File for transcoding

   # Uncomment if you want to adjust the bandwidth for this thread
   #MYPID=$$	# Process ID for current script
   # Adjust niceness of CPU priority for the current process
   #renice 19 $MYPID
   echo "Filename: $FILE" >> $TXTLog
   echo "Extension: $extension" >> $TXTLog
   echo "Savefilename: $SAVEFILENAME" >> $TXTLog
   echo "Begin Handbrake line" >> $TXTLog
   echo "Temp Save File for HandBrake: $TEMPFILENAME" >> $TXTLog
   echo "********************************************************"
   echo "Transcoding, Converting to H.264 w/Handbrake"
   echo "********************************************************"
  echo "THIS IS WHAT WILL BE PROCESSED ON HANDBRAKE LINE" >> $TXTLog
  echo "HandBrakeCLI -i TEMP/$FILE -f mkv -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 -e x264 --x264-preset slow --x264-profile auto -q 22 --encoder-level=4.1 --maxHeight 1080  --decomb bob -o $TEMPFILENAME" >> $TXTLog

$HANDBRAKE_CLI -i /var/lib/plexmediaserver/Scripts/TEMP/$FILE -f av_mkv -e x264 -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 --x264-preset slow -q 22 --encoder-level="4.1" --decomb bob -o $TEMPFILENAME >> $TXTLog

   echo "********************************************************"
   echo "Cleanup / Copy $TEMPFILENAME to $FILENAME"
   echo "********************************************************"

   rm -f TEMP/"$FILE"
   mv -f -v "$TEMPFILENAME" "$SAVEFILENAME.mkv" >> $TXTLog
   chown plex:plex "$SAVEFILENAME.mkv" # Makes Sure the FILE is owned by plex
   chmod 644 "$SAVEFILENAME.mkv" # This step may no tbe neccessary, but hey why not.
   rm -f "$1"

   echo "Done.  Congrats!"
else
   echo "PlexPostProc by nebhead"
   echo "Usage: $0 FileName"
fi
