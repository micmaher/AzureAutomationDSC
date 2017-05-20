# Login as a Service Principal as the personal/@tripadvisor.com login won't work with PowerShell
    $subscr ="Visual Studio Professional"
    $applicationID = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    $tenantID = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    $global:resourceGroup = 'DSCAutomation'
    $global:DSCAutomationAccount = 'DSCAutomationAccount'
    $global:loc = 'westeurope'
    If (!($loc)){$global:loc = (Get-AzureRmLocation | Out-GridView -passthru | Select-Object Location).location} #Select a location
    $global:addressPrefix = '10.1.0.0/16'
    $global:NSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup

    # To create a key --> Azure Active Directory, App Registrations, App Name, Keys
    $key = ConvertTo-SecureString -String '**************************' -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $applicationID, $key
    Login-AzureRmAccount -Credential $credential -ServicePrincipal -TenantId $tenantID -Verbose


    # Now save your context locally (Force will overwrite if there)
    $path = '.\ProfileContext.ctx'
    if (($cmd = Get-Command Save-AzureRmProfile -ErrorAction SilentlyContinue)) {
        Save-AzureRmProfile -Path $path -Force}
