require 'rubygems'
require 'sinatra'
require 'pry'
require_relative 'helpers'
require_relative 'shared_constants'
include SharedConstants

set :sessions, true
helpers Helpers

get '/' do
  session[:balance] = nil
  session[:bet] = nil
  erb :home
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required!"
    halt erb(:home)
  else
    session[:player_name] = params[:player_name].capitalize
    session[:balance]     = START_BALANCE
    redirect '/game'
  end
end

get '/game' do
  if !session[:bet]
    if session[:balance] > 0
      redirect '/bet'
    else
      @error = "#{name} does not have enough chips to start a new game."
      redirect '/gameover'
    end
  end

  suits = %w(hearts diamonds spades clubs)
  cards = %w(2 3 4 5 6 7 8 9 10 jack queen king ace)
  session[:deck] = suits.product(cards).shuffle!

  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:hide_hole] = true
  session[:player_status] = 'decide'

  if blackjack?(session[:player_hand]) && !HIGH_CARDS.include?(session[:dealer_hand][0][1])
    session[:player_status] = 'win'
    session[:balance] += ((session[:bet] * 2) + (session[:bet] / 2))
    @end = "Congratulations, #{name} has Blackjack and won!"
  end

  erb(:game)
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  total = calculate_total(session[:player_hand])
  if total > 21
    @info = "Sorry, it seems like #{name} busted!"
    session[:player_status] = 'loss'
    @end = true
  elsif total == 21
    redirect '/game/player/stay'
  end

  erb :game
end

post '/game/player/stay' do
  if params[:stay]
    @success = "#{name} decided to stay!"
  end
  session[:player_status] = 'stay'
  session[:hide_hole] = false
  if calculate_total(session[:dealer_hand]) > 17
    redirect '/game/results'
  end
  erb :game
end

post '/game/dealer' do
  session[:dealer_hand] << session[:deck].pop
  dealer_total = calculate_total(session[:dealer_hand])
  if dealer_total >= 17
    redirect '/game/results'
  end
  erb :game
end


get '/game/results' do
  dealer_total = calculate_total(session[:dealer_hand])
  player_total = calculate_total(session[:player_hand])
  if dealer_total > 21
    session[:balance] += (session[:bet] * 2)
    @success = "Congratulations, Dealer busted! #{name}'s balance is now #{session[:balance]}."
  elsif dealer_total == 21
    if blackjack?(session[:player_hand]) && !blackjack?(session[:dealer_hand])
      @success = "Congratulations, #{name} wins!
              #{name} has Blackjack and dealer has only 21. 
              #{name}'s balance is now #{session[:balance]}."
    elsif !blackjack?(session[:player_hand]) && blackjack?(session[:dealer_hand])
      @info = "Sorry #{name}, dealer had Blackjack but you only had 21."
    end
  elsif dealer_total == player_total
    session[:balance] += session[:bet]
    @warning = "It's a push."
  elsif dealer_total > player_total
    @info = "Sorry, dealer wins by better score."
  elsif dealer_total < player_total
    session[:balance] += (session[:bet] * 2)
    @success = "Congratulations, #{name} wins! #{name}'s balance is now #{session[:balance]}."
  end

  if session[:balance] <= 0
    @error = "#{name}'s balance is dry."
  end
  @end = true
  erb :game
end

# Betting system
  get '/bet' do
    erb :bet
  end

  post '/bet' do
    bet = params[:bet].to_i
    if bet <= 0
      @error = "Bet can not be negative number or zero."
      halt erb(:bet)
    elsif bet > session[:balance]
      @error = "Sorry, #{name} can't bet more than his balance."
      halt erb(:bet)
    end

    session[:bet] = bet
    session[:balance] -= session[:bet]
    redirect '/game'
  end

post '/game/again' do
  session[:bet] = nil
  session[:hide_hole] = true

  if params[:yes]
    redirect '/game'
  elsif params[:no]
    redirect '/gameover'
  end   
end

get '/gameover' do
  erb :gameover
end