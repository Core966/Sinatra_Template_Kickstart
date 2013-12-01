require 'bundler/setup'
require 'sinatra'
require 'active_record'
require 'yaml'

require File.join(File.dirname(__FILE__), 'models/post.rb')

APP_CONFIG = YAML.load_file('./config/database.yml')

ActiveRecord::Base.establish_connection(
adapter: "mysql2",
host: APP_CONFIG['db_host'],
database: APP_CONFIG['db_name'],
username: APP_CONFIG['db_username'],
password: APP_CONFIG['db_password'])

	configure do
	  set :views, "#{File.dirname(__FILE__)}/views"
	end

	before do
	  @title = "Web application title"
	  @author = "Web application author"
	end

	# root page
	get '/' do
	  @posts = Post.find_by_sql("SELECT title, CONCAT(SUBSTRING(body,1, 50), '...') AS partial_body FROM posts")
	  erb :home
	end

#Enable the below in order to activate the CRUD operations of posts:
#require File.join(File.dirname(__FILE__), 'posts_controller.rb')

