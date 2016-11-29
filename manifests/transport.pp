define postfix::transport(
                            $domain            = $name,
                            $includesubdomains = true,
                            $nexthop           = undef,
                            $error             = undef,
                            $order             = '55',
                          ) {

  if(! defined(Concat::Fragment['/etc/postfix/main.cf transport_maps']))
  {
    # # transport
    # transport_maps = hash:/etc/postfix/transport
    concat::fragment{ '/etc/postfix/main.cf transport_maps':
      target  => '/etc/postfix/main.cf',
      order   => '01',
      content => "\n# transport\ntransport_maps = hash:/etc/postfix/transport\n",
    }
  }

  if($nexthop!=undef)
  {
    concat::fragment{ "/etc/postfix/transport ${name} ${domain} ${nexthop}":
      target  => '/etc/postfix/transport',
      order   => $order,
      content => template("${module_name}/transport/nexthop.erb"),
    }
  }
  elsif($error!=undef)
  {
    concat::fragment{ "/etc/postfix/transport error ${name} ${domain}":
      target  => '/etc/postfix/transport',
      order   => $order,
      content => template("${module_name}/transport/error.erb"),
    }
  }
  else
  {
    fail('no action configured for this transport rule')
  }

}