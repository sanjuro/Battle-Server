require 'em-synchrony/activerecord'

ActiveRecord::Base.establish_connection(:adapter => 'em_mysql2',
                                        :database => 'battleships_server',
                                        :username => 'root',
                                        :password => '',
                                        :reconnect => true,
                                        :pool => 10,
                                        :wait_timeout => 0.5,
                                        :host => 'localhost')