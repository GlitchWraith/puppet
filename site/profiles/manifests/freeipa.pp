# =Class files
# File Sharing Site
class profiles::freeipa (
  String  $join_principal,
  String  $principal_auth,
  Boolean $dns              = false
){



  $kind = lookup('FreeIPA_role')

  if  $kind == 'replica'  {

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
    }
  }
  if  $kind == 'master'  {

    notify{ 'Installs packages only, no potentilly overwriting config, im not writing that': }

    package{$freeipa::ipa_server_package_name:
      ensure => present,
    }


  }




}

