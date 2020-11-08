# Config common to all nodes
class profiles::common {

    # sshd config
    include profiles::ssh::server

    # common packages needed everywhere
    package {[
            'vim',
            'sudo',
        ]:
        ensure => present,
    }

}
