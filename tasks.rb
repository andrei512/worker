task :count do |params|
	number = params["number"]
	Thread.new do 
		params["number"] = number + 1

		sleep 10

		call_hook params
	end

	task_ok params
end

def say message
	# filteres message to prevent XSS
	message = message.gsub("\"", "")
	`say -v Vicki "#{message}"`
end

task :say do |params|
	Thread.new do 
		say params["message"]
		call_hook params
	end

	task_ok params
end

filter :github, -> (params) {
	params["head_commit"] 
} do |params|
	say "new push!"
	sleep 1
	say params["head_commit"]["message"]
	`git pull`
	say "system updated!"

	task_ok params
end