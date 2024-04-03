. "$PSScriptRoot\..\..\Private\Get-InternalCallSample.ps1"

Describe "Get-InternalCallSample" {
    it "Should return StuffThing" {
        Get-InternalCallSample | should Be "StuffThing"
    }
}