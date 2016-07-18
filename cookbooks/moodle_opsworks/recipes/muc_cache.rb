thisinstance = search(:aws_opsworks_instance, "self:true").first
firstinstance = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").first

# Only first instance works as a memcached host
	if thisinstance['instanceid'] == firstinstance['instanceid']
		memcached_instance 'memcached_sessions' do
            port 11_212
            memory 64
            action :start
        end
## Seperate cache so we can purge without killing session
        memcached_instance 'memcached_application' do
            port 111_212
            memory 128
            action :start
        end

		template 'config.php' do
            path '/mnt/nfs/moodledata/muc/config.php'
            source 'config.php.muc.erb'
            owner 'apache'
            group 'ec2-user'
            mode '0770'
            variables(
                :memcached_ip	=> firstinstance['private_ip']
            )
        end

        template '/var/www/html/admin/cli/scan_cache.php' do
            source 'scan_cache.php'
        end

        execute 'apache_configtest' do
            command 'sudo -u apache /usr/bin/php /var/www/html/admin/cli/scan_cache.php'
        end
	else
		memcached_instance 'memcached_sessions' do
            action :remove
        end

        memcached_instance 'memcached_application' do
            action :remove
        end
	end	






