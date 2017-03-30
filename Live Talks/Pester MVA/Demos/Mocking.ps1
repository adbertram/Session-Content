#########################
## Mocking basics
#########################

    function Do-Thing {
        param($Action)

        Write-Host 'Doing the thing...'
        Write-Output "I did the thing $Action!"
    }

    describe 'Do-Thing' { 
        
        it 'does the thing' {
            ## I know the input and the output together. It's Foo
            Do-Thing -Action 'Foo' | should be 'I did the thing Foo!' 
        }
        
    }

    describe 'Do-Thing' { 

        mock 'Write-Output' {
            'No you did not'
        }
        
        it 'does the thing' {
            Do-Thing -Action 'Foo' | should be 'I did the thing Foo.' 
        }
        
    }

#########################
## Mocking 101
#########################
    function Set-Thing {
        param($Attribute)

        if ($Attribute -eq 'Foo') {
            $true
        } else {
            $false
        }
    }

    function Do-Thing {
        param($Action)

        Write-Host 'Setting the thing...'
        $result = Set-Thing -Attribute $Action
        if ($result -eq 'Success') {
            $true
        } else {
            $false
        }
    }

    ## Need to run this without actually doing anything. This is a UNIT test.
    ## Set-Thing may modify a file, reg key, VM, whatever. It just does SOMETHING to the environment
    ## We need to prevent this and setup a way to ensure Set-Thing is called correctly and so we can control it's output

    ## Test v1
    describe 'Do-Thing' {

        $result = Do-Thing -Action 'Foo'

        it 'passes the right parameter to Set-Thing' {
            ## Unit tests just ensure code paths are followed. Without mocks there's no way to determine what parameters
            ## are passed to Set-Thing
        }

        it 'returns $true if Set-Thing was successful' {
            ## This isn't possible. Do-Thing is just going to run as usual and we have no way to control what Set-Thing
            ## actually returns.

            ## $result | should be $true??
        }

        it 'returns $false if Set-Thing was not successful' {
            ## This isn't possible. Do-Thing is just going to run as usual and we have no way to control what Set-Thing
            ## actually returns.

            ## $result | should be $false??
        }

        it 'does not murder poor, innocent, little puppies' {

            ## How are we supposed to know what Write-Host was used? We can't!
        }

    }

    ## Test v2
    describe 'Do-Thing' {

        mock 'Write-Host'

        $result = Do-Thing -Action 'Foo'

        it 'does not murder poor, innocent, little puppies' {

            $assMParams = @{
                CommandName = 'Write-Host'
                Times = 0
                Exactly = $true
            }
            Assert-MockCalled @assMParams

        }

        context 'Set-Thing returns $true' {
            mock 'Set-Thing' {
                $true
            }

            $result = Do-Thing -Action 'Foo'

            it 'passes the right parameter to Set-Thing' {
                
                $assMParams = @{
                    CommandName = 'Set-Thing'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {$Attribute -eq 'Foo' }
                }
                Assert-MockCalled @assMParams
            }

            it 'returns $true if Set-Thing was successful' {
            
                $result | should be $true

            }
        }

        context 'Set-Thing returns $false' {
            
            mock 'Set-Thing' {
                $false
            }   

            $result = Do-Thing -Action 'Foo'

            it 'returns $false if Set-Thing was not successful' {
                $result | should be $false
            }
        }
    }