source 'https://rubygems.org'

# Distribute your app as a gem
# gemspec

# Server requirements
gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'
gem 'rack-throttle', :require => 'rack/throttle'
gem 'bcrypt', :require => "bcrypt"

# Component requirements
gem 'bson_ext', :require => 'mongo'
gem 'mongo_mapper'
gem 'sass'
gem 'haml'

# Test requirements
gem 'rspec', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.11.4'

gem 'padrino-sprockets', :require => ['padrino/sprockets'], :git => 'git://github.com/nightsailer/padrino-sprockets.git'
gem 'uglifier', '2.1.1'
gem 'yui-compressor', '0.9.6'

gem 'redis'

gem 'builder'

gem 'twitter'

group :development, :test do
  gem 'debugger'
end

gem 'newrelic_rpm'

gem 'whenever', :require => false

gem 'wtf_lang'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.11.4'
# end
