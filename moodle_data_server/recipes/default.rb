# Create NFS share to be available for other servers

include_recipe "nfs"

directory "/vol/moodledata" do
  owner 48
  group 48
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


# TODO: If /vol/moodledata/filedir is empty, restore it from backup from Amazon S3

# if Dir["/vol/moodledata/filedir"]
