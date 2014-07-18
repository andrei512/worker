# def say message
# 	# filteres message to prevent XSS
# 	message = message.gsub("\"", "")
# 	message = message.gsub("`", "")
# 	`say -v Vicki "#{message}"`
# end

# def play_sound sound
# 	sound_file = Dir["**/**#{sound}**"].first
# 	`afplay "#{sound_file}"`
# end

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

		upgrade_sounds = [
			"Alert_ProtossUpgradeComplete",
			"Alert_TerranAddOnComplete",
			"Alert_ZergMutationComplete"
		]

		play_sound upgrade_sounds.sample

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

			song_name.gsub!("'", "")
			song_name.gsub!("`", "")

			# raw log
			File.open(".youtube_log", "a+") { |log|  
				log.write("#{Time.now} #{song_name}\n")
			}

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

			play_sound "door bell.wav"

			set_volume old_volume

			call_hook params
		end

		task_ok params
	end

	task :sound do |params|
		Thread.new do 
			sound = params["q"] || params["sound"] || params["query"] || params["message"]

			play_sound  sound
			
			call_hook params
		end

		task_ok params
	end

end


