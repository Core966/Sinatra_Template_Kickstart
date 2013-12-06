    
    get '/posts/?' do
      @posts = Post.find_by_sql("SELECT * FROM posts")
      erb "post_views/posts".to_sym
    end
    
    get '/posts/new' do
	@title = @title + " | New Post"
	@post = Post.new
	erb "post_views/new_post".to_sym
    end
    
    get '/posts/:id' do
      #@post = Post.find_by_sql("SELECT posts.title AS post_title, posts.body AS post_body, comments.comment AS post_comment FROM posts LEFT OUTER JOIN comments ON posts.id = comments.post_id WHERE posts.id = " + params[:id])
      @post = Post.find_by_sql("SELECT posts.*, comments.comment, comments.post_id FROM posts, comments WHERE posts.id = comments.post_id")
      @comment = Comment.new
      @title = @title + " | " + @post[0].title
      erb "post_views/show_post".to_sym
    end
    
    post '/posts/?' do
      @post = Post.new(params[:post])
	if @post.save #In case of failure to save into the database...
	  redirect "/posts/#{@post.id}"
	else
	  erb "post_views/new_post".to_sym #...the application redirects to the same page.
	end
    end

    post '/comments/?' do
      @comment = Comment.new(params[:comment])
	if @comment.save
	  redirect "/posts/#{@comment.post_id}"
	else
	  erb "post_views/show_post".to_sym
	end
    end
    
    get '/posts/:id/edit' do
      @post = Post.find(params[:id])
      @title = @title + " | Edit Form"
      erb "post_views/edit_post".to_sym
    end
    
    put '/posts/:id' do
      post = Post.find(params[:id])
	if post.update_attributes(params[:post])
	  redirect "/posts/#{post.id}"
	else
	  redirect to("/posts/#{params[:id]}")
	end
    end
    
    delete '/posts/:id' do
      @post = Post.find(params[:id]).destroy
      redirect to('/')
    end
