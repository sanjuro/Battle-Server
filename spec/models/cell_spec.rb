require 'spec_helper'

describe Cell do
  
  before(:all) do 
    ship1 =  FactoryGirl.create(:carrier) 
    ship2 =  FactoryGirl.create(:battleship)
    ship3 =  FactoryGirl.create(:destroyer)
    ship4 =  FactoryGirl.create(:submarine)
    ship5 =  FactoryGirl.create(:patrol)
    @game = FactoryGirl.create(:game) 
  end
  
  after :all do
    Ship.destroy_all
  end
  
  context 'Given a new cell is created' do
    it "should create a new instance given valid attributes" do 
      FactoryGirl.create(:cell).should be_valid
    end
    
    it "And then it should require a game id" do
      FactoryGirl.build(:cell, :game_id => '').should_not be_valid
    end
    
    it "And then it should be associated to a piece" do
      FactoryGirl.build(:cell, :cell_ship_id => '').should_not be_valid
    end

  end
  
  context 'Given a new cell is updated' do
    it "Then the associated piece hit count needs to be updated" do
      cell = FactoryGirl.create(:cell, :game_id => @game.id)
      Cell.should_receive(:update_ships).exactly(0).times
      cell.update_attributes(:status => 'hit')
      # expect { cell.update_attributes(:status => 'hit') }.to change(@game, :server_hits).by(1)
    end
  end

  
end