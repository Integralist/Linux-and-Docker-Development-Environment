VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  # Port forwarding from the VM to the Host can be problematic.
  # It's better to use a private ip to access the VM instead.
  # It also means that we can access the Docker commands from outside the VM.
  # 172 is a private network range (we add this in ~/.zshrc like so: `export DOCKER_HOST=tcp://172.17.8.100:2375`)
  config.vm.network :private_network, ip: "172.17.8.100"

  # Sync our application files into the VM (creating the directory if it doesn't exist)
  config.vm.synced_folder "./Application", "/www", create: true

  # We assume the sudo role and specify the provisioning script
  config.vm.provision "shell" do |s|
    s.privileged = true
    s.path = "provision.sh"
  end

  # Allow Vagrant to forward your ~/.ssh credentials to the instance
  # This allows us to use Git to clone private repositories
  config.ssh.forward_agent = true
end
