#!/bin/bash
SIZE=$(du -sm /mnt/nfs/moodledata/filedir | awk '{print $1;}')
if [ $SIZE -gt 2000 ]; then
  echo "running backup";
  aws s3 sync /mnt/nfs/moodledata/filedir s3://<%= @backupbucket %>/moodledata/filedir2 --delete;
else
  echo "Files to backup are smaller than expected please check directory";
fi
