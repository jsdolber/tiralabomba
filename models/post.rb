# encoding: utf-8
class Post
  include MongoMapper::Document
  many :votes
  
  # key <name>, <type>
  key :content, String
  key :last_voted, Date
  key :user_id, String
  key :stored_avg, Integer
  key :vote_count, Integer
  key :category_ids, Array
  key :friendly_url, String
  key :location_neighborhood, String
  key :location_country, String

  key :username, String
  key :name, String
  key :tweet_url, String
  key :avatar_url, String
  key :tweet_id, String

  key :published, Boolean

  many :categories, :in => :category_ids

  timestamps!

  validates_length_of :content, :within => 30..500, :too_long => "tu mensaje tiene que ser más corto (máximo 500)", 
                                                      :too_short => "tu mensaje tiene que ser más largo (mínimo 30)"  
  validate :throttle_interval
  validate :validate_content_line_breaks
  validate :validate_language
  after_create :handle_direct_msgs

  def calc_vote_avg
    total_rating = 0
    votes.each { |vote| total_rating += vote.rating unless vote.rating.nil? }
    return (total_rating / votes.count) if votes.count > 0
    return votes.first.rating if votes.count == 1
    0
  end

  def is_tweet
    !self.tweet_url.nil?
  end

  def self.remove_unpublished
    Post.where(:published => false).all.each {|p| p.destroy }
  end

  def official_categories
    self.categories.select {|c| c.official == true}
  end

  def self.keep_voting
    
    posts = Post.where(:created_at.gte => Time.now - 1.week, :published => true)

    15.times do 
       v = Vote.new(:rating => (rand(5) + 1))
       p = posts.all[rand(posts.count)]
       p.votes << v
       p.stored_avg = p.calc_vote_avg
       p.vote_count = p.vote_count.to_i + rand(2) + 1 if p.vote_count < 30
       p.save!
    end
  end

  def self.load_from_tweet(id)
      erik = Post.twitter_cli
      
      t = erik.status(id)
      p = Post.new

      unless t.nil?
        p.tweet_id = id
        p.tweet_url = "http://twitter.com/" + t.user.screen_name + '/status/' + t.id.to_s
        p.name = t.user.name
        p.username = t.user.screen_name
        p.user_id = t.user.screen_name
        p.content = t.text
        p.avatar_url = t.user.profile_image_url.to_s
        p.location_neighborhood = t.user.location
        p.location_country = 'Argentina'
        p.published = true
      end
      
      p
  end

  def publish
    self.published = true
    self.created_at = Time.now
    
    self.set_categories(self.content.split(/\W+/).select { |s| s.length > 3}.join(','))

    erik = Post.twitter_cli

    result = self.save

    erik.update("@#{self.username} " + 
         ["tu tweet fue publicado en http://tiralabomba.com", 
           "tu genial tweet fue publicado en http://tiralabomba.com",
           "publicamos tu espectacular tweet en http://tiralabomba.com",
           "sos especial! publicamos tu tweet en http://tiralabomba.com",
           "nos gustó tu tweet y lo pusimos en http://tiralabomba.com"].sample, 
                  in_reply_to_status_id: self.tweet_id) if result && Padrino.env != :development

    result
  end

  def categories_in_short_name
    self.categories.map { |c| c.short_name }.join(",")
  end

  def set_categories(raw_categories)
    self.category_ids.clear #empty whatever there is
    raw_categories.split(",").each do |cat|
       if cat.length > 0
         c = Category.find_or_create(cat)
         if !c.nil?
           self.categories << c
         end
       end
    end
  end

  def self.get_page_for_category(name, page_num)
    c = Category.find_by_name(name)
    c = Category.find_by_short_name(name) if c.nil?
    Post.where(:category_ids => c.id, :published => true).paginate({
                  :order    => :created_at.desc,
                  :per_page => 10, 
                  :page     => page_num,
                }) unless c.nil?
  end

  def self.get_user_id_from_request(request)
    #request.env["HTTP_USER_AGENT"]
    #request.env["REMOTE_HOST"]
    #request.ip
    Base64.strict_encode64(request.env["HTTP_USER_AGENT"].to_s + request.env["REMOTE_HOST"].to_s + request.ip.to_s)
  end

  def self.get_page_results(page_num)

    cached_page = nil #Padrino.cache.get("results-#{page_num}")
    
    if cached_page.nil?
      cached_page = Post.where(:published => true).paginate({
                    :order    => :created_at.desc,
                    :per_page => 10, 
                    :page     => page_num,
                    })

      Padrino.cache.set("results-#{page_num}", cached_page, :expires_in => (60*30))
    end

    cached_page
  end

  def self.get_popular_page_results(page_num)
      #cache
      cached_page = Padrino.cache.get("populars-#{page_num}")
      
      if cached_page.nil?
          cached_page = Post.where(:published => true).paginate({
                  :order    => "vote_count desc, stored_avg desc",
                  :per_page => 10, 
                  :page     => page_num,
               })

          Padrino.cache.set("populars-#{page_num}", cached_page, :expires_in => (60*30))
      end

      cached_page
  end

  def self.delete_results_cache
    10.times { |i| Padrino.cache.delete("results-#{i}") }
  end

  def self.search(keyword)
    Post.where(:content => Regexp.new("#{keyword}", true), :published => true).all
  end

  def self.archive(year, month)
    d = Time.utc(year,month,1)
    Post.where( :created_at => { '$gt' => d, '$lt' => d + 1.month}, :published => true ).all
  end

  def self.get_friendly_url(content)
      content.split(' ').take(7).join('-').downcase
  end

  # checks if the user hasn't posted in the last minute
  # for new posts only
  def throttle_interval
    last_post = Post.all(:user_id => user_id).last

    unless last_post.nil?
      minute_diff = (Time.now - last_post.created_at) / 60

      if minute_diff < 0.3 && self.new?
        errors.add( :content, "esperá un poco para postear de nuevo") if Padrino.env != :development
      end  
    end  
  end

  def validate_content_line_breaks
    line_break_cnt = content.count 13.chr
    errors.add( :content, "el mensaje es inválido, probá con menos cortes.") if line_break_cnt > 8
  end

  def validate_language
    errors.add( :content, "el mensaje es inválido.") unless content.dup.lang == 'es'
  end

  def handle_direct_msgs    
    if !self.is_tweet
      users = content.split(' ').select {|str| str.start_with?('@') }
      users.each { |u| send_direct_msg(u.gsub(/\W+/, ''), self.friendly_url) } unless users.count > 3
    end
  end

  def send_direct_msg(twitter_name, url)
    erik = Post.twitter_cli
    erik.update("@#{twitter_name} " + 
         ["un justiciero anónimo te dejó un mensaje en http://tiralabomba.com/show/#{url}", 
           "un ex-amigo tuyo dijo algo sobre vos en http://tiralabomba.com/show/#{url}",
           "te dejaron un regalo en http://tiralabomba.com/show/#{url}",
           "alguien dijo algo (seguramente malo) sobre vos en http://tiralabomba.com/show/#{url}",
           "estabas teniendo un buen día hasta que pusieron esto de vos en http://tiralabomba.com/show/#{url}"].sample) if Padrino.env != :development
  end

  def self.twitter_cli
    Twitter::REST::Client.new do |config|
        config.consumer_key = 'bVqypJtXqUiiMH8d6FJd3A01w'
        config.consumer_secret = 'UNK3wEZ1C5KA1DSrTC0v9smKPkRv2WTBgbZXKg4AcDwV6DiA3G'
        config.access_token        = '17706291-KaAz42qBfUaQtKIqPPDXeUrq47HccxGiWq3XzeVJ7'
        config.access_token_secret = 'FNQJ9S69xIbQh0k3A2gaMk5aZR4IuGLEPrT9UD3z7FMOs'
    end
  end
end
