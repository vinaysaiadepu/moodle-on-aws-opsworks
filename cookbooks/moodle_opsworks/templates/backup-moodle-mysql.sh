#!/bin/bash

<% @moodle_databases.each do |db| %>
    /bin/nice -n 15 mysqldump -u <%= db[:db_user] %> -p<%= db[:db_pass] %> -h <%= db[:db_host] %> --single-transaction <%= db[:db_name] %> > /mnt/nfs/<%= db[:db_name] %>.sql
    if test `find "/mnt/nfs/<%= db[:db_name] %>.sql" -mmin -60`
    then
        /bin/nice -n 15 tar -zcf /mnt/nfs/<%= db[:db_name] %>.tgz /mnt/nfs/<%= db[:db_name] %>.sql
        /bin/nice -n 15 aws s3 cp /mnt/nfs/<%= db[:db_name] %>.tgz s3://<%= db[:backupbucket] %>/<%= db[:stack] %>/
        echo "Compress & Upload finished for <%= db[:db_name] %>"
    else
        echo "Mysql Dump for <%= db[:db_name] %> has likely failed as <%= db[:db_name] %>.sql is older than 60 minutes"
    fi
    
<%end %>