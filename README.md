# Powershell Plaster Skeleton

## Purpose

This repository is meant to be a skeleton project for powershell modules distributed by build pipeline generated artifacts. These modules will be pulled down using a private PowershellGet provider hosted internally on Nexus. The plaster skeleton supports DSC and PowerShell Module projects.

## Powershell Module Rules

- Create a single file per cmdlet and follow the standards designated in this repository wiki. Example: New-CmdletSample
- Ensure that the PUBLIC cmdlets are marked in the ModuleName.psd1 file
- Ensure that all PRIVATE (meaning you will not see proper cmdlets when you import the module) are located in the PRIVATE folder
- Write Pester tests for your code, submission to MASTER branch is locked to PR only and the reviewer will have the expectation you have written them
- Always work in a feature\someBranchName and squash merge into develop
- Please open an ISSUE in gogs if you have any trouble using this repository
- Pester testing must exceed 90% code coverage, leaning on 100% most of the time
- Use the Install-OrgNameModule to install the module to your local powershell module folder

## DSC Module Rules

- Write one DSC class per file in the DscResources folder
- Running the vscode tests will auto generate the DSC module file
- DSC module must be installed to a powershell module folder to function, use Install-OrgNameModule.ps1 to install it
- If you need to generate the psm without using vscode runpester.ps1 task, run GenerateDscPsm.ps1 from the folder
## Repository Features

- GitFlow is being used to manage collaboration
- A .vscode tasks file and script has been included to allow for execution of pester directly from vscode, this is awesome (requires installing pester)
  - TestAll will do the full pester test
  - TestFile will do the current open file in the editor
- PSScriptAnalyzer is designed for us to follow and conform to standards, this is run as well when you run the vscode task
- Problems will show up in vscode problem tab and link through the documents accordingly

## How-To Use
```
$RepoUri = 'https://cleprepogit01.serv.infr.it.OrgNamena.com/Systems-Windows/powershell-skeleton/archive/master.zip'
Invoke-WebRequest -OutFile $env:temp/Skeleton.zip -Uri $RepoUri
Remove-Item -Recurse "C:\Program Files\WindowsPowerShell\Modules\Powershell-Skeleton" -ErrorAction 0
Expand-Archive $env:Temp/Skeleton.zip "C:\Program Files\WindowsPowerShell\Modules\"
Remove-Item $env:temp/Skeleton.zip -Force
```

Once it is installed to the powershell module folder you can run the following CmdLet:

`Start-OrgNamePlaster -ModulePath C:\Program Files\WindowsPowerShell\Modules\SomeModuleName`