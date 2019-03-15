#!/bin/bash

#****************************************************************************** 
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#****************************************************************************** 
#  
#  Version: 2.32
#  Date:2⅞/03/2019 
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

DATE=$(date +%Y%m%d)
DATETIME=$(date '+%Y%m%d-%H:%M:%S')
JOBNUM=$(date +%s)

#Edit Line Below to change path of SCRIPT LOG FILE
TXTLogPATH="/var/lib/plexmediaserver/Scripts"

TXTLog="$TXTLogPATH/TXTLog-$DATE.txt"

#A Function to replace echo with echolog to place all messages in the TXTLog Location DO NOT CHANGE
echolog(){
	if [ $# -eq 0 ]
        then cat - | while read -r message
            do
                echo "$(date +"[%F %T %Z] -") $message" | tee -a "$TXTLog"
             done
         else
                echo -n "$(date +'[%F %T %Z]') - " | tee -a "$TXTLog"
	        echo $* | tee -a "$TXTLog"
	 fi
 }

echolog "..............................................................................................."
# Checks to see if todays Log Files Exists if not create the new one
if [ -f $TXTLog ]; then
        echolog "JOB|$JOBNUM|--Log File Exists"
else
        touch "$TXTLog"
        chown plex:plex $TXTLog
        chmod 755 $TXTLog
        echolog "JOB|$JOBNUM|--Create new Log File:$TXTLog"
fi


#Function that is called to check the status of the last command that was run to see if it was a success of failed
lastcmdchk(){
if [ $? -ne 0 ]
then
    echolog "JOB|$JOBNUM|--Command Failed!"
else
    echolog "JOB|$JOBNUM|--Command Success!"
fi
}

echolog ".........................................................,...................................."
echolog "JOB|$JOBNUM|--START OF SCRIPT"
echolog "JOB|$JOBNUM|--FILE PASSED BY Plex $1"



#Old Log Removal
echolog "JOB|$JOBNUM|--THE NEXT LINES ARE LOG FILES THAT WILL BE DELETED"
LOGDEL=$(find $TXTLogPATH/TXTL*.txt -mtime +$LOGFILEAGE -type f -delete -print)
echolog "JOB|$JOBNUM|--$LOGDEL"
lastcmdchk
echolog "JOB|$JOBNUM|--END OF LOG FILE REMOVAL" 

#Handbrake CLI 
HANDBRAKE_CLI=HandBrakeCLI
 

#This line Removes the spaces and () from the file and replaces them with underscores
#Issues early on with puncuation and quotes caused me to remove the need to worry about them in the script
FILETOPROCESS=$(echo "$1" | tr " ()" "___")

 
if [ ! -z "$FILETOPROCESS" ]; then 
# The if selection statement proceeds to the script if $1 is not empty.

   FILENAME=$FILETOPROCESS

   FILE=$(basename "$FILENAME")
 
  extension=${FILENAME##*.}
  echolog "JOB|$JOBNUM|--Copying Source File to Temp Dir Provided"
  cp "$1" "$TEMPDVRPATH/$FILE"
  lastcmdchk
  
  #Gets File Size of Original File and stores it in bytes
  SIZEORIG=$(stat -c%s "$TEMPDVRPATH/$FILE")
  SIZEORIGMB=$(((SIZEORIG / 1024) / 1024))
  echolog "JOB|$JOBNUM|--Original File Size is $SIZEORIGMB MiB" 
  66
  SAVEFILENAME=${1%.*}
  echolog "JOB|$JOBNUM|--Checking Archive Status"
   	if [ $ARCHIVEYES = "TRUE" ]; then
		echolog "JOB|$JOBNUM|--Achrive was set to TRUE!" 
		cp "$1" "$ARCHIVETSDIR/$FILE"
	        lastcmdchk	
                echolog "JOB|$JOBNUM|--Files Listed in DVR Archive after this are older than $ARCHIVELENGTH they will be deleted" 
		ARCHIVEDEL=$(find $ARCHIVETSDIR/ -mtime +$ARCHIVELENGTH -type f -delete -print)
		echolog "JOB|$JOBNUM|--$ARCHIVEDEL"
		echolog "JOB|$JOBNUM|--End of Archive Delete Line"  
	fi
   TEMPFILENAME="$TEMPDVRPATH/$(date +%s.mkv)"  # Temporary File for transcoding
   echolog "JOB|$JOBNUM|--Script Variables being used below"
   echolog "JOB|$JOBNUM|--Filename: $FILE" 
   echolog "JOB|$JOBNUM|--Extension: $extension" 
   echolog "JOB|$JOBNUM|--Savefilename: $SAVEFILENAME" 
   echolog "JOB|$JOBNUM|--Temp Save File for HandBrake: $TEMPFILENAME"

  #Add System Path for LIB Files due to Handbrake error missing libz.so.1 because the one in Plex's lib file doesnt work with Handbrake 
   echolog "JOB|$JOBNUM|--LD LIBRARY PATH ORIGINAL: $LD_LIBRARY_PATH"
   ORIGLDLIBRARYPATH=$LD_LIBRARY_PATH
   export LD_LIBRARY_PATH="/usr/lib64:$ORIGLDLIBRARYPATH"
   echolog "JOB|$JOBNUM|--New LD LIBRARY PATH: $LD_LIBRARY_PATH"
   echolog "JOB|$JOBNUM|--THIS IS WHAT WILL BE PROCESSED ON HANDBRAKE LINE" 

  #Looking to add a switch for 1080 or over content in the next version that uses H265 for that and leaces SD content in H264 
   echolog "JOB|$JOBNUM|--HandBrakeCLI -i $TEMPDVRPATH/$FILE -f mkv -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 -e x264 --x264-preset medium --x264-profile auto -q 22 --encoder-level=4.1 --maxHeight 1080  --decomb bob -o $TEMPFILENAME" 
   echolog "JOB|$JOBNUM|--Handbrake Will Now Start Processing File"

   # Handbrake Processing Line currently H264 in Original Resolution with 1 Audio track ACC 160Kbps, slow Q=22
   $HANDBRAKE_CLI -i $TEMPDVRPATH/$FILE -f av_mkv -e x264 -a 1 -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 --x264-preset medium -q 22 --encoder-level="4.1" --decomb bob -o $TEMPFILENAME 
   
   export LD_LIBRARY_PATH=$ORIGLDLIBRARYPATH
   echolog "JOB|$JOBNUM|--Setting LD LIBRARY PATH Back to Orig Path: $LD_LIBRARY_PATH"

   echolog "JOB|$JOBNUM|--Handbrake Processing has been Completed" 

   #Deletes TEMP File from the TEMP DIR
   echolog "JOB|$JOBNUM|--Cleanup Process Delete $TEMPDVRPATH/$FILE"
   rm -f $TEMPDVRPATH/"$FILE"
   lastcmdchk

   # Moves HandBrake Output File to Original Path
   echolog "JOB|$JOBNUM|--Cleanup Process Moves $TEMPFILENAME to $SAVEFILENAME.mkv"
   mv -f -v "$TEMPFILENAME" "$SAVEFILENAME.mkv" 
   lastcmdchk

   #Gets File Size of Transcoded File and stores it in Mibytes
   SIZEFINAL=$(stat -c%s "$SAVEFILENAME.mkv")
   SIZEFINALMB=$(((SIZEFINAL / 1024) / 1024))
   echolog "JOB|$JOBNUM|--Transcoded File Size is $SIZEFINALMB MiB"
   SIZEREDUCTION=$(echo "scale=2; ((($SIZEORIGMB-$SIZEFINALMB)/$SIZEORIGMB)*100)" | bc ) 
   echolog "JOB|$JOBNUM|--There was a $SIZEREDUCTION % reduction in file size with this transcode"

   chown plex:plex "$SAVEFILENAME.mkv" # Makes Sure the FILE is owned by plex
   chmod 644 "$SAVEFILENAME.mkv" # This step may not be neccessary, but hey why not.
   
   # Removes the file passed to the script --DVR RAW FILE  
   echolog "JOB|$JOBNUM|--Cleanup Process Deletes Orig File Passed to Script" 
   rm -f "$1"
   lastcmdchk

   echolog "JOB|$JOBNUM|--HandBrake and Script have finsihed Congrats!" 

   #Tkes the JOBNUM which is the start time of the script and uses the below date to determine how long the script took to get to this point
   ENDDATE=$(date +%s)
   seconds=$(echo "$ENDDATE - $JOBNUM" | bc)
   echolog "JOB|$JOBNUM|--Script Completed in $seconds seconds"

else
   echolog "JOB|$JOBNUM|--No FILE was passed in the aurgument" 
   echolog "JOB|$JOBNUM|--Usage: $0 FileName"
fi
