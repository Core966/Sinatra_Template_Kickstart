require 'bundler/setup'
require 'sinatra'
require 'active_record'
require 'yaml'
require 'warden'
require 'sinatra/flash'
require 'bcrypt'

#Load all models in the model directory:

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models")
Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require File.basename(model, '.*') }

# The database configuration data ready from the below yaml file.

# Necessary format:

# db_name: <db name here>
# db_host: <hostname here>
# db_username: <db username here>
# db_password: <db user password here>

APP_CONFIG = YAML.load_file('./config/database.yml')

ActiveRecord::Base.establish_connection(
adapter: "mysql2",
host: APP_CONFIG['db_host'],
database: APP_CONFIG['db_name'],
username: APP_CONFIG['db_username'],
password: APP_CONFIG['db_password'])

####################################################

	require File.join(File.dirname(__FILE__), './warden_auth.rb')

	configure do
	  set :views, "#{File.dirname(__FILE__)}/views"
	end

	before do
	  @title = "Web application title"
	  @author = "Web application author"
	end

	def current?(path='/') #This will return the path of the page that’s currently being visited, relative to the root URL
	  (request.path==path || request.path==path+'/') ? "pure-menu-selected" : nil
	end

	# root page
	get '/' do
	  @posts = Post.find_by_sql("SELECT id, title, CONCAT(SUBSTRING(body,1, 50), '...') AS partial_body FROM posts WHERE is_deleted = 0") #We are only displaying the first 50 characters of a given post.
	  erb :home
	end

	get '/about/?' do
	  erb :about
	end
	
	get '/login/?' do
	  erb :login
	end
	
	post '/login' do
	  env['warden'].authenticate!

    	  if session[:return_to].nil?
	    redirect '/'
	  else
	    redirect session[:return_to]
	  end
	end
	
	get '/restricted' do
	  if env['warden'].authenticate
	    "You have entered a restricted area! Congratulations"
	  else
	    redirect '/login'
          end
	end
	
	get '/logout' do
	  env['warden'].raw_session.inspect
          env['warden'].logout
          redirect '/'
	end

#Enable the below in order to activate the CRUD operations of posts and their comments:
require File.join(File.dirname(__FILE__), './posts_controller.rb')
#Or you may delete the post_views folder and all its files within. You must also edit the menu.erb partial.

require File.join(File.dirname(__FILE__), './users_controller.rb')