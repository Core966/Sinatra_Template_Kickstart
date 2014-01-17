    
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
      @post = Post.find_by_sql("SELECT posts.*, comments.* FROM posts, comments WHERE comments.post_id = posts.id AND posts.id = " + params[:id])
      if (nil == @post[0])
	@post = Post.find_by_sql("SELECT * FROM posts WHERE posts.id = " + params[:id])
        @no_comment = true
      end
      @comment = Comment.new
      #@edit_comment = Comment.find(params[:id])
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

    get '/comments' do
      @comment = Comment.new(params[:comment])
	if @comment.save
          @post = Post.find_by_sql("SELECT comments.* FROM comments WHERE comments.post_id = " + params[:comment][:post_id])
	  erb "post_views/comments".to_sym, :layout => false
	else
	  "There is problem with the save of the comment!"
	end
    end

    get '/comments/:id' do
      comment = Comment.find(params[:id])
	if comment.update_attributes(params[:comment])
          @post = Post.find_by_sql("SELECT comments.* FROM comments WHERE comments.post_id = " + params[:comment][:post_id])
	  erb "post_views/comments".to_sym, :layout => false
	else
	  "There is problem with the save of the comment!"
	end
    end

    get '/comments/:id/delete' do
      #1.) We need to check for the given post_id of the given comment.
      @post_id = Comment.find_by_sql("SELECT post_id FROM comments WHERE comments.id = " + params[:id])
      #2.) Destroy the comment to be deleted.
      @comment = Comment.find(params[:id]).destroy
      #3.) Check if the comment is still there.
      @comment = Comment.find_by_sql("SELECT * FROM comments WHERE comments.id = " + params[:id])
      if (nil == @comment[0]) #If its there is is probably an error, but if not...
        #We need to get all of the posts with the post_id got from the deleted comment.
	@post_id = @post_id[0].post_id
	@post_id = @post_id.to_s
	@post = Post.find_by_sql("SELECT comments.* FROM comments WHERE comments.post_id = " + @post_id)
	#If the query would still not wield results, then we probably deleted all of the comments.
	if (nil == @post)
	@no_comment = true #And we need to tell that to the check in the erb template
	@post = Post.find_by_sql("SELECT * FROM posts WHERE posts.id = " + @post_id)
	end
	erb "post_views/comments".to_sym, :layout => false
      else
        "There is problem with the deletion of the comment!"
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
