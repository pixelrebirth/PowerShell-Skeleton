param ($FileName)

Start-Transcript "$PSScriptRoot\docs\LastPester.txt"
$OriginalWarning = $WarningPreference
$WarningPreference = 'SilentlyContinue'

if ($FileName){
    Write-Output "Running Pester on $FileName"
    $Paths = $FileName.split("\|\")
    $FileName = $Paths[-1].split(".")[0]
    $TestPath = $Paths[0] + "\tests\" + $FileName + ".tests.ps1"
    $RootPath = $Paths[0]  + "\" + $FileName + ".ps1"
    $Results = Invoke-Pester -Script $TestPath -CodeCoverage $RootPath -PassThru
}
else {
    Write-Output "Running Pester on All Files"
    $ExclusionList = @(
        '*.tests.*',
        'RunPester.ps1',
        'DscLocalTest.ps1',
        'GenerateDscPsm.ps1',
        'Install-OrgNameModule.ps1'
    )
    $ItemExclusions = Get-ChildItem -recurse "$PSScriptRoot\*.ps1" -Exclude $ExclusionList
    $Results = Invoke-Pester -CodeCoverage $ItemExclusions -PassThru
}
$FailedResults = $Results.TestResult | Where-Object {-not $_.Passed}
$FailedResults | ForEach-Object {
    $_.StackTrace -match "at line: (\d*)" | Out-Null
    $LineNumber = $matches[1]

    $_.StackTrace -match "at line: (?:\d*) in (.*)\n" | Out-Null
    $File = $matches[2] | Resolve-Path -Relative -ErrorAction 0

    $CollapsedMessage = $_.FailureMessage -replace "`n"," "
    $TestDescription = "$($_.Describe):$($_.Name)"
    Write-Output "$File;$LineNumber;$TestDescription`:$CollapsedMessage"
}

$FailedLines = $Results.CodeCoverage.MissedCommands
$FailedLines | ForEach-Object {
    $File = $_.file | Resolve-Path -Relative -ErrorAction 0
    $LineNumber = $_.line
    Write-Output "$File;$LineNumber;Missing Code Coverage"
}

$list = Get-ChildItem -recurse "$PSScriptRoot\*.ps1"
$count = $list.count
$content = get-content -path $list
$line_count = $content.count
Write-Output "$line_count lines of code written in $pwd in $count ps1 files`n`n"

$PSScriptAnalyzer = "$PSScriptRoot\Configs\PSScriptAnalyzerSettings.psd1"
$CurrentModule = (Get-ChildItem -Path "$PSScriptRoot\*.psd1").name
$DscModuleTest = [bool](Get-ChildItem -Path "$PSScriptRoot\DscResources" -ErrorAction SilentlyContinue)

if ($DscModuleTest -eq $true){
    & "$PSScriptRoot\GenerateDscPsm.ps1"
}

try {
    $AnalyzerOutput = Invoke-ScriptAnalyzer -Recurse -Path "$PSScriptRoot" -Setting $PSScriptAnalyzer -ErrorAction Stop
}
catch {
    $ErrorMessage = $error[0].exception.message
        
    if ($ErrorMessage -match "Could not find the module" -and $DscModuleTest -eq $true){
        Write-Output "$CurrentModule;1;DSC module not found, develop from an 'ENV:PSModulePath' location"
    }
}

if (-NOT $AnalyzerOutput){
    Write-Output "Script Analyzer Passed"
}
else {
    $AnalyzerOutput
}

If ($DscModuleTest -eq $false){
    $DocsPath = "$PSScriptRoot\Docs\Help"
    Import-Module -Name "$PSScriptRoot\$CurrentModule" -Force
    try {
        $MarkdownSplat = @{
            Module = $CurrentModule.replace(".psd1","")
            AlphabeticParamsOrder = $true
            OutputFolder = $DocsPath
            ErrorAction = "Stop"
        }
        New-MarkdownHelp @MarkdownSplat
    }
    catch {
        $ErrorMessage = $error[0].exception.message

        if ($ErrorMessage -match "Import-Module"){
            $LineNumber = Get-Content -Path $CurrentModule | where {$_ -match "FunctionsToExport"}
            Write-Output "$CurrentModule;$LineNumber;Must have one or more cmdlets in FunctionsToExport"
        }
        
        if ($ErrorMessage -match "file exists"){
            $ErrorMessage | Out-Null
        }
    }
    Update-MarkdownHelp -Path $DocsPath | Out-Null

    foreach ($MarkdownDoc in $(Get-ChildItem -Path $DocsPath)){
        $MissingDocumentation = Get-Content -Path $MarkdownDoc.FullName | where {$_ -match "\{|\}"}
        foreach ($MissingLine in $MissingDocumentation){
            $LineNumber = $MissingLine.ReadCount
            Write-Output "$DocsPath\$($MarkdownDoc.Name);$LineNumber;Missing Documentation"
        }
    }
}

Stop-Transcript
$WarningPreference = $OriginalWarning