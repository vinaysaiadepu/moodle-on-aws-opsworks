# allow searching aws stack from attributes file
class AttributeSearch
  extend Chef::DSL::DataQuery
end

stack = AttributeSearch.search(:aws_opsworks_stack).first

default['cwlogs']['logfiles']['Site-httpd_access'] = {
    :log_stream_name => '{instance_id}-{hostname}',
    :log_group_name => "#{stack['name']}-httpd_access-group",
    :file => '/var/log/httpd/access_log',
    :datetime_format => '%d/%b/%Y:%H:%M:%S %z',
    :initial_position => 'end_of_file'
}

default['cwlogs']['logfiles']['Site-httpd_error'] = {
    :log_stream_name => '{instance_id}-{hostname}',
    :log_group_name => "#{stack['name']}-httpd_error-group",
    :file => '/var/log/httpd/error_log',
    :datetime_format => '%d/%b/%Y:%H:%M:%S %z',
    :initial_position => 'end_of_file'
}

override['oh_my_zsh']['users'] = [{
                                      :login => 'ec2-user',
                                      :theme => 'candy',
                                      :plugins => ['git', 'gem', 'docker', 'cp']
                                  },
                                  {
                                      :login => 'root',
                                      :theme => 'af-magic',
                                      :plugins => ['git', 'gem', 'docker', 'cp']
                                  }]
