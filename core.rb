require 'bundler/setup'
require 'sinatra'

	configure do
	  set :views, "#{File.dirname(__FILE__)}/views"
	end

	before do
	  @title = "Web application title"
	  @author = "Web application author"
	end

	# root page
	get '/' do
	  erb :home
	end

