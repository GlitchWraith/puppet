# Config common to all nodes
class profiles::common {
    # common users
    users { 'common': }

    # sshd config
    include profiles::ssh::server



    # common packages needed everywhere
    package {[
            'vim',
            'sudo',
            'screen'
        ]:
        ensure => present,
    }

    # set locale
    class { 'locales':
        default_locale => 'en_GB.UTF-8',
        locales        => ['en_GB.UTF-8 UTF-8'],
    }
}
