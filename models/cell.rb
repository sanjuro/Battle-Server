class Cell < ActiveRecord::Base
  belongs_to :cell_ship
  belongs_to :game

  validates :game_id, :presence => true
  validates :cell_ship_id, :presence => true
  
  after_update :update_ships
  
  scope :by_game_id, lambda {|game_id| where("cells.game_id =?", game_id)}

  scope :for_ship_horizontal, lambda {|game_id,x_min_value,x_max_value,y_value|
    where("cells.game_id = ?", game_id).
    where("cells.x >= ?", x_min_value).
    where("cells.x < ?", x_max_value).
    where("cells.y = ?", y_value)
  }
  
  scope :for_ship_vertical, lambda {|game_id,x_value,y_min_value,y_max_value|
    where("cells.game_id = ?", game_id).
    where("cells.x = ?", x_value).
    where("cells.y >= ? ", y_min_value).
    where("cells.y < ?", y_max_value)
  }
  
  def update_ships
    cell_ship = CellShip.find(self.cell_ship_id)
    cell_ship.hit_count += 1
    cell_ship.check_if_ship_is_sunk
    game = self.game
    game.server_hits += 1
    game.save
  end

end