Function Register-MmDSCNode{
    [CmdletBinding()]
    param(
    [string] $Name)    
    # Ensure VM is running

    $VMInfo = Get-MmVm -Name $Name 
    $PowerState = $VMInfo.Statuses | where {$_.code -like "PowerState*"}
    If ($powerState.DisplayStatus -like "*deallocated"){
        Write-Verbose "$Name is powered off"
        Start-MmVm -Name $Name -Verbose}
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Register-AzureRmAutomationDscNode -AzureVMName $Name -AzureVMResourceGroup $resourceGroup}

Function Assign-MmDSCNodeConfiguration{
    [CmdletBinding()]
    param(
    [string] $ConfigurationName,
    [string] $Name
    )    
    # Ensure VM is running

    $VMInfo = Get-MmVm -Name $Name 
    $PowerState = $VMInfo.Statuses | where {$_.code -like "PowerState*"}
    If ($powerState.DisplayStatus -like "*deallocated"){
        Write-Verbose "$Name is powered off"
        Start-MmVm -Name $Name -Verbose}
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Get-AzureRmAutomationDscNode -Name $Name -OutVariable DSCNode
    $AutoAccount | Get-AzureRmAutomationDscNodeConfiguration -ConfigurationName $ConfigurationName -OutVariable NodeConfig
    $DSCNode | Set-AzureRmAutomationDscNode -NodeConfigurationName $NodeConfig.name -Force -Verbose}