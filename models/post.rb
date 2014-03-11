class Post
  include MongoMapper::Document
  many :votes
  # key <name>, <type>
  key :content, String
  key :last_voted, Date
  key :user_id, String
  key :stored_avg, Integer

  timestamps!

  validates_length_of :content, :within => 10..500, :too_long => "tu mensaje tiene que ser mas corto", :too_short => "tu mensaje tiene que ser mas largo"  
  #validate :throttle_interval

  def vote_avg
    total_rating = 0
    votes.each { |vote| total_rating += vote.rating unless vote.rating.nil? }
    return (total_rating / votes.count) if votes.count > 0
    return votes.first.rating if votes.count == 1
    0
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
      Post.paginate({
                  :order    => :stored_avg.desc,
                  :per_page => 10, 
                  :page     => page_num,
               })
  end

  # checks if the user hasn't posted in the last minute
  # for new posts only
  def throttle_interval
    last_post = Post.all(:user_id => user_id).last

    unless last_post.nil?
      minute_diff = (Time.now - last_post.created_at) / 60

      if minute_diff < 1 && self.new?
        errors.add( :content, "espera un poco para postear de nuevo")
      end  
    end
  
  end
end
