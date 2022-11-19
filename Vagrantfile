Vagrant.configure("2") do |config|

   iface_bridge = "br0"
   
# BUILD with a full up to date vm if you don't want version with old vulns 
# ansible versions boxes : https://app.vagrantup.com/jborean93
boxes = [
   # windows server 2019
  { :name => "DC01",  :ip => "10.13.5.10", :box => "jborean93/WindowsServer2019", :os => "windows" },
  # windows server 2019
  { :name => "DC02",  :ip => "10.13.5.11", :box => "jborean93/WindowsServer2019", :os => "windows" },
  # windows server 2016
  { :name => "DC03",  :ip => "10.13.5.12", :box => "jborean93/WindowsServer2016", :os => "windows" },
  # windows server 2019
  { :name => "SRV02", :ip => "10.13.5.22", :box => "jborean93/WindowsServer2019", :os => "windows" },
  # windows server 2016
  { :name => "SRV03", :ip => "10.13.5.23", :box => "jborean93/WindowsServer2016", :os => "windows" }
]

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 6
    libvirt.memory = 6000
  end

  # disable rdp forwarded port inherited from StefanScherer box
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true, disabled: true

  # no autoupdate if vagrant-vbguest is installed
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.boot_timeout = 1200
  config.vm.graceful_halt_timeout = 600
  config.winrm.retry_limit = 60
  config.winrm.retry_delay = 15

  boxes.each do |box|
    config.vm.define box[:name] do |target|
      # BOX
      target.vm.provider "virtualbox" do |v|
        v.name = box[:name]
      end
      target.vm.box_download_insecure = box[:box]
      target.vm.box = box[:box]
      if box.has_key?(:box_version)
        target.vm.box_version = box[:box_version]
      end

      # issues/49
      target.vm.synced_folder '.', '/vagrant', disabled: true

      # IP
      # target.vm.network :public_network, bridge: box[:iface_bridge], ip: box[:ip]
      target.vm.network :public_network,
        :dev => iface_bridge,
        :mode => "bridge",
        :type => "bridge",
        :ip => box[:ip]

      # OS specific
      if box[:os] == "windows"
        target.vm.guest = :windows
        target.vm.communicator = "winrm"
        target.vm.provision :shell, :path => "vagrant/Install-WMF3Hotfix.ps1", privileged: false
        target.vm.provision :shell, :path => "vagrant/ConfigureRemotingForAnsible.ps1", privileged: false
      else
        target.vm.communicator = "ssh"
      end

      if box.has_key?(:forwarded_port)
        # forwarded port explicit
        box[:forwarded_port] do |forwarded_port|
          target.vm.network :forwarded_port, guest: forwarded_port[:guest], host: forwarded_port[:host], host_ip: "127.0.0.1", id: forwarded_port[:id]
        end
      end

    end
  end
end
