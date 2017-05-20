# Install Azure Resource Manager Modules
If (-not(Get-Module -Name AzureRm -ListAvailable)){
    Find-Package -Name AzureRM -Source psgallery
    Install-Package -Name AzureRM -Source PSGallery -Force -Confirm:$false
    Get-Command *azurerm*
}

If (Test-Path -Path '.\ProfileContext.ctx'){
    Import-AzureRmContext -Path $path
}
Else{
    ./firstTimeLogin.ps1
    # Use new method: https://t.co/1yKiYN0jBG
    Save-AzureRmContext -Path $path -Force
}

# Import Modules
Set-Location $path
Import-Module .\Functions\DSCFunctions\DSCFunctions.psd1 -Verbose
Import-Module .\Functions\setupFunctions\setupFunctions.psd1 -Verbose
Import-Module .\Functions\vmFunctions\vmFunctions.psd1 -Verbose
Import-Module .\Functions\onboardFunctions\onboardFunctions.psd1 -Verbose