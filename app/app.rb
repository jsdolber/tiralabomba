# encoding: utf-8
module Tiralabomba
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Sprockets
    sprockets :minify => (Padrino.env == :production)

    require 'base64'

    enable :sessions

    ##
    # Caching support.
    #
    register Padrino::Cache
    enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    error do
      "Dificultades tecnicas. Sepa disculpar."
    end

    not_found do
      "Hola! Estas perdid@??"
    end

    ##
    # You can manage errors like:
    #
    #    error 404 do
    #     render 'errors/404'
    #    end

    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #
    
    get :index do
      @post = Post.new

      @page = (params[:p] || 1).to_i
      @filter = params[:f] || 'n'
      
      @posts = @filter == 'n'? Post.get_page_results(@page) : Post.get_popular_page_results(@page)

      @posts = [] if @posts.nil?

      @tweets = AppHelper.get_twitter_posts

      render "index"
    end

    get 'tags', :with => :id do
      @page = (params[:p] || 1).to_i
      @category = params[:id]
    
      redirect url(:index) if @category.nil?

      @posts = Post.get_page_for_category(@category, @page)
      
      @tweets = AppHelper.get_twitter_posts

      render "index"
    end

    get :show, :with => :id do
      @post = Post.find_by_friendly_url(params[:id])
      @post = Post.find_by_id(params[:id]) if @post.nil?
      redirect url('/') if @post.nil?

      #metadata
      @title = truncate_words(@post.content, :length => 8)
      @description = @post.content
      @url = uri url_for(:show, :id => params[:id])

      render "show"
    end

    get '/rss', :provides => [:rss] do
      @posts = Post.get_page_results(0)
      builder :rss
    end

    post :create_post do
      p = Post.new
      p.content = strip_tags(params[:content])
      p.user_id = Post.get_user_id_from_request(request)
      p.set_categories(params[:categories])      
      p.friendly_url = p.content.split(' ').take(7).join('-').downcase

      if !p.save
        flash[:notice] = '! ' + p.errors.messages[:content].first
      end
      
      Post.delete_results_cache
      
      redirect url('/')

    end

    post :vote_post do
      p = Post.find(params[:post_id])
      
      if (p)
        v = Vote.new
        v.rating = params[:rating]
        p.last_voted = Time.now
        p.votes << v
        p.stored_avg = p.vote_avg + p.votes.count
        p.save!
      end
    end

    post :create_contact do
      p = Contact.new
      p.email = params[:email]
      p.content = params[:content]

      if !p.save
        flash[:notice] = '!' + p.errors.messages[:content].first
      else
        flash[:notice] = 'gracias!'
      end
      
      redirect url('/contact')

    end

    # get :who, :cache => true do
    #   render "who"
    # end

    get :privacy, :cache => true do

      #metadata
      @title = 'Privacidad'

      render "privacy"
    end

    get :contact, :cache => true do

      #metadata
      @title = 'Contacto'

      render "contact"
    end

    get :terms, :cache => true do

      #metadata
      @title = 'Términos y Condiciones'

      render "terms"
    end
    
  end
end
