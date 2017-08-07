<#

PS C:\Users\micma\OneDrive\Scripts\Powershell\AzureRM\AzureAutomationDSC\Configurations> dc


    Directory: C:\Users\micma\OneDrive\Scripts\Powershell\AzureRM\AzureAutomationDSC\Configurations\DC


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----       07/08/2017     18:30           2718 localhost.mof
WARNING: The configuration 'DC' is loading one or more built-in resources without explicitly importing associated modules. 
Add Import-DscResource –ModuleName 'PSDesiredStateConfiguration' to your configuration to avoid this message.

#>

Configuration DC {
 
    WindowsFeature DHCP {
        Name = 'DHCP'
    }
    
    WindowsFeature NPAS {
        Name = 'NPAS'
    }

}
