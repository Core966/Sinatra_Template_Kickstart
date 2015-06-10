    
    get '/posts/?' do
      @posts = Post.find_by_sql("SELECT * FROM posts WHERE is_deleted = 0")
      erb "post_views/posts".to_sym
    end
    
    get '/posts/new' do
	    @title = @title + " | New Post"
  	  @post = Post.new
	    erb "post_views/new_post".to_sym
    end
    
    get '/posts/:id' do
      @post = Post.find_by_sql(["SELECT posts.* FROM posts WHERE posts.id = ? AND posts.is_deleted = false", params[:id]])
    
      if @post[0].nil? == true #We check if the post is already flagged as deleted.
        redirect "/posts"
      end

      @post = Post.find_by_sql(["SELECT posts.*, comments.* FROM posts, comments WHERE comments.post_id = posts.id AND posts.id = ? AND comments.is_deleted = 0", params[:id]]) #We get the post and the comment of it.
      @comment = Comment.find_by_sql(["SELECT posts.*, comments.* FROM posts, comments WHERE comments.post_id = posts.id AND posts.id = ? AND comments.is_deleted = 0", params[:id]]) #We check if the comment is already expanded.
      if (@post[0].nil?) #But if there is no result...
	      @post = Post.find_by_sql(["SELECT * FROM posts WHERE posts.id = ?", params[:id]]) #...then there is no comment for the post.
        @no_comment = true #We need to tell it to the erb template also, because rendering is different.
      end
      @comment = Comment.new #We need to prepare here the new comment because the comments are on the show page of the post.
      @title = @title + " | " + @post[0].title
      erb "post_views/show_post_v3".to_sym
    end
    
    post '/posts/?' do
      if env['warden'].authenticate
      @post = Post.new(params[:post])
      	if @post.save #In case of failure to save into the database...
      	  redirect "/posts/#{@post.id}"
      	else
      	  redirect "/posts/new" #...the application redirects to the same page.
      	end
      else
        flash[:error] = "You must login before entering a restricted area!"
	      redirect '/login'
      end
    end

    put '/posts/:id' do
      if env['warden'].authenticate
      post = Post.find(params[:id])
      	if post.update_attributes(params[:post])
      	  redirect "/posts"
      	else
      	  redirect "/posts/#{params[:id]}"
      	end
      else
        flash[:error] = "You must login before entering a restricted area!"
	      redirect '/login'
      end
    end
    
    #Comment controllers start from here:

    post '/comments' do
      if env['warden'].authenticate
        @comment = Comment.new(params[:comment])
      	if @comment.save
      	  redirect "/posts/#{@comment.post_id}"
      	else
      	  flash[:error] = "There is problem with the save of the comment!"
      	  redirect "/posts/"
      	end
      else
        flash[:error] = "You must login before entering a restricted area!"
	      redirect '/login'
      end
    end

    put '/comments/:id/edit' do #Don't forget that this method will only append content, and only once at most!
      if env['warden'].authenticate
        comment = Comment.find(params[:id])
        
        expanded_comment = params[:comment][:comment] + "\n\n" + "Edit:" + "\n\n" + params[:comment][:expansion]
        
      	if comment.update_attributes(comment: expanded_comment, was_expanded: true)
      	  redirect "/posts/#{params[:comment][:post_id]}"
      	else
      	  redirect "/posts/#{params[:id]}"
      	end
      else
        flash[:error] = "You must login before entering a restricted area!"
	      redirect '/login'
      end
    end

    put '/comments/:id/delete' do

      if env['warden'].authenticate

        comment = Comment.find(params[:id])
        
        @post_id = Comment.find_by_sql("SELECT post_id FROM comments WHERE comments.id = " + params[:id])
  
        @post_id = @post_id[0].post_id.to_s
        
      	if comment.update_attributes(params[:comment])
      	  redirect "/posts/#{@post_id}"
      	else
      	  redirect "/posts/#{params[:id]}"
      	end
      	
      else
        flash[:error] = "You must login before entering a restricted area!"
	      redirect '/login'
      end
    end
