require 'json'
require 'rubygems'
require 'rack'

SERVER_FILE = 'server.rb'

class App
	attr_accessor :last_mtime

	def call(env)
		mtime = File.mtime(SERVER_FILE)

		if last_mtime == nil or (last_mtime and mtime - last_mtime > 0)
			load SERVER_FILE
			last_mtime = mtime 
		end

		server_call env
	end
end

