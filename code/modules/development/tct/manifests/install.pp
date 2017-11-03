# Class: tct::install
# ===========================
#
# Full description of class tct here.
#
#
# Examples
# --------
#
#
# Authors
# -------
#
# Flannon Jackson <flannon@nyu.edu>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class tct::install (
  String $allowed_hosts = lookup('tct::allowed_hosts', String, 'first'),
  String $backend       = lookup('tct::backend', String, 'first'),
  String $backend_revision = lookup('tct::backend_revision', String, 'first'),
  String $basename      = lookup('tct::basename', String, 'first'),
  String $baseurl       = lookup('tct::baseurl', String, 'first'),
  String $db_host       = lookup('tct::db_host', String, 'first'),
  String $db_password   = lookup('tct::db_password', String, 'first'),
  String $db_user       = lookup('tct::db_user', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $frontend      = lookup('tct::frontend', String, 'first'),
  String $frontend_revision = lookup('tct::frontend_revision', String, 'first'),
  String $install_dir   = lookup('tct::install_dir', String, 'first'),
  String $media_root    = lookup('tct::media_root', String, 'first'),
  String $secret_key    = lookup('tct::secret_key', String, 'first'),
  String $static_root   = lookup('tct::static_root', String, 'first'),
  String $tct_db        = lookup('tct::tct_db', String, 'first'),
  String $user          = lookup('tct::user', String, 'first'),
  String $venv          = lookup('tct::venv', String, 'first'),
  String $www_dir       = lookup('tct::www_dir', String, 'first'),
 ){

  # Add the user
  user { $user :
    ensure     => present,
    name       => $user,
    comment    => "Topic Curation Toolkit",
    home       => $install_dir,
    managehome => false,
  }

  file { $install_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  # Install the repos
  vcsrepo { "${install_dir}/${backend}":
    ensure   => present,
    provider => git,
    source   => "https://github.com/NYULibraries/dlts-enm-tct-backend",
    revision => $backend_revision,
  }
  # Install ius-release and python35u
  include yumrepos::ius
  # Setup python
  ensure_packages(['python34', 
                   'python34-devel', 
                   'python34-pip',
                   'python34-virtualenv',
                   'python35u',
                   'python35u-devel',
                   'python35u-pip',
                   ], 
  {'ensure' => 'present'})
  class { 'python':
    version    => 'system',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'present',
    gunicorn   => 'absent',
    use_epel   => true,
    require    => Class['Yumrepos::Ius'],
  }->
  python::pip { 'pip':
    ensure     => latest,
    pkgname    => 'pip',
    virtualenv => 'system',
    owner      => 'root',
    timeout    => 1800,
  }->
  #python::pip { 'virtualenv':
  #  ensure     => latest,
  #  pkgname     => 'virtualenv',
  #  virtualenv => 'system',
  #  owner      => 'root',
  #  timeout    => 1800,
  #}->
  python::pip { 'setuptools':
    ensure     => latest,
    pkgname    => 'setuptools',
    virtualenv => 'system',
    owner      => 'root',
    timeout    => 1800,
  }
  python::pyvenv { "$venv" :
    ensure     => present,
    version    => '3.5',
    systempkgs => false,
    venv_dir   => $venv,
    owner      => 'root',
    group      => 'root',
    require    => [ Class['python'], Package['python35u'] ],
    notify     => File["${venv}/requirements.txt"],
  }
  #python::pip { 'django' :
  #  ensure     => '1.11.6',
  #  pkgname    => 'django',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-allauth' :
  #  ensure     => '0.34.0',
  #  pkgname    => 'django-allauth',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-autoslug' :
  #  ensure     => '1.9.3',
  #  pkgname    => 'django-autoslug',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-cors-headers' :
  #  ensure     => '2.1.0',
  #  pkgname    => 'django-cors-headers',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-debug-toolbar' :
  #  ensure     => '1.5',
  #  pkgname    => 'django-debug-toolbar',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-extensions' :
  #  ensure     => '1.9.7',
  #  pkgname    => 'django-extensions',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-filter' :
  #  ensure     => '0.14.0',
  #  pkgname    => 'django-filter',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  # ??? or is it dango-rest-framework?
  #python::pip { 'djangorestframework' :
  #  ensure     => '3.7.1',
  #  pkgname    => 'djangorestframework',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'django-rest-auth' :
  #  ensure     => '0.8.1',
  #  pkgname    => 'django-rest-auth',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'lxml' :
  #  ensure     => '3.6.4',
  #  pkgname    => 'lxml',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #python::pip { 'psycopg2' :
  #  ensure     => '2.7.3.2',
  #  pkgname    => 'psycopg2',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    => 1800,
  #}
  #  python::pip { 'uwsgi':
  #  ensure     => latest,
  #  pkgname    => 'uwsgi',
  #  virtualenv => $venv,
  #  owner      => 'root',
  #  timeout    =>  1800,
  #}
  python::requirements { "${venv}/requirements.txt":
    virtualenv => $venv,
    owner      => 'root',
    group      => 'root',
    #require    => Python::Virtualenv["${venv}"],
    require    => Python::Pyvenv["${venv}"],
  }
  file { 'requirements-documentation.txt':
    ensure => present,
    path   => "${venv}/requirements-documentaiton.txt",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/tct/requirements-documentation.txt",
  }
  python::requirements { "${venv}/requirements-documentation.txt":
    virtualenv => $venv,
    owner      => 'root',
    group      => 'root',
    require    => Python::Pyvenv["${venv}"],
  }
}
