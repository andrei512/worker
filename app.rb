require 'json'
require 'rubygems'
require 'rack'

SERVER_FILE = 'server.rb'

class App
	attr_accessor :last_mtime


	def call(env)
		mtime = Dir.glob("**/*").inject(Time.new(0)) { |mem, var|  
			time = File.mtime(var)
			mem - time > 0 ? mem : time
		}

		@last_mtime ||= Time.new(0)

		puts "[#{mtime - @last_mtime}] mtime: #{mtime} @last_mtime: #{@last_mtime}"

		if mtime - @last_mtime > 0
			load SERVER_FILE
			@last_mtime = mtime 
		end

		Worker.server_call env
	end
end

