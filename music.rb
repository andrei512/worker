def play_sound sound
  sound_file = Dir["**/**#{sound}**"].first
  `afplay "#{sound_file}"`
end

require 'singleton'
require 'youtube_search'
require './yt_mp3.rb'


class MusicPlayer 
  include Singleton

  attr_accessor :queue 


  def initialize
    queue = []
  end

  def add song
    queue << YoutubeSearch.search(song).first
  end

  def play_next
    until queue.empty?
      song = queue.shift

      first_song = songs.first

      duration = first_song["duration"].to_i

      id = first_song["video_id"]

      link = "http://www.youtube.com/watch?v=#{id}"

    end


  end

end

puts "yolo"