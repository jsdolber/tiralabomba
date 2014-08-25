class Bombardero
  include MongoMapper::Document

  # key <name>, <type>
  key :username, String
  key :name, String
  key :content, String
  key :url, String
  key :avatar_url, String
  key :tweet_id, String

  timestamps!

  validates_presence_of :tweet_id

  def self.load_from_tweet(id)
  	  erik = Twitter::REST::Client.new do |config|
        config.consumer_key = 'bVqypJtXqUiiMH8d6FJd3A01w'
        config.consumer_secret = 'UNK3wEZ1C5KA1DSrTC0v9smKPkRv2WTBgbZXKg4AcDwV6DiA3G'
        config.access_token        = '17706291-lYhpVZTIJeUzlI03wpeA7CoCwl1wqyUeha2JZvRoz'
        config.access_token_secret = 'YxMP10KKSaFujFMlGT4ykHBJ1rS5745CiMUlWgKJ3Y8Wz'
      end
      
      t = erik.status(id)
      b = Bombardero.new

      unless t.nil?
	      b.tweet_id = id
	      b.url = t.url.to_s
	      b.name = t.user.name
	      b.username = t.user.username
	      b.content = t.text
	      b.avatar_url = t.user.profile_image_url.to_s
  	  end
  	  
      b
  end

  def self.get_top_five
    cached_bs = Padrino.cache.get("bombarderos")
    
    if cached_bs.nil?
      cached_bs = Bombardero.order(:created_at.desc).all[0,5]
      Padrino.cache.set("bombarderos", cached_bs, :expires_in => (60*30))
    end

    cached_bs
    
  end
end
