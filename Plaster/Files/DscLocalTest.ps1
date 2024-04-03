Configuration LocalTest {
    Import-DscResource -ModuleName <%= $PLASTER_PARAM_ModuleName %>

    Node localhost {
        SampleFileCheck file {
            FileName = "Blah.txt"
            FilePath = "c:\temp"
            Ensure = "Present"
        }
    }
}
LocalTest
Start-DscConfiguration LocalTest -Wait -Force -Verbose