thisinstance = search(:aws_opsworks_instance, "self:true").first
lastinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").last
db = search(:aws_opsworks_rds_db_instance, "*:*").first

template '/home/ec2-user/backup-moodledata.sh' do
	source 'backup-moodledata.sh'
	owner 'ec2-user'
	mode '0770'
	variables(
		:backupbucket		=> node['S3_backup_bucket'],
	)
end


template '/home/ec2-user/backup-moodle-mysql.sh' do
	source 'backup-moodle-mysql.sh'
	owner 'ec2-user'
	mode '0770'
	variables(
		:backupbucket		=> node['S3_backup_bucket'],
        :db_host		=> db['address'],
		:db_user		=> db['db_user'],
		:db_pass		=> db['db_password'],
        :db_main        => db['database_name'],
	)
end

template '/etc/cron.d/hourly-moodlebackup.cron' do
    if thisinstance['instanceid'] == lastinstance['instanceid']
        source 'hourly-moodlebackup.cron.erb'
    else
        source 'empty'
    end
end