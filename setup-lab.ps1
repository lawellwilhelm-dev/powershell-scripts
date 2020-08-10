#CREATE VIRTUAL MACHINES
# Create an array of objects,each representing a differencing disk for the lab
$Disks = @(
    [Tuple]::Create("D:\Hyper-V\Virtual Hard Disks\DC.vhdx", "D:\Hyper-V\Virtual Hard Disks\Windows Server 2016 DX.vhdx"),
    [Tuple]::Create("D:\Hyper-V\Virtual Hard Disks\CORE.vhdx", "D:\Hyper-V\Virtual Hard Disks\Windows Server 2016 Core.vhdx"),
    [Tuple]::Create("D:\Hyper-V\Virtual Hard Disks\SERVER1.vhdx", "D:\Hyper-V\Virtual Hard Disks\Windows Server 2016 DX.vhdx"),
    [Tuple]::Create("D:\Hyper-V\Virtual Hard Disks\SERVER2.vhdx", "D:\Hyper-V\Virtual Hard Disks\Windows Server 2016 DX.vhdx"),
    [Tuple]::Create("D:\Hyper-V\Virtual Hard Disks\ROUTER.vhdx", "D:\Hyper-V\Virtual Hard Disks\Windows Server 2016 DX.vhdx"),
    [Tuple]::Create("D:\Hyper-V\Virtual Hard Disks\CLIENT.vhdx", "D:\Hyper-V\Virtual Hard Disks\Windows 10 Enterprise.vhdx")
);

$VMs = @(
    [Tuple]::Create("DC", "2GB"),
    [Tuple]::Create("CORE", "1GB"),
    [Tuple]::Create("SERVER1", "2GB"),
    [Tuple]::Create("SERVER2", "1GB"),
    [Tuple]::Create("ROUTER", "1GB"),
    [Tuple]::Create("CLIENT", "1GB")
);

$count = 0;

# Iterate through $Disks and Create the differencing disks 
foreach ($disk in $Disks) {
    $vm = $VMs[$count];

    Write-Verbose -Message ("Creating Differencing disk for " + $vm[0]) -Verbose
    New-VHD -Path $disk[0] -ParentPath $disk[1] -Differencing
    Write-Verbose -Message "Differencing disk created successfully" -Verbose

    # Iterate through $VMs and Create the VMs
    Write-Verbose -Message ("Creating " + $vm[0]) -Verbose
    New-VM -Name $vm[0] -MemoryStartupBytes $vm[1] -Generation 2 -VHDPath $disk[0] -SwitchName intSwitch1

    Write-Verbose -Message ("Setting up the maximum memory size for " + $vm[0]) -Verbose
    Set-VMMemory -VMName $vm[0] -MaximumBytes $vm[1]
    
    if ($vm[0] -eq "ROUTER") {
        Add-VMNetworkAdapter -VMName $vm[0] -SwitchName intSwitch2
    }

    Write-Verbose -Message ($vm[0] + " Created successfully") -Verbose
    $count++;
}
#NOTE: Can refactor it to create two function CreateDiffencingDisk and CreateVMs

#SETUP VIRTUAL MACHINES
#NOTE: I don't have enough memory to set all of them at once

#SET UP DC
$credential = Get-Credential

Enter-PSSession -VMName DC -Credential $credential

Set-TimeZone -Id UTC 

$ifx = (Get-NetAdapter).InterfaceIndex 

New-NetIPAddress -InterfaceIndex $ifx -PrefixLength 8 -IPAddress 10.0.0.100 -DefaultGateway 10.0.0.1
Set-DnsClientServerAddress -InterfaceIndex $ifx -ServerAddresses 10.0.0.100
Get-NetIpConfiguration

Rename-Computer -NewName DC -Restart;exit 

# Set up primary domain controller
Install-WindowsFeature -Name AD-Domain-Services
Install-ADDSForest -DomainName waslab.local -InstallDns

$domainCredentials = Get-Credential
Invoke-Command -VMName DC -Credential $domainCredentials -ScriptBlock {Get-NetIPConfiguration}


#SET UP SERVER 1
Enter-PSSession -VMName SERVER1 -Credential $credential

Set-TimeZone -Id UTC 

$ifx = (Get-NetAdapter).InterfaceIndex 

New-NetIPAddress -InterfaceIndex $ifx -PrefixLength 8 -IPAddress 10.0.0.101 -DefaultGateway 10.0.0.1
Set-DnsClientServerAddress -InterfaceIndex $ifx -ServerAddresses 10.0.0.100
Get-NetIpConfiguration

Rename-Computer -NewName SERVER1 -Restart;exit 

Invoke-Command -Credential $credential -VMName SERVER1 -ScriptBlock {
    ADD-Computer -DomainName waslab.local -credential waslab\administrator -Restart
}

