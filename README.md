The Battle Service allows anyone using the Battle-Client to play a game of battleships with a server. I will
expand the service and allow for player vs player. This runs using Golaith and needs Ruby 1.9.3 installed

Instructions:

1. git clone git@github.com:sanjuro/Battle-Service.git
2. Build your RVM gemset if you use gemsets and switch to it
3. Set up your db credentials and update database.yml file
4. rake db:migrate
5. ruby server.rb