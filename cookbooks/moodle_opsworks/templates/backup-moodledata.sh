#!/bin/bash
SIZE=$(du -B 1 /mnt/nfs/moodledata/filedir | cut -f 1 -d "   ")   
if [[ $SIZE -gt 2147483648]]; then
  echo "running backup";
  aws s3 sync /mnt/nfs/moodledata/filedir s3://<%= @backupbucket %>/moodledata/filedir2 --delete;
else
  echo "backup not run - no files in source dir";
fi