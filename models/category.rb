class Category
  include MongoMapper::Document

  # key <name>, <type>
  key :name, String
  key :short_name, String
  key :order, Integer
  timestamps!
end
