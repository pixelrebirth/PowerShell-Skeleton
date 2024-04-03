. "$PSScriptRoot\..\..\Classes\ClassLibrarySample.ps1"

Describe "ClassLibrarySample" {
    Context "InternalClass" {
        it "Should return with propertyname Stuff when Stuff is input to instantiation of object" {
            (New-Object -TypeName InternalClass -ArgumentList "Stuff").PropertyName | should Be "Stuff"
        }
    }

    Context "InternalOtherClass" {
        it "Should return with propertyname Thing when Stuff is input to instantiation of object" {
            (New-Object -TypeName InternalOtherClass -ArgumentList "Stuff").PropertyName | should Be "Thing"
        }
    }
}