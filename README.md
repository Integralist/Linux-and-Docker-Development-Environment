## Getting started

- `vagrant up --provider=virtualbox` 
- `curl 172.17.8.100:4567`

> Note: or just `vagrant up` if you use VirtualBox by default  
I use VMWare by default and so any VirtualBox boxes  
require the use of the `--provider` flag

## What?

This repository is set-up to automate the construction of a basic Ruby application that is running inside a Docker container in a Ubuntu VM.

Vim and tmux is installed inside the VM and so you could have just developed directly inside of the VM without any issues, but I've made it so that you can develop outside the VM (e.g. in your host environment). 

For you to access the running application from your host machine we needed to tell the Docker daemon to run from a specific private ip (`172.17.8.100`). We also set-up the VM to have the same ip address. Along with some trickery in our `provision.sh` we're able to run the Docker CLI from the host machine and access the application running inside the VM as well.

To access the application (running on port `4567`) open a web browser and visit `http://172.17.8.100:4567`

To use Docker simply type `docker ps` to see the running containers.

If you want to develop from the VM then that's fine as well, you can run `vagrant ssh` to enter the VM and then start using Vim and tmux (the application files are synced into the `/www` directory of the VM).

But if you want to use Docker from inside the VM you now have to switch to being the `root` user. So once inside the VM run `su` followed by the password Vagrant assigns to the `root` user (which is `vagrant`).

## No updates showing?

If you make a change to the application then you'll need to restart the docker container with `docker restart {container_id}`

## Inside or out?

I've set-up the VM to allow you to develop directly from within the VM using tmux and Vim as well as from outside the VM. Choose whichever you prefer.

Because we're syncing our application directory into the VM and then mounting that VM sync'ed folder into the container as a volume, it means we can develop from the host machine as well as from within the VM (as the files changed will be synced to the VM and then passed directly through to the container).

## Reptyr

> reptyr is a utility for taking an existing running program and attaching it to a new terminal

- Open a program (e.g. `top`)
- Suspend that program (e.g. `<C-z>`)
- Send the program into a background process (e.g. `bg`)
- Detach the program from its *current* parent (e.g. `disown top`)
- Open your terminal multiplexer (e.g. `tmux` or `screen`)
- Reattach the program to your terminal multiplexer using Reptyr (e.g. `reptyr $(pgrep top)`)

## Process

The steps I took to get the initial Vagrant file and box were:

- Visited https://vagrantcloud.com/ and clicked on Discover Boxes"
- Searched for "Ubuntu" and found https://vagrantcloud.com/ubuntu/boxes/trusty64
- `vagrant init ubuntu/trusty64`
- Modified the Vagrantfile as seen in this GitHub repository
- `vagrant up --provider=virtualbox`
