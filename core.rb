require 'bundler/setup'
require 'sinatra'
require 'active_record'
require 'yaml'
require 'warden'
require 'sinatra/flash'
require 'bcrypt'
require 'rack/csrf'
require 'bb-ruby'
require 'encrypted_cookie'

#Load all models in the model directory:

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models")
Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require File.basename(model, '.*') }

# The database configuration data ready from the below yaml file.
# Necessary format:
# db_encoding: <db encoding here>
# db_adapter: <db adapter here>
# db_name: <db name here>
# db_host: <hostname here>
# db_username: <db username here>
# db_password: <db user password here>

#APP_CONFIG = YAML.load_file('./config/database.yml')

#ActiveRecord::Base.establish_connection(
#encoding: APP_CONFIG['db_encoding'],
#adapter: APP_CONFIG['db_adapter'],
#host: APP_CONFIG['db_host'],
#database: APP_CONFIG['db_name'],
#username: APP_CONFIG['db_username'],
#password: APP_CONFIG['db_password']
#)

ActiveRecord::Base.establish_connection(
encoding: 'utf8',
adapter: 'mysql2',
host: ENV['IP'],
database: 'c9',
username: ENV['C9_USER']
)

####################################################

	configure do
		#set :port, ENV['PORT']
		#set :host, ENV['IP']
		set :views, "#{File.dirname(__FILE__)}/views"
		use Rack::Session::EncryptedCookie, :http_only => true, :expire_after => 60*60*3, :secret => "nothingissecretontheinternet"
		use Rack::Csrf
		use Rack::MethodOverride
	end
	
	require File.join(File.dirname(__FILE__), './warden_auth.rb')

	before do
	  @title = "Web application title"
	  @author = "Web application author"
	end
	
	after do
		if session[:status] == "counting"

			if session[:failed] == true
				session[:counter] = session[:counter] + 1
			end

		  session[:failed] = false

		end
	end

	def current?(path='/') #This will return the path of the page that’s currently being visited, relative to the root URL
	  (request.path==path || request.path==path+'/') ? "pure-menu-selected" : nil
	end

	def stripBB(bbstring)
		bbstring.gsub!(/\[(.*?)\]/) do|tag|
		tag.gsub(/.*/, ' ')
		end
	return bbstring
	end

	# root page
	get '/' do
	  @posts = Post.find_by_sql("SELECT id, title, CONCAT(SUBSTRING(body,1, 250), '...') AS partial_body FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 5") #We are only displaying the first 250 characters of a given post.
	  erb :home
	end

	get '/about/?' do
	  erb :about
	end
	
	get '/login/?' do
	
	    if session[:status] == "counting"
		flash[:info] = "You have failed to login, number of retries left: " + (5 - session[:counter]).to_s
	    end

	    if session[:status] == "locked"
		flash[:error] = "You have failed to login too many times and you have been locked out!"
		flash[:info] = "You can try again after three hours."
		redirect '/'
	    end
	  
	  erb :login
	  
	end
	
	post '/login' do
      if env['warden'].authenticate
	    session[:status] = ""
	    flash[:success] = "You have successfuly logged in!"
	    redirect '/'
	  else
	    flash[:error] = "Password or username is incorrect!"

		session[:status].nil? ? session[:counter] = 0 : nil

		if session[:status] == "counting"
			if session[:counter] >= 5
				session[:status] = "locked"
				flash[:error] = "You have failed to login too many times and you have been locked out!"
				flash[:info] = "You can try again after three hours."
				redirect '/'
			end
		end

		session[:status] = "counting"

		session[:failed] = true

		flash[:info] = "You have failed to login, number of retries left: " + (4 - session[:counter]).to_s

	    redirect '/login'
	  end
	end
	
	get '/restricted' do
	  if env['warden'].authenticate
	    "You have entered a restricted area! Congratulations"
	  else
	    flash[:error] = "You must login before entering a restricted area!"
	    redirect '/login'
          end
	end
	
	get '/logout' do

		if session[:status] == "locked"
		  flash[:error] = "You have failed to login too many times and you have been locked out!"
		  flash[:info] = "You can try again after three hours."
		  redirect '/'
		end

			 env['warden'].logout
			 session.clear
			 flash[:success] = "You have successfuly logged out!"
			 redirect '/'

	end

#Enable the below in order to activate the CRUD operations of posts and their comments:
require File.join(File.dirname(__FILE__), './posts_controller.rb')
#Or you may delete the post_views folder and all its files within. You must also edit the menu.erb partial.

require File.join(File.dirname(__FILE__), './users_controller.rb')
