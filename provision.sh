# Get Vim and tmux installed
apt-get update
apt-get remove vim-tiny
apt-get install vim
apt-get install tmux

# Setup for getting Docker installed
cd /etc/apt/sources.list.d/
touch docker.list
chmod 777 docker.list
echo deb https://get.docker.io/ubuntu docker main > docker.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
apt-get update # now we have our new repository to search
apt-get install -y lxc-docker

# Define our Docker container
# We place it in the /srv directory as that is the recommended place for
# site-specific data which is served by the system
cat > /srv/Dockerfile <<EOF
# Build from...
FROM ubuntu:14.04
MAINTAINER Mark McDonnell <mark.mcdx@gmail.com>

# Install Ruby and Sinatra
RUN apt-get -qq update
RUN apt-get -qqy install ruby ruby-dev
RUN gem install sinatra

# Make sure to expose the port so we can access the application outside of the VM
EXPOSE 4567

# Execute the application that we've copied over to the container
ENTRYPOINT ["ruby", "/www/app.rb"]
EOF

# Create an image from our Dockerfile
#
# BE CAREFUL!
# Any other files in this folder will be tar'ed up
# and uploaded to the docker engine to create the image from
docker build -t integralist/sinatra /srv

# Check the image was created
docker images

# Run a container (in the background using -d) from our image
# Make sure to expose the port to the VM (using -p host:container)
# Also mount the directory from the VM into the container
docker run -p 4567:4567 -v /www:/www -d integralist/sinatra

# Check the container is running
docker ps

# Check application is running (we should be able to do this from outside the VM as well thanks to Vagrantfile port forwarding)
curl -i http://localhost:4567/
