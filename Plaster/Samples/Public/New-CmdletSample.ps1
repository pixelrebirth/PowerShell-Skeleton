function New-CmdletSample {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([string])]
    #Requires -Version 5
    param (
        [Parameter(Mandatory=$true)]
        [string]$TestServer,

        [string]$UserName,

        [string]$BlobFilePath
    )
    
    begin {
        if ($BlobFilePath -ne ""){
            $BlobContent = "Stuff Goes Here"
        }
        else {
            $BlobContent = "Stuff Goes Here"
        }
        Write-Debug -Message "BlobContent: $BlobContent"
    }
    
    process {
        $BodyHash = @{}
        $BodyHash.Add("Data", $BlobContent)
        $BodyHash.Add("User",$UserName)
        
        $BodyJson = $BodyHash | ConvertTo-Json
        Write-Debug -Message "BodyJson: $BodyJson"

        try {
            $TestUri = "http:\\$TestServer\testapi"
            if ($PsCmdlet.ShouldProcess($TestUri)) {
                Invoke-RestMethod -Method POST -Uri $TestUri -Body $BodyJson
                Start-Sleep -Milliseconds 10
            }
        }
        catch {
            $CompletedTest = $false
            Write-Verbose -Message "Invoke-RestMethod Failed to Execute"
            Write-Warning -Message "Error was: $($Error[0].Exception.Message)"
        }
    }
    
    end {
        if ($CompletedTest -eq $false){
            [string](Write-Output "Operation Failed")
        }
    }
}
