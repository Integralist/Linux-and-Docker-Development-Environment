# Install dependencies
apt-get update
apt-get remove vim-tiny -y
apt-get install vim git tree htop reptyr build-essential -y

# Change to Bash shell (as Zsh isn't available)
chsh -s /bin/bash

# Install tmux 1.9 (which is surprisingly harder than it should be)

tmux_version="1.9"
tmux_patch_version="a" # leave empty for stable releases

libevent_version="2.0.21"
ncurses_version="5.9"

tmux_name="tmux-$tmux_version"
tmux_relative_url="$tmux_name/$tmux_name$tmux_patch_version"
libevent_name="libevent-$libevent_version-stable"
ncurses_name="ncurses-$ncurses_version"

target_dir="/usr/local"

wget -O $tmux_name.tar.gz http://sourceforge.net/projects/tmux/files/tmux/$tmux_relative_url.tar.gz/download
wget -O $libevent_name.tar.gz https://github.com/downloads/libevent/libevent/$libevent_name.tar.gz
wget -O $ncurses_name.tar.gz ftp://ftp.gnu.org/gnu/ncurses/$ncurses_name.tar.gz

# libevent installation
tar xf $libevent_name.tar.gz
cd $libevent_name
./configure
make
make install
cd -

# ncurses installation (requires c++ compiler from build-essential package)
tar xvzf $ncurses_name.tar.gz
cd $ncurses_name
./configure
make
make install
cd -

# tmux installation
tar xvzf ${tmux_name}*.tar.gz
cd ${tmux_name}*/
./configure CFLAGS="-I$target_dir/include -I$target_dir/include/ncurses" LDFLAGS="-L$target_dir/lib -L$target_dir/include/ncurses -L$target_dir/include"
CPPFLAGS="-I$target_dir/include -I$target_dir/include/ncurses" LDFLAGS="-static -L$target_dir/include -L$target_dir/include/ncurses -L$target_dir/lib" make
cp tmux /usr/bin
cd -

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
