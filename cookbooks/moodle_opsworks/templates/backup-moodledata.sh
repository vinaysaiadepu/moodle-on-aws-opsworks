#!/bin/bash

SIZE=$(du -sm /mnt/nfs/moodledata/filedir | awk '{print $1;}')
if [ $SIZE -gt <%= @moodledata_size %> ]; then
  echo "Running backup for the moodledata/filedir directory on <%= @stack %>";
  echo "Backup Started at $(date)" > /mnt/nfs/moodledata/filedir/start
  aws s3 sync /mnt/nfs/moodledata/filedir s3://<%= @backupbucket %>/<%= @stack %>/moodledata/filedir --delete;
  echo "Completed Backup for the moodledata/filedir directory on <%= @stack %>";
  echo "Backup Started at $(date)" > /mnt/nfs/moodledata/filedir/end
else
  echo "Files in  moodledata/filedir for the <%= @stack %> are smaller than expected please check directory, backup has not run";
fi
