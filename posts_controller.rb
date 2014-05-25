    
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
      @post = Post.find_by_sql("SELECT posts.* FROM posts WHERE posts.id = " + params[:id])
    
      if @post[0].is_deleted == true
        redirect "/posts"
      end

      @post = Post.find_by_sql("SELECT posts.*, comments.* FROM posts, comments WHERE comments.post_id = posts.id AND posts.id = " + params[:id] + " AND comments.is_deleted = 0") #We get the post and the comment of it.
      @comment = Comment.find_by_sql("SELECT posts.*, comments.* FROM posts, comments WHERE comments.post_id = posts.id AND posts.id = " + params[:id] + " AND comments.was_expanded = 1 AND comments.is_deleted = 0") #We get the post and the comment of it.
      if (nil == @post[0]) #But if there is no result...
	@post = Post.find_by_sql("SELECT * FROM posts WHERE posts.id = " + params[:id]) #...then there is no comment for the post.
        @no_comment = true #We need to tell it to the erb template also, because rendering is different.
      end
      if (nil == @comment[0])
        @not_expanded = true
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

    put '/posts/:id' do
      post = Post.find(params[:id])
	if post.update_attributes(params[:post])
	  redirect "/posts"
	else
	  redirect to("/posts/#{params[:id]}")
	end
    end
    
    #Comment controllers start from here:

    post '/comments' do
      @comment = Comment.new(params[:comment])
	if @comment.save
	  redirect "/posts/#{@comment.post_id}"
	else
	  @flash = "<div class=\"flash\">There is problem with the save of the comment!</div>"
	end
    end

    put '/comments/:id/edit' do #Don't forget that this method will only append content, and only once at most!

      comment = Comment.find(params[:id])
      
      expanded_comment = params[:comment][:comment] + "\n\n" + "Edit:" + "\n\n" + params[:comment][:expansion]
      
	if comment.update_attributes(comment: expanded_comment, was_expanded: true)
	  redirect to("/posts/#{params[:comment][:post_id]}")
	else
	  redirect to("/posts/#{params[:id]}")
	end
 
    end

    put '/comments/:id/delete' do

      comment = Comment.find(params[:id])
      
      @post_id = Comment.find_by_sql("SELECT post_id FROM comments WHERE comments.id = " + params[:id])

      @post_id = @post_id[0].post_id.to_s
      
	if comment.update_attributes(params[:comment])
	  redirect to("/posts/#{@post_id}")
	else
	  redirect to("/posts/#{params[:id]}")
	end
   end