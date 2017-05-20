<# To Do

Pipeline binding Get-AllMmVM | Get-MmVmStatus
Dynamic Private IP with Test-AzureRmPrivateIPAddressAvailability -IPAddress 10.1.1.4 -VirtualNetwork $VNet
#>

# Login and assign global variables
. .\loginAzure.ps1
Start-Process iexplore.exe 'https://portal.azure.com/'

# Sample Operations

Get-AllMmVM

Get-MmVmStatus -Name 'dc1' -Verbose
break

Start-MmVm -Name dc4

New-MmVM -Name dc3 -Verbose
Remove-MmVm -Name dc1 -Verbose
Remove-MmVm -Name dc2 -Verbose
Stop-AllMmVM

$node = Register-MmDSCNode -Name 'dc3'
Assign-MMDSCNodeConfiguration -Name 'dc3' -ConfigurationName 'dc' -Verbose