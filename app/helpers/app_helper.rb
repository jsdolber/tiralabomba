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
    return "label-danger" if minute_diff < 120
    "no-display"
  end

  def self.style_for_post_header(post)  
    return "no-display" if AppHelper.label_style_for_post(post.created_at) == "no-display" && post.location_neighborhood.to_s.length == 0
    ""
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
    #debugger
    tweets = Padrino.cache.get('tweets')

    if tweets.nil?
      erik = Post.twitter_cli

      tweets = erik.user_timeline("tiralabombaaa", :exclude_replies => true, :count => 100)

      Padrino.cache.set('tweets', tweets, :expires_in => (60*10))
    end

    tweets[0, 7]
  end
end