

Function Get-MmOnboardKey{
    Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $resourceGroup -AutomationAccountName $DSCAutomationAccount}

Function Import-MmConfig{
    [CmdletBinding()]
    param(
    [string] $ConfigPath)
    # Imports a DSC Configuration from $workDir
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Import-AzureRmAutomationDscConfiguration -SourcePath "$ConfigPath" -Published -Force
    $AutoAccount | Get-AzureRmAutomationDscConfiguration -name $ConfigName
    $job = $AutoAccount | Get-AzureRmAutomationDscConfiguration -name $ConfigName | Start-AzureRmAutomationDscCompilationJob # Create the MOF file
    while (-not($job | Get-AzureRmAutomationDscCompilationJob).EndTime){Start-Sleep -Seconds 3}
    $AutoAccount | Get-AzureRmAutomationDscNodeConfiguration}

Function Get-MmConfig{
    [CmdletBinding()]
    param(
    [string] $VMName)
    # Gets a DSC Configuration from $workDir
    $AutoAccount = Get-AzureRMResourceGroup -Name $resourceGroup | Get-AzureRmAutomationAccount
    $AutoAccount | Get-AzureRmAutomationDscConfiguration -name $VMName}