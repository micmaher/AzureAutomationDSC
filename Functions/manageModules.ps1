

Get-ChildItem -Path "Functions\*\*.psm1" | 
    Foreach-Object{New-ModuleManifest -Path ($_.FullName).Replace('.psm1', '.psd1') -Author 'MMaher' -ModuleVersion '1.0.0' -Description 'Azure functions' -FunctionsToExport '*'}
Get-ChildItem -Path "Functions\*.psm1" | Foreach-Object{Import-Module -Name($_.FullName).Replace('.psm1', '') -PassThru}

Get-ChildItem -Path "Functions\*\*.psd1" | 
    Foreach-Object{Test-ModuleManifest -Path ($_.FullName)}
