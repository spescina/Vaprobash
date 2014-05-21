class Classy
  def Classy.configure(config, settings)
    # Configure The Box
    config.vm.box = "ubuntu/trusty64"
    config.vm.hostname = settings["machine"]["hostname"]

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["machine"]["ip"]

    # Configure A Few VirtualBox Settings
    config.vm.provider :virtualbox do |vb|
      settings["machine"]["vm"].each do |key, value|
        vb.customize ["modifyvm", :id, "--#{key}", "#{value}"]
      end
    end

    # Configure Port Forwarding To The Box
    settings["machine"]["forwarded_ports"].each do |i, port|
	  if port["guest"] != '' && port["host"] != ''
        config.vm.network :forwarded_port, guest: port['guest'].to_i, host: port['host'].to_i
      end
  	end

    # Configure The Public Key For SSH Access
    config.vm.provision "shell" do |s|
      s.inline = "echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
      s.args = [File.read(settings["ssh"]["authorize"])]
    end

    # Copy The SSH Private Keys To The Box
    settings["ssh"]["keys"].each do |key|
      config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
        s.args = [File.read(key), key.split('/').last]
      end
    end

    # Register All Of The Configured Shared Folders
    settings["shares"].each do |share|
      config.vm.synced_folder share["map"], share["to"]
    end
        
	
	# Provision Base Packages
	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/base.sh", args: [settings["github"]["url"]]
	
	# Provision Vim
  	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/vim.sh", args: [settings["github"]["url"]]

	# Provision PHP
  	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/php.sh", args: [settings["machine"]["timezone"]]
  	
  	# Provision Apache Base
  	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/apache.sh", args: [settings["machine"]["ip"], settings["apache"]["document_root"], settings["machine"]["hostname"], settings["github"]["url"]]
  	
  	# Provision MySQL
  	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/mysql.sh", args: [settings["mysql"]["password"]]
  	
  	# Provision SQLite
  	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/sqlite.sh"
  	
  	# Install Nodejs
  	config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/nodejs.sh", privileged: false, args: settings["nodejs"]["packages"].unshift(settings["nodejs"]["version"], settings["github"]["url"])
  	
  	# Provision Composer
  	#config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/composer.sh", privileged: false, args: [settings["composer"]["packages"].join(" ")]
  	
  	# Install Mailcatcher
  	# config.vm.provision "shell", path: settings["github"]["url"] + "/scripts/mailcatcher.sh"
  	
  end
end