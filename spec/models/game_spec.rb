require 'spec_helper'

describe Game do

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
  
  context 'Given a new game is created' do
    it "Then it should require a email" do
      FactoryGirl.build(:game, :email => '').should_not be_valid
    end
    
    it "And then it should require a name" do
      FactoryGirl.build(:game, :name => '').should_not be_valid
    end
    
    it "And then it should create a 5 new pieces for the game" do 
      lambda { FactoryGirl.create(:game) }.should change(CellShip, :count).by(7)
    end
  end
  
end