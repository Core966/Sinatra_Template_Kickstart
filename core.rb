require 'bundler/setup'
require 'sinatra'
require 'active_record'
require 'yaml'

require_relative 'models/post'

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
	  @posts = Post.find_by_sql("SELECT title, CONCAT(SUBSTRING(body,1, 10), '...') AS partial_body FROM posts")
	  erb :home
	end

