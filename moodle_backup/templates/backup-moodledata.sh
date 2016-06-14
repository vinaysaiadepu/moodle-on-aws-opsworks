if [ "$(ls -A /vol/moodledata/filedir)" ]; then
  echo "running backup";
  aws s3 sync /vol/moodledata/filedir s3://<%= @backupbucket %>/moodledata/filedir --delete;
else
  echo "backup not run - no files in source dir";
fi
