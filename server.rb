puts "loading server..."

require 'json'
require "net/http"
require "uri"
require 'securerandom'

def call_post url, params
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = params.to_json
    res = http.request(req)
    puts "response #{res.body}"
rescue => e
    puts "failed #{e}"
end

module Worker
	@@tasks = {}
	@@filters = []
	@@paths = {}

	def self.task_ok task
		{
			task: task["task"],
			id: task["id"],
			status: :success
		}
	end

	def self.task name, &lambda
		@@tasks[name.to_s] = lambda
	end

	def self.call_hook task, results={}
		callback = task["callback"]

		if callback
			params = task["callback_params"]
			unless params
				params = task.clone
			 	params.delete("callback")
			 	taskname = params.delete("task")
			 	params["original-task"] = taskname
			end 

			params[:results] = results

			call_post callback, params
		end
	end

	def self.load_tasks!
		@@tasks = {}
		load 'tasks.rb'	
	end

	def self.list_tasks 
		[
			200,
		 	{
		 		"Content-Type" => "text/json"
		 	},
		 	[JSON.pretty_generate(@@tasks.keys)]
		]
	end

	def self.page_not_found 
		[404, {}, ["404 - Page not found"]]
	end

	def self.error_501 status
		[
			501, 
			{
		 		"Content-Type" => "text/json"
		 	},
		 	[JSON.pretty_generate(status)] 
		]
	end

	def self.work_or_501 error
		begin
			yield
		rescue Exception => e 
			puts "Error: #{e}\n#{e.backtrace.join("\n")}"
			error_501 error
		end
	end

	def self.undefined_task_proc 
		-> (params) {
			{
		 		message: "Undefined task!"
	 		}
		}
	end

	def self.filter name, validator, &lambda
		@@filters << {
			validator: validator,
			lambda: lambda
		}
	end

	def self.path path, mathod = "GET", &lambda
		@@paths << {
			path: path,
			method: method,
			lamdba: lambda
		}
	end


	def self.proc_for task
		proc = @@tasks[task["task"]] 

		unless proc
			@@filters.each do |filter|
				if filter[:validator].call(task)
					proc = filter[:lambda]
					break
				end
			end
		end

		proc ||= undefined_task_proc

		proc
	end

	def self.run task
		name = task["task"]

		proc = proc_for task

		output = proc.call(task)

		[
			200,
		 	{
		 		"Content-Type" => "text/json"
		 	},
		 	[JSON.pretty_generate(output)]
		]
	end

	def self.get_params request
		params_info = request.params["params"] 

		params = nil

		begin
			if params_info == nil
				params = JSON.parse(request.body.read)
			else
				params = JSON.parse(params_info)
			end
		rescue Exception => e
			return [
				200,
			 	{
			 		"Content-Type" => "text/json"
			 	},
			 	{ 
			 		status: :error 
			 	}
			 ]
		end

		id = SecureRandom.base64.to_s
		params["id"] = id

		params
	end

	def self.path_matches path, request_path
		false
	end

	def path_description_matches path_info, request
		path = path_info[:path]
		method = path_info[:method]

		matches = true

		if method != request.request_method
			matches = false
		else 
			components = path_matches path, request.path
		end

		matches
	end

	def self.server_call(env)
		request = Rack::Request.new env

		@@paths.each do |path_info| 
			if path_matches path_info, request
				params = get_params(request)
				lambda = path_info[:lambda]
				return lambda()
			end
		end

		if request.path == "/tasks.json"
			list_tasks
		elsif request.path == "/run.json"
			if request.request_method == "GET"
				[
					200,
				 	{
				 		"Content-Type" => "text/html"
				 	},
				 	[open('index.html').read]
				]
			elsif request.request_method == "POST"
				work_or_501({ status: :error }) do 
					puts "=" * 100
					puts "new task:"

					params = get_params(request)

					puts "params = #{JSON.pretty_generate(params)}"

					run(params)
				end
			else 				
				page_not_found
			end
		else
			page_not_found
		end
	end

	def self.reboot_system!
		Thread.main do
			say "rebooting system!"

			[3, 2, 1].each do |i|
				say "#{i}"
				sleep 0.5
			end

			exec "rackup config.ru -p 80"
		end
	end
end
 
Worker.load_tasks!