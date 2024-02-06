Write-Host "Setting up environment..."
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        Write-Host "Asking UAC for administrator privileges..."
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

if (!($env:CI -eq "true")) {
    if (!(Test-Connection github.com -Quiet -Count 2)) {
        Write-Host "Please connect to the Internet."
        Exit
    }
}

if (!(Test-Path "Win10.iso")) {
    Write-Host "Windows 10 ISO not found. Downloading one..."
    .\aria2\aria2c.exe "https://archive.org/download/win-10-full-collection/windows 10 ISOs/Win10_22H2_English_x64.iso" -o "Win10.iso" -x16 -s16
}
if (!(Test-Path "Win11.iso")) {
    Write-Host "Windows 11 ISO not found. Downloading one..."
    .\aria2\aria2c.exe "https://archive.org/download/windows-11-23h2-english-x-64_202312/Win11_23H2_English_x64.iso" -o "Win11.iso" -x16 -s16
}

$currentDate = Get-Date -Format "yy-MM-dd"

if (Test-Path "DVD") {
    Write-Host "Deleting DVD folder..."
    Remove-Item DVD -Recurse -Force
}

if (Test-Path "Win11") {
    Write-Host "Deleting Win11 folder..."
    Remove-Item Win11 -Recurse -Force
}

Write-Host "Extracting ISO..."

.\7z.exe x Win10.iso -oDVD
.\7z.exe x Win11.iso -oWin11

Write-Host "Patching..."
If (Test-Path .\Win11\sources\install.esd) {
    if (Test-Path .\DVD\sources\install.esd) {
        Remove-Item .\DVD\sources\install.esd -Force
    }
    if (Test-Path .\DVD\sources\install.wim) {
        Remove-Item .\DVD\sources\install.wim -Force
    }
    Copy-Item .\Win11\sources\install.esd .\DVD\sources\install.esd -Force
}

If (Test-Path .\Win11\sources\install.wim) {
    if (Test-Path .\DVD\sources\install.esd) {
        Remove-Item .\DVD\sources\install.esd -Force
    }
    if (Test-Path .\DVD\sources\install.wim) {
        Remove-Item .\DVD\sources\install.wim -Force
    }
    Copy-Item .\Win11\sources\install.wim .\DVD\sources\install.wim -Force
}

if (Test-Path .\EI.CFG) {
    Write-Host "Adding patch to bypass default windows edition and product key request..."
    if (Test-Path .\DVD\sources\EI.CFG) {
        Remove-Item .\DVD\sources\EI.CFG -Force
    }
    Copy-Item .\EI.CFG .\DVD\sources\EI.CFG -Force
}

Write-Host "Creating ISO..."

$isoName = "Bypass11_build_$currentDate.iso"

cmd.exe /c "oscdimg.exe -h -m -o -u2 -udfver102 -bootdata:2#p0,e,bDVD\boot\etfsboot.com#pEF,e,bDVD\efi\microsoft\boot\efisys.bin -lBypass11 DVD $isoName"

if (Test-Path $isoName) {
    $hash = (Get-FileHash $isoName -Algorithm SHA256).Hash.ToLower()
    Write-Host "Checksum is $hash (SHA256)."
    Set-Content -Path ($isoName + ".sha256") -Value $hash -Encoding Ascii
    Write-Host "Saved checksum."
}

Write-Host "Cleaning up..."
Remove-Item Win11 -Recurse -Force
Remove-Item DVD -Recurse -Force