# encoding: utf-8
class Post
  include MongoMapper::Document
  many :votes
  
  # key <name>, <type>
  key :content, String
  key :last_voted, Date
  key :user_id, String
  key :stored_avg, Integer
  key :category_ids, Array
  key :friendly_url, String
  many :categories, :in => :category_ids

  timestamps!

  validates_length_of :content, :within => 30..500, :too_long => "tu mensaje tiene que ser más corto (máximo 500)", 
                                                      :too_short => "tu mensaje tiene que ser más largo (mínimo 30)"  
  validate :throttle_interval
  validate :validate_content_line_breaks

  def vote_avg
    total_rating = 0
    votes.each { |vote| total_rating += vote.rating unless vote.rating.nil? }
    return (total_rating / votes.count) if votes.count > 0
    return votes.first.rating if votes.count == 1
    0
  end

  def categories_in_short_name
    self.categories.map { |c| c.short_name }.join(",")
  end

  def set_categories(raw_categories)
    self.category_ids.clear #empty whatever there is
    raw_categories.split(",").each do |cat|
       if cat.length > 0
         c = Category.find_by_short_name(cat)
         if !c.nil?
           self.categories << c
         end
       end
    end
  end

  def self.get_page_for_category(name, page_num)
    c = Category.find_by_name(name)
    c = Category.find_by_short_name(name) if c.nil?
    Post.where(:category_ids => c.id).paginate({
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

    cached_page = Padrino.cache.get("results-#{page_num}")
    
    if cached_page.nil?
      cached_page = Post.paginate({
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
          cached_page = Post.paginate({
                  :order    => :stored_avg.desc,
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
    Post.where(:content => Regexp.new("#{keyword}", true)).all
  end

  # checks if the user hasn't posted in the last minute
  # for new posts only
  def throttle_interval
    last_post = Post.all(:user_id => user_id).last

    unless last_post.nil?
      minute_diff = (Time.now - last_post.created_at) / 60

      if minute_diff < 0.3 && self.new?
        errors.add( :content, "esperá un poco para postear de nuevo")
      end  
    end  
  end

  def validate_content_line_breaks
    line_break_cnt = content.count 13.chr
    errors.add( :content, "el mensaje es inválido, probá con menos cortes.") if line_break_cnt > 8
  end
end
