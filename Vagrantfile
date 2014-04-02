VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "3072"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # Box info
  config.vm.box = "debian"
  #config.vm.box_url = "http://tj.unitmakers.dk/virtualbox.box"

  # Hostname
  config.vm.hostname = "loop"
  config.hostsupdater.aliases = ["loop.local"]

  # IP
  config.vm.network "private_network", ip: "192.168.50.11"
  
  # Shared folder
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  # What to install
  config.vm.provision :shell, :path => "bootstrap.sh"
end
