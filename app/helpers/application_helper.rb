module ApplicationHelper
  
  def show_player(player)
    Player.find(player).email
  end
  
end
