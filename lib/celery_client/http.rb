require 'net/http'


module CeleryClient
	class HTTP
		def initialize(config)
			@url = config.fetch('url')
			@username = config.fetch('username')
			@password = config.fetch('password')
		end

		def get(path, params={})
				uri = URI("#{@url}#{path}")
				uri.query = URI.encode_www_form(params)
				request = Net::HTTP::Get.new(uri.request_uri)
				make_request(request, uri)
		end

		def post(path, params={})
				uri = URI("#{@url}#{path}")
				request = Net::HTTP::Post.new(uri.request_uri)
				request.set_form_data(params)
				make_request(request, uri)
		end

		private

		def make_request(request, uri)
			request.basic_auth @username, @password
			response = Net::HTTP.start(uri.host, uri.port,
				:use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
				http.request(request)
			end
			case response
			when Net::HTTPSuccess, Net::HTTPRedirection
				response.body
			else
				response.value
			end
		end
	end
end
