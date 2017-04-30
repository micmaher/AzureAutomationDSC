<# 
    Part 1. Initial Set-up
        Create a Resource Group
        Create a network
        Create a storage account
        Create a VM (optional)
        Create an automation account

        https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-4-Advanced-onboarding-1

    Part 2. Configuration Files  
        Start/Stop VM
        Upload DSC Configuration File
        Generate MOF file

        https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-2-Configurations-Basics

    Part 3. Onboarding
        Onboard DSC Nodes

        https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-3-Onboarding-Azure-Windows-Nodes?ocid=player   
#>

Function New-MmResourceGroup{
    If (-Not(Get-AzureRmResourceGroup)){
        #New-AzureRmResourceGroup -Name (Read-Host -Prompt 'Name the resource group') -Location $loc
        New-AzureRmResourceGroup -Name $resourceGroup -Location $loc
    }}

Function New-MmNetwork{
    $newSubnetParams = @{
        'Name' = 'MySubnet'
        'AddressPrefix' = $addressprefix
    }
    $subnet = New-AzureRmVirtualNetworkSubnetConfig @newSubnetParams

    $newVNetParams = @{
        'Name' = 'Network'
        'ResourceGroupName' = $resourceGroup
        'Location' = $loc
        'AddressPrefix' = $addressprefix
    }
    $vNet = New-AzureRmVirtualNetwork @newVNetParams -Subnet $subnet

    # Create public IP
    $date = ((get-date).ToShortDateString()).Replace('/','')
    $newPublicIpParams = @{
        'Name' = 'NIC1'
        'ResourceGroupName' = $resourceGroup
        'AllocationMethod' = 'Dynamic' ## Dynamic or Static
        'DomainNameLabel' = "dom" + $date
        'Location' = $loc
    }
    $publicIp = New-AzureRmPublicIpAddress @newPublicIpParams}

Function New-MmStorageAccount{
    $staccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup
    If (-not($staccount)){
    $newStorageAcctParams = @{
        'Name' = 'mystorageaccount' ## Must be globally unique and all lowercase
        'ResourceGroupName' = $resourceGroup
        'Type' = 'Standard_LRS'
        'Location' = $loc
    }
    $stAccount = New-AzureRmStorageAccount @newStorageAcctParams
    }

    Select-AzureRmSubscription -SubscriptionName $subscr
    $staccount | Set-AzureRmCurrentStorageAccount}


Function New-MmAutomationAccount{ #(Free Plan allows 5 VMs)
    $automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $resourceGroup
    If (-not($automationAccount)){
        New-AzureRmAutomationAccount -Name $DSCAutomationAccount -Plan Free -ResourceGroupName $resourceGroup
    }}


Function Grant-MMRdpAccess{    
 # Create an inbound network security group rule for port 3389
 $NSGRule = New-AzureRmNetworkSecurityRuleConfig `
 -Name MyNsgRuleRDP `
 -Protocol Tcp `
 -Direction Inbound `
 -Priority 1000 `
 -SourceAddressPrefix * `
 -SourcePortRange * `
 -DestinationAddressPrefix * `
 -DestinationPortRange 3389 -Access Allow}

Function Grant-MMRdpPermission{  
 # Create a network security group
 $NSG = New-AzureRmNetworkSecurityGroup `
 -ResourceGroupName $resourceGroup `
 -Location $Loc `
 -Name DefaultNetworkSecurityGroup `
 -SecurityRules $NSGRule}