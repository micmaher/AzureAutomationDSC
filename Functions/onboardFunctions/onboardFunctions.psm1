Function Register-MmDSCNode{
    [CmdletBinding()]
    param(
    [string] $Name)

    $VMInfo = Get-MmVm -Name $Name
    $PowerState = $VMInfo.Statuses | Where-Object {$_.code -like "PowerState*"}
    If ($powerState.DisplayStatus -like "*deallocated"){
        Write-Verbose "$Name is powered off"
        Start-MmVm -Name $Name -Verbose}
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Register-AzureRmAutomationDscNode -AzureVMName $Name -AzureVMResourceGroup $resourceGroup}


Function Get-MmDSCNode{
    [CmdletBinding()]
    param(
    [string] $Name)
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Get-AzureRMAutomationDSCNode -ResourceGroupName $resourceGroup}


Function Unregister-MmDSCNode{
    [CmdletBinding()]
    param(
    [string] $NodeName
    )

    $id = Get-MmDSCNode -Name $NodeName
    $id | Unregister-AzureRmAutomationDscNode -ResourceGroupName $resourceGroup -Confirm:$false -Force}

Function Get-MmDSCNodeConfiguration{
    [CmdletBinding()]
    param(
    [string] $Name)
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Get-AzureRMAutomationDSCNodeConfiguration -ResourceGroupName $resourceGroup}


Function Set-MmDSCNodeConfiguration{
    [CmdletBinding()]
    param(
    [string] $ConfigurationName,
    [string] $Name
    )
    # Ensure VM is running

    $VMInfo = Get-MmVm -Name $Name
    $PowerState = $VMInfo.Statuses | Where-Object {$_.code -like "PowerState*"}
    If ($powerState.DisplayStatus -like "*deallocated"){
        Write-Verbose "$Name is powered off"
        Start-MmVm -Name $Name -Verbose}
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Get-AzureRmAutomationDscNode -Name $Name -OutVariable DSCNode
    $AutoAccount | Get-AzureRmAutomationDscNodeConfiguration -ConfigurationName $ConfigurationName -OutVariable NodeConfig
    $DSCNode | Set-AzureRmAutomationDscNode -NodeConfigurationName $NodeConfig.name -Force -Verbose}


Function Remove-MmDSCNodeConfiguration{
    [CmdletBinding()]
    param(
    [string] $ConfigurationName
    )
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    Remove-AzureRmAutomationDscNodeConfiguration -Name $ConfigurationName -AutomationAccountName $AutoAccount}