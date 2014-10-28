require_relative 'card'

class Deck
  SUITS = ["\u2660", "\u2663", "\u2665", "\u2666"]
  CARD_NAMES = Array(2..10).push(%w(J Q K A)).flatten

  attr_accessor :pack, :up_edge, :player_cut
  def initialize(number_of_decks = 4)
    @pack = []
    number_of_decks.times do
      SUITS.each do |suit|
        CARD_NAMES.each { |name| @pack << Card.new(name, suit) }
      end
    end
  end

  def shuffle(n = 1)
    n.times { pack.shuffle! }
  end
  alias :shuffle_n_times :shuffle

  def deal_card
    check_shuffle_reminder
    pack.pop
  end
  alias :burn_card :deal_card
end
