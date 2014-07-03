
    get '/users/?' do
      if env['warden'].authenticate
        @title = @title + " | Admin Panel"
        @users = User.find_by_sql("SELECT id, username, CONCAT('...', SUBSTRING(email,7, 4), '...') AS partial_email FROM users WHERE is_deleted = 0")
        erb "user_views/admin".to_sym, :layout => :admin_layout
      else
	flash[:error] = "You must login before entering a restricted area!"
	redirect '/login'
      end
    end

    get '/users/new' do
	@title = @title + " | New User"
	@user = User.new
	erb "user_views/new_user".to_sym
    end
    
    post '/users/?' do
      @user = User.new(params[:user])
	if @user.save #In case of failure to save into the database...
	  flash[:success] = "You have successfuly created a new user!"
	  redirect "/login"
	else
	  flash[:error] = "Save of new user into the database has failed."
	  erb "user_views/new_user".to_sym #...the application redirects to the same page.
	end
    end
    
    put '/users/:id' do
      if env['warden'].authenticate
        user = User.find(params[:id])
	  if user.update_attributes(params[:user])
	    if params[:user][:is_deleted]
	      flash[:success] = "You have successfuly deleted a user!"
	    else
	      flash[:success] = "You have successfuly changed the password of the user!"
	    end
	    redirect "/users"
	  else
	    if params[:user][:is_deleted]
	      flash[:error] = "Failed to delete user."
	    else
	      flash[:error] = "Failed to change the password of the user."
	    end
	    redirect "/users"
	  end
      else
        flash[:error] = "You must login before entering a restricted area!"
	redirect '/login'
      end
    end