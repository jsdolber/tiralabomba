class Category
  include MongoMapper::Document

  # key <name>, <type>
  key :name, String
  key :short_name, String
  key :order, Integer
  key :mentions, Integer
  key :official, Boolean
  timestamps!

  def self.find_or_create(name)
  	c = Category.find_by_short_name(name)

  	if c.nil?
  		c = Category.new :name => name, :short_name => name, :mentions => 1
  	else
  		c.mentions += 1
  	end

  	c.save!

  	return c
  end

  def self.get_top(per_page)
  	Category.paginate({:order => :mentions.desc, :per_page => per_page, :page => 0})
  end
end
