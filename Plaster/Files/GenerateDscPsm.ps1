$AllFilesToGenerate = Get-ChildItem -Path "$PSScriptRoot\DscResources\*.ps1" -Recurse -Exclude *.tests.*
$DscModuleName = (Get-ChildItem -Path "$PSScriptRoot\*.psm1")[0].Name
"### DYNAMIC GENERATED FILE DO NOT EDIT ###" | Out-File "$PSScriptRoot\$DscModuleName"

Foreach ($EachFile in $AllFilesToGenerate){
    $DscContent = Get-Content -Path $EachFile.FullName
    $DscContent | Out-File "$PSScriptRoot\$DscModuleName" -Append -Force
}