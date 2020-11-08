# =Class files
# File Sharing Site
class profiles::freeipa (
  String  $join_principal,
  String  $principal_auth,
  Boolean $dns              = false
){



  $kind = lookup('FreeIPA_role')

  if  $kind == 'replica'  {
    notify{ 'Replica': }
    class {'freeipa':
      ipa_role                    => $kind,
      domain                      => lookup('ipaRealmName').downcase,
      realm                       => lookup('ipaRealmName'),
      install_epel                => false, # managed elsewhere
      ipa_master_fqdn             => lookup('ipaRealmMaster'),
      # Could use profile::base::cacert::ldap_server but that might create some loops
      install_ipa_server          => true,
      ip_address                  => $::ipaddress6,
      ipa_server_fqdn             => $::fqdn,
      configure_dns_server        => $dns,
      principal_usedto_joindomain => $join_principal,
      password_usedto_joindomain  => $principal_auth,
      puppet_admin_password       => 'NOT Needed For THIS',
      directory_services_password => 'Still NOT Needed',
      ipa_server_package_name     => '@idm:DL1/server',
      ipa_client_package_name     => '@idm:DL1/client'
    }
  }
  if  $kind == 'master'  {

    notify{ 'Installs packages only, no potentilly overwriting config, im not writing that': }

    package{$freeipa::ipa_server_package_name:
      ensure => present,
    }


  }

  if  $kind == 'client'  {

    class {'freeipa':
      ipa_role                    => $kind,
      domain                      => lookup('ipaRealmName').downcase,
      realm                       => lookup('ipaRealmName'),
      install_epel                => false, # managed elsewhere
      ipa_master_fqdn             => lookup('ipaRealmMaster'),
      # Could use profile::base::cacert::ldap_server but that might create some loops
      install_ipa_server          => false,
      ip_address                  => $::ipaddress6,
      ipa_server_fqdn             => $::fqdn,
      principal_usedto_joindomain => $join_principal,
      password_usedto_joindomain  => $principal_auth,
      puppet_admin_password       => 'NOT Needed For THIS',
      directory_services_password => 'Still NOT Needed',
      ipa_server_package_name     => '@idm:DL1/server',
      ipa_client_package_name     => '@idm:DL1/client'
    }
  }




}

