class CreateBattleships < ActiveRecord::Migration
  def self.up
    create_table :cells do |t|
      t.integer :game_id
      t.integer :cell_ship_id
      t.integer :x
      t.integer :y
      t.string :status, :default => "has_ship"

      t.timestamps
    end
    
    create_table :cell_ships do |t|
      t.integer :game_id
      t.integer :ship_id
      t.integer :x
      t.integer :y
      t.boolean :is_sunk, :default => false
      t.integer :hit_count, :default => 0
      t.string :orientation

      t.timestamps
    end
    
    create_table :games do |t|
      t.integer :server_game_id
      t.string :name
      t.string :email
      t.string :status, :default => "in_progress"
      t.integer :server_hits, :default => 0
      t.integer :player_hits, :default => 0

      t.timestamps
    end
    
    create_table :sunks do |t|
      t.integer :game_id
      t.string :name
      t.boolean :is_sunk, :default => false

      t.timestamps
    end
    
    create_table :ships do |t|
      t.string :name
      t.integer :length
      t.integer :max_per_game

      t.timestamps
    end
  end
  
  def self.down
  
  end
end