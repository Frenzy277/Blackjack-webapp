require 'pry'

module Helpers

  def display_hand(hand)
    cards = hand.map do |card|
      card[0] + "_" + card[1] + ".jpg"
    end
    cards.each do |c|
      "<img src='/public/images/cards/#{c}' />"
    end
  end


  # def display_hand(hand, hide = false)
  #   cards = []
  #   unless hide
  #     hand.each_index { |x| cards << hand[x] }
  #     cards.join(', ')
  #   else
  #     hand[0]  # Shows dealers first card only and hole is hidden.
  #   end
  # end

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

  # def check_entry_params
  #   if params[:player_name] == '' || params[:player_name].nil? || params[:difficulty] == "0" || params[:difficulty].nil?
  #     redirect '/'
  #   end
  # end

  # def set_minimal_bet(difficulty)
  #   case difficulty
  #   when '1' then 10
  #   when '2' then 100
  #   when '3' then 200
  #   end
  # end

  # def number_of_decks(difficulty)
  #   if difficulty == '1'
  #     1
  #   else
  #     2
  #   end
  # end


end