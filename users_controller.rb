
    get '/users/new' do
	@title = @title + " | New User"
	@user = User.new
	erb "user_views/new_user".to_sym
    end
    
    post '/users/?' do
      @user = User.new(params[:user])
	if @user.save #In case of failure to save into the database...
	  redirect "/login"
	else
	  erb "user_views/new_user".to_sym #...the application redirects to the same page.
	end
    end