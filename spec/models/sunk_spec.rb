require 'spec_helper'

describe Sunk do
  
  context 'Given a new ship is sunk' do
    it "Then it should require a name" do
      FactoryGirl.build(:sunk).should be_valid
    end

  end
  
end