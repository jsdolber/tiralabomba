class Vote
  include MongoMapper::EmbeddedDocument
  belongs_to :post
  # key <name>, <type>

  key :rating, Integer
  timestamps!

  validates_numericality_of :rating, :message => "tiene que ser numero"
  validate :rating_number_validation

  def rating_number_validation
  	if rating < 1 || rating > 5
      errors.add( :rating, "rating entre 1 y 5")
    end
  end

end
