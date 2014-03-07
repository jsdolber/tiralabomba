class Post
  include MongoMapper::Document
  many :votes
  # key <name>, <type>
  key :content, String
  key :last_voted, Date
  timestamps!

  validates_length_of :content, :within => 10..500, :too_long => "tu mensaje tiene que ser mas corto", :too_short => "tu mensaje tiene que ser mas largo"

  def vote_avg
    total_rating = 0
    votes.each { |vote| total_rating += vote.rating unless vote.rating.nil? }
    return (total_rating / votes.count) if votes.count > 0
    return votes.first.rating if votes.count == 1
    0
  end
end
