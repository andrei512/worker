def say message
	# filteres message to prevent XSS
	message = message.gsub("\"", "")
	message = message.gsub("`", "")
	`say -v Vicki "#{message}"`
end

module Worker
	task :count do |params|
		Thread.new do 
			number = params["number"]
			sleep 2

			call_hook params, number + 1
		end

		task_ok params
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
		say "rebooting system!"
		for i in 3..1 do
			say "#{i}"
			sleep 1
		end
		exec "rackup config.ru -p 80"

		task_ok params
	end

	task :google do |params|
		q = params["q"]
		q = q.gsub("\"", "")
		q = q.gsub("`", "")
		Thread.new do 
			results_data = `ruby google.rb "#{q}"`

			call_hook params, JSON.parse(results_data)
		end

		task_ok params
	end
end



