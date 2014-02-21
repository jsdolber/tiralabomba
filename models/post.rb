class Post
  include MongoMapper::Document

  # key <name>, <type>
  key :content, Text
  key :last_voted, Datetime
  key :votes, Float
  timestamps!
end
