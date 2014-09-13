require 'sinatra'

# Bind to ALL device interfaces
# This is so the app can be accessed outside a Docker container
# And so although in the Dockerfile we expose port 4567 to the host machine
# we're not able to access the VM's localhost unless we set
# the application to bind to all the available interfaces
set :bind, '0.0.0.0'

get '/' do
  'Hello World (from Ruby)'
end
