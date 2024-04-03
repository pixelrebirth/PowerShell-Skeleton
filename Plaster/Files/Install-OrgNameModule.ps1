try {
    $ModuleDirectoryRoot = "C:\Program Files\WindowsPowerShell\Modules\"
    $ModuleName = (Get-ChildItem "$PSScriptRoot\*.psd1").Name.replace(".psd1","")
    $ModulePath = $ModuleDirectoryRoot + $ModuleName
}
catch {
    Write-Error -message "Module is missing a PSD1 manifest. Cannot continue."
    Exit 1
}

Remove-Item -Path $ModulePath -Recurse -Force -ErrorAction SilentlyContinue
try {
    Copy-Item -Path "$PSScriptRoot" -Destination $ModuleDirectoryRoot -Force -Recurse
}
catch {
    Write-Error -Message "Cannot copy files into module path: $ModulePath"
    Exit 1
}

try {
    Import-Module -Name $ModuleName
    Remove-Module -Name $ModuleName
}
catch {
    Write-Error -Message "Module $ModuleName did not install or remove correctly from runtime."
    Exit 1
}