include 'docker'

package { 'fail2ban':
  ensure => installed,
}

docker::image { 'conjur-ui':
   image => 'conjurinc/conjur-ui',
}

docker::image { 'conjurinc/conjur-appliance'
   docker_tar  => '/vagrant/conjur-appliance-4.6.1.tgz',
}

docker::run { 'conjur-solo':
   image   => 'registry.tld/conjur-appliance',
   ports   => ['443:443','636:636','5432:5432'],
   restart => 'always',
}

docker::exec { 'configure-master':
   container => 'conjur-solo',
   command => 'evoke configure master -h conjur.local -p conjur dev',
   require => Docker::Run['conjur-solo'],
   unless => "/usr/bin/test $(docker exec conjur-solo evoke role) = master",
}

$certdir="/vagrant"

exec {'create_self_signed_sslcert':
  command => "openssl req -newkey rsa:2048 -nodes -keyout ${::fqdn}.key  -x509 -days 365 -out ${::fqdn}.crt -subj '/CN=${::fqdn}'",
  cwd     => $certdir,
  creates => [ "${certdir}/${::fqdn}.key", "${certdir}/${::fqdn}.crt", ],
  path    => ["/usr/bin", "/usr/sbin"],
}

docker::run { 'conjur-ui':
   image => 'conjurinc/conjur-ui',
   ports => ['8443:443'],
   env => ['CONJUR_APPLIANCE_URL=https://conjur.local','SERVER_HOSTNAME=conjur.local','SERVER_SSL_KEY="$(cat /vagrant/conjur.local.key)"','SERVER_SSL_CERT="$(cat /vagrant/conjur.local.crt)"'],
   links => ['conjur-solo:conjur.local'],
   require => Docker::Exec['configure-master'],
}
