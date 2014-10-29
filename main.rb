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

post '/new_player' do
  if params[:player_name] == '' || params[:difficulty] == '0'
    redirect '/'
  else
    session[:player_name] = params[:player_name].capitalize
    #session[:difficulty]  = params[:difficulty]
    #session[:game_count]  = params[:game_count]
    #session[:minimal_bet] = set_minimal_bet(session[:difficulty])
    #session[:balance]     = START_BALANCE
    redirect '/game'
  end
end

get '/game' do
  suits = %w(hearts diamonds spades clubs)
  cards = %w(2 3 4 5 6 7 8 9 10 jack queen king ace)
  session[:deck] = suits.product(cards).shuffle!

  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  
  session[:player_status] = 'decide'
  erb :game
end

post '/hit' do
  session[:player_hand] << session[:deck].pop
  total = calculate_total(session[:player_hand])
  if total >= 21
    redirect '/results'
  else
    session[:player_status] = 'decide'
  end

  erb :game
end

post '/stay' do
  session[:player_status] = 'stay'
  erb :game
end

get '/results' do
  player_total = calculate_total(session[:player_hand])
  dealer_total = calculate_total(session[:dealer_hand])
  binding.pry
  if player_total > 21
    #player busts
  elsif dealer_total > 21
    #dealer busts
  elsif player_total == 21 && session[:player_hand].size == 2 && !%w(10 J Q K A).include?(session[:dealer_hand][0][1])
    #player won
  end

  erb :game
end


#session[:bet] = params[:bet]

# post '/bet' do
  
  

#   erb :bet
# end

post '/decision' do
  if params[:hit]
    redirect '/hit'
  elsif params[:stay]
    redirect '/stay'
  elsif params[:double]
    redirect '/double'
  end
end


get '/rules' do
  erb :rules
  # to do
end
