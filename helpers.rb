require 'pry'

module Helpers

  def name
    session[:player_name]
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