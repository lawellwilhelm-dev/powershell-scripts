New-VMSwitch -Name intswitch1 -SwitchType Internal
New-VMSwitch -Name intswitch2 -SwitchType Internal

Get-NetAdapter

New-NetIPAddress -InterfaceIndex 32 -IPAddress 10.0.0.254 -PrefixLength 8
New-NetNat -Name waslabnat01 -InternalIPInterfaceAddressPrefix 10.0.0.0/8

# Note: Multiple NAT is not supported.

Get-NetNat | Remove-NetNat
Remove-NetIPAddress -InterfaceIndex 32 -IPAddress 10.0.0.254 -PrefixLength 8