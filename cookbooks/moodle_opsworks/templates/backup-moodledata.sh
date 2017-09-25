#!/bin/bash

SIZE=$(du -sm /mnt/nfs/moodledata/filedir | awk '{print $1;}')
if [ $SIZE -gt <%= @moodledata_size %> ]; then
  echo "Running backup for the $1 moodledata/filedir directory on <%= @stack %>";
  echo "Backup Started at $(date)" > /mnt/nfs/moodledata/filedir/start
  aws s3 sync /mnt/nfs/moodledata/filedir s3://<%= @backup_bucket %>/<%= @stack %>/$1/moodledata/filedir --delete --storage-class STANDARD_IA;
  echo "Completed Backup for the $1 moodledata/filedir directory on <%= @stack %>";
  echo "Backup Started at $(date)" > /mnt/nfs/moodledata/filedir/end
else
  echo "Files in  moodledata/filedir for the <%= @stack %> are smaller than expected please check directory, backup has not run";
fi
