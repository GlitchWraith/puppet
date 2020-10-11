class roles::dynmap (
  String    $vhostname   = undef
){

  selboolean { 'httpd_can_network_connect':
    value      => on,
    persistent => true,
  }



  apache::vhost { $vhostname:
  port       => '80',
  docroot    => '/var/www/user',
  proxy_pass => [
      {
        'path' => '/',
        'url'  => 'http://localhost:8123/'
      },
    ],
  }
}
