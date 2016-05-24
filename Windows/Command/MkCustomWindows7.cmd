Rem ***************************************************************************
    @Echo Off
    Cls

Rem 作業開始 ******************************************************************
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    If /I "%1" == "" (
        Set CPU_TYP=x64
    ) Else If /I "%1" == "x86" (
        Set CPU_TYP=%1
    ) Else If /I "%1" == "x64" (
        Set CPU_TYP=x64
    ) Else (
        Echo MkCustomWindows7.cmd [ x86 ^| x64 ] [ COMMIT ^| DISCARD ]
        GoTo DONE
    )

    Set DVD_DRV=D:
Rem Set USB_DRV=E:
    Set WPE_DIR=C:\WinPE
    Set WPE_IMG=%WPE_DIR%\img\%CPU_TYP%
    Set WPE_SRC=%WPE_DIR%\src\%CPU_TYP%
    Set WPE_MNT=%WPE_DIR%\mnt\%CPU_TYP%
    Set WPE_PKG=%WPE_DIR%\pkg\%CPU_TYP%
    Set WPE_BAK=%WPE_DIR%\bak\%CPU_TYP%
    Set WIM_DVD=%DVD_DRV%\sources\install.wim
    Set WIM_IMG=%WPE_IMG%\sources\install.wim
    Set WIM_SRC=%WPE_SRC%\install.wim
    Set WIM_BAK=%WPE_BAK%\install.wim
    Set DVD_ISO=%WPE_DIR%\windows_7_with_sp1_%CPU_TYP%_dvd_custom.iso

    If /I "%OSCDImgRoot%" == "" (
        Echo Windows ADK をインストールして下さい。
        GoTo DONE
    )

    If /I "%2" == "COMMIT"  GoTo COMMIT
    If /I "%2" == "DISCARD" GoTo DISCARD

:START
Rem *** 作業フォルダーの作成 ***************************************************
    Echo *** 作業フォルダーの作成 ******************************************************
    MkDir "%WPE_IMG%" "%WPE_SRC%" "%WPE_MNT%" "%WPE_PKG%" "%WPE_BAK%" > Nul 2>&1
    If Not Exist "%WPE_PKG%\WindowsUpdateAgent-7.6-%CPU_TYP%.exe" (
        Echo 統合するパッケージを"%WPE_PKG%"にコピーして下さい。
        GoTo DONE
    )

Rem *** 原本から作業フォルダーにコピーする *************************************
    Echo *** 原本から作業フォルダーにコピーする ****************************************
    If Not Exist "%WIM_IMG%" (
        If Not Exist "%DVD_DRV%" (
            Echo 統合する%CPU_TYP%版のDVDを"%DVD_DRV%"にセットして下さい。
            GoTo DONE
        )
        Xcopy /Y /E "%DVD_DRV%\*.*" "%WPE_IMG%"
    )
    If Not Exist "%WIM_SRC%" (Copy /Y /B "%WIM_IMG%" "%WPE_SRC%")
    If Not Exist "%WIM_BAK%" (Copy /Y /B "%WIM_IMG%" "%WPE_BAK%")

Rem *** install.wimをマウントする *********************************************
    Echo *** install.wimをマウントする *************************************************
Rem Dism /Mount-WIM /WimFile:"%WIM_SRC%" /Name:"Windows 7 HomeBasic"    /MountDir:"%WPE_MNT%"
Rem Dism /Mount-WIM /WimFile:"%WIM_SRC%" /Name:"Windows 7 HomePremium"  /MountDir:"%WPE_MNT%"
    Dism /Mount-WIM /WimFile:"%WIM_SRC%" /Name:"Windows 7 Professional" /MountDir:"%WPE_MNT%"
Rem Dism /Mount-WIM /WimFile:"%WIM_SRC%" /Name:"Windows 7 Ultimate"     /MountDir:"%WPE_MNT%"

Rem *** パッケージの追加 ******************************************************
    Echo *** パッケージの追加 **********************************************************
    If /I "%CPU_TYP%" == "x86" (
Rem     Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\WindowsUpdateAgent-7.6-x86.exe"
Rem     Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\IE11-Windows6.1-x86-ja-jp.exe"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3138612-x86.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3145739-x86.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3153199-x86.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3020369-x86.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu"
    ) Else (
Rem     Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\WindowsUpdateAgent-7.6-x64.exe"
Rem     Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\IE11-Windows6.1-x64-ja-jp.exe"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3138612-x64.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3145739-x64.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3153199-x64.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\Windows6.1-KB3020369-x64.msu"
        Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_PKG%\windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    )

:COMMIT
Rem *** install.wimをアンマウントする *****************************************
    Echo *** install.wimを更新してアンマウントする *************************************
    Dism /UnMount-Wim /MountDir:"%WPE_MNT%" /Commit
    GoTo MAKE

:DISCARD
    Echo *** install.wimを破棄してアンマウントする *************************************
    Dism /UnMount-Wim /MountDir:"%WPE_MNT%" /Discard
    GoTo DONE

:MAKE
    Copy /Y /B "%WIM_SRC%" "%WIM_IMG%"
    Oscdimg -m -o -nt -h -bootdata:2#p0,e,b"%OSCDImgRoot%\etfsboot.com"#pEF,e,b"%OSCDImgRoot%\efisys.bin" "%WPE_IMG%" "%DVD_ISO%"

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** 作業終了 ******************************************************************
    Echo [Enter]を押下してください。
    Pause > Nul 2>&1
Rem Echo On
Rem
Rem Memo **********************************************************************
Rem # Windows ADK for Windows 10 バージョン 1511 ==============================
Rem   # 10.1.10586.0 ----------------------------------------------------------
Rem     wget "http://download.microsoft.com/download/3/8/B/38BBCA6A-ADC9-4245-BCD8-DAA136F63C8B/adk/adksetup.exe"
Rem   # 10.1.14295.1000 -------------------------------------------------------
Rem     wget "http://download.microsoft.com/download/C/8/4/C84E1024-8994-4D32-9893-FEB3CBA772D1/adk/adksetup.exe"
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
Rem     wget "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
Rem   # Update for Windows 7 for x64-based Systems (KB3125574) ････････････････
Rem     wget "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
Rem   # Update for Windows 7 (KB3125574) ･･････････････････････････････････････
Rem     wget "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu"
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
Rem ===========================================================================
Rem wmic qfe
Rem ***************************************************************************
    Echo On
