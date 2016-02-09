Import-Module C:\MyDeployment\SoftwareInstallManager.psm1 -DisableNameChecking
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

if (Test-InstalledSoftware -Name 'Adobe Flash Player 10 Plugin' -Version '10.1.53.64') {
    Start-Process -FilePath "$WorkingDir\install_flash_player_10.1_non-ie.exe" -ArgumentList "-uninstall" -Wait -NoNewWindow
    if (-not (Test-InstalledSoftware -Name 'Adobe Flash Player 10 Plugin' -Version '10.1.53.64')) {
        Write-Log -Message 'Adobe Flash Player 10 has been uninstalled. Cleaning up.'
        if ((Get-Architecture) -eq 'x64') {
            $FlashFolderPath = "$($env:SystemDrive)\Windows\SysWow64\MacroMed\Flash"
        } else {
            $FlashFolderPath = "$($env:SystemDrive)\Windows\System32\MacroMed\Flash"
        }

        if ((Get-OperatingSystem) -like '*XP*') {
            $AppDataFolderPath = 'Application Data'
        } else {
            $AppDataFolderPath = 'AppData\Roaming'
        }

        Remove-Item $FlashFolderPath -Recurse -Force -ErrorAction SilentlyContinue
        Get-UserProfilePath  | foreach {
            Remove-Item "$($_)\$AppDataFolderPath\Adobe\Flash Player" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "$($_)\$AppDataFolderPath\Macromedia\Flash Player" -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Log -Message 'Cleanup complete.'
    } else {
        Write-Log -Message 'Adobe Flash Player 10 has failed to uninstall' -LogLevel 3
    }
} else {
    Write-Log -Message 'Adobe Flash Player 10 is not installed'
}
