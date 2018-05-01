# WARNING: this may break comms with Vagrant - TBC
# Configure WinRM
# http://robvit.com/system_center/vmm/error-vmm-host-not-responding/
sc.exe config WinRM start= delayed-auto
sc.exe config winrm type= own

# The defaults are more already on Server 2016
#winrm set winrm/config @{MaxTimeoutms = "1800000"}
#winrm set winrm/config/Service @{MaxConcurrentOperationsPerUser = "400"}
net stop winrm
net start winrm

winrm get winrm/config
