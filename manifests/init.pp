# == Class: ipmi
#
# Please refer to https://github.com/jhoblitt/puppet-ipmi#usage for
# parameter documentation.
#
class ipmi (
  Array[String]           $packages,
  Stdlib::Absolutepath    $conf_file,
  String                  $ipmi_service_name,
  Stdlib::Ensure::Service $ipmi_service_ensure,
  String                  $ipmievd_service_name,
  Stdlib::Ensure::Service $ipmievd_service_ensure,
  Boolean                 $watchdog,
  Optional[Hash]          $snmp_communities,
  Optional[Hash]          $users,
  Optional[Hash]          $networks,
) {

  $enable_ipmi = $ipmi_service_ensure ? {
    'running' => true,
    'stopped' => false,
  }

  $enable_ipmievd = $ipmievd_service_ensure ? {
    'running' => true,
    'stopped' => false,
  }
  ensure_packages($packages)
  augeas {$conf_file:
    context => "/files${conf_file}",
    changes => ["set IPMI_WATCHDOG ${watchdog.bool2str('yes', 'no')}"],
    require => Package[$packages],
    notify  => Service[$ipmi_service_name, $ipmievd_service_name],
  }
  service{ $ipmi_service_name:
    ensure  => $ipmi_service_ensure,
    enable  => $enable_ipmi,
    require => Package[$packages],
  }
  service{ $ipmievd_service_name:
    ensure  => $ipmievd_service_ensure,
    enable  => $enable_ipmievd,
    require => Package[$packages],
  }
  if $snmp_communities {
    create_resources('ipmi::snmp_community', $snmp_communities)
  }
  if $users {
    create_resources('ipmi::user', $users)
  }
  if $networks {
    create_resources('ipmi::network', $networks)
  }
}
