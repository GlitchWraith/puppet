# Sets ssh config for all instances
class profiles::ssh::server {
    package { 'openssh-server':
        ensure => present,
    }
}
