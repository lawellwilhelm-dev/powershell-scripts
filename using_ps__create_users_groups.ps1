#USING POWERSHELL TO CREATE USER ACCOUNTS AND GROUPS

Start-VM -VMName DC, CLIENT 
Get-VM -Name DC, CLIENT 

# ENTER DC VIA PS REMOTING
$domainAdmin = Get-Credential 
Enter-PSSession -VMName DC -Credential $domainAdmin


# CREATE USER ACCOUNT USING WINDOWS POWERSHELL 
# Create BrancheOffice OU
New-ADOrganizationalUnit -Name BranchOffice
Get-ADOrganizationalUnit -Filter 'Name -Like "Branch*"'

# Create use account Kofi in BranchOffice OU
New-ADUser -Name Kofi -DisplayName 'Kofi kunle' -Path 'OU=BranchOffice,DC=waslab,DC=local'

# Set password for user account kofi
Set-ADAccountPassword -Identity kofi

# Enable kofi account
Enable-ADAccount -Identity kofi 

Exit-PSSession

# Test the user account
Enter-PSSession -VMName CLIENT -Credential waslab\kofi 
Exit-PSSession


# CREATING GROUP USING POWERSHELL
Enter-PSSession -VMName DC -Credential $domainAdmin

# Create a new group BranchUsers
New-ADGroup -Name BranchUsers -Path 'OU=BranchOffice,DC=waslab,DC=local' `
-GroupScope Global -GroupCategory Security

# Add Kofi as a member of BranchUsers
Add-ADGroupMember -Identity BranchUsers -Members kofi

# View BranchUsers group members
Get-ADGroupMember -Identity BranchUsers

# EXPORING USERS USING LDIFDE TOOL
ldifde.exe -f waslabusers.txt

ldifde.exe -d "dc=waslab,dc=local" -r "(objectClass=User)" -f waslabUsers.txt

#View the content of the file
Get-Content -Path .\waslabUsers.txt

Exit-PSSession

# END
Stop-VM -Name DC, CLIENT

Restore-VMSnapshot -Name BASELINE -VMName DC
Restore-VMSnapshot -Name BASELINE -VMName CLIENT


