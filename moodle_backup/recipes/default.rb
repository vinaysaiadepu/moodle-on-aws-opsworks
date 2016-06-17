template '/home/ec2-user/hourly-moodledata.sh' do
	source 'hourly-moodledata.sh'
	owner 'ec2-user'
	mode '0770'
	variables(
		:backupbucket => ${node['backupbucket']}
	)
end

template '/etc/cron.d/hourly-moodlebackup.cron' do
	source 'hourly-moodlebackup.cron'
end

# service 'crond' do
# 	action :restart
# end
