# configure a Simple WebAuth "SP"

class webauth (
  $webkdc     = 'weblogin.itlab.stanford.edu',
  $domain     = 'itlab.stanford.edu',
  $base_dn    = 'cn=people,dc=itlab,dc=stanford,dc=edu',
  $ldap       = 'ldap.itlab.stanford.edu',
  $authz_attr = 'isMemberOf',
  $contact    = "webmaster@$::fqdn",
){

  package {
    [
      'libapache2-mod-webauth',
      'libapache2-mod-webauthldap',
    ]:
    ensure => 'latest',
    notify => [
      File['/etc/webauth'],
      File['/etc/apache2/conf-available/webauth.conf'],
      Exec['enable webauth'],
      Exec['enable webauthldap'],
      Exec['apache restart'],
    ],
  }

  exec { 'enable webauth':
    command => '/usr/sbin/a2enmod webauth',
    creates => '/etc/apache2/mods-enabled/webauth.load',
  }

  exec { 'enable webauthldap':
    command => '/usr/sbin/a2enmod webauthldap',
    creates => '/etc/apache2/mods-enabled/webauthldap.load',
  }

  file { '/etc/webauth':
    ensure => dir,
    owner  => 'root',
    group  => 'www-data',
    mode   => '0750',
  }

  file { '/etc/apache2/conf-available/webauth.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'www-data',
    mode    => '0644',
    content => template('webauth/webauth.conf.erb'),
    notify  => Exec['enable webauth.conf'],
  }

  exec { 'enable webauth.conf':
    command => '/usr/sbin/a2enconf webauth',
    creates => '/etc/apache2/conf-enabled/webauth.conf',
    notify  => Exec['apache restart'],
  }

  exec { 'apache restart':
    command     => '/usr/sbin/service apache2 restart',
    refreshonly => true,
  }

}

