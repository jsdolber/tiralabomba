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
      "Dificultades técnicas. Sepa disculpar."
    end

    not_found do
      "Hola, estas perdid@?"
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

    before do
      should_set_vars = request.route_obj.action == :index || 
                    request.route_obj.action == 'tags' || 
                    request.route_obj.action == :search || 
                    request.route_obj.action == :archive unless request.route_obj.nil?

      set_sidebar_vars if should_set_vars
    end
    
    get :index do
      @post = Post.new

      @page = (params[:p] || 1).to_i
      @filter = params[:f] || 'n'
      
      @posts = @filter == 'n'? Post.get_page_results(@page) : Post.get_popular_page_results(@page)

      @posts = [] if @posts.nil?

      render "index"
    end

    get 'tags', :with => :id do
      @page = (params[:p] || 1).to_i
      @category = params[:id]
    
      redirect url(:index) if @category.nil?

      @posts = Post.get_page_for_category(@category, @page)

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

    get :search, :with => :k do
      @posts = [] 

      @posts = Post.search(params[:k]) unless params[:k].nil?

      @keyword = params[:k]

      render "search"
    end

    get :archive, :with => [:year, :month] do
      @posts = [] 

      @month = params[:month]
      @year = params[:year]
      
      @posts = Post.archive(@year, @month) unless @month.nil? || @year.nil?

      render "archive"
    end

    get '/rss', :provides => [:rss] do
      @posts = Post.get_page_results(0)
      builder :rss
    end

    post :create_post, :csrf_protection => false do
      p = Post.new
      
      p.content = strip_tags(params[:content])
      p.user_id = Post.get_user_id_from_request(request)  
      p.location_neighborhood = params[:location_neighborhood]
      p.location_country = params[:location_country]
      p.friendly_url = Post.get_friendly_url(p.content)
      p.published = true
      p.set_categories([params[:categories], p.content.split(/\W+/).select { |s| s.length > 3}].join(',')) if p.valid?

      result = nil
      
      if !p.save
        result = {"status" => 0, "message" => p.errors.messages[:content].first}
      else
        Post.delete_results_cache
        result = {"status" => 1, "message" => 'Tu mensaje va a ser publicado en breve.'}
      end

      result.to_json

    end

    post :vote_post, :csrf_protection => false do
      p = Post.find(params[:post_id])
      
      if (p)
        v = Vote.new
        v.rating = params[:rating]
        p.last_voted = Time.now
        p.votes << v
        p.stored_avg = p.calc_vote_avg
        p.vote_count = p.vote_count.to_i + 1
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

    get :privacy do #, :cache => true do

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

    private

    def set_sidebar_vars
      @tweets = AppHelper.get_twitter_posts
    end
    
  end
end
