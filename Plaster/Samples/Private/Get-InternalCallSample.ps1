function Get-InternalCallSample {
    param ()
    begin {
        $VariableOne = "Stuff"
    }
    process {
        $VariableTwo = "Thing"
    }
    end {
        return $VariableOne + $VariableTwo
    }
}
