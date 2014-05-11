MongoMapper.connection = Mongo::MongoClient.new("localhost", nil, :logger => logger, :pool_size => 10, :pool_timeout => 30)
#Mongo::Connection.new('localhost', nil, :logger => logger, :pool_size => 5, :query_timeout => 30)

case Padrino.env
  when :development then MongoMapper.database = 'tiralabomba_development'
  when :production  then MongoMapper.database = 'tiralabomba_production'
  when :test        then MongoMapper.database = 'tiralabomba_test'
end
