require 'sinatra/base'

require File.join(File.dirname(__FILE__), 'core.rb')

map('/') { run WebApplicationCoreRoutes }
