# UniDev: A concentrated, consistent Dev environment

## Requirements

1. Vagrant
2. Virtualbox

### Preparing Vagrant

This uses Berks, so you will want to install the chef-dk first and be sure that you don't have any gem Berks interfering:

```
wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.4.0-1_amd64.deb
sudo dpkg -i chefdk_0.4.0-1_amd64.deb
```

Vagrant will be ready as soon as you run:

```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-berkshelf
```

If you have trouble with berks, you can either point your current paths to the right chef-dk binaries/libs:

```
eval "$(chef shell-init bash)"
```

or try uninstalling the gem version:

```
gem uninstall berkshelf
```

This deploy has been tested against vagrant 1.8


## Using

### Ports used

1. http://localhost:8100 Reserved
2. http://localhost:8200 Cloud9 Ace IDE
3. http://localhost:8300 Reserved
4. http://localhost:8400 Reserved
5  2932 The SSH port to access guest via ssh -p 2932 vagrant@localhost


### Using the Cloud 9 IDE

Loading http://localhost:8200 in your browser of choice will take you to the IDE which
provides you with an IDE for editing code as well as a terminal on the VM as the vagrant user.
This obviates the need to login separately to the VM, though that is still possible either by
going into the same directory as Vagrantfile and typing `vagrant ssh` or by running 

```
ssh -p 2932 vagrant@localhost
```

