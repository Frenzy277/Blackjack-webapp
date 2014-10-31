require 'rubygems'
require 'sinatra'
require 'pry'
require_relative 'helpers'

START_BALANCE       = 2_000
HOUSE_BALANCE       = 100_000
EASY_MIN_BET        = 10
HARD_MIN_BET        = 100
CHALLENGE_MIN_BET   = 200
HIGH_CARDS          = %w(10 jack queen king ace)
BLACKJACK_BENCHMARK = 21
DEALER_MIN_HIT      = 17

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
  elsif params[:difficulty] == '0'
    @error = "Difficulty must be selected!"
    halt erb(:home)
  else
    session[:player_name] = params[:player_name].capitalize
    session[:difficulty]  = params[:difficulty].to_i
    session[:min_bet]     = nil
    session[:game_count]  = 0
    session[:balance]     = START_BALANCE
    session[:house]       = HOUSE_BALANCE
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
  session[:game_count] += 1
  session[:house] = HOUSE_BALANCE - session[:bet] - (session[:balance] - START_BALANCE)

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
    @success = "#{name} has Blackjack and wins!"
    @end = true
  elsif blackjack?(session[:player_hand]) && HIGH_CARDS.include?(session[:dealer_hand][0][1])
    session[:player_status] = 'stay'
  end

  erb(:game)
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  total = calculate_total(session[:player_hand])

  if total > BLACKJACK_BENCHMARK
    @info = "Sorry, it seems like #{name} busted at #{total}!"
    session[:player_status] = 'loss'
    @end = true
  elsif total == BLACKJACK_BENCHMARK
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
  if calculate_total(session[:dealer_hand]) >= DEALER_MIN_HIT
    redirect '/game/results'
  end
  erb :game
end

post '/game/dealer' do
  session[:hide_hole] = false
  check_dealer_hit
  session[:dealer_hand] << session[:deck].pop
  check_dealer_hit
  erb :game
end

get '/game/results' do
  dealer_total = calculate_total(session[:dealer_hand])
  player_total = calculate_total(session[:player_hand])
  if dealer_total > BLACKJACK_BENCHMARK
    session[:balance] += (session[:bet] * 2)
    @success = "Dealer busts at #{dealer_total}! #{name}'s balance is now #{session[:balance]}."
  elsif dealer_total == BLACKJACK_BENCHMARK
    if blackjack?(session[:player_hand]) && !blackjack?(session[:dealer_hand])
      session[:balance] += ((session[:bet] * 2) + (session[:bet] / 2))
      @success = "#{name} wins!
              #{name} has Blackjack and dealer has only #{BLACKJACK_BENCHMARK}. 
              #{name}'s balance is now #{session[:balance]}."
    elsif !blackjack?(session[:player_hand]) && blackjack?(session[:dealer_hand])
      @warning = "Sorry #{name}, dealer has Blackjack but you only have #{player_total}."
    elsif blackjack?(session[:player_hand]) && blackjack?(session[:dealer_hand])
      @info = "It's a push."
    elsif player_total < BLACKJACK_BENCHMARK
      @warning = "Dealer wins. #{name}'s total #{player_total} vs Dealer's total #{dealer_total}."
    end
  elsif dealer_total == player_total
    session[:balance] += session[:bet]
    @info = "It's a push."
  elsif dealer_total > player_total
    @warning = "Dealer wins. #{name}'s total #{player_total} vs Dealer's total #{dealer_total}."
  elsif dealer_total < player_total
    session[:balance] += (session[:bet] * 2)
    @success = "#{name} wins! #{name}'s total #{player_total} vs Dealer's total #{dealer_total}. 
                #{name}'s balance is now #{session[:balance]}."
  end
  
  @end = true
  erb :game
end

# Betting system
  get '/bet' do
    session[:bet] = nil
    session[:hide_hole] = true

    set_min_bet
    erb :bet
  end

  post '/bet' do
    bet = params[:bet].to_i
    if bet < session[:min_bet]
      @error = "#{name} can not bet less than minimum."
      halt erb(:bet)
    elsif bet > session[:balance]
      @error = "Sorry, #{name} can't bet more than his balance."
      halt erb(:bet)
    end

    session[:bet] = bet
    session[:balance] -= session[:bet]
    redirect '/game'
  end

get '/rules' do
  erb :rules
end

get '/gameover' do
  @gameover = true
  session[:game_count] = 0
  erb :gameover
end