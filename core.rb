require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

class WebApplicationSettings < Sinatra::Base

	configure do
	  set :views, "#{File.dirname(__FILE__)}/views"
	end

	before do
	  @title = "Web application title"
	  @author = "Web application author"
	end

end

class WebApplicationCoreRoutes < WebApplicationSettings

	# root page
	get '/' do
	  "Hello world!"
	end

end
