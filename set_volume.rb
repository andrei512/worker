new_volume = ARGV[0].to_i

if new_volume > 10 
	new_volume = 10
end

if new_volume < 0
	new_volume = 0
end

`osascrip -e "set Volume #{new_volume}"`
