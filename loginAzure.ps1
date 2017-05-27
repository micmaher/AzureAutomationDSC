# Install Azure Resource Manager Modules
If (-not(Get-Module -Name AzureRm -ListAvailable)){
    Find-Package -Name AzureRM -Source psgallery
    Install-Package -Name AzureRM -Source PSGallery -Force -Confirm:$false
    Get-Command *azurerm*
}

$path = '.\ProfileContext.ctx'
If (Test-Path -Path $path){
    Import-AzureRmContext -Path $path
}
Else{
    ./firstTimeLogin.ps1
    # Use new method: https://t.co/1yKiYN0jBG
    Save-AzureRmContext -Path $path -Force
}

# Import Modules
Import-Module .\Functions\DSCFunctions\DSCFunctions.psd1 -Verbose
Import-Module .\Functions\setupFunctions\setupFunctions.psd1 -Verbose
Import-Module .\Functions\vmFunctions\vmFunctions.psd1 -Verbose
Import-Module .\Functions\onboardFunctions\onboardFunctions.psd1 -Verbose

$global:resourceGroup = 'DSCAutomation'
$global:DSCAutomationAccount = 'DSCAutomationAccount'
$global:loc = 'westeurope'
If (!($loc)){$global:loc = (Get-AzureRmLocation | Out-GridView -passthru | Select-Object Location).location} #Select a location
$global:addressPrefix = '10.1.0.0/16'
$global:NSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup
