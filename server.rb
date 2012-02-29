#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require 'goliath'
require 'em-synchrony/em-http'
require 'active_record'
require 'json'

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
  
class GamesIndex < Goliath::API
  use Goliath::Rack::Formatters::JSON

  def response(env)

    logger.debug "Showing all Games" 

    games = Game.all
    
    [200, {'X-Goliath' => 'Proxy','Content-Type' => 'application/javascript'}, games]
    
  end
  
end  

# curl -d "name=shadley&email=shad6ster@gmail.com" http://127.0.0.1:9000/games
class GamesNew < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Formatters::JSON

  URL = 'http://battle.platform45.com/'

  def response(env)

    logger.debug "Accesing #{URL}/register"

    @request_options = {
      :body => " ",
      :keepalive => true,
      :head => {
        'content-type' => 'application/json',
        'accept' => 'application/json',
        'Accept-Encoding' => 'gzip,deflate,sdch'
      }
    }
    
    @request_options[:body] = {:name => env.params['name'], :email => env.params['email']}.to_json
    @request_options[:path] = 'register' 
    
    http_request = EventMachine::HttpRequest.new(URL).post  @request_options
    
    logger.info "Received #{http_request.response_header.status} from Battle.Platform45"
    http_response = JSON.parse http_request.response
    p http_response
    game = Game.create(:server_game_id => http_response['id'], :name => env.params['name'].to_s(), :email => env.params['email'].to_s())
    
    response = { 
                 :game => {:id => game.server_game_id, :status => 'in_progress'}, 
                 :cells => game.cells
               }
  
    [200, {'X-Goliath' => 'Proxy','Content-Type' => 'application/javascript'}, response]
    
  end
  
end

# curl http://127.0.0.1:9000/game?id=1000
class GamesShow < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, :key => 'id'
  use Goliath::Rack::Formatters::JSON

  def response(env)
    
    logger.debug "Showing Game: #{env.params['id']}" 
    
    game = Game.find_by_server_game_id!(env.params['id'])
  
    cells = game.cells
    
    sunk_ships = Sunk.where(:game_id => game.id).select([:id, :name])
  
    [200, {'X-Goliath' => 'Proxy','Content-Type' => 'application/javascript'},  { 
                                                                                  :game => game, 
                                                                                  :cells => cells, 
                                                                                  :sunk => sunk_ships
                                                                                }
    ]
    
  end
  
end  

# curl -d "game_id=1144&y_value=8&x_value=4" http://127.0.0.1:9000/nukes
class NukesNew < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Formatters::JSON   # JSON output formatter
  use Goliath::Rack::Render             # auto-negotiate response format

  URL = 'http://battle.platform45.com/'

  def response(env)

    logger.debug "Accesing #{URL}/nuke"

    @request_options = {
      :body => " ",
      :keepalive => true,
      :head => {
        'content-type' => 'application/json',
        'accept' => 'application/json',
        'Accept-Encoding' => 'gzip,deflate,sdch'
      }
    }

    @request_options[:body] = {:id => env.params['game_id'].to_i, :x => env.params['x_value'].to_i, :y => env.params['y_value'].to_i}.to_json
    @request_options[:path] = 'nuke' 
    
    http_request = EventMachine::HttpRequest.new(URL).post  @request_options
    
    logger.info "Received #{http_request.response_header.status} from Battle.Platform45"
      
    http_response = JSON.parse http_request.response
    # http_response = '{"sunk"=>"Submarine", "game_status"=>"lost", "prize"=>"Congratulations! Please zip and email your code to neil+priority@platform45.com", "status"=>"hit", "x"=>6, "y"=>2}'
    p http_response
    game = Game.by_server_game_id(env.params['game_id']).first
    
    if http_response['status'] == 'hit'
      game.player_hits += 1
      game.save
    end
      
    if cell = Cell.where(:game_id => game.id.to_i(), :x => http_response['x'], :y => http_response['y'], :status => 'has_ship').first
      cell.update_attributes(:status => "hit")
      server_nuke_status = 'hit'
    else
      server_nuke_status = 'miss'
    end
    
    if !http_response["sunk"].nil?
      Sunk.create(:game_id => game.id.to_i(), :name => http_response['sunk'].to_s())
    end
    
    if !http_response["error"].nil?
      game.update_attributes(:status => "error")
    end
    
    if !http_response["prize"].nil?
      game.update_attributes(:status => "won")
    end
    
      
    response = {
                :game => game, 
                :player_status => http_response['status'], 
                :x => http_response['x'],
                :y => http_response['y'],  
                :server_status => server_nuke_status, 
                :game_status => game.status,
                :sunk => sunk_ships = Sunk.where(:game_id => game.id).select([:id, :name])
               }
    p response
    [200, {'X-Goliath' => 'Proxy','Content-Type' => 'application/javascript'}, response ]

  end
  
end


class HeaderCollector < Goliath::API
  def on_headers(env, header)
    @headers ||= {}
    @headers.merge!(header)
  end

  def response(env)
    [200, {}, "headers: #{@headers.inspect}"]
  end
end

class BadRequest < Goliath::API

  def response(env)
    [400, {}, "does not compute!"]
  end
end

class Server < Goliath::API

  # map Goliath API to a specific path
  get "/games", GamesIndex
  post "/games", GamesNew
  get "/game", GamesShow 
  
  post "/nukes", NukesNew

  # map Goliath API to a specific path and inject validation middleware
  # for this route only in addition to the middleware specified by the
  # API class itself
  map "/headers", HeaderCollector do
    use Goliath::Rack::Validation::RequestMethod, %w(GET)
  end

  # bad route: you cannot run arbitrary procs or classes, please provide
  # an implementation of the Goliath API
  get "/bad_route", BadRequest 

  not_found('/') do
    run Proc.new { |env| [404, {"Content-Type" => "text/html"}, ["Try /games or /nukes"]] }
  end

  # You must use either maps or response, but never both!
  def response(env)
    raise RuntimeException.new("#response is ignored when using maps, so this exception won't raise. See spec/integration/rack_routes_spec.")
  end

end