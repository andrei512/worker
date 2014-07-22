def say message
	# filteres message to prevent XSS
	message = message.gsub("\"", "")
	message = message.gsub("`", "")
	`say -v Vicki "#{message}"`
end

TEMP_FILE = ".play_song_temporary_file"

if File.exists? TEMP_FILE
	old_pid = open(TEMP_FILE).read.to_i
	`pkill -9 -P #{old_pid}`
end

File.open(TEMP_FILE, "w") { |file|
	file.write(Process.pid)
}

song = ARGV[0]

history = open(".youtube_log").read.lines

while song == "random"
	song = history.sample[26..-1]
end

# raw log
File.open(".youtube_log", "a+") { |log|  
	log.write("#{Time.now} #{song_name}\n")
}

require 'rubygems'
require 'youtube_search'
require 'json'
require 'watir'
require 'watir-webdriver'
# require 'yt_mp3'

say "looking for #{song}"

songs = YoutubeSearch.search(song)

first_song = songs.first

duration = first_song["duration"].to_i

id = first_song["video_id"]

link = "http://www.youtube.com/watch?v=#{id}"

browser = Watir::Browser.new
browser.goto link

sleep duration + 15

browser.close




