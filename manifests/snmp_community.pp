# == Defined resource type: ipmi::snmp
#

define ipmi::snmp_community (
  Integer           $lan_channel = 1,
  Optional[String]  $community   = undef,
)
{
  include ipmi
  $_community = $community ? {
    undef   => $name,
    default => $community,
  }
  exec { "ipmi_set_snmp_${lan_channel}":
    command => "/usr/bin/ipmitool lan set ${lan_channel} snmp ${_community}",
    onlyif  => "/usr/bin/test \"$(ipmitool lan print ${lan_channel} |\
    grep 'SNMP Community String' | sed -e 's/.* : //g')\" != \"${_community}\"",
    require => Package[$ipmi::packages],
  }
}
