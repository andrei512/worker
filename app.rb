require 'json'
require 'rubygems'
require 'rack'

SERVER_FILE = 'server.rb'

puts "server starting..."

class App
	def call(env)
		load SERVER_FILE

		Worker.server_call env
	end
end

