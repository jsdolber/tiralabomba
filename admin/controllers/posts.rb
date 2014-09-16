Tiralabomba::Admin.controllers :posts do
  get :index do
    @title = "Posts"
    @posts = Post.all(:order => :created_at.desc)
    render 'posts/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'post')
    @post = Post.new
    render 'posts/new'
  end

  post :create do
    @post = Post.new(params[:post])
    @post = Post.load_from_tweet(@post.tweet_id) unless @post.tweet_id.nil?
    
    if @post.save
      @title = pat(:create_title, :model => "post #{@post.id}")
      flash[:success] = pat(:create_success, :model => 'Post')
      params[:save_and_continue] ? redirect(url(:posts, :index)) : redirect(url(:posts, :edit, :id => @post.id))
    else
      @title = pat(:create_title, :model => 'post')
      flash.now[:error] = pat(:create_error, :model => 'post')
      render 'posts/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "post #{params[:id]}")
    @post = Post.find(params[:id])
    if @post
      render 'posts/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'post', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "post #{params[:id]}")
    @post = Post.find(params[:id])
    if @post
      @post.set_categories(params[:post][:categories_in_short_name])
      if @post.update_attributes(params[:post])
        flash[:success] = pat(:update_success, :model => 'Post', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:posts, :index)) :
          redirect(url(:posts, :edit, :id => @post.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'post')
        render 'posts/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'post', :id => "#{params[:id]}")
      halt 404
    end
  end

  post :publish, :with => :id do
    @title = "Publicao"
    post = Post.find(params[:id])
    if post
      if post.publish
        flash[:success] = pat(:publish_success, :model => 'Post', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:publish_error, :model => 'post')
      end
      redirect url(:posts, :index)
    else
      flash[:warning] = pat(:publish_warning, :model => 'post', :id => "#{params[:id]}")
      halt 404
    end
  end

  post :publish_many do
    @title = "Publicaos"
    unless params[:post_ids]
      flash[:error] = pat(:publish_many_error, :model => 'post')
      redirect(url(:posts, :index))
    end
    ids = params[:post_ids].split(',').map(&:strip)
    posts = Post.find(ids)
    
    if posts.each(&:publish)
    
      flash[:success] = pat(:publish_many_success, :model => 'Posts', :ids => "#{ids.to_sentence}")
    end
    redirect url(:posts, :index)
  end

  delete :destroy, :with => :id do
    @title = "Posts"
    post = Post.find(params[:id])
    if post
      if post.destroy
        flash[:success] = pat(:delete_success, :model => 'Post', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'post')
      end
      redirect url(:posts, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'post', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Posts"
    unless params[:post_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'post')
      redirect(url(:posts, :index))
    end
    ids = params[:post_ids].split(',').map(&:strip)
    posts = Post.find(ids)
    
    if posts.each(&:destroy)
    
      flash[:success] = pat(:destroy_many_success, :model => 'Posts', :ids => "#{ids.to_sentence}")
    end
    redirect url(:posts, :index)
  end
end
