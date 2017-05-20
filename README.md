## AzureAutomationDSC

Working with the AzureRM Modules to create/destroy, spin up/spin down VMs.

The end goal is to have these VMs fully configured as an Active Directory test lab using DSC.

DSC on premise is limited as it does not have a management portal. In Azure we have the Azure Automation portal.

Operations.ps1 contains sample commands to use the functions in this project. This is a good place to start to get an idea.

### Configurations

Contains DSC resources

1. newDomain.ps1
2. newForest.ps1
3. setupDC.ps1


### Functions

manageModules.ps1 - Set-up module manifest files for all the modules created

#### SetupFunctions
Create the initial environment in Azure. Typically run once

1. Resource Group
2. Networks
3. IP Address Scheme
4. Public IP
5. Storage Account
6. Automation Account
7. RDP Access

#### DSCFunctions

1. Get an Azure onboarding key
2. Import DSC resources into Azure
3. Read where the DSC Config is published

#### OnboardFunctions

1. Register a DSC node configuration
2. Add a node configuration

#### VMFunctions
The main function for working with VMs in Azure

1. List VMs
2. Create VMs
3. Start VMs
4. Stop VMs
5. Remove VMs

Examples

```powershell
Get-MvVM -Name DC1
New-MmVM -Name DC2
Get-AllMmVM -Verbose
```
[Access the Azure portal here](https://portal.azure.com)
