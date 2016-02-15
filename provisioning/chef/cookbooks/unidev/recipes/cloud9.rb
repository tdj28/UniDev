#
# Cookbook Name:: devbox
# Recipe:: cloud9
#
# Apache Public License 

git "/home/vagrant/c9sdk" do
  repository 'git://github.com/c9/core.git'
  reference 'master'
  action :sync
  user 'vagrant'
  group 'vagrant'
end

execute 'install_c9_sdk' do
  cwd '/home/vagrant/c9sdk'
  user 'vagrant'
  command "/home/vagrant/c9sdk/scripts/install-sdk.sh"
  environment ({'HOME' => '/home/vagrant', 'USER' => 'vagrant'})
end

git "/home/vagrant/c9install" do
  repository 'git://github.com/c9/install.git'
  reference 'master'
  action :sync
  user 'vagrant'
  group 'vagrant'
end

execute 'install_c9install' do
  cwd '/home/vagrant/c9install'
  user 'vagrant'
  group 'vagrant'
  command "./install.sh"
  environment ({'HOME' => '/home/vagrant', 'USER' => 'vagrant'})

end

supervisor_service "cloud9" do
  action :enable
  autostart true
  autorestart true
  command "nodejs /home/vagrant/c9sdk/server.js -a : --listen 0.0.0.0 -w /home/vagrant/code"
  directory "/home/vagrant/c9sdk"
  environment 'HOME' => '/home/vagrant'
  user "vagrant"
  stdout_logfile "/var/log/cloud9.out.log"
  stderr_logfile "/var/log/cloud9.out.log"
end