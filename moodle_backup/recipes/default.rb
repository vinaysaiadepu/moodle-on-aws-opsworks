# only run backups from the first webserver
thisinstance = search(:aws_opsworks_instance, "self:true").first
firstinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").first

template '/home/ec2-user/hourly-moodledata.sh' do
	if thisinstance['instanceid'] == firstinstance['instanceid']
		source 'hourly-moodledata.sh'
	else
		source 'empty'
	end
	owner 'ec2-user'
	mode '0770'
	variables(
		:backupbucket => ${node['S3_backup_bucket']}
	)
end

template '/etc/cron.d/hourly-moodlebackup.cron' do
	if thisinstance['instanceid'] == firstinstance['instanceid']
		source 'hourly-moodlebackup.cron'
	else
		source 'empty'
	end
end
