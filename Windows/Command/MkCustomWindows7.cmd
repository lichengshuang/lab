Rem ***************************************************************************
    @Echo Off
    Cls

Rem 作業開始 ******************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    If /I "%OSCDImgRoot%" == "" (
        Echo Windows ADK をインストールして下さい。
        GoTo DONE
    )

    Set CPU_TYP=x64
    Set WIN_TYP=Windows 7 Professional

    If /I "%1" == "x86" ((Set CPU_TYP=%1) & Shift)
    If /I "%1" == "x64" ((Set CPU_TYP=%1) & Shift)

    Set DVD_DRV=D:
Rem Set USB_DRV=E:
    Set WPE_DIR=C:\WinPE
    Set WPE_IMG=%WPE_DIR%\img\%CPU_TYP%
    Set WPE_SRC=%WPE_DIR%\src\%CPU_TYP%
    Set WPE_MNT=%WPE_DIR%\mnt\%CPU_TYP%
    Set WPE_PKG=%WPE_DIR%\pkg\%CPU_TYP%
    Set WPE_BAK=%WPE_DIR%\bak\%CPU_TYP%
    Set WPE_DRV=%WPE_DIR%\pkg\drv
    Set WIM_DVD=%DVD_DRV%\sources\install.wim
    Set WIM_IMG=%WPE_IMG%\sources\install.wim
    Set WIM_SRC=%WPE_SRC%\install.wim
    Set WIM_BAK=%WPE_BAK%\install.wim
    Set DVD_ISO=%WPE_DIR%\windows_7_with_sp1_%CPU_TYP%_dvd_custom.iso

    If /I "%1" == "" (GoTo MAIN)

    If /I "%1" == "COMMIT"  (GoTo COMMIT)
    If /I "%1" == "DISCARD" (GoTo DISCARD)

    If /I "%1" == "1" ((Set WIN_TYP=Windows 7 Starter)      & GoTo MAIN)
    If /I "%1" == "2" ((Set WIN_TYP=Windows 7 HomeBasic)    & GoTo MAIN)
    If /I "%1" == "3" ((Set WIN_TYP=Windows 7 HomePremium)  & GoTo MAIN)
    If /I "%1" == "4" ((Set WIN_TYP=Windows 7 Professional) & GoTo MAIN)
    If /I "%1" == "5" ((Set WIN_TYP=Windows 7 Ultimate)     & GoTo MAIN)

    GoTo ERROR

:MAIN
Rem *** Debug Area ************************************************************
    If /I "%DBG_FLG%" == "DEBUG" (
        Echo CPU_TYP="%CPU_TYP%"
        Echo WIN_TYP="%WIN_TYP%"
        Echo DVD_DRV="%DVD_DRV%"
        Echo USB_DRV="%USB_DRV%"
        Echo WPE_DIR="%WPE_DIR%"
        Echo WPE_IMG="%WPE_IMG%"
        Echo WPE_SRC="%WPE_SRC%"
        Echo WPE_MNT="%WPE_MNT%"
        Echo WPE_PKG="%WPE_PKG%"
        Echo WPE_BAK="%WPE_BAK%"
        Echo WPE_DRV="%WPE_DRV%"
        Echo WIM_DVD="%WIM_DVD%"
        Echo WIM_IMG="%WIM_IMG%"
        Echo WIM_SRC="%WIM_SRC%"
        Echo WIM_BAK="%WIM_BAK%"
        Echo DVD_ISO="%DVD_ISO%"
        GoTo DONE
    )
Rem *** Debug Area ************************************************************

    Echo CPUタイプ="%CPU_TYP%"の"%WIN_TYP%"を処理します。

Rem *** 作業フォルダーの作成 ***************************************************
    Echo *** 作業フォルダーの作成 ******************************************************
    MkDir "%WPE_IMG%" "%WPE_SRC%" "%WPE_MNT%" "%WPE_PKG%" "%WPE_BAK%" > Nul 2>&1
    If Not Exist "%WPE_PKG%\Windows6.1-KB3020369-%CPU_TYP%.msu" (
        Echo 統合するパッケージを"%WPE_PKG%"にコピーして下さい。
        GoTo DONE
    )

    If /I Not Exist "%WPE_PKG%\ie11\IE-Win7.CAB" ("%WPE_PKG%\IE11-Windows6.1-%CPU_TYP%-ja-jp.exe" /X:"%WPE_PKG%\ie11")

    If /I Not Exist "%WPE_PKG%\wua7.6\WUA-Win7SP1.exe"         ("%WPE_PKG%\WindowsUpdateAgent-7.6-%CPU_TYP%.exe" /X:"%WPE_PKG%\wua7.6")
    If /I Not Exist "%WPE_PKG%\wua7.6\WUA-Win7SP1\wusetup.exe" ("%WPE_PKG%\wua7.6\WUA-Win7SP1.exe"               /X:"%WPE_PKG%\wua7.6\WUA-Win7SP1")

Rem *** 原本から作業フォルダーにコピーする *************************************
    Echo *** 原本から作業フォルダーにコピーする ****************************************
    If Not Exist "%WIM_IMG%" (
        If Not Exist "%DVD_DRV%" (
            Echo 統合する%CPU_TYP%版のDVDを"%DVD_DRV%"にセットして下さい。
            GoTo DONE
        )
        Xcopy /Y /E "%DVD_DRV%\*.*" "%WPE_IMG%"
    )

Rem If Not Exist "%WIM_SRC%" (Copy /Y /B "%WIM_IMG%" "%WPE_SRC%")
    If Not Exist "%WIM_BAK%" (Copy /Y /B "%WIM_IMG%" "%WPE_BAK%")

Rem install.wimを初期化する ***************************************************
    RoboCopy "%WPE_BAK%" "%WPE_SRC%" > Nul

Rem *** install.wimをマウントする *********************************************
    Echo *** install.wimをマウントする *************************************************
    Dism /Mount-WIM /WimFile:"%WIM_SRC%" /Name:"%WIN_TYP%" /MountDir:"%WPE_MNT%"

Rem *** パッケージの追加 ******************************************************
    Echo *** パッケージの追加 **********************************************************
Rem == Windows Update Client 7.6.7600.320 =====================================
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\wua7.6\WUA-Win7SP1\WUClient-SelfUpdate-ActiveX.cab"
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\wua7.6\WUA-Win7SP1\WUClient-SelfUpdate-Aux-TopLevel.cab"
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\wua7.6\WUA-Win7SP1\WUClient-SelfUpdate-Core-TopLevel.cab"
Rem == IE11 ===================================================================
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2834140-v2-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2670838-%CPU_TYP%.msu"
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2639308-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2533623-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2731771-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2729094-v2-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2786081-%CPU_TYP%.msu"
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB2888049-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\ie11\IE-Win7.CAB"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\ie11\ielangpack-ja-JP.CAB"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\ie11\IE-Spelling-en.MSU"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\ie11\IE-Hyphenation-en.MSU"
Rem == KB3138612 https://support.microsoft.com/ja-jp/kb/3138612 [Windows 7用更新プログラム]
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3138612-%CPU_TYP%.msu"
Rem == KB3145739 https://support.microsoft.com/ja-jp/kb/3145739 [Windows 7 用セキュリティ更新プログラム]
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3145739-%CPU_TYP%.msu"
Rem == KB3153199 https://support.microsoft.com/ja-jp/kb/3153199 [Windows 7 用セキュリティ更新プログラム]
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3153199-%CPU_TYP%.msu"
Rem == KB3154070 https://support.microsoft.com/ja-jp/kb/3154070 [Internet Explorerの累積的なセキュリティ更新プログラム]
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\IE11-Windows6.1-KB3154070-%CPU_TYP%.msu"
Rem == convenience rollup =====================================================
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3020369-%CPU_TYP%.msu"
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\windows6.1-kb3125574-v4-%CPU_TYP%.msu"
Rem == USB3.0 ドライバー ======================================================
    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_DRV%\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_4.0.4.51\Drivers\Win7\%CPU_TYP%\iusb3xhc.inf"
    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_DRV%\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_4.0.4.51\Drivers\Win7\%CPU_TYP%\iusb3hub.inf"
    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_DRV%\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_4.0.4.51\Drivers\HCSwitch\%CPU_TYP%\iusb3hcs.inf"

Rem *** install.wimをアンマウントする *****************************************
:COMMIT
    Echo *** install.wimを更新してアンマウントする *************************************
    Dism /UnMount-Wim /MountDir:"%WPE_MNT%" /Commit
    GoTo MAKE

:DISCARD
    Echo *** install.wimを破棄してアンマウントする *************************************
    Dism /UnMount-Wim /MountDir:"%WPE_MNT%" /Discard
    GoTo DONE

:MAKE
Rem *** install.wimを最適化する ***********************************************
Rem Echo *** install.wimを最適化する ***************************************************
Rem If Exist "%WIM_IMG%" (Del "%WIM_IMG%")
Rem Imagex /Export "%WIM_SRC%" 1 "%WIM_IMG%"

Rem *** CDイメージを作成する **************************************************
    Echo *** CDイメージを作成する ******************************************************
    Copy /Y /B "%WIM_SRC%" "%WIM_IMG%"
    Dism /Get-ImageInfo /ImageFile:"%WIM_IMG%"
    Oscdimg -m -o -u1 -h -bootdata:2#p0,e,b"%OSCDImgRoot%\etfsboot.com"#pEF,e,b"%OSCDImgRoot%\efisys.bin" "%WPE_IMG%" "%DVD_ISO%"
    GoTo DONE

:ERROR
    Echo MkCustomWindows7.cmd [ x86 ^| x64 ] [  1^～5 ^| COMMIT ^| DISCARD ]
    Echo 1:Windows 7 Starter (32bit版のみ)
    Echo 2:Windows 7 HomeBasic
    Echo 3:Windows 7 HomePremium
    Echo 4:Windows 7 Professional
    Echo 5:Windows 7 Ultimate

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** 作業終了 ******************************************************************
    Echo [Enter]を押下してください。
    Pause > Nul 2>&1
Rem Echo On
Rem
Rem # Memo ********************************************************************
Rem # Windows ADK for Windows 10 バージョン 1511 ==============================
Rem   # 10.1.10586.0 ----------------------------------------------------------
Rem     wget -O "adksetup_10.1.10586.0.exe" "http://download.microsoft.com/download/3/8/B/38BBCA6A-ADC9-4245-BCD8-DAA136F63C8B/adk/adksetup.exe"
Rem   # 10.1.14295.1000 -------------------------------------------------------
Rem     wget -O "adksetup_10.1.14295.1000.exe" "http://download.microsoft.com/download/C/8/4/C84E1024-8994-4D32-9893-FEB3CBA772D1/adk/adksetup.exe"
Rem
Rem # convenience rollup ------------------------------------------------------
Rem   # Update for Windows Server 2008 R2 x64 Edition (KB3020369) ･････････････
Rem     wget "https://download.microsoft.com/download/F/D/3/FD3728D5-0D2F-44A6-B7DA-1215CC0C9B75/Windows6.1-KB3020369-x64.msu"
Rem   # Update for Windows 7 for x64-based Systems (KB3020369) ････････････････
Rem     wget "https://download.microsoft.com/download/5/D/0/5D0821EB-A92D-4CA2-9020-EC41D56B074F/Windows6.1-KB3020369-x64.msu"
Rem   # Update for Windows 7 (KB3020369) ･･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/C/0/8/C0823F43-BFE9-4147-9B0A-35769CBBE6B0/Windows6.1-KB3020369-x86.msu"
Rem   # -----------------------------------------------------------------------
Rem   # Update for Windows Server 2008 R2 x64 Edition (KB3125574) ･････････････
Rem     wget -O "windows6.1-kb3125574-v4-x64.msu" "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
Rem   # Update for Windows 7 for x64-based Systems (KB3125574) ････････････････
Rem     wget -O "windows6.1-kb3125574-v4-x64.msu" "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
Rem   # Update for Windows 7 (KB3125574) ･･････････････････････････････････････
Rem     wget -O "windows6.1-kb3125574-v4-x86.msu" "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu"
Rem
Rem # IE11 ====================================================================
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/D/5/3/D53EB67F-A614-4943-9162-E1479A6D6CB3/IE11-Windows6.1-x86-ja-jp.exe"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/3/F/2/3F2D186B-826D-4F72-8386-91AFCCAED57F/IE11-Windows6.1-x64-ja-jp.exe"
Rem   # KB2834140 https://support.microsoft.com/ja-jp/kb/2834140 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/F/1/4/F1424AD7-F754-4B6E-B0DA-151C7CBAE859/Windows6.1-KB2834140-v2-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/5/A/5/5A548BFE-ADC5-414B-B6BD-E1EC27A8DD80/Windows6.1-KB2834140-v2-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/8/B/E/8BEB6BA4-29DC-434D-914A-0D15CD873D3A/Windows6.1-KB2834140-v2-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem   # KB2670838 https://support.microsoft.com/ja-jp/kb/2670838 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/1/4/9/14936FE9-4D16-4019-A093-5E00182609EB/Windows6.1-KB2670838-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/1/4/9/14936FE9-4D16-4019-A093-5E00182609EB/Windows6.1-KB2670838-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem   # KB2639308 https://support.microsoft.com/ja-jp/kb/2639308 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/3/1/D/31DB4F4F-207D-416E-9A07-FBD9E431F9FB/Windows6.1-KB2639308-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/9/1/C/91CC3B0D-F58B-4B36-941D-D810A8FF6805/Windows6.1-KB2639308-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/7/A/F/7AFDD2C2-EC5B-469D-B5A0-E91CE96A6CB7/Windows6.1-KB2639308-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/A/B/5/AB5DC786-960F-43DF-87A6-3B28CCFBB690/Windows6.1-KB2639308-ia64.msu"
Rem   # KB2533623 https://support.microsoft.com/ja-jp/kb/2533623 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/2/D/7/2D78D0DD-2802-41F5-88D6-DC1D559F206D/Windows6.1-KB2533623-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/F/1/0/F106E158-89A1-41E3-A9B5-32FEB2A99A0B/Windows6.1-KB2533623-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/0/B/D/0BD4C49B-92F8-4BD3-A835-8E8A8CDA2A30/Windows6.1-KB2533623-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/C/9/5/C95DA212-18C0-4359-8077-28547770C432/Windows6.1-KB2533623-ia64.msu"
Rem   # KB2731771 https://support.microsoft.com/ja-jp/kb/2731771 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/A/0/B/A0BA0A59-1F11-4736-91C0-DFCB06224D99/Windows6.1-KB2731771-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/9/F/E/9FE868F6-A0E1-4F46-96E5-87D7B6573356/Windows6.1-KB2731771-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/9/C/C/9CC1082A-EB58-437A-BA11-C295129E0144/Windows6.1-KB2731771-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/0/D/8/0D83188A-8425-4DF6-8B22-3DBF0980CC9C/Windows6.1-KB2731771-ia64.msu"
Rem   # KB2729094 https://support.microsoft.com/ja-jp/kb/2729094 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/B/6/B/B6BF1D9B-2568-406B-88E8-E4A218DEA90A/Windows6.1-KB2729094-v2-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/6/C/A/6CA15546-A46C-4333-B405-AB18785ABB66/Windows6.1-KB2729094-v2-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/D/9/A/D9ABBEFB-A8F2-4D00-AB4C-4455526A85B6/Windows6.1-KB2729094-v2-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/6/1/F/61F9FDBA-F592-4B6A-BF7F-A5E921F54F39/Windows6.1-KB2729094-v2-ia64.msu"
Rem   # KB2786081 https://support.microsoft.com/ja-jp/kb/2786081 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/4/8/1/481C640E-D3EE-4ADC-AA48-6D0ED2869D37/Windows6.1-KB2786081-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/1/8/F/18F9AE2C-4A10-417A-8408-C205420C22C3/Windows6.1-KB2786081-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/D/2/3/D233411A-945B-4E03-8F65-C200A40A245A/Windows6.1-KB2786081-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/A/9/E/A9ED4409-F67D-44E6-A47E-BB97364B8394/Windows6.1-KB2786081-ia64.msu"
Rem   # KB2888049 https://support.microsoft.com/ja-jp/kb/2888049 --------------
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/3/9/D/39D85CA8-7BF3-47C1-9031-FD6E51D8BBEB/Windows6.1-KB2888049-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/4/1/3/41321D2E-2D08-4699-A635-D9828AADB177/Windows6.1-KB2888049-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/0/5/3/053E30EF-868E-47B0-B9BC-276916F64341/Windows6.1-KB2888049-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/E/9/D/E9DA3C98-564B-463C-91F6-52165610F111/Windows6.1-KB2888049-ia64.msu"
Rem
Rem # =========================================================================
Rem   # KB3138612 https://support.microsoft.com/ja-jp/kb/3138612 -------------- Windows 7用更新プログラム
Rem     # x86 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem       wget "https://download.microsoft.com/download/E/4/7/E47FB37E-7443-4047-91F7-16DDDCF2955C/Windows6.1-KB3138612-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem       wget "https://download.microsoft.com/download/B/7/C/B7CD3A70-1EA7-486A-9585-F6814663F1A9/Windows6.1-KB3138612-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem       wget "https://download.microsoft.com/download/E/1/4/E1454DBC-813E-4EBF-AE66-1736D562ACB9/Windows6.1-KB3138612-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem       wget "https://download.microsoft.com/download/C/C/7/CC7C3DBA-4E6A-4FEF-A733-4E5EACB906E7/Windows6.1-KB3138612-ia64.msu"
Rem   # KB3148198 https://support.microsoft.com/ja-jp/kb/3148198 -------------- Internet Explorerの累積的なセキュリティ更新プログラム
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/6/1/4/614DD441-3821-45C9-8082-C315602CE339/IE11-Windows6.1-KB3148198-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/0/6/6/0669BA26-E09C-4F1F-B3D7-3ED82B44AB78/IE11-Windows6.1-KB3148198-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/2/A/4/2A40DCCC-76E2-477D-B4D4-F4E74B081A58/IE11-Windows6.1-KB3148198-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem # =========================================================================
Rem   # KB976932  https://support.microsoft.com/ja-jp/kb/976932 --------------- Windows 7 および Windows Server 2008 R2 Service Pack 1
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X86.exe"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-X64.exe"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/windows6.1-KB976932-IA64.exe"
Rem # =========================================================================
Rem   # KB3154070 https://support.microsoft.com/ja-jp/kb/3154070 -------------- Windows 7 用 Internet Explorer 11 の累積的なセキュリティ更新プログラム 
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/B/E/4/BE43169A-901F-4F1D-BEE2-F243DC04C0C6/IE11-Windows6.1-KB3154070-x86.msu"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/9/A/4/9A41A90C-BB55-4C39-8AE5-5288DF0BDF11/IE11-Windows6.1-KB3154070-x64.msu"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/F/8/3/F83E7679-110A-400F-8175-E64458247462/IE11-Windows6.1-KB3154070-x64.msu"
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem # =========================================================================
Rem   # KB2538243 https://support.microsoft.com/ja-jp/kb/2538243 -------------- Microsoft Visual C++ 2008 Service Pack 1 再頒布可能パッケージ 
Rem     # x86 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"
Rem     # x64 ベース バージョンの Windows 7 ･･･････････････････････････････････
Rem       wget "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"
Rem     # x64 ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget ""
Rem     #  IA ベース バージョンの Windows Server 2008 R2 ･･････････････････････
Rem       wget "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_IA64.exe"
Rem
Rem # USB3.0 ドライバー =======================================================
Rem   wget "https://downloadmirror.intel.com/22824/eng/Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_4.0.4.51.zip"
Rem
Rem # Windows 7 および Windows Server 2008 R2 用 Windows Update クライアント: 2016 年 3 月
Rem   # x86 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/E/4/7/E47FB37E-7443-4047-91F7-16DDDCF2955C/Windows6.1-KB3138612-x86.msu"
Rem   # x64 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/B/7/C/B7CD3A70-1EA7-486A-9585-F6814663F1A9/Windows6.1-KB3138612-x64.msu"
Rem   # x64 ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem     wget "https://download.microsoft.com/download/E/1/4/E1454DBC-813E-4EBF-AE66-1736D562ACB9/Windows6.1-KB3138612-x64.msu"
Rem   #  IA ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem     wget "https://download.microsoft.com/download/C/C/7/CC7C3DBA-4E6A-4FEF-A733-4E5EACB906E7/Windows6.1-KB3138612-ia64.msu"
Rem # [MS16-039] Windows Graphics コンポーネントのセキュリティ更新プログラムについて (2016 年 4 月 12 日)
Rem   # x86 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/C/E/9/CE982A9D-C4C4-4355-B87A-1A72CCD0CC73/Windows6.1-KB3145739-x86.msu"
Rem   # x64 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/8/D/7/8D75A16B-5BC0-457A-BE97-A93566AB82D6/Windows6.1-KB3145739-x64.msu"
Rem   # x64 ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem     wget "https://download.microsoft.com/download/E/9/9/E99EBB28-1F55-4EB7-9A28-2F615BC3CB4E/Windows6.1-KB3145739-x64.msu"
Rem   #  IA ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem     wget "https://download.microsoft.com/download/9/2/1/9219A26D-982C-4596-BA7E-E0593B8D1509/Windows6.1-KB3145739-ia64.msu"
Rem # [MS16-062] Windows カーネルモード ドライバー用のセキュリティ更新プログラムについて (2016 年 5 月 10 日)
Rem   # x86 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/4/1/A/41A646DA-0E13-4881-A9F5-C1C2D7A3CAD1/Windows6.1-KB3153199-x86.msu"
Rem   # x64 ベース バージョンの Windows 7 ･････････････････････････････････････
Rem     wget "https://download.microsoft.com/download/0/4/B/04BA1FE5-75FC-431C-AF35-13182082EFF7/Windows6.1-KB3153199-x64.msu"
Rem   # x64 ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem     wget "https://download.microsoft.com/download/3/D/5/3D59E4C9-8C4D-4386-83DC-835AB7328BD6/Windows6.1-KB3153199-x64.msu"
Rem   #  IA ベース バージョンの Windows Server 2008 R2 ････････････････････････
Rem     wget "https://download.microsoft.com/download/F/C/6/FC62C159-AB7F-4662-90EF-5ADB0AE1A3ED/Windows6.1-KB3153199-ia64.msu"
Rem # =========================================================================
Rem # wmic qfe
Rem # *************************************************************************
    Echo On
