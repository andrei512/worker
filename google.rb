require 'watir'
require 'watir-webdriver'
require 'nokogiri'
# require 'os'
require 'json'

query_string = ARGV[0]

# if OS.linux?
# 	# no more ui
# 	require 'headless'
# 	headless = Headless.new
# 	headless.start
# end

browser = Watir::Browser.new
browser.goto 'google.ro'

sleep Random.rand(6) + 1

browser.text_field(:name => 'q').set query_string


browser.button(:name => 'btnG').click

sleep 2

content = browser.html
doc = Nokogiri::HTML(content)

results = doc.css("li.g").select { |result|
	title = result.css('h3').inner_text
	title and title.length > 0
}

results_info = []

results.each do |result|
	title = result.css('h3').inner_text
	description = result.css('span.st').inner_text
	keywords = result.css('span.st em').map(&:inner_text)
	link = result.css('h3 a').attr('href')

	results_info << {
		title: title,
		description: description,
		keywords: keywords,
		link: link
	}
end

puts JSON.pretty_generate(results_info)

lucky_link = results_info[Random.rand(3)]

sleep Random.rand(5) + 1

browser.link(text: lucky_link[:title]).when_present.click

sleep 10 

browser.close



