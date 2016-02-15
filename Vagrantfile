# -*- mode: ruby -*-
# vi: set ft=ruby :


# ---------------------------------------------------
# Booleans, this is where you can turn things off/on
# ---------------------------------------------------
copy_keys = true
bash_prov = false
chef_prov = true
pupp_prov = false
ansi_prov = false
cloud9_tf = true

# ---------------------------------------------------
# ---------------------------------------------------


# ---------------------------------------------------
# Pull in ssh keys if necessary
# ---------------------------------------------------

if copy_keys
  i = 0
  id_pub = []
  id_pri = []
  home = ENV['HOME']
  keytype = ["rsa", "dsa"]
  ssh_loc = File.join("#{home}",".ssh")
  for key in keytype
    if File.exist?((File.join("#{ssh_loc}", "id_#{key}")))
      id_pub[i] = IO.read((File.join("#{ssh_loc}", "id_#{key}.pub")))
      id_pri[i] = IO.read((File.join("#{ssh_loc}", "id_#{key}")))
      i = i + 1
    end
  end
end

# Note, if you do this, never commit or share your
# VM unless you remove your keys. If you do not want
# your keys on the VM, set copy_keys above to false

# ---------------------------------------------------
# ---------------------------------------------------


# ---------------------------------------------------
# Provision ssh keys (imports id_rsa and id_dsa in ~/.ssh)
# ---------------------------------------------------

contents = ""
k = 0

def import_keys(config, id_pub, id_pri)
  k = 0
  for i in id_pub
    contents = i
    $pubscript = <<SCRIPT
echo 'Importing ssh public keys'
echo '#{contents}' >> /home/vagrant/.ssh/authorized_keys
echo '#{contents}' > /home/vagrant/.ssh/id_#{k}.pub
chmod -R 600 /home/vagrant/.ssh/authorized_keys
sudo chown vagrant /home/vagrant/.ssh/id_#{k}.pub
SCRIPT
    config.vm.provision :shell, :inline => $pubscript
    k = k + 1
  end
  k = 0
  for i in id_pri
    contents = i
    $priscript = <<SCRIPT
echo 'Importing ssh private keys'
echo '#{contents}' > /home/vagrant/.ssh/id_#{k}
chmod 400 /home/vagrant/.ssh/id_#{k}
sudo chown vagrant /home/vagrant/.ssh/id_#{k}
SCRIPT
    config.vm.provision :shell, :inline => $priscript
    k = k + 1
  end
end

# ---------------------------------------------------
# ---------------------------------------------------


# ---------------------------------------------------
# Provision chef if so chosen
# ---------------------------------------------------

def prov_chef(config)  
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = "./provisioning/chef/cookbooks"
    chef.roles_path = "./provisioning/chef/roles"
    #chef.data_bags_path = "./provisioning/chef/databags"
    #chef.add_recipe "cloud9"
    chef.add_role "unidev"
  
    # You may also specify custom JSON attributes:
    chef.json = { mysql_password: "foo" }
  end
end

# ---------------------------------------------------
# --------------------------------------------------- 

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 8100, host: 8100
  config.vm.network "forwarded_port", guest: 8181, host: 8200
  config.vm.network "forwarded_port", guest: 8200, host: 8300
  config.vm.network "forwarded_port", guest: 8400, host: 8400
  config.vm.network "forwarded_port", guest: 80, host: 8300
  config.vm.network "forwarded_port", guest: 22, host: 2932

  config.omnibus.chef_version = :latest
  config.berkshelf.berksfile_path = "./Berksfile"
  config.berkshelf.enabled = true


  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
     vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  
  if copy_keys
    import_keys(config, id_pub, id_pri)
  end

  if chef_prov
    prov_chef(config)
  end

  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "default.pp"
  # end


  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
