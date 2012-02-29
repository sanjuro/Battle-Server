class CellShip < ActiveRecord::Base
  
  MAX_X_VALUE = 9
  MAX_Y_VALUE = 9
  
  belongs_to :game
  belongs_to :ship
  has_many :cells

  validates :ship_id, :presence => true
  validates :game_id, :presence => true

  before_create :check_for_max_ships
  after_create :place_ship
  
  scope :by_game_id, lambda {|game_id| where("cell_ships.game_id =?", game_id)}

  def check_for_max_ships
    ship = Ship.find(self.ship_id)
    if CellShip.where(:ship_id => ship.id, :game_id => self.game_id).count >= ship.max_per_game
      return false
    end
  end

  def check_if_ship_is_sunk
    if self.is_sunk == false
      if self.hit_count == self.ship.length
        self.update_attributes(:is_sunk => true, :hit_count => self.ship.length)
      end
    end
  end
  
  def place_ship
    orientation = Random.rand(10)
    if (orientation % 2 == 0)
      self.update_attributes(:orientation => 'horizontal')
      place_horizontal
    else
      self.update_attributes(:orientation => 'vertical')
      place_vertical
    end
    create_cells_for_ship
  end
  
  def place_horizontal
    found_place = false
    while found_place != true do
      x = Random.rand(9)
      y = Random.rand(9)
      for i in 0..self.ship.length
        found_place = can_place_at(x + i, y); 
        if found_place != true
          break
        end
      end
      self.update_attributes(:x => x, :y => y)
      
    end
  end
  
  def place_vertical
    found_place = false
    while found_place != true do
      x = Random.rand(9)
      y = Random.rand(9)
      for i in 0..self.ship.length
        found_place = can_place_at(x, y + i); 
        if found_place != true
          break
        end
      end
      self.update_attributes(:x => x, :y => y)
      
    end
  end
  
  def can_place_at(x,y)
    cell_check = false
    horizontal_check = (x >= 0 && x < 10 && self.orientation == 'horizontal')
    if horizontal_check
      cell_check = (!Cell.where(:x => x, :y => y).by_game_id(self.game_id).first)
      if(cell_check && (x > 0))
          cell_check = (!Cell.where(:x => x-1, :y => y).by_game_id(self.game_id).first)
      end
      if(cell_check && (x < (9)))
          cell_check = (!Cell.where(:x => x+1, :y => y).by_game_id(self.game_id).first)
      end
    end
      
    vertical_check = (y >= 0 && y < 10 && self.orientation == 'vertical')
    if vertical_check
      cell_check = (!Cell.where(:x => x, :y => y).by_game_id(self.game_id).first)
      if(cell_check && (y > 0)) 
        cell_check = (!Cell.where(:x => x, :y => y-1).by_game_id(self.game_id).first)
      end
      if(cell_check && (y < (9)))
        cell_check = (!Cell.where(:x => x, :y => y+1).by_game_id(self.game_id).first)
      end
    end
     
    return cell_check
  end
  
  def create_cells_for_ship

    if self.orientation == "horizontal"
      (0...self.ship.length).each do |x_value|
         Cell.create(:cell_ship_id => self.id, :game_id => self.game_id, :x => self.x + x_value, :y => self.y)
      end
     else
      (0...self.ship.length).each do |y_value|
         Cell.create(:cell_ship_id => self.id, :game_id => self.game_id, :x => self.x, :y => self.y + y_value)
      end
     end
  end

end