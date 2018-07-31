define postfix::transport(
                            $domain            = $name,
                            $includesubdomains = true,
                            $suppressmxlookups = true,
                            $transport         = undef,
                            $nexthop           = undef,
                            $error             = undef,
                            $transport_noop    = false,
                            $order             = '55',
                            $include_to_maincf = true,
                            $target            = '/etc/postfix/transport',
                          ) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(! defined(Concat::Fragment["/etc/postfix/main.cf transport_maps ${target}"]))
  {
    # # transport
    # transport_maps = hash:/etc/postfix/transport
    if($include_to_maincf)
    {
      concat::fragment{ "/etc/postfix/main.cf transport_maps ${target}":
        target  => '/etc/postfix/main.cf',
        order   => '01',
        content => "\n# transport\ntransport_maps = hash:${target}\n",
      }
    }
  }

  if(! defined(Concat[$target]))
  {
    concat { $target:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec["reload postfix transport ${target}"],
    }

    exec { "reload postfix transport ${target}":
      command     => "postmap ${target}",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/transport"] ],
    }

    concat::fragment{ "${target} header":
      target  => $target,
      order   => '00',
      content => template("${module_name}/transport/header.erb"),
    }
  }

  if($transport_noop)
  {
    $transport_real = ''
    $nexthop_real = ''
    $suppressmxlookups_real = false
  }
  elsif($nexthop!=undef)
  {
    $transport_real = ''
    $nexthop_real = $nexthop
    $suppressmxlookups_real = $suppressmxlookups
  }
  elsif($error!=undef)
  {
    $transport_real = 'error'
    $nexthop_real = $error
    $suppressmxlookups_real = false
  }
  elsif($transport!=undef)
  {
    $transport_real = $transport
    $nexthop_real = $nexthop
    $suppressmxlookups_real = $suppressmxlookups
  }

  concat::fragment{ "{target} ${transport_real} ${name} ${domain}":
    target  => $target,
    order   => $order,
    content => template("${module_name}/transport/generic.erb"),
  }

}
