$source = "c:\ConfigMgr 2012 R2 CU4 client"
$comps = "machine01","machine02"
#$comps = get-content \\mymachine\shared\scripts\sccm\ClientPush\computers.txt
$workdir = "c:\temp\ConfigMgr2012R2CU4"

workflow ClientPush {
    foreach ($comp in $comps) {
        if (Test-Connection $comp -count 1) {
            inlinescript {
                write-output "$comp is online!" 
                $dest = "\\$comp\c$\temp\ConfigMgr2012R2CU4"
                copy-item $source -destination $dest -recurse
                copy-item '\\mymachine\shared\sccm\SMS 2003 Toolkit 2\ccmclean.exe' -Destination "\\$comp\c$\temp"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp net stop ccmexec"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp net stop iphlpsvc"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp net stop wscsvc"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp net stop winmgmt"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp winmgmt /resetrepository"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp taskkill.exe /im /f ccmsetup.exe"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp c:\temp\ccmclean.exe"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp rd /s /q c:\windows\ccmsetup"
                start-process -Wait -PSPath 'c:\PsExec.Exe' -ArgumentList "\\$comp c:\temp\ConfigMgr2012R2CU4\ccmsetup.exe /UsePKICert /NoCRLCheck SMSSITECODE=AUTO SMSCACHESIZE=52400 /mp:prisiteserver.domain.com /noservice /forceinstall"
            }
        } else {
            write-error "$comp is Offline!"
        }
    }
}

ClientPush