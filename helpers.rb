module Helpers
  START_BALANCE = 2_000

  def check_entry_params(params)
    if params[:player_name] == ''
      #@error = "You have to set a name!"
      redirect '/'
    elsif params[:difficulty] == "0"
      #@error = "You have to select a game difficulty"
      redirect '/'
    end
  end

  def set_minimal_bet(difficulty)
    case difficulty
    when '1' then 10
    when '2' then 100
    when '3' then 200
    end
  end

end