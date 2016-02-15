#
# Cookbook Name:: devbox
# Recipe:: default
#
# Apache Public License 

execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    !File.exists?('/var/lib/apt/periodic/update-success-stamp') ||
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

packages = [
			'apache2-utils',
			'build-essential',
			'curl',
			'docker.io',
			'g++',
			'git',
			'inotify-tools',
			'jp2a',
			'libssl-dev',
			'libxml2-dev',
			'nmap',
			'nodejs',
			'nodejs-legacy',
			'npm',
			'sshfs',
			'supervisor',
			'texlive',
			'texlive-latex-recommended',
			'texlive-math-extra',
			'texlive-publishers',
			'texlive-science',
			'unzip',
			'vim'	
		]

packages.each do |p|
	package p do
		action :install
	end
end

execute "add-vagrant-to-docker-group" do
	command "usermod -aG docker vagrant"
	user "root"
end

execute "restart-docker-service" do
	command "service docker restart"
	user "root"
end

execute "newgrp-docker-vagrant" do
	command "newgrp docker"
	user "vagrant"
end