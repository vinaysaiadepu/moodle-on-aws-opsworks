Chef::Log.info("********* HELLO WORLD! *************")

Chef::Log.info("********* Cloning app from github *************")
app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"
git app_path do
	repository app["app_source"]["url"]
	revision app["app_source"]["revision"]
end
