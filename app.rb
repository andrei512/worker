require 'json'
require 'rubygems'
require 'rack'

SERVER_FILE = 'server.rb'

class App
	attr_accessor :last_mtime


	def call(env)
		mtime = File.mtime(SERVER_FILE)

		@last_mtime ||= Time.new(0)

		if mtime - @last_mtime > 0
			load SERVER_FILE
			@last_mtime = mtime 
		end

		Worker.server_call env
	end
end

