## Process

The steps I took to arrive at the repository of files and code you find here before you:

- Visited https://vagrantcloud.com/ and clicked on Discover Boxes"
- Searched for "Ubuntu" and found https://vagrantcloud.com/ubuntu/boxes/trusty64
- `vagrant init ubuntu/trusty64`
- Modified the Vagrantfile as seen in this GitHub repository
  - It exposes port 4567 from the VM to the host
  - It syncs our application folder to the VM
  - When up'ing the box it'll execute a provisioning script
- `vagrant up --provider=virtualbox`
  - Provisioning script executes the following on the VM:
    - Installs Vim, tmux and Docker
    - Creates a Dockerfile
    - Builds an image from the Dockerfile
    - Runs a container from the image (and tries to mount the application directory inside the container)
    - Curls localhost
- `vagrant ssh`
- `su` and entered the password `vagrant`, which gives us root access (no more `sudo`)
- Start developing
