Plex DVR Post Process Script

After working with Plex DVR and the file size for MPEG was so large this script was developed after going through multiple forums on how plex was delivering the files to the script



--Installing--
Built using Fedora 28 Server

Directories required for running the script

The script in currently being run from /var/lib/plexmediaserver/Scripts. To use the file as written please create the Scripts folder in the plexmediaserver folder and then edit the file and change the below three entries to path in your environment.

	-TEMPDVRPATH (Default:/DataDrive/Video/TEMPDVR)
	-ARCHIVETSDIR (Default:/DataDrive/Video/DVRArchive)
	-TXTLogPATH (Default:/var/lib/plexmediaserver/Scripts

-Other Items to Change if need from Defaults-
	ARCHIVEYES=TRUE  # Set to FALSE to turn off or TRUE to turn on

	ARCHIVELENGTH=4 # Set to the number of days to keep archived TS files
	LOGFILEAGE=7 #number is days

By seting ARCHIVEYES to FALSE you can skip the archive directory path if you dont require that ability.
	 
As the TS files can be ery large set the archive length for number of days to make sure this directory doesnt fill up its drive



--Usage--

-WITH PLEX-
	1)  Goto Settings>LiveTV & DVR>DVR Settings
	2)  Scroll down to Postprocessing script section
	3)  If you used the default location paste in the below:
		/var/lib/plexmediaserver/Scripts/PlexPostProcV2_2.sh

-IN CLI-
	Ex. /var/lib/plexmediaserver/Scripts/PlexPostProcV2_2.sh $1
	
	$1 is the file to process

-Reading the log files-
The LOG file writes logs by date and by default keeps the last 7 days. As multiple scripts can be running at one time its possible the logs will have entries from different jobs that are happening at the same time. To keep track of which log entries a JOBNUM was added to each line. The JOBNUM will stay unique for the script process. At this time there is no LOGS from handbrake itself as during its processing it spams the console with encoding messages and creates a mess. If you are having issues with Handbrake look at the system journal. Also running the script in CLI mode will show you the handbrake output if some diagnostics is needed.

-Handbrake Options-
Everyone's preferences are differnet here so modify the CLI code as needed for Plex. If no changes are made it uses H264 with Quality setting of 23 and 160Kb 2 channel audio in AAC as this is the most universal audio codecs for direct play.

Future
Looking to add these features in no order.

-Orig file size vs transcoded size with % //Added in V2.31
-LOG entries to note if other instances of Handbrake are currently running and how many
-Error handling of some commands % //Basic Operation added in V2.31
-For 1080(HD files) add option to change the codec to H265 but leave SD content with H264


Creator and Support Information
Written by: Dgtlpsyche
Email: Dgtlpsyche@gmail.com
https://github.com/dgtlpsyche


Release History
2.31
	-A few bug fixes and spelling fixes
	-Updated syntax for some commands
	-Added Command Success check
	-Added Log entries for Original File Size and Final File Size and calculated % reduction
	-General Clean-up of the log entries order
2.2
	-First Release




	
