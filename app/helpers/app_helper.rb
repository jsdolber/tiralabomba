# encoding: utf-8
class AppHelper
  def self.href_for_facebook_share(post_id)
  "https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.href_for_twitter_share(post_id, content)
    "https://twitter.com/share?url=http%3A%2F%2Ftiralabomba.com/show/#{post_id}&text=#{content}"
  end

  def self.href_for_gplus_share(post_id)
    "https://plus.google.com/share?url=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.href_for_email_share(post_id)
    "mailto:?subject=Tira La Bomba&body=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.label_style_for_post(created_at)
    minute_diff = (Time.now - created_at) / 60
    return "label-danger" if minute_diff < 15
    "no-display"
  end

  def self.text_for_input_placeholder
    ['Tirala', 'Sacate las ganas', 'Dale ahora', 'Dale!', 'Rompé todo', 'Encendé la mecha'].sample
  end

  def self.is_disqus_link_displayed(url)
    if url.include? "/show"
      "display:none;"
    else
      "display:inline;"
    end
  end

  def self.get_twitter_posts

    tweets = Padrino.cache.get('tweets')

    if tweets.nil?
      erik = Twitter::REST::Client.new do |config|
        config.consumer_key = 'bVqypJtXqUiiMH8d6FJd3A01w'
        config.consumer_secret = 'UNK3wEZ1C5KA1DSrTC0v9smKPkRv2WTBgbZXKg4AcDwV6DiA3G'
        config.access_token        = '17706291-lYhpVZTIJeUzlI03wpeA7CoCwl1wqyUeha2JZvRoz'
        config.access_token_secret = 'YxMP10KKSaFujFMlGT4ykHBJ1rS5745CiMUlWgKJ3Y8Wz'
      end

      tweets = erik.user_timeline("tiralabombaaa")

      Padrino.cache.set('tweets', tweets, :expires_in => (60*5))
    end

    tweets[0, 10]
  end
end