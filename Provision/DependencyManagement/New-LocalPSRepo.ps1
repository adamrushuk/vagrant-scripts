<#
.SYNOPSIS
    Creates a local PowerShell Repository.
.DESCRIPTION
    Creates a PowerShell Repository for local offline development.
    Creates a folder, a share, a local user account, and some environment variables - used to authenticate from
    within local virtual machines for network access to the host computer.
.PARAMETER Name
    The name of the folder. This will also be the SMB share name.
.PARAMETER Path
    The full PowerShell Repository folder path.
.PARAMETER ChangeAccess
    Specifies which users are granted modify permission to access the share.
    Multiple users can be specified by using a comma-separated list.
.PARAMETER Description
    Specifies an optional description of the SMB share.
.EXAMPLE
    $newPSRepositoryParams = @{
        Name         = 'PSModules'
        Path         = 'C:\PSModules'
        ChangeAccess = 'Everyone'
        Description  = 'PowerShell Repository'
    }
    .\New-LocalPSRepo.ps1 @newPSRepositoryParams

    Creates a folder called 'C:\PSModules', and create SMB share called 'PSModules'.
    Everyone will be granted modify permission to the SMB share.
.NOTES
    Author: Adam Rush
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [String]$Name = 'PSModules',

    [Parameter(Mandatory = $false)]
    [String]$Path = 'C:\Store\PSModules',

    [Parameter(Mandatory = $false)]
    [String[]]$ChangeAccess = 'Everyone',

    [Parameter(Mandatory = $false)]
    [String]$Description = 'PowerShell Repository'
)

# Output param values
Write-Host "INFO: Name: [$Name]"
Write-Host "INFO: Path: [$Path]"
Write-Host "INFO: ChangeAccess: [$($ChangeAccess | Out-String)]"
Write-Host "INFO: Description: [$Description]"


# Create folder if doesnt already exist
$taskMessage = "Creating folder: [$Path]"
Write-Host "STARTED: $taskMessage..."
try
{
    New-Item -Path $Path -ItemType 'Directory' -Force -ErrorAction 'Stop' | Out-String | Write-Host
    Write-Host "FINISHED: $taskMessage."
}
catch
{
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}


# Create SMB share
$taskMessage = "Creating SMB share: [$Name]"
Write-Host "STARTED: $taskMessage..."
try
{
    if (-not (Get-SmbShare -Name $Name -ErrorAction 'SilentlyContinue')) {
        $smbShareParam = @{
            Name         = $Name
            Path         = $Path
            Description  = $Description
            ChangeAccess = $ChangeAccess
            ErrorAction = 'Stop'
        }
        New-SmbShare @smbShareParam | Out-String | Write-Host
    } else {
        Write-Warning "SMB Share already exists for: [$Name]"
    }
    Write-Host "FINISHED: $taskMessage."
}
catch
{
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}


# Create user and env vars if user does not yet exist
if (-not (Get-LocalUser -Name $Name -ErrorAction 'SilentlyContinue')) {

    # Create local user
    $taskMessage = "Creating local user: [$Name]"
    Write-Host "STARTED: $taskMessage..."
    try
    {
        # Get random password
        $password = [System.Web.Security.Membership]::GeneratePassword(30,10)

        # Create user
        $newLocalUserSplat = @{
            Description = "Used to access PSModules share within VMs"
            Name = $Name
            Password = $password | ConvertTo-SecureString -AsPlainText -Force
            AccountNeverExpires = $true
        }
        New-LocalUser @newLocalUserSplat | Out-String | Write-Host
        Write-Host "FINISHED: $taskMessage."
    }
    catch
    {
        Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
        throw $_
    }


    # Create ENV vars ready to pass through to VM build scripts
    $taskMessage = "Creating environment variables"
    Write-Host "STARTED: $taskMessage..."
    try
    {
        # Set permanent env vars
        [Environment]::SetEnvironmentVariable('REPO_USER', $Name, 'User')
        [Environment]::SetEnvironmentVariable('REPO_PASS', $password, 'User')

        # Set session env vars
        $env:REPO_USER = $Name
        $env:REPO_PASS = $password

        Write-Host "FINISHED: $taskMessage."
    }
    catch
    {
        Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
        throw $_
    }

} else {
    Write-Warning "Local user [$Name] already exists."
}
