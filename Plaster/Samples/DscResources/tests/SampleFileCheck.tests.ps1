. "$PSScriptRoot\..\..\DscResources\SampleFileCheck.ps1"

Describe "SampleFileCheck" {
    Context "Check DSC Class SampleFileCheck Get()" { 
        $DscClass = New-Object -TypeName SampleFileCheck
        $DscClass.FilePath = 'c:\thing'
        $DscClass.FileName = 'test.txt'
        $DscClass.Ensure = 'Present'

        it "DscClass Get should set FilePath equal to c:\thing when Get-ChildItem succeeds" {
            mock Get-ChildItem {
                @{
                    directory = "c:\thing"
                    name = "test.txt"
                }
            }
            $DscClass.Get().FilePath | should Be "c:\thing"
        }

        it "DscClass Get should set FilePath equal to NULL when Get-ChildItem fails" {
            mock Get-ChildItem {$false}            
            $DscClass.Get().FilePath | should BeNullOrEmpty
        }
    }
    
    Context "Check DSC Class SampleFileCheck Set()" {
        $DscClass = New-Object -TypeName SampleFileCheck
        $DscClass.FilePath = 'c:\thing'
        $DscClass.FileName = 'test.txt'
        $DscClass.Ensure = 'Present'

        mock Remove-Item {$true}
        mock New-Item {$true}
        mock Get-ChildItem {
            @{
                directory = "c:\thing"
                name = "test.txt"
            }
        }

        it "Should return with SetTest True when DSC Set is Ensure:Present" {
            $DscClass.Set() | should BeNullOrEmpty
        }

        mock Get-ChildItem {throw 'Things'}
        it "Should return with SetTest True when DSC Set is Errored" {
            $DscClass.Set() | should BeNullOrEmpty
        }    

        $DscClass.Ensure = 'Absent'
        it "Should return with SetTest True when DSC Set is executed Ensure:Absent" {
            $DscClass.Set() | should BeNullOrEmpty
        }
        
    }
    
    Context "Check DSC Class SampleFileCheck Test()" {
        $DscClass = New-Object -TypeName SampleFileCheck
        $DscClass.FilePath = 'c:\thing'
        $DscClass.FileName = 'test.txt'
        
        mock Get-ChildItem {Throw 'Fish'}
        
        $DscClass.Ensure = 'Present'
        it "Should return False when Missing and Present" {
            $DscClass.Test() | should Be $False
        }

        $DscClass.Ensure = 'Absent'
        it "Should return True when Missing and Absent" {
            $DscClass.Test() | should Be $True
        }

        mock Get-ChildItem {
            @{
                FullName = "c:\thing\test.txt"
            }
        }

        $DscClass.Ensure = 'Present'
        it "Should return True when Exists and Present" {
            $DscClass.Test() | should Be $True
        }

        $DscClass.Ensure = "Absent"
        it "Should return False when Exists and Absent" {
            $DscClass.Test() | should Be $False
        }

    }
}