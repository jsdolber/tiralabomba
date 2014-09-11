cmd = "node classifier/classy.js"
run_tweets = system( cmd )

exit unless run_tweets

tweets = JSON.parse(File.read('tweets.json'))

tweets.each do |tweet|
	p = Post.new :content => tweet["content"],
					:user_id => tweet["username"] + (rand * 10).to_s,
					:stored_avg => 0,
					:vote_count => 0,
					:friendly_url => Post.get_friendly_url(tweet["content"]),
					:location_neighborhood => tweet["location"],
					:location_country => "Argentina",
					:username => tweet["username"],
					:name => tweet["name"],
					:tweet_url => tweet["url"],
					:avatar_url => tweet["avatar_url"],
					:tweet_id => tweet["tweet_id"],
					:published => false

	p.save!
end