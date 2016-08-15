if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')

elsif !::File.exists?("/mnt/nfs/moodledata/muc")
  Chef::Log.warn('Was not able to find moodledata folder to configure the MUC cache')
else

this_instance = search(:aws_opsworks_instance, 'self:true').first
first_moodle_instance = search(:aws_opsworks_instance, 'role:moodle-web-server AND status:online').first
# TODO check for existance of the moodle data folder and muc cache folder so this can be included  in configure 


# Only first instance works as a memcached host
if this_instance['instanceid'] == first_moodle_instance['instanceid']

  message = 'Starting Configuration of Muc Cache'
  log(message) { level :info }

  template 'config.php' do
    path '/mnt/nfs/moodledata/muc/config.php'
    source 'muc.config.php.erb'
    owner 'apache'
    group 'ec2-user'
    mode '0770'
    variables(
        :memcached_ip => first_moodle_instance['private_ip']
    )
  end


  # setup moodle cache to use memcahced
  template '/var/www/html/admin/cli/scan_cache.php' do
    source 'scan_cache.php'
  end

  # scan cache afterwards to pickup any changes
  execute 'apache_configtest' do
    command 'sudo -u apache /usr/bin/php /var/www/html/admin/cli/scan_cache.php'
  end

  message = 'Muc Cache configured and rescanned'
  log(message) { level :info }
else
  message = 'Not the first instance, muc cache has not been configured'
  log(message) { level :warn }
end

end
