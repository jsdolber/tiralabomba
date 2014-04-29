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

  def set_categories(raw_categories)
    raw_categories.split(",").each do |cat|
       if cat.length > 0
         c = Category.find_by_short_name(cat)
         self.categories << c unless c.nil?
       end
    end
  end

  def self.get_page_for_category(short_name, page_num)
    c = Category.find_by_short_name(short_name)
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
    Post.paginate({
                  :order    => :created_at.desc,
                  :per_page => 10, 
                  :page     => page_num,
                })
  end

  def self.get_popular_page_results(page_num)
      #cache
      pop = Padrino.cache.get('populars-#{page_num}')
      
      if pop.nil?
          pop = Post.paginate({
                  :order    => :stored_avg.desc,
                  :per_page => 10, 
                  :page     => page_num,
               })

          Padrino.cache.set('populars-#{page_num}', pop, :expires_in => (60*5))
      end

      pop
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
