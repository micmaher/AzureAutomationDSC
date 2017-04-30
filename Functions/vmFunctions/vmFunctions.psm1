
Function Get-AllMmVm{
    Get-AzureRmVm -ResourceGroupName $resourceGroup
    Write-Host -ForegroundColor Green "Checking VM status . . ."}

Function Get-MmVm{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$True,
        ValueFromPipeline=$True)]
		[string]$Name
    )     
    Begin{}
    Process{
    Get-AzureRmVm -ResourceGroupName $resourceGroup -Name $Name -Status}
    End{}}

Function New-MmVM{
    <#
        Example . . .
            Publisher: MicrosoftWindowsServer
            Offer: WindowsServer
            SKU: 2016-Datacenter
            Version: 2016.127.20170406
            Size: Basic_A2 (2 cores, 3.5 GB memory)
    .URI 
        https://docs.microsoft.com/en-us/powershell/module/azurerm.compute/new-azurermvm?view=azurermps-1.7.0
    #>
    [CmdletBinding()]
    param(
    [string] $Name)

    # Select a VM Image type
    $publisher = Get-AzureRmVMImagePublisher -Location $loc | Out-GridView -passthru | Select-Object publishername #check all the publishers available
    $offer = Get-AzureRmVMImageOffer -Location $loc -PublisherName $publisher.PublisherName| Out-GridView -passthru | Select-Object offer #look for offers for a publisher
    $sku = Get-AzureRmVMImageSku -Location $loc -PublisherName $publisher.PublisherName -Offer $offer.Offer | Out-GridView -passthru |Select-Object skus #view SKUs for an offer
    $version = Get-AzureRmVMImage -Location $loc -PublisherName $publisher.PublisherName -Offer $offer.Offer -Skus $sku.Skus | Out-GridView -passthru | Select-Object version
    $serverOrder = Get-AzureRmVMImage -Location $loc -PublisherName $publisher.PublisherName -Offer $offer.Offer -Skus $sku.Skus -Version $version.Version

    # Set-up the VM's properties
    $vmsize = Get-AzureRmVMSize -Location $loc | Out-GridView -passthru | Select-Object name
    $vmConfig = New-AzureRMVMConfig -Name $Name -VMSize $vmsize.Name
    $cred = (Get-Credential -UserName 'MyAdmin' -Message "Type the password of the local administrator account" )
    $vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $Name -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
    $vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $serverOrder.PublisherName -Offer $serverOrder.Offer -Skus $serverOrder.Skus -Version $serverOrder.Version # Can use 'latest'

    # Storage
    $staccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup


    # Network
    If (-not($vNet)){$vNet = Get-AzureRmVirtualNetwork}

    $subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vNet
    $Subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetConfig.Name -VirtualNetwork $VNet
    
    $publicIP = New-AzureRmPublicIpAddress -Name "$($Name)-public" -ResourceGroupName $resourceGroup -AllocationMethod Dynamic -Location $loc

    # Test-AzureRmPrivateIPAddressAvailability -IPAddress 10.1.1.4 -VirtualNetwork $VNet

    # Create an IP configuration add it to a new network interface and then add it to the vm config
    $IpConfig = New-AzureRmNetworkInterfaceIpConfig -Name "$($Name)Ipconfig" -Subnet $Subnet -PrivateIpAddress 10.1.1.4 -PublicIpAddress $publicIP -Primary
    $NIC = New-AzureRmNetworkInterface -Name "$($Name)NIC" -ResourceGroupName $resourceGroup -Location $loc -NetworkSecurityGroupId $NSG.Id -IpConfiguration $IpConfig
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $NIC.Id


    # Disk
    $disk = 'OSDisk'
    $OSDiskUri = $staccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $Name + ".vhd"
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $disk -VhdUri $OSDiskUri -CreateOption fromImage

    # Now Create VM
    New-AzureRmVM -VM $vm -ResourceGroupName $resourceGroup -Location $loc -Verbose -ErrorAction Stop
    Get-AzureRmVm -ResourceGroupName $resourceGroup -Name $vmConfig.Name | Select-Object ProvisioningState

    Stop-AzureRmVM -ResourceGroupName $resourceGroup -Name $vmConfig.Name -Force
    Get-AzureRmVm -ResourceGroupName $resourceGroup -Name $vmConfig.Name | Select-Object ProvisioningState}

Function Start-MmVm{
    [CmdletBinding()]
    param(
    [string] $Name) 

    Get-AzureRmVm -ResourceGroupName $resourceGroup -Name $Name | Select-Object Name, ProvisioningState
    Write-Host -ForegroundColor Green "Starting VM this can take a few minutes"
    Start-AzureRmVM -Name $Name -ResourceGroupName $resourceGroup
    Get-AzureRmVm -ResourceGroupName $resourceGroup -Name $Name | Select-Object *}

Function Start-AllMmVm{
    Get-AzureRmVm -ResourceGroupName $resourceGroup | Select-Object Name, ProvisioningState
    Write-Host -ForegroundColor Green "Starting VM this can take a few minutes"
    Get-AzureRmVm -ResourceGroupName $resourceGroup | Start-AzureRmVM
    Get-AzureRmVm -ResourceGroupName $resourceGroup}

Function Stop-AllMmVm{
    Get-AzureRmVm | Stop-AzureRmVM -Force}

Function Stop-MmVm{
    [CmdletBinding()]
    param(
    [string] $Name)    
    Stop-AzureRmVM -Force -Name $Name}

Function Remove-MmVm{
    [CmdletBinding()]
    param(
    [string] $Name)    
    Write-Warning "Removing $Name"
    $check = Get-AzureRmVm -ResourceGroupName $resourceGroup -Name $Name
    If ($check){Remove-AzureRmVM -Name $Name -ResourceGroupName $resourceGroup}}

Function Get-MmVmStatus{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,
        ValueFromPipeline=$True)]
		[string[]]$Name
    )   
    Begin{}
    Process{
    Foreach ($n in $Name){ 
        $VMInfo = Get-MmVm -Name $n
        $PowerState = $VMInfo.Statuses | where {$_.code -like "PowerState*"}
        If ($powerState.DisplayStatus -like "*deallocated"){Return "$n is powered off"}}
        }
    End{}}