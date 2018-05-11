@{
    # Defaults for all dependencies
    PSDependOptions      = @{
        Scope      = 'AllUsers'
        Parameters = @{
            # Use a local repository for offline support
            Repository = 'LocalPSRepository'
        }
    }

    # Use SkipPublisherCheck as later versions of Pester are not signed by Microsoft
    Pester               = @{
        Name       = 'Pester'
        Version    = '4.3.1'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }

    # Common modules
    FJHelperFunctions    = '1.7.0'
    'posh-git'           = '0.7.1'
    #PSCodeHealth         = '0.2.9'
    PSDeploy             = '0.2.3'
    PSScriptAnalyzer     = '1.16.1'
    PlatyPS              = '0.9.0'
    SqlServerDSC         = '11.1.0.0'
    psake                = '4.7.0'
    xDSCDiagnostics      = '2.6.0.0'
    xDSCResourceDesigner = '1.9.0.0'
    xFailOverCluster     = '1.10.0.0'
    xWebAdministration   = '1.19.0.0'
    xActiveDirectory     = '2.18.0.0'

    # Custom modules
    HobSqlServer         = @{
        DependencyType = 'FileSystem'
        Source         = 'C:\vagrant\HobSqlServer'
        Target         = 'C:\Program Files\WindowsPowerShell\Modules'
    }
}
