puts "loading server... #yolo"

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

@@tasks = {}
@@filters = []

def task_ok task
	{
		task: task["task"],
		id: task["id"],
		status: :success
	}
end

def task name, &lambda
	@@tasks[name.to_s] = lambda
end

def call_hook task
	callback = task["callback"]

	if callback
		params = task["callback_params"]
		unless params
			params = task.clone
		 	params.delete("callback")
		end 

		call_post callback, params
	end
end

def load_tasks!
	@@tasks = {}
	load 'tasks.rb'	
end

def list_tasks 
	[
		200,
	 	{
	 		"Content-Type" => "text/json"
	 	},
	 	[JSON.pretty_generate(@@tasks.keys)]
	]
end

def page_not_found 
	[404, {}, ["404 - Page not found"]]
end

def error_501 status
	[
		501, 
		{
	 		"Content-Type" => "text/json"
	 	},
	 	[JSON.pretty_generate(status)] 
	]
end

def work_or_501 error
	begin
		yield
	rescue Exception => e 
		puts "Error: #{e}\n#{e.backtrace.join("\n")}"
		error_501 error
	end
end

def undefined_task_proc 
	[
		200,
	 	{
	 		"Content-Type" => "text/json"
	 	},
	 	[JSON.pretty_generate({
	 		message: "Undefined task!",
 		})]
	]
end

def filter name, validator, &lambda
	@@filters << {
		validator: validator,
		lambda: lambda
	}
end

def proc_for task
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

def run task
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

load_tasks!

def server_call(env)
	request = Rack::Request.new env

	puts "#{request.request_method} #{request.path}"
	puts "params = #{request.params}" 

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

				params_info = request.params["params"] 

				params = nil
				if params_info == nil
					params = JSON.parse(request.body.read)
				else
					params = JSON.parse(params_info)
				end

				id = SecureRandom.base64.to_s
				params["id"] = id

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


