if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else

this_instance = search(:aws_opsworks_instance, 'self:true').first
log(this_instance) { level :warn }
# Find the first instance with the same layer ID as us
first_instance = search(:aws_opsworks_instance, 'role:moodle-web-server AND status:online').first
db = search(:aws_opsworks_rds_db_instance, '*:*').first
stack = search(:aws_opsworks_stack).first
moodle_databases = []
s3_bucket = node['S3_backup_bucket']

# Search for a moodle app, we only want to do DB backups if we have an app to backup,
# also include any extra databases from the stack json in the following format
# "extra_databases" : [{"name" : "some_database"}]}
# note db credentials from primary app have to have access to any extra db's
search('aws_opsworks_app').each do |app|
  if app['name'] == 'Moodle'

    primary_db = {
        backup_bucket: s3_bucket,
        stack: stack['name'],
        db_host: db['address'],
        db_user: db['db_user'],
        db_pass: db['db_password'],
        db_name: app['data_sources'][0]['database_name'] }

    moodle_databases.push(primary_db)
    unless node['extra_databases'].nil?
      node['extra_databases'].each do |additional_db|
        extra_db = {
            backup_bucket: s3_bucket,
            stack: stack['name'],
            db_host: db['address'],
            db_user: db['db_user'],
            db_pass: db['db_password'],
            db_name: additional_db['name'] }

        moodle_databases.push(extra_db)
      end
    end
  else
    message = 'No moodle application found, check app name in opsworks'
    log(message) { level :warn }
  end

end

# create the backup script from db's'
template '/home/ec2-user/backup-moodle-mysql.sh' do
  source 'backup-moodle-mysql.sh'
  owner 'ec2-user'
  mode '0770'
  variables moodle_databases: moodle_databases
end

# create backup script for moodle data folder, will only backup filedir
template '/home/ec2-user/backup-moodledata.sh' do
  source 'backup-moodledata.sh'
  owner 'ec2-user'
  mode '0770'
  variables(
      stack: stack['name'],
      backup_bucket: s3_bucket,
      moodledata_size: node['moodledata_size']
  )
end

if node['env'].nil? || node['env'].downcase != 'dev'
  # choose instance to run backup from
  template '/etc/cron.d/moodlebackup.cron' do
    if this_instance['instance_id'] == first_instance['instance_id']
      source 'moodlebackup.cron.erb'
    else
      source 'empty'
    end
  end
else
  template '/etc/cron.d/moodlebackup.cron' do
    source 'empty'
  end
  log('Dev Environment detected, not scheduling automatic backups') { level :warn }
end

end