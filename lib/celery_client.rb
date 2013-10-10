require "pathname"


require "celery_client/version"
require "celery_client/http"
require "celery_client/task_manager"


module CeleryClient
	lib_path = Pathname.new(File.expand_path("../celery_client", __FILE__))
	autoload :HTTP, lib_path.join("http")
	autoload :HTTP, lib_path.join("task_manager")

	def self.source_root
		@source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
	end
end
