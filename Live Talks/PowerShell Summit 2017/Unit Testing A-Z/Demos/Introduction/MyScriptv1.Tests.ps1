## Everything you need to create a test script
describe 'MyScript Tests' {

    context 'optional context to separate out tests' {
        
        it 'should return 1 plus the Number passed to it' {
            & "$PSScriptRoot\MyScriptv1.ps1" -Number 1 | should be 2
        }

        2..10 | foreach {
            it "should return $($_ + 1) given $_" {
                & "$PSScriptRoot\MyScriptv1.ps1" -Number $_ | should be ($_ + 1)
            }
        }
    }
}