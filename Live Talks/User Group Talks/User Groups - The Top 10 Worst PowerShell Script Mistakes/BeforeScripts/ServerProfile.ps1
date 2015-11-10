function configmgr {
    $startpath = "$env:appdata\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu"

    $scpath = "C:\windows\system32"
    $scfile = "cmd.exe"

    $shell = new-object -comobject "Shell.Application"  
    $folder = $shell.Namespace($scpath)    
    $item = $folder.Parsename($scfile)
    $verb = $item.Verbs() | Where-Object {$_.Name -eq 'Pin to Start Men&u'}
    if ($verb) {
        $verb.DoIt()
    }

    start-sleep -seconds 2
    rename-item "$startpath\Windows Command Processor.lnk" -NewName "Configuration Manager.lnk"

    $shell2 = new-object -comobject "Wscript.shell"
    $shortcut = $shell2.CreateShortcut("$startpath\Configuration Manager.lnk") 
    $shortcut.TargetPath = "c:\windows\system32\control.exe"
    $shortcut.arguments = "smscfgrc"
    $shortcut.iconlocation = "c:\windows\ccm\smscfgrc.cpl,0"
    $shortcut.workingdirectory = "c:\windows\ccm"
    $shortcut.Save()
}

function softcenter {
    $startpath1 = "$env:appdata\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu"

    $scpath1 = "C:\windows\ccm"
    $scfile1 = "SCClient.exe"

    $shell1 = new-object -comobject "Shell.Application"  
    $folder1 = $shell1.Namespace($scpath1)    
    $item1 = $folder1.Parsename($scfile1)
    $verb1 = $item1.Verbs() | Where-Object {$_.Name -eq 'Pin to Start Men&u'}
    if ($verb1) {
        $verb1.DoIt()
    }
    start-sleep -seconds 2
    rename-item $startpath1\SCClient.lnk -NewName "Software Center.lnk"
}

function bgcolor {
    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value ""
    Set-ItemProperty -path 'HKCU:\Control Panel\Colors\' -name Background -value "153 217 234"
    rundll32.exe user32.dll, UpdatePerUserSystemParameters
}

function taskbar {
    Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -name TaskbarGlomLevel -value 00000002
    Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\' -name EnableAutoTray -value 00000000
}

configmgr
start-sleep -seconds 3
softcenter
bgcolor
taskbar

Stop-Process -Name explorer -Force