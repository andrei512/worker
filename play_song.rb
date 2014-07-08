def say message
	# filteres message to prevent XSS
	message = message.gsub("\"", "")
	message = message.gsub("`", "")
	`say -v Vicki "#{message}"`
end

song = ARGV[0]

require 'rubygems'
require 'youtube_search'
require 'json'
require 'watir'
require 'watir-webdriver'

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




