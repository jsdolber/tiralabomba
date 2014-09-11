#!/usr/bin/env ruby

require 'twitter'

username = ARGV[0]

if username == nil
	puts "No username provided"
	exit 
end

erik = Twitter::REST::Client.new do |config|
	config.consumer_key = 'bVqypJtXqUiiMH8d6FJd3A01w'
	config.consumer_secret = 'UNK3wEZ1C5KA1DSrTC0v9smKPkRv2WTBgbZXKg4AcDwV6DiA3G'
	config.access_token        = '17706291-lYhpVZTIJeUzlI03wpeA7CoCwl1wqyUeha2JZvRoz'
	config.access_token_secret = 'YxMP10KKSaFujFMlGT4ykHBJ1rS5745CiMUlWgKJ3Y8Wz'
end

tweets = erik.user_timeline(username, :count => 200)

buddys = {}
buddy_tweet = []

tweets.each do |t|
	content = t.text

	if content.index('@') != nil
		
		content.scan(/(?<=^|\s)@([a-z0-9_]+)/i).each do |u|
			buddys[u] = 0 if buddys[u] == nil
			buddys[u] += 1			
		end

		buddy_tweet.push(content)
	end
end

File.open('report.text', 'w') do |file| 
	file.puts buddys.sort.map {|k,v| "#{k}-" + v.to_s}
	file.puts('')
	file.puts('================================')
	file.puts('') 
	buddy_tweet.each {|text| file.puts text}
end
