require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  erb :home
end

get '/rules' do
  erb :rules
  # to do
end

post '/bet' do
  session[:player_name] = params[:player_name].capitalize
  session[:difficulty] = params[:difficulty]
  session[:game_count] = params[:game_count]
  erb :bet
end

post '/game' do
  session[:bet] = params[:bet]

  #binding.pry
  erb :game
end




