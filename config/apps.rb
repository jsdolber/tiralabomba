##
# This file mounts each app in the Padrino project to a specified sub-uri.
# You can mount additional applications using any of these commands below:
#
#   Padrino.mount('blog').to('/blog')
#   Padrino.mount('blog', :app_class => 'BlogApp').to('/blog')
#   Padrino.mount('blog', :app_file =>  'path/to/blog/app.rb').to('/blog')
#
# You can also map apps to a specified host:
#
#   Padrino.mount('Admin').host('admin.example.org')
#   Padrino.mount('WebSite').host(/.*\.?example.org/)
#   Padrino.mount('Foo').to('/foo').host('bar.example.org')
#
# Note 1: Mounted apps (by default) should be placed into the project root at '/app_name'.
# Note 2: If you use the host matching remember to respect the order of the rules.
#
# By default, this file mounts the primary app which was generated with this project.
# However, the mounted app can be modified as needed:
#
#   Padrino.mount('AppName', :app_file => 'path/to/file', :app_class => 'BlogApp').to('/')
#

##
# Setup global project settings for your apps. These settings are inherited by every subapp. You can
# override these settings in the subapps as needed.
#
Padrino.configure_apps do
  # enable :sessions
  set :session_secret, 'e02b5fb40a2294c739bb7dce4bf19757bf4fd4c5110190f7a5c4df407d7126d2'
  set :protection, true
  set :protect_from_csrf, false
  set :allow_disabled_csrf, true
end

# Padrino.use(Rack::Auth::Basic) do |username, password|
#   username == 'tirala' && password == 'bombita'
# end 

# Mounts the core application for this project
Padrino.mount('Tiralabomba::App', :app_file => Padrino.root('app/app.rb')).to('/')

Padrino.mount("Tiralabomba::Admin", :app_file => File.expand_path('../../admin/app.rb', __FILE__)).to("/admin")