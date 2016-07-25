thisinstance = search(:aws_opsworks_instance, "self:true").first
firstinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").first

template '/etc/cron.d/minutely-moodle.cron' do
	# only run cron on the first webserver
	if thisinstance['instanceid'] == firstinstance['instanceid']
		source 'minutely-moodle.cron'
	else
		source 'empty'
	end		
end
