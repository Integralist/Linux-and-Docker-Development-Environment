VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  # Expose VM's port 4567 so we can access it on our host's port 4567
  config.vm.network :forwarded_port, guest: 4567, host: 4567, auto_correct: true

  # Sync our application files into the VM (creating the directory if it doesn't exist)
  config.vm.synced_folder "./Application", "/www", create: true

  config.vm.provision "shell" do |s|
    s.privileged = true
    s.path = "provision.sh"
  end
end
