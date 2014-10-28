class Card
  attr_reader :label, :value
  
  def initialize(name, suit)
    @label = name.to_s + suit
    if name == "A"
      @value = 11
    elsif %W(J Q K).include?(name)
      @value = 10
    else
      @value = name
    end
  end

  def ace?
    label.start_with?("A")
  end
end