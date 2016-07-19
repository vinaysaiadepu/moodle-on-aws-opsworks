thisinstance = search(:aws_opsworks_instance, "self:true").first
lastinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").last

template '/home/ec2-user/backup-moodledata.sh' do
	source 'backup-moodledata.sh'
	owner 'ec2-user'
	mode '0770'
	variables(
		:backupbucket		=> node['S3_backup_bucket'],
	)
end

template '/etc/cron.d/hourly-moodlebackup.cron' do
    if thisinstance['instanceid'] == lastinstance['instanceid']
        source 'hourly-moodlebackup.cron'
    else
        source 'empty'
    end
end