require 'rubygems'
require 'sinatra'
require 'pry'
require_relative 'helpers'
include Helpers

set :sessions, true
helpers Helpers

get '/' do
  erb :home
end

get '/rules' do
  erb :rules
  # to do
end

post '/bet' do
  #binding.pry
  check_entry_params(params)
  #binding.pry


  session[:player_name] = params[:player_name].capitalize
  session[:difficulty] = params[:difficulty]
  session[:game_count] = params[:game_count]
  session[:minimal_bet] = set_minimal_bet(session[:difficulty])
  session[:balance] = START_BALANCE
  erb :bet
end

post '/game' do
  session[:bet] = params[:bet]

  #binding.pry
  erb :game
end




