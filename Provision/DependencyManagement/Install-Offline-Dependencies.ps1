param (
    $PSDependConfigPath,
    $RepoUsername = 'psmoduleuser',
    $RepoPassword,
    $PowershellRepositoryPath = '\\192.168.56.1\PSModules',
    $LocalPSRepositoryName = 'LocalPSRepository',
    $PSDriveLetter = 'R'
)

# User with permissions for shared folder
$credential = New-Object -TypeName 'PSCredential' -ArgumentList ($RepoUsername, (ConvertTo-SecureString -String $RepoPassword -AsPlainText -Force))


# Setup Nuget without an Internet Connection:
# https://docs.microsoft.com/en-us/powershell/gallery/psget/repository/bootstrapping_nuget_proivder_and_exe#manually-bootstrapping-nugetexe-to-support-publish-operations-on-a-machine-that-is-not-connected-to-the-internet
Write-Host "CHECKING: NuGet PackageProvider is installed..."
if (-not (Get-PackageProvider | Where-Object Name -eq 'NuGet'))
{
    $taskDescriptionNuget = "Installing NuGet PackageProvider"
    Write-Host "STARTING: $taskDescriptionNuget..."
    try
    {
        # NuGet DLL
        $nugetDllDestinationPath = Join-Path -Path $env:ProgramFiles -ChildPath 'PackageManagement\ProviderAssemblies\nuget'
        New-Item -Path $nugetDllDestinationPath -ItemType 'Directory' -Force
        Copy-Item -Path 'C:\vagrant\Vagrant\Provision\DependencyManagement\nuget\dll\*' -Destination $nugetDllDestinationPath -Recurse -Force

        # NuGet EXE
        $nugetExeDestinationPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet'
        New-Item -Path $nugetExeDestinationPath -ItemType 'Directory' -Force
        Copy-Item -Path 'C:\vagrant\Vagrant\Provision\DependencyManagement\nuget\nuget.exe' -Destination $nugetExeDestinationPath -Recurse -Force
    }
    catch
    {
        Write-Error "ERROR: $taskDescriptionNuget..." -ErrorAction 'Continue'
        throw $_
    }
    Write-Host "FINISHED: $taskDescriptionNuget..."
}
else
{
    Write-Host "SKIPPING: NuGet PackageProvider installation as already exists."
}


# Map drive (done every time as there is issue with Server 2016 and persistent drives)
Write-Verbose "`nSTARTED: Mapping PS Drive..."
try
{
    $newPSDriveParams = @{
        Name        = $PSDriveLetter
        PSProvider  = 'FileSystem'
        Root        = $PowershellRepositoryPath
        Credential  = $credential
        Persist     = $true
        Scope       = 'Global'
        ErrorAction = 'SilentlyContinue'
        Verbose     = $true
    }
    New-PSDrive @newPSDriveParams
    Write-Host "`nFINISHED: Mapping PS Drive."
}
catch
{
    Write-Error "ERROR: Creating PSDrive using path [$PowershellRepositoryPath].." -ErrorAction 'Continue'
    throw $_
}


# Set up PSGallery and install any modules
Write-Host 'Setting up offline PSRepository and installing modules...'

#region Register offline PowerShell repository
$taskDescription = "Creating PSRepository [$LocalPSRepositoryName]"

if (-not (Get-PSRepository -Name $LocalPSRepositoryName -ErrorAction 'SilentlyContinue'))
{

    Write-Host "`nSTARTED: $taskDescription..."

    if (-not (Test-NetConnection -ComputerName ([Uri]$PowershellRepositoryPath).Host -Port 445).TcpTestSucceeded)
    {
        throw "Cannot connect to [$PowerShellRepositoryPath] on port 445. Please ensure this is enabled and re-create your environment"
    }

    # Register the local PowerShell repository for offline builds, and set to "Trusted"
    try
    {
        $repositoryParams = @{
            Name               = $LocalPSRepositoryName
            SourceLocation     = $PowershellRepositoryPath
            PublishLocation    = $PowershellRepositoryPath
            InstallationPolicy = 'Trusted'
            Credential         = $credential
            Verbose            = $true
            ErrorAction        = 'Stop'
        }
        Write-Host "Registering PSRepository [$Name]"
        Register-PSRepository @repositoryParams

        Set-PSRepository -Name $LocalPSRepositoryName -InstallationPolicy 'Trusted'
    }
    catch
    {
        Write-Error "`nERROR: $taskDescription..." -ErrorAction 'Continue'
        throw $_
    }

    Write-Host "`nFINISHED: $taskDescription."

}
else
{
    Write-Host "[$LocalPSRepositoryName] already registered"
}
#endregion


# Load PSDepend
if (-not (Get-Module -Name 'PSDepend' -ListAvailable))
{
    Install-Module -Name 'PSDepend' -Scope 'AllUsers' -Repository $LocalPSRepositoryName -Verbose
}
Import-Module -Name 'PSDepend' -Verbose


# Install and import dependencies
Write-Host "Checking / resolving module dependencies from [$PSDependConfigPath]..." -ForegroundColor 'Yellow'
Invoke-PSDepend -Path $PSDependConfigPath -Install -Confirm:$false
