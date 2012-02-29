FactoryGirl.define do
  factory :game do
    id                1
    name              'Test'
    email             'hads@gmail.com'
    server_game_id    1000
    status            'in_progress'
    server_hits       0
    player_hits       0
  end
  
  factory :cell_ship do
    id           1
    game_id      1
    ship_id      1
    hit_count    0
    is_sunk      false
    orientation  'vertical'
  end
  
  factory :cell do
    game_id           1
    cell_ship_id      1
    y                 0
    x                 0
    status            'in_play'
  end
  
  factory :carrier, :class => Ship do
    id                1
    name              'carrier'
    length            5
    max_per_game      1
  end
  
  factory :battleship, :class => Ship  do
    id                2
    name              'battleship'
    length            4
    max_per_game      1
  end
  
  factory :destroyer, :class => Ship  do
    id                3
    name              'destroyer'
    length            3
    max_per_game      1
  end
  
  factory :submarine, :class => Ship  do
    id                4
    name              'submarines'
    length            2
    max_per_game      2
  end
  
  factory :patrol, :class => Ship  do
    id                5
    name              'patrol boats'
    length            1
    max_per_game      2
  end
  
  factory :sunk, :class => Sunk  do
    id                5
    game_id           1
    name              'carrier'
    is_sunk           false
  end
end