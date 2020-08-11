Start-VM -Name DC, SERVER1

Install-WindowsFeature -Name AD-Domain-Services
Install-ADDSDomainController -InstallDns -NoGlobalCatalog -DomainName waslab.local -Credential waslab\administrator 


# ENABLE REMOTE DESKTOP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"


#CONFIGURE SERVER AS GLOBAL CATALOG
Set-ADObject -Identity (Get-ADDomainController SERVER1).ntdssettingsobjectdn -Replace @{options='1'}