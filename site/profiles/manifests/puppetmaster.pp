class profiles::puppetmaster {

  # Puppet hiera  setup
  class { 'hiera':
          hiera_version   =>  '5',
          hiera5_defaults =>  {"datadir" => "data", "data_hash" => "yaml_data"},
          hierarchy       =>  [
                                {"name" =>  "Nodes yaml", "paths" =>  ['nodes/%{::trusted.certname}.yaml',]},
                                {"name" =>  "OS", "paths" =>  ['os/%{facts.os.name}.yaml', 'os/%{::osfamily}.yaml']},
                                {"name" =>  "Location", "paths" =>  ['location/site1.yaml',]},
                                {"name" =>  "eyaml", "paths" =>  ['nodes/%{::trusted.certname}.eyaml','location/site1.eyaml','common.eyaml']},
                                {"name" =>  "Default yaml file", "path" =>  "common.yaml"},
                              ],
          eyaml           => true,
          create_keys     => true,
          hiera_yaml      => '/etc/puppet/hiera.yaml',
  }

  class { '::puppet':
    server          => true,
    server_git_repo => false,
    server_foreman  => false,
    server_certname => 'pp.ghostlink.net',
    dns_alt_names   =>  [
                          'puppet.core.ghostlink.net',
                          'puppet.ghostlink.net',
                          'puppet'
                        ],
    hiera_config    => '/etc/puppet/hiera.yaml',
  }

  class { 'puppet::server::puppetdb':
    server => 'ppdb.ghostlink.net',
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
