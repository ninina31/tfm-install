class install {	

	class {'iptables':}

	class {'apache':}

	apache::vhost { 'portal.dev':
	      port          => '80',
	      docroot       => '/www',
	}

	apache::vhost { 'portal.pro':
	      port          => '80',
	      docroot       => '/www',
	}

	####################################################### php ###############################################################
	class {'yum':}
	
	#PHP
	$php_version = '56'
	$yum_repo = 'remi-php56'
	::yum::managed_yumrepo { 'remi-php56':
	  descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 5.6',
	  mirrorlist     => 'http://rpms.famillecollet.com/enterprise/$releasever/php56/mirror',
	  enabled        => 1,
	  gpgcheck       => 1,
	  gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
	  gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-remi',
	  priority       => 1,
	}
	
	class { 'php':
	  version => 'latest',
	  require => Yumrepo[$yum_repo]
	}

	include apache::mod::php
	php::module { ['pdo']: }

	####################################################### php ###############################################################


	###################################################### MySQL ###############################################################

	class { 'yum::repo::mysql_community':
          enabled_version => '5.6',
    }

	package { 'mysql-community-server':
	    ensure  => 'latest',
	    require => Class['yum::repo::mysql_community'],
	}


	class { 'init_mysql':
		subscribe 	=> Class['yum::repo::mysql_community'],
	}

	mysql_database { 'portaldb':
	  	ensure  => 'present',
	  	charset => 'latin1',
	  	collate => 'latin1_swedish_ci',
	  	subscribe 	=> Class['init_mysql']
	}

	###################################################### MySQL ###############################################################

	class {'memcached':}

	class { '::ntp':
		servers => [ '1.es.pool.ntp.org', '2.europe.pool.ntp.org', '3.europe.pool.ntp.org' ],
		package_ensure => 'latest'
	}

	$misc_packages = ['vim-enhanced','telnet','zip','unzip','screen','libssh2','libssh2-devel', 'gcc', 'gcc-c++', 'autoconf', 	'automake']
	
	package { $misc_packages: ensure => latest }

	class {'stdlib':}
	class {'git': 
		subscribe 	=> Class['stdlib']
	}

	class { 'composer':
  		command_name => 'composer',
  		target_dir   => '/usr/local/bin',
	}

	class { 'timezone':
    	timezone => 'Europe/Madrid',
	}

}	
