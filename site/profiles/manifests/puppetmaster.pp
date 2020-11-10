class profiles::puppetmaster {

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
          create_keys     => true,
          hiera_yaml      => '/etc/hiera.yaml',
          create_symlink  => false,
  }

  class { '::puppet':
    server                => true,
    server_git_repo       => false,
    server_foreman        => false,
    server_reports        => 'store',
    server_external_nodes => '',
    server_certname       => 'puppet.core.ghostlink.net',
    dns_alt_names         =>  [
                                'pp.ghostlink.net',
                                'puppet.ghostlink.net',
                                'puppet'
                              ],
    hiera_config          => '/etc/hiera.yaml',
  }

  #class { 'puppet::server::puppetdb':
  #  server => 'puppet.core.ghostlink.net',
  #}

  #class { 'puppetdb':
  #  manage_package_repo     => false,
  #  postgres_version        => '',
  #  database_listen_address => 'puppet.core.ghostlink.net'
  #  # 'postgresql-server'
  #}


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
