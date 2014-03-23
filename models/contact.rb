class Contact
  include MongoMapper::Document

  # key <name>, <type>
  key :email, String
  key :content, String
  timestamps!

  validates_length_of :content, :within => 10..200, :too_long => "tu mensaje tiene que ser mas corto", :too_short => "tu mensaje tiene que ser mas largo"
end
