class profile::repo::copr(
        String                                  $copr_repo      = $title,
        Enum['enabled', 'disabled', 'removed']  $ensure         = 'enable',
) {
  $prereq_plugin = $facts['package_provider'] ? {
    'dnf'   => 'dnf-plugins-core',
    default => 'yum-plugin-copr',
  }
  ensure_packages([ $prereq_plugin ])
  if $facts['package_provider'] == 'dnf' {
    case $ensure {
      'enabled':
        {
          exec { "dnf -y copr enable ${copr_repo}":
            unless  => "dnf copr list | egrep -q '${copr_repo}\$'",
            require => Package[$prereq_plugin],
          }
        }
      'disabled':
        {
          exec { "dnf -y copr disable ${copr_repo}":
            unless  => "dnf copr list | egrep -q '${copr_repo} (disabled)\$'",
            require => Package[$prereq_plugin],
          }
        }
      'removed':
        {
          exec { "dnf -y copr remove ${copr_repo}":
            unless  => "dnf copr list | egrep -q '${copr_repo}'",
            require => Package[$prereq_plugin],
          }
        }
    }
  } else {
    $copr_repo_name_part = regsubst($copr_repo, '/', '-', 'G')
    case $ensure {
      'enabled':
        {
          exec { "yum -y copr enable ${copr_repo}":
            onlyif  => "test ! -e /etc/yum.repos.d/_copr_${copr_repo_name_part}.repo",
          }
        }
      'disabled', 'removed':
        {
          exec { "yum -y copr disable ${copr_repo}":
            onlyif  => "test -e /etc/yum.repos.d/_copr_${copr_repo_name_part}.repo",
          }
        }
    }
  }
}
