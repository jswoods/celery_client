require 'celery_client'


describe CeleryClient::HTTP do
	c = CeleryClient::HTTP.new({'url' => 'http://tools.dev.jivehosted.com', 'username' => 'admin', 'password' => 'admin'})
	it "test get request" do
 		c.get('/health/status').class.should eql(String)
	end

	t = CeleryClient::TaskManager.new(c)
	task_id = t.run('zenoss', 'Zenoss.tasks.sync_installation', {'installationname' => 'devonp-puppet-test'})
	it "test sync installation" do
	  t.run('zenoss', 'Zenoss.tasks.sync_installation', {'installationname' => 'devonp-puppet-test'}).class.should eql(String)
	end

	it "test get task result" do
	  t.status(task_id).class.should eql(String)
	end
end

