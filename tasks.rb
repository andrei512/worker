def say message
	# filteres message to prevent XSS
	message = message.gsub("\"", "")
	message = message.gsub("`", "")
	`say -v Vicki "#{message}"`
end

def set_volume volume
	system("ruby set_volume.rb '#{volume}'") 
end

def get_volume 
	volume_info = `osascript -e 'get volume settings'`
	# output volume:29, input volume:58, alert volume:100, output muted:false

	raw_volume = volume_info.split(":")[1].to_i  #29
	volume = (raw_volume / 14).to_i # 2
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

		reboot_system!

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

	task :youtube do |params|
		Thread.new do 
			song_name = params["q"] || params["song"] || params["query"] || params["message"]

			system("ruby play_song.rb '#{song_name}'") 

			call_hook params
		end

		task_ok params
	end

	task :volume do |params|
		Thread.new do 
			volume = params["volume"] || params["v"] || params["message"] || params["value"]

			set_volume volume

			call_hook params
		end

		task_ok params
	end

	task :yell do |params|
		Thread.new do 
			message = params["message"]

			old_volume = get_volume

			set_volume 6

			say message

			set_volume old_volume

			call_hook params
		end

		task_ok params
	end

	task :door do |params|
		Thread.new do 
			old_volume = get_volume

			set_volume 6

			`afplay "resources/sounds/door bell.wav"`

			set_volume old_volume

			call_hook params
		end

		task_ok params
	end

end


