param(
    $DomainName = "lab.local",
    $NetbiosName = "LAB",
    $SafeModeAdministratorPassword = "Passw0rds123",
    $IPAddress
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Check domain exists in case provisioner is ran again
if (-not (Test-NetConnection -ComputerName $DomainName -WarningAction 'SilentlyContinue').PingSucceeded) {
    Install-WindowsFeature -Name AD-Domain-Services
    Import-Module ADDSDeployment

    Write-Host "Starting ADDS Forest installation at $(Get-Date). This clears NIC DNS settings..."
    $adForestParams = @{
        DomainName                    = $DomainName
        InstallDns                    = $true
        NoDnsOnNetwork                = $true
        CreateDnsDelegation           = $false
        SafeModeAdministratorPassword = (ConvertTo-SecureString $SafeModeAdministratorPassword -AsPlainText -Force)
        NoRebootOnCompletion          = $true
        Force                         = $true
        Verbose                       = $true
    }
    Install-ADDSForest @adForestParams

    Write-Host "Finished ADDS Forest installation at $(Get-Date)"

    Write-Host "Resetting NIC DNS settings..."
    #Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ResetServerAddresses -Verbose
    Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses $null -Verbose
    Set-DnsClient -InterfaceAlias 'Ethernet' -RegisterThisConnectionsAddress $false -Verbose
    Set-DnsClientServerAddress -InterfaceAlias 'Ethernet 2' -ServerAddresses $IPAddress, '127.0.0.1' -Verbose

    # Change NIC priority (metric)
    Set-NetIPInterface -InterfaceAlias 'Ethernet 2' -AddressFamily 'IPv4' -InterfaceMetric 10
}
else {
    Write-Host 'Domain exists already - skipping forest installation'
}
