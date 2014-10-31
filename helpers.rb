require 'pry'
module Helpers

  def name
    session[:player_name]
  end

  def difficulty_name
    case session[:difficulty]
    when 1 then "Easy"
    when 2 then "Hard"
    when 3 then "Challenge"
    end
  end

  def set_min_bet
    if session[:game_count] == 0
      case session[:difficulty]
      when 1 then session[:min_bet] = EASY_MIN_BET
      when 2 then session[:min_bet] = HARD_MIN_BET
      when 3 then session[:min_bet] = CHALLENGE_MIN_BET
      end
    elsif session[:game_count] % 10 == 0
      case session[:difficulty]
      when 1 then session[:min_bet] += EASY_MIN_BET
      when 2 then session[:min_bet] += HARD_MIN_BET
      when 3 then session[:min_bet] += CHALLENGE_MIN_BET
      end
    end        
  end

  def check_dealer_hit
    if calculate_total(session[:dealer_hand]) >= DEALER_MIN_HIT
      redirect '/game/results'
    end
  end

  def display_card(card)
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='card' />"
  end

  def calculate_total(hand)
    values = hand.map do |card| 
      if card[1] == 'ace'
        11
      elsif %w(jack queen king).include?(card[1])
        10
      else
        card[1].to_i
      end
    end

    total = values.inject(:+)

    values.select { |v| v == 11 }.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def blackjack?(hand)
    hand.size == 2 && calculate_total(hand) == 21
  end

end