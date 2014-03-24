# encoding: utf-8
class AppHelper
  def self.href_for_facebook_share(post_id)
  "https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.href_for_twitter_share(post_id)
    "https://twitter.com/share?url=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.href_for_gplus_share(post_id)
    "https://plus.google.com/share?url=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.href_for_email_share(post_id)
    "mailto:?subject=Tira La Bomba&body=http%3A%2F%2Ftiralabomba.com/show/#{post_id}"
  end

  def self.label_style_for_post(created_at)
    minute_diff = (Time.now - created_at) / 60
    return "label-danger" if minute_diff < 5
    "label-default"
  end

  def self.text_for_input_placeholder
    ['Tirala', 'Sacate las ganas', 'Dale ahora', 'Dale!', 'Rompé todo', 'Encendé la mecha'].sample
  end
end