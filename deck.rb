require_relative 'card'
require_relative 'shared_constants'

class Deck
  include SharedConstants
  SUITS = ["\u2660", "\u2663", "\u2665", "\u2666"]
  CARD_NAMES = Array(2..10).push(%w(J Q K A)).flatten

  attr_accessor :deck, :up_edge, :player_cut
  def initialize(number_of_decks = 1)
    @deck = []
    number_of_decks.times do
      SUITS.each do |suit|
        CARD_NAMES.each { |name| @deck << Card.new(name, suit) }
      end
    end
  end

  def shuffle(n = 1)
    n.times { deck.shuffle! }
  end
  alias :shuffle_n_times :shuffle

  def deal_card
    check_shuffle_reminder
    deck.pop
  end
  alias :burn_card :deal_card

  private

  def check_shuffle_reminder
    if deck.last == SHUFFLE_REMINDER
      deck.pop
      puts "After this game dealer will have to shuffle the pack."
      sleep 3
    end
  end
end
