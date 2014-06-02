require 'json'
require 'rubygems'
require 'rack'

SERVER_FILE = 'server.rb'

class App
	def call(env)
		load SERVER_FILE

		Worker.server_call env
	end
end

