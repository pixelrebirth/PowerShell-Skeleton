function Start-OrgNamePlaster {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)][string]$ModulePath
    )
    #Requires -version 5
    #Requires -RunAsAdministrator
    function Invoke-ErrorHandle {
        param (
            [Parameter(Mandatory=$true)][string]$HumanMessage
        )
        Write-Error -message $HumanMessage
        Write-Debug -message $global:error[0].exception.message
        Read-Host -Prompt "Press enter to end"
        exit 1
    }

    Write-Verbose -message "Verifying git is installed."
    if ((git)[0] -notmatch "^usage: git"){
        Invoke-ErrorHandle -HumanMessage "Please install git and add it to your path: https:\\git-scm.com\download\win"
    }

    if ((Get-ChildItem -path $ModulePath -ErrorAction 0).count -gt 0){
        Invoke-ErrorHandle -HumanMessage "PackagePath $ModulePath needs to be empty or missing"
    }

    $PackageList = @(
        "Pester",
        "Plaster",
        "PlatyPS",
        "PSake",
        "Posh-Git",
        "PSScriptAnalyzer"
    )

    foreach ($ExternalPackage in $PackageList){
        Write-Verbose -message "Verifying package: $ExternalPackage is installed."
        try {
            Import-Module $ExternalPackage -ErrorAction stop
        }
        catch {
            try {
                Write-Verbose -message "$ExternalPackage was missing, installing it now.."
                Find-Package $ExternalPackage -Source PSGallery | Install-Package -force
                Import-Module $ExternalPackage
            }
            catch {
                Invoke-ErrorHandle -HumanMessage "An error occurred trying to install the Package $ExternalPackage."
            }
        }
    }

    try {
        Invoke-Plaster -TemplatePath "$PSScriptRoot\" -DestinationPath $ModulePath
    }
    catch {
        Invoke-ErrorHandle -HumanMessage "Cannot reading the PlasterManifest.xml file, linting error?"
    }

    try {
        $ModulePathLeafRemoved = ((Get-Item -Path $ModulePath).PsParentPath -split("::"))[1]
        $PackageName = (Get-ChildItem -Path $ModulePath\*.psm1).Name.split(".")[0]
        $NewDirectoryName = "$ModulePathLeafRemoved\$PackageName"
        
        Rename-Item -Path $ModulePath -NewName $NewDirectoryName -Force -ErrorAction Stop
        
        $HumanMessage = "For compliance reasons, your Package folder has changed names to: $NewDirectoryName"
        Write-Output "`n`-----`n$HumanMessage`n`-----`n"
    }
    catch {
        $ErrorMessage  = $global:error[0].exception.message
        if ($ErrorMessage -eq "Source and destination path must be different."){
            $HumanMessage = "Congratulations, you have named your folder compliantly: $NewDirectoryName"
            Write-Verbose -message $HumanMessage
        }
        else {
            Invoke-ErrorHandle -HumanMessage "Cannot properly name repository folder from $ModulePath to $NewDirectoryName"
        }
    }

    try {
        $PsdContent = Get-Content -Path "$NewDirectoryName\$PackageName.psd1"
        $PsdContent.replace('*','@()') | Out-File "$NewDirectoryName\$PackageName.psd1" -Force -Encoding UTF8
    }
    catch {
        Invoke-ErrorHandle -HumanMessage "Cannot format the PSD1 file correctly in $NewDirectoryName"
    }

    $DscModuleTest = [bool](Get-ChildItem -Path "$NewDirectoryName\DscResources" -ErrorAction SilentlyContinue)

    if ($DscModuleTest -eq $true){
        $PSScriptRoot = $NewDirectoryName
        . "$NewDirectoryName\GenerateDscPsm.ps1"
    }
}