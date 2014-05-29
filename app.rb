require 'json'
require 'rubygems'
require 'rack'

class App
	def call(env)
		load 'server.rb'

		server_call env
	end
end

