## Test the functions
. "$PSScriptRoot\Add-Number.ps1"

describe 'Add-Number' {

    it 'should return 1 plus the Number passed to it' {
        Add-Number -Number 1 | should be 2
    }

    2..10 | foreach {
        it "should return $($_ + 1) given $_" {
            Add-Number -Number $_ | should be ($_ + 1)
        }
    }
}