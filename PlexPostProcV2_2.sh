#!/bin/bash

#****************************************************************************** 
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#****************************************************************************** 
#  
#  Version: 2.2
#	Date: 1-28-2019
#
#  Creator and Support Information
#  Written by: Dgtlpsyche
#  Email: Dgtlpsyche@gmail.com
#  https://github.com/dgtlpsyche
#
#  Pre-requisites: 
#     HandBrakeCLI
#
#
#  Usage: 
#     'PlexPostProc.sh %1'
#
#  Description: See Github page for More Details
#  https://github.com/dgtlpsyche/PlexDVRPostProcess
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
JOBNUM=`date +%s`

#Edit Line Below to change path of SCRIPT LOG FILE
TXTLogPATH="/var/lib/plexmediaserver/Scripts"

TXTLog="$TXTLogPATH/TXTLog-$DATE.txt"
echolog "..............................................................................................."
# Checks to see if todays Log Files Exists if not create the new one
if [ -f $TXTLog ]; then
        echolog "JOB|$JOBNUM|--Log File Exists"
else
        touch $TXTLog
        chown plex:plex $TXTLog
        chmod 755 $TXTLog
        echolog "JOB|$JOBNUM|--Create new Log File:$TXTLog"
fi


#A Function to replace echo with echolog to place all messages in the TXTLog Location DO NOT CHANGE
echolog(){
    if [ $# -eq 0 ]
    then cat - | while read -r message
        do
                echo "$(date +"[%F %T %Z] -") $message" | tee -a $TXTLog
            done
    else
        echo -n "$(date +'[%F %T %Z]') - " | tee -a $TXTLog
        echo $* | tee -a $TXTLog
    fi
}


echolog ".......................................,.................,...................................."
echolog "JOB|$JOBNUM|--START OF SCRIPT"
echolog "JOB|$JOBNUM|--FILE PASSED BY Plex $1"



#Old Log Removal
echolog "JOB|$JOBNUM|--THE NEXT LINES ARE LOG FILES THAT WILL BE DELETED"
find .$TXTLogPATH/TXTL*.txt -mtime +$LOGFILEAGE -type f -delete -print 
echolog "JOB|$JOBNUM|--END OF LOG FILE REMOVAL" 

#Handbrake CLI 
HANDBRAKE_CLI=HandBrakeCLI
 

#This line Removes the spaces and () from the file and replaces them with underscores
#Issues early on with puncuation and quotes caused me to remove the need to worry about them in the script
FILETOPROCESS=$(echo "$1" | tr " ()" "___")

echolog "JOB|$JOBNUM|--FILE TO PROCESS: $FILETOPROCESS" 
if [ ! -z "$FILETOPROCESS" ]; then 
# The if selection statement proceeds to the script if $1 is not empty.

   FILENAME=$FILETOPROCESS

   FILE=$(basename "$FILENAME")
 
  extension=${FILENAME##*.}
  cp "$1" "$TEMPDVRPATH/$FILE" 
  SAVEFILENAME=${1%.*}
echolog "JOB|$JOBNUM|--Checking Archive Status"
   	if [ $ARCHIVEYES="TRUE" ]; then
		echolog "JOB|$JOBNUM|--Achrive was set to TRUE!" 
		cp "$1" "$ARCHIVETSDIR/$FILE" 
                echolog "JOB|$JOBNUM|--Files Listed in DVR Archive after this are older than $ARCHIVELENGTH they will be deleted" 
		find .$ARCHIVETSDIR/ -mtime +$ARCHIVELENGTH -type f -delete -print 
		echolog "JOB|$JOBNUM|--End of Archive Delete Line"  
	fi
   TEMPFILENAME="$TEMPDVRPATH/$(date +%s.mkv)"  # Temporary File for transcoding
   echolog "JOB|$JOBNUM|--Script Variables being used below"
   echolog "JOB|$JOBNUM|--Filename: $FILE" 
   echolog "JOB|$JOBNUM|--Extension: $extension" 
   echolog "JOB|$JOBNUM|--Savefilename: $SAVEFILENAME" 
   echolog "JOB|$JOBNUM|--Temp Save File for HandBrake: $TEMPFILENAME" 
   echolog "JOB|$JOBNUM|--THIS IS WHAT WILL BE PROCESSED ON HANDBRAKE LINE" 

  #Looking to add a switch for 1080 or over content in the next version that uses H265 for that and leaces SD content in H264 
   echolog "JOB|$JOBNUM|--HandBrakeCLI -i $TEMPDVRPATH/$FILE -f mkv -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 -e x264 --x264-preset slow --x264-profile auto -q 23 --encoder-level=4.1 --maxHeight 1080  --decomb bob -o $TEMPFILENAME" 
   echolog "JOB|$JOBNUM|--Handbrake Will Now Start Processing File"

   # Handbrake Processing Line currently H264 in Original Resolution with 1 Audio track ACC 160Kbps, slow Q=22
   $HANDBRAKE_CLI -i $TEMPDVRPATH/$FILE -f av_mkv -e x264 -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 --x264-preset slow -q 23 --encoder-level="4.1" --decomb bob -o $TEMPFILENAME 

   echolog "JOB|$JOBNUM|--Handbrake Processing has been Completed" 
   echolog "JOB|$JOBNUM|--Cleanup Process Moves $TEMPFILENAME to $SAVEFILENAME.mkv"                
   echolog "JOB|$JOBNUM|--Cleanup Process Delete $TEMPDVRPATH/$FILE" 

   rm -f $TEMPDVRPATH/"$FILE" #Deletes TEMP File from the TEMP DIR

   # Moves HandBrake Output File to Original Path
   mv -f -v "$TEMPFILENAME" "$SAVEFILENAME.mkv" 

   chown plex:plex "$SAVEFILENAME.mkv" # Makes Sure the FILE is owned by plex
   chmod 644 "$SAVEFILENAME.mkv" # This step may not be neccessary, but hey why not.
   rm -f "$1" # Removes the file passed to the script --DVR RAW FILE

   echolog "JOB|$JOBNUM|--HandBrake and Script have finsihed Congrats!" 

   #Tkes the JOBNUM which is the start time of the script and uses the below date to determine how long the script took to get to this point
   ENDDATE=`date +%s`
   seconds=$(echo "$ENDDATE - $JOBNUM" | bc)
   echolog "JOB|$JOBNUM|--Script Completed in $seconds seconds"

else
   echolog "JOB|$JOBNUM|--No FILE was passed in the aurgument" 
   echolog "JOB|$JOBNUM|--Usage: $0 FileName"
fi
