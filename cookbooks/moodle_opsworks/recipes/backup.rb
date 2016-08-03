thisinstance = search(:aws_opsworks_instance, "self:true").first
log(thisinstance){level :warn}

lastinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").last
firstinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").first
db = search(:aws_opsworks_rds_db_instance, "*:*").first
stack = search(:aws_opsworks_stack).first
moodle_databases = []

# Search for a moodle app, we only want to do DB backups if we have an app to backup,
# also include any extra databases from the stack json in the following format
# "extra_databases" : [{"name" : "some_database"}]}
# note db credentials from primary app have to have access to any extra db's
search("aws_opsworks_app").each do |app|
 if app['name'] == "Moodle"

	primary_db = {
		:backupbucket	=> node['S3_backup_bucket'],
		:stack				=> stack['name'],
        :db_host		=> db['address'],
		:db_user		=> db['db_user'],
		:db_pass		=> db['db_password'],
        :db_name        => app["data_sources"][0]["database_name"],}

		moodle_databases.push(primary_db)
	unless node['extra_databases'].nil?
		node['extra_databases'].each do |i|
			extra_db = {
			:backupbucket	=> node['S3_backup_bucket'],
			:stack				=> stack['name'],
        	:db_host		=> db['address'],
			:db_user		=> db['db_user'],
			:db_pass		=> db['db_password'],
        	:db_name        => i['name'],}

			moodle_databases.push(extra_db)
		end
	end
	else
	log('No moodle application found, check app name in opsworks') { level :warn }
 end

end

# create the backup script from db's'
template '/home/ec2-user/backup-moodle-mysql.sh' do
	source 'backup-moodle-mysql.sh'
	owner 'ec2-user'
	mode '0770'
	variables :moodle_databases => moodle_databases
end

# create backup script for moodle data folder, will only backup filedir
template '/home/ec2-user/backup-moodledata.sh' do
	source 'backup-moodledata.sh'
	owner 'ec2-user'
	mode '0770'
	variables(
		:backupbucket		=> node['S3_backup_bucket'],
		:stack				=> stack['name'],
		:moodledata_size	=> node['moodledata_size']
	)
end


# choose instance to run backup from
template '/etc/cron.d/moodlebackup.cron' do
    if thisinstance['instanceid'] == firstinstance['instanceid']
        source 'moodlebackup.cron.erb'
    else
        source 'empty'
    end
end