VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "3072"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # Box info
  config.vm.box = "debian"
  config.vm.box_url = "http://gambit.etek.dk/vagrant/debian-7.box"

  # Hostname
  config.vm.hostname = "loop.vm"

  # IP
  config.vm.network "private_network", ip: "192.168.50.11"
  
  # Shared folder
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  # What to install
  config.vm.provision :shell, :path => "bootstrap.sh"
end
