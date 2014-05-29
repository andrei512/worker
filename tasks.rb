task :count do |params|
	number = params["number"]
	Thread.new do 
		params["number"] = number + 1

		sleep 10

		call_hook params
	end

	task_ok params
end

task :say do |params|
	Thread.new do 
		message = params["message"]
		`say -v Vicki #{message}`

		call_hook params
	end

	task_ok params
end