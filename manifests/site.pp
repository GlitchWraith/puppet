node 'puppet.core.ghostlink.net' {
  include profiles::puppetmaster
}
node default {
  lookup('classes', {merge => unique}).include
}

