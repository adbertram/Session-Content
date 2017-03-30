#########################
## Mocking basics
#########################

    function Start-ClusterTest {
        param($Action)

        Write-Host 'Doing the thing...'
        Write-Output "I did the thing $Action!"
    }

    describe 'Start-ClusterTest' { 

        $result = Start-ClusterTest -Action 'Foo'
        
        it 'returns a string with $Action inside' {
            ## I know the input and the output together. It's Foo
            $result | should be 'I did the thing Foo!' 
        }
        
    }

    describe 'Start-ClusterTest' { 

        mock -CommandName 'Write-Output' -MockWith {
            'No you did not'
        }

        $result = Start-ClusterTest -Action 'Foo'
        
        it 'does the thing' {
           $result | should be 'I did the thing Foo!' 
        }
        
    }

#########################
## Mocking 101
#########################

    ## Helper function to Start-ClusterTest
    function Restart-Cluster {
        param($ClusterName)

        ## Do whatever it takes to restart the cluster here
    }
    
    ## Helper function to Start-ClusterTest
    function Test-ClusterProblem {
        param($ClusterName)

        ## Check some stuff here. Return either $true if all checks passed
        ## or false if they did not. For now, we'll just return $true.
        $true
    }

    function Start-ClusterTest {
        param($ClusterName)

        Write-Host 'Starting cluster test...'
        $result = Test-ClusterProblem -ClusterName $ClusterName ## Run another function
        if ($result) {
            $true
        } else {
            Restart-Cluster -ClusterName $ClusterName
        }
    }

    ## Need to run this without actually doing anything. This is a UNIT test.
    ## We need to ensure just to test this code we don't have to have an entire cluster setup.

    ## Test v1
    describe 'Start-ClusterTest' {

        $result = Start-ClusterTest -ClusterName 'DOESNOTMATTER'

        it 'tests the correct cluster' {
            ## Unit tests just ensure code paths are followed. Without mocks there's no way to determine what parameters
            ## are passed to Set-Thing
        }

        it 'when no problems are detected, it should return $true' {
            ## This isn't possible. Test-ClusterProblem is just going to run as usual and we have no way to control what Test-ClusterProblem
            ## actually returns.

            ## $result | should be $true??
        }

        it 'when a problem is detected, it should restart the cluster' {

        }

        it 'does not murder poor, innocent, little puppies' {

            ## How are we supposed to know what Write-Host was used? We can't!
        }

    }

    ## Test v2
    describe 'Start-ClusterTest' {

        ## Create mocks to simply let the function execute and essentially do nothing
        mock 'Write-Host'

        mock 'Test-ClusterProblem' {
            $true
        }

        mock 'Restart-Cluster' ## Null

        $result = Start-ClusterTest -ClusterName 'DOESNOTMATTER'

        ## These it blocks do not depend on a specific scenario and are not in a context block.
        it 'does not murder poor, innocent, little puppies' {

            $assMParams = @{
                CommandName = 'Write-Host'
                Times = 0
                Exactly = $true
            }
            Assert-MockCalled @assMParams

        }

        it 'tests the correct cluster' {

            $assMParams = @{
                CommandName = 'Test-ClusterProblem'
                Times = 1
                Exactly = $true
                ParameterFilter = {
                    $ClusterName -eq 'DOESNOTMATTER'
                }
            }
            Assert-MockCalled @assMParams

        }

        context 'when a problem is detected with a cluster' {
            
            ## This mock overrides Test-ClusterProblem only in this context block. We are ONLY testing the scenario
            ## when there's a problem with the cluster.

            mock 'Test-ClusterProblem' {
                $false
            }

            $result = Start-ClusterTest -ClusterName 'DOESNOTMATTER'

            it 'restarts the cluster' {
                
                $assMParams = @{
                    CommandName = 'Restart-Cluster'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {$ClusterName -eq 'DOESNOTMATTER' }
                }
                Assert-MockCalled @assMParams
            }
        }

        context 'when no problems are detected on the cluster' {
            
            ## Override again to simulate the scenario
             mock 'Test-ClusterProblem' {
                $true
            }  

            $result = Start-ClusterTest -ClusterName 'DOESNOTMATTER'

            it 'should return $true' {
                $result | should be $true
            }
        }
    }