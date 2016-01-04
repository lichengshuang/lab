@   echo off
rem ***************************************************************************
rem Factory Images "razorg" for Nexus 7 [2013] (Mobile)
rem ***************************************************************************
    setlocal

rem -- 6.0.0 (MRA58K) ---------------------------------------------------------
    set     update=image-razorg-mra58v
    set bootloader=bootloader-deb-flo-04.05.img
    set      radio=radio-deb-deb-z00_2.44.0_0213.img

rem ---------------------------------------------------------------------------
    set    archive=%update%.zip
rem -- sdk --------------------------------------------------------------------
    set path="%ProgramFiles%\Java\jdk1.8.0_65\bin";%path%
    set path="%ProgramFiles(x86)%\Android\android-sdk\tools";%path%
    set path="%ProgramFiles(x86)%\Android\android-sdk\platform-tools";%path%
rem -- unlock -----------------------------------------------------------------
    fastboot oem unlock
rem -- bootloader -------------------------------------------------------------
    fastboot flash bootloader %bootloader%
    fastboot reboot-bootloader

    ping -n 5 127.0.0.1 >nul
rem -- radio ------------------------------------------------------------------
    fastboot flash radio %radio%
    fastboot reboot-bootloader

    ping -n 5 127.0.0.1 >nul
rem -- boot/cache/recovery/system/userdata ------------------------------------
    fastboot format cache
    fastboot format system
    fastboot format userdata

rem fastboot -w update %archive%

    fastboot flash boot     %update%\boot.img
    fastboot flash cache    %update%\cache.img
    fastboot flash recovery %update%\recovery.img
    fastboot flash system   %update%\system.img
    fastboot flash userdata %update%\userdata.img

    fastboot reboot-bootloader

    ping -n 5 127.0.0.1 >nul
rem -- lock -------------------------------------------------------------------
    fastboot oem lock
rem ---------------------------------------------------------------------------
    echo Press any key to exit...
    pause >nul
rem exit
rem End Of File ---------------------------------------------------------------
