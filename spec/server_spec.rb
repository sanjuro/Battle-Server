require 'spec_helper'
require 'test/unit'
require 'goliath'
require 'goliath/rack'
require 'goliath/test_helper'

require_relative '../server'

describe Server do
  include Goliath::TestHelper

  it "can set and retrieve data" do
    with_api(Server) do     
      get_request(:path => '/games') do |api|
        api.response.must_equal 'OK'
      end
    end

    with_api(Server) do
      post_request :path => '/games?name=test&email=test@gmail.com' do |api|
        api.response.must_equal 'OK'
      end
    end
    
    with_api(Server) do     
      get_request(:path => '/game?id=1000') do |api|
        api.response.must_equal 'OK'
      end
    end
    
    with_api(Server) do
      post_request :path => '/nukes?game_id=1144&y_value=8&x_value=4"' do |api|
        api.response.must_equal 'OK'
      end
    end

  end
end
