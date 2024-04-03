. "$PSScriptRoot\..\..\public\New-CmdletSample.ps1"
function Invoke-RestMethod ($uri, $method){}
Describe "New-CmdletSample" {
    mock Invoke-RestMethod {"Response"}
    it "Should be Operation Completed with no errors" {
        New-CmdletSample -BlobFilePath 'someFilePath' -TestServer "stuff"-UserName "Sam" | should Be "Response"
    }
    
    mock Invoke-RestMethod {Throw "SomeError"}
    it "Should be Operation Failed with errors" {
        New-CmdletSample -TestServer "stuff" -UserName "Sam" | should Be "Operation Failed"
    }
}
