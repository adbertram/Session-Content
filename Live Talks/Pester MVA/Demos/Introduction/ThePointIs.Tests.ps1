. "$PSScriptRoot\ThePointIs.ps1"

describe 'Remove-Software' {

    mock 'Start-Process'

    mock 'Remove-Item'

    context 'when -Force is used' {

        mock 'Get-InstalledSoftware' {
            [pscustomobject]@{
                Guid = 'YOURGUIDHERE'
            }
        }

        it 'should remove the expected registry key and a GUID is found' {
        
            Remove-Software -Name 'Foo' -Force

            $assMParams = @{
                CommandName = 'Remove-Item'
                Times = 1
                Exactly = $true
                Scope = 'It'
                ParameterFilter = {$Path -eq "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\YOURGUIDHERE" }
            }
            Assert-MockCalled @assMParams
        }

        mock 'Get-InstalledSoftware' {
            [pscustomobject]@{
                Guid = $null
            }
        }

        it 'should not remove a registry key when and a GUID is not found' {
        
            Remove-Software -Name 'Foo' -Force

            $assMParams = @{
                CommandName = 'Remove-Item'
                Times = 0
                Exactly = $true
                Scope = 'It'
            }
            Assert-MockCalled @assMParams
        }
    }

    ## More tests here
}