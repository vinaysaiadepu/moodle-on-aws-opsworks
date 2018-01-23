#!/bin/bash

SIZE=$(du -sm /mnt/nfs/moodledata/filedir | awk '{print $1;}')
if [ $SIZE -gt <%= @moodledata_size %> ]; then
	echo "Running backup for the $1 moodledata/filedir directory on <%= @stack %>";
	echo "$(date)" > /mnt/nfs/moodledata/filedir/start
	/bin/nice -n 15 aws s3 sync /mnt/nfs/moodledata/filedir s3://<%= @backup_bucket %>/<%= @stack %>/$1/moodledata/filedir --delete --storage-class STANDARD_IA;
	if [ $? -eq 0 ]; then
		echo "Completed Backup for the $1 moodledata/filedir directory on <%= @stack %>";
		echo "$(date)" > /mnt/nfs/moodledata/filedir/end
		aws s3 cp /mnt/nfs/moodledata/filedir/end s3://<%= @backup_bucket %>/<%= @stack %>/$1/moodledata/filedir/end
	else
		echo "Sync command did not complete successfully for the $1 moodledata/filedir directory on <%= @stack %>";
	fi

else
	echo "Files in  moodledata/filedir for the <%= @stack %> are smaller than expected please check directory, backup has not run";
fi