class Game < ActiveRecord::Base
  has_many :cell_ships, :dependent => :destroy
  has_many :ships, :through => :game_ships
  has_many :cells, :dependent => :destroy
  validates :email, :presence => true
  validates :name, :presence => true

  scope :by_server_game_id, lambda {|server_game_id| where("games.server_game_id =?", server_game_id)}

  after_create :create_ships_for_game
  
  after_save :check_game_status, :on => :update
  
  # FIX ME: to make this dynamic
  def create_ships_for_game
    # create ships for player
    
    # create carrier
    CellShip.create(:game_id => self.id, :ship_id => 1)
    
    # create battleship
    CellShip.create(:game_id => self.id, :ship_id => 2)
    
    # create destroyer
    CellShip.create(:game_id => self.id, :ship_id => 3)
    
    # create submarines
    CellShip.create(:game_id => self.id, :ship_id => 4)
    CellShip.create(:game_id => self.id, :ship_id => 4)
    
    # create patrol boats
    CellShip.create(:game_id => self.id, :ship_id => 5)
    CellShip.create(:game_id => self.id, :ship_id => 5)
    
  end
  
  def check_game_status
    if self.player_hits == 18 && self.status == 'in_progress'
      self.update_attributes(:status => "won")
    end
    if self.server_hits == 18 && self.status == 'in_progress'
      self.update_attributes(:status => "lost")
    end
  end

end