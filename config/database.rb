MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'tiralabomba_development'
  when :production  then MongoMapper.database = 'tiralabomba_production'
  when :test        then MongoMapper.database = 'tiralabomba_test'
end
