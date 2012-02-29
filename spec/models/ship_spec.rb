require 'spec_helper'

describe Ship do
  
  context 'Given a new Ship is created' do
    it "Then it should require a name" do
      FactoryGirl.build(:carrier, :name => '').should_not be_valid
    end
    
    it "And then it should require a length" do
      FactoryGirl.build(:carrier, :length => '').should_not be_valid
    end
  end
  
end