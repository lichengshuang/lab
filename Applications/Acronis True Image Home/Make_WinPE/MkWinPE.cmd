Rem ***************************************************************************
Rem *** Windows PE��ATI2016[amd64] (VMware Workstation 12�Ή�)              ***
Rem ***************************************************************************

    @Echo Off
    Cls

Rem ��ƊJ�n ******************************************************************
    SetLocal EnableDelayedExpansion

Rem Set CPU_TYP=x86
    Set CPU_TYP=amd64
    Set WPE_DIR=C:\WinPE
    Set WPE_SRC=%USERPROFILE%\Desktop\AcronisBootablePEMedia.wim
    Set WPE_DST=%WPE_DIR%\%CPU_TYP%
    Set DVD_DST=%WPE_DIR%\WinPE_ATI2016.iso
    Set USB_DST=E:
    Set XFR_DIR=\\vmware-host\Shared Folders\Share\My Documents\Backup\ati

    Echo *******************************************************************************
    Echo *** Windows PE��ATI2016[%CPU_TYP%] (VMware Workstation 12�Ή�)                  ***
    Echo *******************************************************************************
    Echo .
    Echo *** ��ƊJ�n ******************************************************************
    Echo %DATE% %TIME%

:START
Rem *** ��ƃt�H���_�[�̍쐬 ***************************************************
    Echo *** ��ƃt�H���_�[�̍쐬 ******************************************************
    Pushd "%SystemDrive%\"
    If Exist "%WPE_DST%" RmDir /S /Q "%WPE_DST%"
    Call CopyPE %CPU_TYP% "%WPE_DST%"

Rem *** ���{�����ƃt�H���_�[�ɃR�s�[���� *************************************
    Echo *** ���{�����ƃt�H���_�[�ɃR�s�[���� ****************************************
    ReName "%WPE_DST%\media\sources\boot.wim" "boot.wim.orig"
    Copy /B "%WPE_SRC%" "%WPE_DST%\media\sources\boot.wim"

Rem *** boot.wim���}�E���g���� ************************************************
    Echo *** boot.wim���}�E���g���� ****************************************************
    Dism /Mount-Image /Imagefile:"%WPE_DST%\media\sources\boot.wim" /Index:1 /MountDir:"%WPE_DST%\mount"

Rem *** CMD�t�@�C���̓���ւ� *************************************************
    Echo *** CMD�t�@�C���̓���ւ� *****************************************************
    ReName "%WPE_DST%\mount\Windows\System32\startnet.cmd" "startnet.cmd.orig"
    Copy /B "%WPE_DIR%\_for ATIH\startnet.cmd" "%WPE_DST%\mount\Windows\System32"
    Copy /B "%WPE_DIR%\_for ATIH\ati.cmd"      "%WPE_DST%\mount\Windows\System32"
    Copy /B "%WPE_DIR%\_for ATIH\menuti.cmd"   "%WPE_DST%\mount\Windows\System32"
    Copy /B "%WPE_DIR%\_for ATIH\shutdown.cmd" "%WPE_DST%\mount\Windows\System32"

Rem *** �p�b�P�[�W�̒ǉ� ******************************************************
    Echo *** �p�b�P�[�W�̒ǉ� **********************************************************

Rem *** WMI�FWindows Management Instrumentation(WinPE-WMI) ********************
    Echo *** WMI�FWindows Management Instrumentation(WinPE-WMI) ************************
    Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-WMI.cab"
    Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-WMI_ja-jp.cab"

Rem *** 802.1X���܂ޗL���l�b�g���[�N�̃T�|�[�g(WinPE-RNDIS, WinPE-Dot3Svc) ****
Rem Echo *** 802.1X���܂ޗL���l�b�g���[�N�̃T�|�[�g(WinPE-RNDIS, WinPE-Dot3Svc) ********
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-RNDIS.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-RNDIS_ja-jp.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-Dot3Svc.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-Dot3Svc_ja-jp.cab"

Rem *** �Í����h���C�u���̃T�|�[�g(WinPE-EnhancedStorage) *********************
Rem Echo *** �Í����h���C�u���̃T�|�[�g(WinPE-EnhancedStorage) *************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-EnhancedStorage.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-EnhancedStorage_ja-jp.cab"

Rem *** �C���[�W�L���v�`���c�[���ƓW�J�T�[�r�X�N���C�A���g(WinPE-WDS-Tools) ***
Rem Echo *** �C���[�W�L���v�`���c�[���ƓW�J�T�[�r�X�N���C�A���g(WinPE-WDS-Tools) *******
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-WDS-Tools.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-WDS-Tools_ja-jp.cab"

Rem **** BitLocker��TPM�̃T�|�[�g(WinPE-SecureStartup) ************************
Rem Echo *** BitLocker��TPM�̃T�|�[�g(WinPE-SecureStartup) *****************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-SecureStartup.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-SecureStartup_ja-jp.cab"

Rem *** �@�\����ł�.net Framework 4.5 (WinPE-NetFX) **************************
Rem Echo *** �@�\����ł�.net Framework 4.5 (WinPE-NetFX) ******************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-NetFx.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-NetFx_ja-jp.cab"

Rem *** WSH�FWindows Scripting Host(WinPE-Scripting) **************************
Rem Echo *** WSH�FWindows Scripting Host(WinPE-Scripting) ******************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-Scripting.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-Scripting_ja-jp.cab"

Rem *** �@�\����ł�Windows PowerShell(WinPE-PowerShell) **********************
Rem Echo *** �@�\����ł�Windows PowerShell(WinPE-PowerShell) **************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-PowerShell.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-PowerShell_ja-jp.cab"

Rem *** Dism �R�}���h���[�e�B���e�B(WinPE-DismCmdlets) ************************
Rem Echo *** Dism �R�}���h���[�e�B���e�B(WinPE-DismCmdlets) ****************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-DismCmdlets_ja-jp.cab"

Rem *** iSCSI���L����Ǘ��pPowerShell�R�}���h���[�e�B���e�B(WinPE-StorageWMI) *
Rem Echo *** iSCSI���L����Ǘ��pPowerShell�R�}���h���[�e�B���e�B(WinPE-StorageWMI) *****
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-JP\WinPE-StorageWMI_ja-jp.cab"

Rem *** HTML �A�v���P�[�V�����T�|�[�g(WinPE-HTA) ******************************
Rem Echo *** HTML �A�v���P�[�V�����T�|�[�g(WinPE-HTA) **********************************
Rem Dism /Image:"%WPE_DST%\mount" /Add-Package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-HTA.cab"
Rem Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-jp\WinPE-HTA_ja-jp.cab"

Rem *** ���{�ꉻ�p�p�b�P�[�W�̒ǉ� ********************************************
    Echo *** ���{�ꉻ�p�p�b�P�[�W�̒ǉ� ************************************************
    Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\WinPE-FontSupport-JA-JP.cab"
    Dism /Image:"%WPE_DST%\mount" /Add-package /PackagePath:"%WinPERoot%\amd64\WinPE_OCs\ja-jp\lp.cab"

Rem *** Windows PE�̓��{�ꉻ **************************************************
    Echo *** Windows PE�̓��{�ꉻ ******************************************************
    Dism /Image:"%WPE_DST%\mount" /Set-AllIntl:ja-jp
    Dism /Image:"%WPE_DST%\mount" /Set-InputLocale:0411:00000411
    Dism /Image:"%WPE_DST%\mount" /Set-LayeredDriver:6
    Dism /Image:"%WPE_DST%\mount" /Set-TimeZone:"Tokyo Standard Time"

Rem *** �h���C�o�[�̒ǉ� ******************************************************
    Echo *** �h���C�o�[�̒ǉ� **********************************************************
Rem --- VMware Tools ----------------------------------------------------------
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\mouse\vmmouse.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\mouse\vmusbmouse.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\pvscsi\pvscsi.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\video_wddm\vm3d.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\video_xpdm\vmx_svga.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\vmci\device\vmci.inf"
    Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\vmxnet3\NDIS5\vmxnet3ndis5.inf"
    Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware.x64\vmxnet3\NDIS6\vmxnet3ndis6.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\VMware Accelerated AMD PCNet Adapter\oem5.inf"
Rem --- LSI Logic SCSI --------------------------------------------------------
    Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\LSI\LSIMPT_SCSI_WinVista_1-28-03\lsimpt_scsi_vista_x64_rel\lsi_scsi.inf"
Rem --- Intel NIC -------------------------------------------------------------
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\INTEL\PROWinx64\PRO1000\Winx64\NDIS65\e1c65x64.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\INTEL\PROWinx64\PRO1000\Winx64\NDIS65\e1d65x64.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\INTEL\PROWinx64\PRO1000\Winx64\NDIS65\e1r65x64.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\INTEL\PROWinx64\PROXGB\Winx64\NDIS65\ixn65x64.inf"
Rem Dism /Image:"%WPE_DST%\mount" /Add-Driver /ForceUnsigned /Driver:"%WPE_DIR%\_drivers\INTEL\PROWinx64\PROXGB\Winx64\NDIS65\ixt65x64.inf"

:COMMIT
Rem *** boot.wim���A���}�E���g���� ********************************************
    Echo *** boot.wim���X�V���ăA���}�E���g���� ****************************************
    Dism /UnMount-Image /MountDir:"%WPE_DST%\mount" /Commit
    GoTo MAKE

:DISCARD
    Echo *** boot.wim��j�����ăA���}�E���g���� ****************************************
    Dism /UnMount-Image /MountDir:"%WPE_DST%\mount" /Discard
    GoTo DONE

:MAKE
Rem *** boot.wim���œK������ **************************************************
    Echo *** boot.wim���œK������ ******************************************************
    Imagex /Export "%WPE_DST%\media\sources\boot.wim" 1 "%WPE_DST%\media\sources\boot2.wim"
    Move /Y "%WPE_DST%\media\sources\boot2.wim" "%WPE_DST%\media\sources\boot.wim"

Rem *** CD�C���[�W���쐬���� **************************************************
    Echo *** CD�C���[�W���쐬���� ******************************************************
    Call MakeWinPEMedia /ISO /F "%WPE_DST%" "%DVD_DST%"

Rem *** CD�C���[�W����ƃt�H���_�[�ɃR�s�[���� ********************************
    Echo *** CD�C���[�W����ƃt�H���_�[�ɃR�s�[���� ************************************
    Copy /B /Y "%DVD_DST%" "%XFR_DIR%"

Rem USB�������ɏ������� *******************************************************
    Echo *** %USB_DST%��USB�������ɏ������� ***************************************************
    Echo [Enter]���������Ă��������B
    Pause > nul
    Call MakeWinPEMedia /UFD /F "%WPE_DST%" "%USB_DST%"

Rem *** ��ƏI�� **************************************************************
:DONE
    PopD
    Echo %DATE% %TIME%
    Echo *** ��ƏI�� ******************************************************************
    Echo [Enter]���������Ă��������B
    Pause > nul
    EndLocal

Rem *** Memo ******************************************************************
Rem Dism /List-Image /ImageFile:"C:\WinPE\amd64\media\sources\boot.wim" /Index:1
Rem Dism /Get-WimInfo /WimFile:"C:\WinPE\amd64\media\sources\boot.wim" /Index:1
Rem Dism /Image:"C:\WinPE\amd64\mount" /Get-Packages
Rem Dism /Image:"C:\WinPE\amd64\mount" /Get-Features
Rem ---------------------------------------------------------------------------
Rem msiexec /a
Rem setup   /a
Rem setup64 /a
Rem *** EOF *******************************************************************
    Echo On
