# Bypass11
Automatic generator of a Windows 11 ISO which bypasses its requirements

## How to use
1. Download a Windows 10 and Windows 11 ISO. Their versions should match for better compatibility
2. Download the [files](https://github.com/usefulstuffs/Bypass11/archive/refs/heads/master.zip) and extract them in a directory (Called here `C:\Bypass11` for ease)
3. Place the Windows 10 ISO to `C:\Bypass11\Win10.iso` and the Windows 11 ISO to `C:\Bypass11\Win10.iso`
4. Open a powershell
5. Type `C:\Bypass11\build.ps1 -ExecutionPolicy Bypass` and press enter/return
6. Wait until the script finishes
7. In that folder you should have the ISO with its hash file (`Bypass11_build_date.iso` and `Bypass11_build_date.iso.sha256`)
8. Burn a DVD/Make an USB with the ISO/Open the ISO and enjoy!

## Credits
Igor Pavlov - 7-Zip

Microsoft - oscdimg.exe

## Support me
I spent almost a day on this script to get it working properly. If you want to support me, please advertise this script or star the repository.
Thank You :)
