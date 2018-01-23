#!/bin/bash

<% @moodle_databases.each do |db| %>
	echo "$(date)" > /mnt/nfs/dbstart
	/bin/nice -n 15 mysqldump -u <%= db[:db_user] %> -p<%= db[:db_pass] %> -h <%= db[:db_host] %> --single-transaction <%= db[:db_name] %> > /mnt/nfs/<%= db[:db_name] %>.sql
	if test `find "/mnt/nfs/<%= db[:db_name] %>.sql" -mmin -60`
	then
		/bin/nice -n 15 tar -zcf /mnt/nfs/<%= db[:db_name] %>.tgz /mnt/nfs/<%= db[:db_name] %>.sql
		if [ $? -eq 0 ]; then
			echo "Compress finished for <%= db[:db_name] %> $1"
			/bin/nice -n 15 aws s3 cp /mnt/nfs/<%= db[:db_name] %>.tgz s3://<%= db[:backup_bucket] %>/<%= db[:stack] %>/$1/<%= db[:db_name] %>.tgz --storage-class STANDARD_IA
			if [ $? -eq 0 ]; then
				echo "Upload finished for <%= db[:db_name] %> $1"
				echo "$(date)" > /mnt/nfs/dbend
				aws s3 cp /mnt/nfs/dbend s3://<%= @backup_bucket %>/<%= @stack %>/$1/dbend
			else
				echo "Upload failed for <%= db[:db_name] %> $1"
			fi
		else
			echo "Compress failed for <%= db[:db_name] %> $1"
		fi
	else
		echo "Mysql Dump for <%= db[:db_name] %> has likely failed as <%= db[:db_name] %>.sql is older than 60 minutes"
	fi
<%end %>
