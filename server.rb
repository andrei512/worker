puts "loading server... #yolo"

require 'json'
require "net/http"
require "uri"
require 'securerandom'

def call_post url, params
	puts "calling #{url} with #{JSON.pretty_generate(params)}"

	uri = URI.parse(url)
	response = Net::HTTP.post_form(uri, params)

	puts response.body
end

@@tasks = {}

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
	params = task["callback_params"]
	params ||= task


	puts "10100000" * 100
	puts "callback_params = #{params}"

	call_post task["callback"], params
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

def run task
	name = task["task"]

	proc = @@tasks[name]

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
				params_info = request.params["params"] 
				params = JSON.parse(params_info) rescue request.params

				id = SecureRandom.base64.to_s
				params["id"] = id

				run(params)
			end
		else 				
			page_not_found
		end
	else
		page_not_found
	end
end

