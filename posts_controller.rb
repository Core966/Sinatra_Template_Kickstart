    
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
      @post = Post.find_by_sql("SELECT posts.*, comments.* FROM posts, comments WHERE comments.post_id = posts.id AND posts.id = " + params[:id]) #We get the post and the comment of it.
      if (nil == @post[0]) #But if there is no result...
	@post = Post.find_by_sql("SELECT * FROM posts WHERE posts.id = " + params[:id]) #...then there is no comment for the post.
        @no_comment = true #We need to tell it to the erb template also, because rendering is different.
      end
      @comment = Comment.new #We need to prepare here the new comment because the comments are on the show page of the post.
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
	  erb "post_views/comments".to_sym, :layout => false #We need to disable layouts because this will be updated with an AJAX call and this is only a small part of the page.
	else
	  "<p>There is problem with the save of the comment!</p>"
	end
    end

    get '/comments/:id' do
      comment = Comment.find(params[:id])
	if comment.update_attributes(params[:comment])
          @post = Post.find_by_sql("SELECT comments.* FROM comments WHERE comments.post_id = " + params[:comment][:post_id])
	  erb "post_views/comments".to_sym, :layout => false
	else
	  "<p>There is problem with the save of the comment!</p>"
	end
    end

    get '/comments/:id/delete' do
      #1.) We need to check for the given post_id of the given comment.
      @post_id = Comment.find_by_sql("SELECT post_id FROM comments WHERE comments.id = " + params[:id])
      #2.) Destroy the comment to be deleted.
      @comment = Comment.find(params[:id]).destroy
      #3.) Check if the comment deletion was successful.
      if @comment.destroy 
        #4.)We need to get the post_id from the already deleted comment.
        @post_id = @post_id[0].post_id.to_s
	#If there would be no more comments with the given post_id, then we have deleted all of the comments for the given post.
	@post = Post.find_by_sql("SELECT comments.* FROM comments WHERE comments.post_id = " + @post_id)

	if (nil == @post)
	@no_comment = true #And we need to tell that to the check in the erb template
	@post = Post.find_by_sql("SELECT * FROM posts WHERE posts.id = " + @post_id)
	end
	erb "post_views/comments".to_sym, :layout => false
      else
        "<p>There is problem with the deletion of the comment!</p>" 
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
