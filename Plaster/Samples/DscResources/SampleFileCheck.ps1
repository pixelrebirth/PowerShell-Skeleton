enum Ensure {
    Absent
    Present
}

[DscResource()]
Class SampleFileCheck {
    
    [DSCProperty(Key)]
    [string]$FileName
    
    [DSCProperty(Mandatory)]
    [string]$FilePath
    
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [SampleFileCheck] Get() {
        $FileExist = Get-ChildItem -Path "$($this.FilePath)\$($this.FileName)"
        if ($FileExist) {
            $this.FileName = $FileExist.Name
            $this.FilePath = $FileExist.Directory
            $this.Ensure = 'Present'
        }
        else {
            $this.FileName = $null
            $this.FilePath = $null
            $this.Ensure = 'Absent'
        }
        return $this
    }

    [bool] Test() {
        try {
            $FullPath = "$($this.FilePath)\$($this.FileName)"
            $FileExist = Get-ChildItem -Path $FullPath -ErrorAction Stop
            If (($this.Ensure -eq [Ensure]::Present) -and ($FileExist.FullName -eq $FullPath)) {
                return $True
            }
            else {
                return $False
            }
        }
        catch {
            if ($this.Ensure -eq [Ensure]::Absent) {return $True}
            else {return $False}
        }
    }

    [void] Set() {
        $FullPath = "$($this.FilePath)\$($this.FileName)"
        If ($this.Ensure -eq [Ensure]::Absent) {
            Remove-Item -Path $FullPath -Force
        }
        else {
            try {
                Get-ChildItem -Path $FullPath -ErrorAction Stop
                Remove-Item -Path $FullPath -Force
                New-Item -Name $this.FileName -Path $this.FilePath
            }
            catch {
                New-Item -Name $this.FileName -Path $this.FilePath
            }
        }
    }
}