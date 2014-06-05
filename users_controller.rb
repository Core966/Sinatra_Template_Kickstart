
    get '/users/?' do
      @users = User.find_by_sql("SELECT * FROM users WHERE is_deleted = 0")
      erb "post_views/posts".to_sym
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
      user = User.find(params[:id])
	if user.update_attributes(params[:post])
	  flash[:success] = "You have successfuly deleted a user!"
	  redirect "/users"
	else
	  flash[:error] = "Failed to delete user."
	  redirect "/users"
	end
    end