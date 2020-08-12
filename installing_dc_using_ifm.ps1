Start-VM -Name DC, SERVER1

$domainAdmin = Get-Credential
Enter-PSSession -VMName DC -Credential $domainAdmin

#CREATE AN IFM FILE
ntdsutil.exe 
activate instance ntds 
ifm
create sysvol full C:\IFM 

Exit-PSSession

Enter-PSSession -VMName SERVER1 -Credential $domainAdmin 

# Map the \\DC\C$\IFM directory 
Net.exe use Z:\\DC\C$\IFM 
Robocopy.exe Z: C:\IFM /copyall /s 

#PowerShell way - favorite
$fromSession = New-PSSession -ComputerName DC -Credential $domainAdmin
Copy-Item -Path C:\IFM -Destination C:\ -Recurse -FromSession $fromSession 

# INSTALL ADDS
$safePassword = Read-Host -AsSecureString
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSDomainController -DomainName waslab.local -InstallationMediaPath C:\IFM -InstallDns `
-SafeModeAdministratorPassword $safePassword -Credential $domainAdmin 

Exit-PSSession
Stop-VM -Name DC, SERVER1
Restore-VMSnapshot -Name BASELINE -VMName SERVER1
Restore-VMSnapshot -Name "BASELINE -Install ADDS Management Tools" -VMName DC