class InternalClass {
    $PropertyName

    InternalClass ($Variable){
        $this.PropertyName = $Variable
    }
}


class InternalOtherClass {
    $PropertyName

    InternalOtherClass ($Variable){
        $this.PropertyName = $Variable.replace("Stuff","Thing")
    }
}