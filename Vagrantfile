# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.require_version ">= 1.8.4"

Vagrant.configure(2) do |config|
  #config.vm.box = 'centos/7'
  config.vm.box = 'bento/centos-7.2'
  config.vm.hostname = 'centos-HN'
  config.vm.network :public_network, bridge: 'en4: LAPDOCK'

  # Provisioning Network
  config.vm.network :private_network, ip: '192.168.0.10',
    virtualbox__intnet: true

  config.vm.network :forwarded_port, guest: 8000, host: 8005

  config.vm.synced_folder './shared/', '/home/vagrant/shared', create: true
  config.vm.synced_folder './opt/', '/opt', create: true

  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil and ENV['no_proxy'] != nil 
    if not Vagrant.has_plugin?('vagrant-proxyconf')
      system 'vagrant plugin install vagrant-proxyconf'
      raise 'vagrant-proxyconf was installed but it requires to execute again'
    end
    config.proxy.http     = ENV['http_proxy']
    config.proxy.https    = ENV['https_proxy']
    config.proxy.no_proxy = ENV['no_proxy']
  end

  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--memory', 1024 * 3 ]
    v.customize ["modifyvm", :id, "--cpus", 2]
  end

#  config.vm.provision 'shell' do |s|
#    s.path = 'post_install.sh'
#  end

end
