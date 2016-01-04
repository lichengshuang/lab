@   echo off

    setlocal
    set path=%ProgramFiles%\Android\android-sdk\tools;%path%
    set path=%ProgramFiles%\Android\android-sdk\platform-tools;%path%

    if "%1" == "lock" (
rem     adb reboot bootloader
        fastboot oem lock
        goto End:
    )

    if "%1" == "unlock" (
rem     adb reboot bootloader
        fastboot oem unlock
        goto End:
    )

    echo locker.cmd [lock] or [unlock]

:End
    echo Press any key to exit...
    pause >nul
rem exit
