include_recipe "nfs"

directory "/vol/moodledata" do
  mode '0777'
end

nfs_export "/vol/moodledata" do
  network '*'
  writeable true
  sync true
  options ['no_root_squash','no_subtree_check']
end

service "nfs" do
  action :start
end