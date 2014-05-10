MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger, :pool_size => 5, :timeout => 5)

case Padrino.env
  when :development then MongoMapper.database = 'tiralabomba_development'
  when :production  then MongoMapper.database = 'tiralabomba_production'
  when :test        then MongoMapper.database = 'tiralabomba_test'
end
