# Install dependencies
add-apt-repository ppa:pi-rho/dev # for latest tmux
apt-get update
apt-get remove vim-tiny -y
apt-get install vim tmux git tree htop reptyr xclip -y

# Install Zsh shell if it's not available
if ! cat /etc/shells | grep zsh; then
  echo "Zsh is not available, so we'll install it now"
  apt-get install zsh -y
fi

# For the Reptyr program to work we need to enable system access
# We do this by changing the ptrace scope from one to zero
sed -i 's/kernel.yama.ptrace_scope = 1/kernel.yama.ptrace_scope = 0/' /etc/sysctl.d/10-ptrace.conf

# Because this is a system control daemon, we need to restart the relevant service
sysctl -p /etc/sysctl.d/10-ptrace.conf

# Avoid the shell asking us to authorise the authenticity of github.com
# This happens when doing a git clone for the first time
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

# Install dotfiles...
dotfiles_location=/home/vagrant/dotfiles
git clone https://github.com/Integralist/dotfiles.git $dotfiles_location
cd $dotfiles_location && git fetch && git checkout linux

# Ensure we don't move unnecessary files
shopt -s extglob
mv !(.|..|.git|README.md) ..

# Clean-up
cd ../ && rm -rf dotfiles

# Change shell permanently to Zsh shell
chsh -s $(which zsh) vagrant

# Setup for getting Docker installed
cd /etc/apt/sources.list.d/
touch docker.list
chmod 777 docker.list
echo deb https://get.docker.io/ubuntu docker main > docker.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
apt-get update # now we have our new repository to search
apt-get install -y lxc-docker

# Modify `DOCKER_OPTS` so the Docker daemon is accessible from a private ip
# Note: The docker daemon location changes per distro...
#       CentOS => /etc/sysconfig/docker
#       Ubuntu => /etc/default/docker
chmod 777 /etc/default/docker
echo "DOCKER_OPTS=\"--host tcp://172.17.8.100:2375\"" >> /etc/default/docker
service docker restart

# Make sure user can now access docker daemon via DOCKER_HOST
cat > ~/.bashrc <<EOF
export DOCKER_HOST=tcp://172.17.8.100:2375
EOF
source ~/.bashrc

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

# Switch to root user (as you'll be able to access DOCKER_HOST and build image)
su

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
