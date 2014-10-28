require 'rubygems'
require 'sinatra'
require 'pry'
require_relative 'deck'
require_relative 'helpers'
require_relative 'shared_constants'
include SharedConstants

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
  check_entry_params(params)
  
  session[:player_name] = params[:player_name].capitalize
  session[:difficulty]  = params[:difficulty]
  session[:game_count]  = params[:game_count]
  session[:minimal_bet] = set_minimal_bet(session[:difficulty])
  session[:balance]     = START_BALANCE
  erb :bet
end

post '/game' do
  session[:deck] = Deck.new(2)
  session[:bet] = params[:bet]


  binding.pry
  erb :game
end




