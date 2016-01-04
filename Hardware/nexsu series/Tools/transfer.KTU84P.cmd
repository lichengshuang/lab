@   echo off
rem ***************************************************************************
rem Factory Images "razorg" for Nexus 7 [2013] (Mobile)
rem ***************************************************************************
    setlocal

rem -- 4.4.4 (KTU84P) ---------------------------------------------------------
    set     update=image-razorg-ktu84p
    set bootloader=bootloader-deb-flo-04.02.img
    set      radio=radio-deb-deb-z00_2.42.0_1204.img

rem -- 5.0.2 (LRX22G) ---------------------------------------------------------
rem set     update=image-razorg-lrx22g
rem set bootloader=bootloader-deb-flo-04.04.img
rem set      radio=radio-deb-deb-z00_2.43.0_1001.img

rem ---------------------------------------------------------------------------
    set    archive=%update%.zip
rem -- sdk --------------------------------------------------------------------
    set path="%ProgramFiles%\Java\jdk1.8.0_31\bin";%path%
    set path="%ProgramFiles%\Android\android-sdk\tools";%path%
    set path="%ProgramFiles%\Android\android-sdk\platform-tools";%path%
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
rem fastboot format cache
rem fastboot format system
rem fastboot format userdata

    fastboot -w update %archive%

rem fastboot flash boot     %update%\boot.img
rem fastboot flash cache    %update%\cache.img
rem fastboot flash recovery %update%\recovery.img
rem fastboot flash system   %update%\system.img
rem fastboot flash userdata %update%\userdata.img

    fastboot reboot-bootloader

    ping -n 5 127.0.0.1 >nul
rem -- lock -------------------------------------------------------------------
    fastboot oem lock
rem ---------------------------------------------------------------------------
    echo Press any key to exit...
    pause >nul
rem exit
rem End Of File ---------------------------------------------------------------
