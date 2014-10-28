require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  "Hello World! For Lesson 3 :assignment Render Text"
end

get '/foo' do
  erb :foo
end

get '/bar' do
  erb :"/foo/bar"
end



