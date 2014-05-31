require 'json'
require 'rubygems'
require 'rack'

SERVER_FILE = 'server.rb'

class App
	def call(env)
		load SERVER_FILE

		say "This worked as expected"

		Worker.server_call env
	end
end

