# Enable ping
$firewallRules = 'FPS-ICMP4-ERQ-In', 'FPS-ICMP4-ERQ-Out'
Set-NetFirewallRule -Name $firewallRules -Enabled 'True'

# Enable Remote xdscdiagnostics use
if ((Get-NetFirewallRule -Name 'Service RemoteAdmin' -ErrorAction 'SilentlyContinue') -eq $null) {
    Write-Host "Creating new Firewall Rule 'Service RemoteAdmin'"
    New-NetFirewallRule -Name "Service RemoteAdmin" -DisplayName "Remote" -Action 'Allow'
}

# Enable Remote Events collection
Set-NetFirewallRule -Name 'RemoteEventLogSvc*' -Enabled 'True'

# Fix: restart Network Location Awareness service if Windows Firewall showing "Public" instead of "Domain"
# Also delay WinRM
$serviceNames = 'NlaSvc'
foreach ($serviceName in $serviceNames) {
    Invoke-Expression "sc.exe config $serviceName start=delayed-auto"
    Get-Service -Name $serviceName | Restart-Service -Force
}

# Update-xDSCEventLogStatus
Write-Host 'Enabling DSC Analytic/Debug logs...' -ForegroundColor 'Yellow'
# Log names
$logNames = 'Operational', 'Analytic', 'Debug'

# Disable logs first
foreach ($logName in $logNames) {
    Update-xDscEventLogStatus -Channel $logName -Status 'Disabled' -ComputerName $computerName -Verbose
}
# Enable logs
foreach ($logName in $logNames) {
    Update-xDscEventLogStatus -Channel $logName -Status 'Enabled' -ComputerName $computerName -Verbose
}

# Create artifact folder
Write-Host 'Creating Artifact folder'
New-Item -Path 'C:\Artifacts' -ItemType 'Directory' -Force
