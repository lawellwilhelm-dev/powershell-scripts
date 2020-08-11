Start-VM -Name DC, SERVER1
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
CheckPoint-VM -VMName DC -SnapshotName 'BASELINE -Install ADDS Management Tools'

$domainAdmin = Get-Credential
Enter-PSSession -VMName SERVER1 -Credential $domainAdmin

# INSTALL ADDS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# VIEW AD REPLICATION SITE
Get-ADReplicationSite

# INSTALL RODC 
Install-ADDSDomainController -DomainName waslab.local -SiteName "Default-First-Site-Name" `
-ReadonlyReplica -DelegatedAdministratorAccountName RODCADMIN `
-InstallDns -Credential $domainAdmin

# ENABLE REMOTE DESKTOP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"


Stop-VM -Name DC, SERVER1
Restore-VMSnapshot -Name BASELINE -VMName SERVER1
Restore-VMSnapshot -Name "BASELINE -Install ADDS Management Tools" -VMName DC




#TODO: View Password Replication Policy