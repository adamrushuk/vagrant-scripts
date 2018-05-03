Write-Host "Resetting NIC DNS settings..."

# Reset NIC 1
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses $null -Verbose
Set-DnsClient -InterfaceAlias 'Ethernet' -RegisterThisConnectionsAddress $false -Verbose

# Change NIC priority (metric) so DNS is served by a Domain Controller on 2nd NIC
Set-NetIPInterface -InterfaceAlias 'Ethernet 2' -AddressFamily 'IPv4' -InterfaceMetric 10
