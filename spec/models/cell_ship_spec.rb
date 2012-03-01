require 'spec_helper'

describe CellShip do

  before(:all) do 
    ship1 =  FactoryGirl.create(:carrier) 
    ship2 =  FactoryGirl.create(:battleship)
    ship3 =  FactoryGirl.create(:destroyer)
    ship4 =  FactoryGirl.create(:submarine)
    ship5 =  FactoryGirl.create(:patrol)
  end
  
  after :all do
    Ship.destroy_all
  end
  
  context 'Given a new piece is created' do
    it "should create a new instance given valid attributes" do 
      FactoryGirl.create(:cell_ship).should be_valid
    end
    
    it "should require a game id" do
      FactoryGirl.build(:cell_ship, :game_id => '').should_not be_valid
    end
    
    it "should require a ship id" do
      FactoryGirl.build(:cell_ship, :ship_id => '').should_not be_valid
    end
    
    it "should check if the max has been reached" do
      CellShip.should
      FactoryGirl.build(:cell_ship, :ship_id => '').should_not be_valid
    end

  end
  
  context 'Given a new carrier piece is created' do
    it "Then 5 cells need to be built" do 
      lambda { FactoryGirl.create(:cell_ship) }.should change(Cell, :count).by(5)
    end
  end

  context 'Given a piece is hit' do
    it "Then its hit count should change" do 
      game = FactoryGirl.create(:game) 
      cell = FactoryGirl.create(:cell)
      cell_ship = FactoryGirl.create(:cell_ship)
      cell.status = 'hit'
      cell.save
      cell_ship.reload.hit_count.should == 1
      #lambda { cell_ship }.should change(CellShip, :hit_count).by(1)
    end
  end
  
end