Tiralabomba::Admin.controllers :bombarderos do
  get :index do
    @title = "Bombarderos"
    @bombarderos = Bombardero.all
    render 'bombarderos/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'bombardero')
    @bombardero = Bombardero.new
    render 'bombarderos/new'
  end

  post :create do
    @bombardero = Bombardero.load_from_tweet(params[:bombardero][:tweet_id])
    
    if @bombardero.save
      @title = pat(:create_title, :model => "bombardero #{@bombardero.id}")
      flash[:success] = pat(:create_success, :model => 'Bombardero')
      params[:save_and_continue] ? redirect(url(:bombarderos, :index)) : redirect(url(:bombarderos, :edit, :id => @bombardero.id))
    else
      @title = pat(:create_title, :model => 'bombardero')
      flash.now[:error] = pat(:create_error, :model => 'bombardero')
      render 'bombarderos/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "bombardero #{params[:id]}")
    @bombardero = Bombardero.find(params[:id])
    if @bombardero
      render 'bombarderos/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'bombardero', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "bombardero #{params[:id]}")
    @bombardero = Bombardero.find(params[:id])
    if @bombardero
      if @bombardero.update_attributes(params[:bombardero])
        flash[:success] = pat(:update_success, :model => 'Bombardero', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:bombarderos, :index)) :
          redirect(url(:bombarderos, :edit, :id => @bombardero.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'bombardero')
        render 'bombarderos/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'bombardero', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Bombarderos"
    bombardero = Bombardero.find(params[:id])
    if bombardero
      if bombardero.destroy
        flash[:success] = pat(:delete_success, :model => 'Bombardero', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'bombardero')
      end
      redirect url(:bombarderos, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'bombardero', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Bombarderos"
    unless params[:bombardero_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'bombardero')
      redirect(url(:bombarderos, :index))
    end
    ids = params[:bombardero_ids].split(',').map(&:strip)
    bombarderos = Bombardero.find(ids)
    
    if bombarderos.each(&:destroy)
    
      flash[:success] = pat(:destroy_many_success, :model => 'Bombarderos', :ids => "#{ids.to_sentence}")
    end
    redirect url(:bombarderos, :index)
  end
end
