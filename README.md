puppet

```bash
dnf install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm
dnf install puppet vim -y
#dnf module enable postgresql:12 -y 
vim bootstrap.pp
#vim /etc/hosts
/opt/puppetlabs/puppet/bin/puppet module install puppet-r10k --version 9.0.0
/opt/puppetlabs/puppet/bin/puppet module install puppet-hiera --version 4.0.0
/opt/puppetlabs/puppet/bin/puppet module install theforeman-puppet --version 14.2.0
/opt/puppetlabs/puppet/bin/puppet module install puppetlabs-puppetdb --version 7.7.0
#/opt/puppetlabs/puppet/bin/puppet apply bootstrap.pp
```

bootstrap.pp
```ruby

node puppet.core.ghostlink.net { 
 
  # Puppet hiera  setup
  class { 'hiera':
          hiera_version   =>  '5',
          hiera5_defaults =>  {"datadir" => "/etc/puppetlabs/code/environments/%{environment}/hiera", "data_hash" => "yaml_data"},
          hierarchy       =>  [
                                {"name" =>  "Nodes yaml", "paths" =>  ['nodes/%{::trusted.certname}.yaml',]},
                                {"name" =>  "OS", "paths" =>  ['os/%{facts.os.name}.yaml', 'os/%{::osfamily}.yaml']},
                                #{"name" =>  "Location", "paths" =>  ['location/site1.yaml',]},
                                {"name" =>  "eyaml", "paths" =>  ['nodes/%{::trusted.certname}.eyaml','common.eyaml'], "options" => {'pkcs7_public_key'  => '/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem','pkcs7_private_key' => '/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem',}, 'lookup_key' => 'eyaml_lookup_key',},
                                {"name" =>  "Default yaml file", "path" =>  "common.yaml"},
                              ],
          eyaml           => true,
          create_keys     => false,
          hiera_yaml      => '/etc/hiera.yaml',
          create_symlink  => false,
  }

  class { '::puppet':
    server                => true,
    server_git_repo       => false,
    server_foreman        => false,
    server_reports        => 'store,puppetdb',
    server_external_nodes => '',
    server_certname       => 'puppet.core.ghostlink.net',
    dns_alt_names         =>  [
                                'pp.ghostlink.net',
                                'puppet.ghostlink.net',
                                'puppet'
                              ],
    hiera_config          => '/etc/hiera.yaml',
  }

  class { 'puppet::server::puppetdb':
    server => 'puppet.core.ghostlink.net',
  }

  firewalld_port { 'puppet-port':
    ensure   => present,
    zone     => 'public',
    port     => 8140,
    protocol => 'tcp',
    before   => Class['::puppet']
  }

  firewalld_port { 'puppetdb-port':
    ensure   => present,
    zone     => 'public',
    port     => 8081,
    protocol => 'tcp',
    before   => Class['puppetdb']
  }

  class { 'puppetdb':
    manage_package_repo     => false,
    postgres_version        => '',
    database_listen_address => '*',
    database_host           => 'localhost',
    manage_firewall         => false,
#    # 'postgresql-server'
  }

  postgresql::server::pg_hba_rule { 'Postgresql':
    description => 'Open up PostgreSQL puppetdb ',
    type        => 'host',
    database    => 'puppetdb',
    user        => 'puppetdb',
    address     => '::1/128',
    auth_method => 'trust',
    order       => '0'
  }


  package { 'git':
    ensure => installed,
  }

  class { 'r10k':
    #remote => 'git@git.ghostlink.net:infra/puppet.git',
    remote => 'https://github.com/GlitchWraith/puppet.git',
  }

  #class { 'r10k::webhook::config':
  #  protected        => false,
  #  gitlab_token     => 'THISISTHEGITLABWEBHOOKSECRET',
  #  use_mcollective => false,
  #}

  #class {'r10k::webhook':
  #  use_mcollective => false,
  #  user            => 'root',
  #  group           => '0',
  #  require         => Class['r10k::webhook::config'],
  #}

}
```
