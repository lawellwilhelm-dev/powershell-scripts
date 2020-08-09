New-VM -Name "Windows 10 Enterprise" -MemoryStartupBytes 2GB -Generation 2 -NewVHDPath 'D:\Hyper-V\Virtual Hard Disks\Windows 10 Enterprise.vhdx' -NewVHDSizeBytes 50GB -SwitchName intswitch1

Get-VMScsiController -VMName "Windows 10 Enterprise"

Add-VMScsiController -VMName "Windows 10 Enterprise" 

Add-VMDvdDrive -VMName "Windows 10 Enterprise" -ControllerNumber 1 -ControllerLocation 0 -Path "D:\DataStore\os\18363.418.191007-0143.19h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

$DVDDrive = Get-VMDvdDrive -VMName "Windows 10 Enterprise"

Set-VMFirmware -VMName "Windows 10 Enterprise" -FirstBootDevice  $DVDDrive