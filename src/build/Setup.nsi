; Script generated by the HM NIS Edit Script Wizard.

Var /GLOBAL IC_DN40 #.Net frameworker 4.0
Var /GLOBAL IC_SCCM #SCCM Server
Var /GLOBAL SCCMInstallPath
Var /GLOBAL PluginExtensionsDir
Var /GLOBAL MenuDir
Var /GLOBAL DBDir
Var /GLOBAL DBDir2

!define SOURCEDIR "Output"
!define UninstName "Huawei SCCM Plugin For Fusion Director Uninst.exe"
; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Huawei SCCM Plugin For Fusion Director"
!define PRODUCT_VERSION "${VERSION}"
!define PRODUCT_PUBLISHER "Huawei Technologies Co.,Ltd."
!define PRODUCT_WEB_SITE "http://www.huawei.com"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "x64.nsh"
!include "nsProcess.nsh"
!include "StrFunc.nsh"
${StrRep}
${UnStrRep}

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
#!insertmacro MUI_PAGE_LICENSE "Licence.txt"
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

; 多语言提示
LangString Lan_CheckNF_Msg ${LANG_ENGLISH} "You must install Microsoft .NET Framework 4.0 or above"
LangString Lan_CheckNF_Msg ${LANG_SIMPCHINESE} "你必须安装 Microsoft .NET Framework 4.0 或以上版本"
LangString Lan_CheckSCCM_Msg ${LANG_ENGLISH} "You must install SCCM 2012 or above"
LangString Lan_CheckSCCM_Msg ${LANG_SIMPCHINESE} "你必须安装 SCCM 2012 或以上版本"
LangString Lan_CheckSCCMIsRuning_Msg ${LANG_ENGLISH} "Microsoft.ConfigurationManagement.exe is running, please restart it, and the plug-in will take effect"
LangString Lan_CheckSCCMIsRuning_Msg ${LANG_SIMPCHINESE} "Microsoft.ConfigurationManagement.exe 正在运行，请重启它，插件才能生效"
LangString Lan_DeleteData_Msg ${LANG_ENGLISH} "Do you want to delete the data before?"
LangString Lan_DeleteData_Msg ${LANG_SIMPCHINESE} "你想要删除之前的数据吗？"
LangString Lan_Uninstall_Msg ${LANG_ENGLISH} "has been successfully removed from your computer."
LangString Lan_Uninstall_Msg ${LANG_SIMPCHINESE} "已经从你的计算机中卸载。"

; MUI end ------
#!define /date PRODUCT_TIME %Y%m%d%H%M%S

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
#OutFile "Huawei_SCCM_Plugin_${PRODUCT_TIME}.exe"
OutFile "Huawei_SCCM_Plugin_For_Fusion_Director${PRODUCT_VERSION}.exe" 
InstallDir "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin"
ShowInstDetails show
ShowUnInstDetails show
RequestExecutionLevel admin

Function .onInit
	!insertmacro MUI_LANGDLL_DISPLAY
	
	Call CheckOS
FunctionEnd

Function .onInstSuccess
	Call CheckSCCMIsRuning	
FunctionEnd
/*--------------------Start----------------------------*/
Section "-LogSetOn"
  LogSet on
SectionEnd

Function CheckOS
	${If} ${RunningX64} 
		SetRegView 64
	${Else} 
		SetRegView 32
	${EndIf}
FunctionEnd

Function CheckSCCMIsRuning
	${nsProcess::FindProcess} "Microsoft.ConfigurationManagement.exe" $R0
	StrCmp $R0 "0" On_Abort End
	On_Abort:
		MessageBox MB_USERICON|MB_OK|MB_TOPMOST "$(Lan_CheckSCCMIsRuning_Msg)"
		
	End:
		
FunctionEnd

Function ReadSCCMInstallDir
	LogText "Reading SCCM InstallDir..." 

	Push $R0
	Push $R1
	ReadRegStr $R0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "SMS_ADMIN_UI_PATH"
	
	LogText "SMS_ADMIN_UI_PATH is: $R0"
	
	${If} $R0 != "" 	
		${StrRep} $SCCMInstallPath $R0 "\i386" ""
		LogText "SCCMInstallPath value is from environment: $SCCMInstallPath"
		StrCpy $INSTDIR $SCCMInstallPath
		goto lbl_?hasread
	${EndIf}
    
	StrCpy $SCCMInstallPath $INSTDIR
	LogText "SCCMInstallPath value is from variable: $SCCMInstallPath"
	
	lbl_?hasread:
	
	Pop $R1
	Exch $R0
FunctionEnd

Function SetPluginExtensionsDir
	LogText "Setting Plugin ExtensionsDir..."
	
	${StrRep} $PluginExtensionsDir $SCCMInstallPath "bin" "XmlStorage\Extensions\Nodes\f10d0965-4b26-4e37-aab5-5400fbbc8eaa"
	LogText "PluginExtensionsDir is: $PluginExtensionsDir"
	
	IfFileExists $PluginExtensionsDir\*.* 0 _Folder_NotExist
	LogText "PluginExtensionsDir is exists"
	
	_Folder_NotExist:
	CreateDirectory $PluginExtensionsDir
	LogText "Create PluginExtensionsDir: $PluginExtensionsDir"
FunctionEnd

Function SetPluginDBDir
	LogText "Setting Plugin DB Dir..."
	
	ReadEnvStr $0 Public
	StrCpy $DBDir "$0\Huawei\SCCM Plugin For Fusion Director\DB"
	LogText "DBDir is: $DBDir"
	
	IfFileExists $DBDir\*.* 0 _Folder_NotExist
	LogText "DBDir is exists"
	
	_Folder_NotExist:
	CreateDirectory $DBDir
	LogText "Create DBDir: $DBDir"
FunctionEnd

Function IsNet40Installed
	LogText "Checking .Net frameworker4.0..."

	Push $R0
	Push $R1
	ReadRegDWORD $R0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Install"
	ReadRegDWORD $R1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Version"
	
	LogText ".Net frameworker install status is: $R0"
	LogText ".Net frameworker version is: $R1"
	
	${If} $R0 == 1
		${If} $R1 >= "4.0.30319"
			StrCpy $R0 "Yes"
			StrCpy $IC_DN40 $R0
			LogText "IC_DN40 Value is: $IC_DN40"
			goto lbl_?net40idone
		${EndIf}
	${EndIf}
    
	StrCpy $R0 "No"
	StrCpy $IC_DN40 $R0
	LogText "IC_DN40 Value is: $IC_DN40"
	
	lbl_?net40idone:
    
	Pop $R1
	Exch $R0
FunctionEnd

Function CheckNF
	Call IsNet40Installed
	${If} $IC_DN40 == 'No'
		MessageBox MB_USERICON|MB_OK|MB_TOPMOST "$(Lan_CheckNF_Msg)"
		Abort
	${EndIf}
FunctionEnd

Function IsSCCMInstalled
	LogText "Checking SCCM..."

	Push $R0
	Push $R1
	ReadRegDWORD $R1 HKLM "SOFTWARE\Microsoft\SMS\Setup" "Full Version"
	
	LogText "SCCM version is: $R1"
	
	${If} $R1 >= "5.00.7711"
		StrCpy $R0 "Yes"
		StrCpy $IC_SCCM $R0
		LogText "IC_SCCM Value is: $IC_SCCM"
		goto lbl_?sccmdone
	${EndIf}
    
	StrCpy $R0 "No"
	StrCpy $IC_SCCM $R0
	LogText "IC_SCCM Value is: $IC_SCCM"
	
	lbl_?sccmdone:
  
	Pop $R1
	Exch $R0
FunctionEnd

Function CheckSCCM
	Call IsSCCMInstalled
	${If} $IC_SCCM == 'No'
		MessageBox MB_USERICON|MB_OK|MB_TOPMOST "$(Lan_CheckSCCM_Msg)"
		Abort
	${EndIf}
FunctionEnd
/*--------------------End----------------------------*/

Section "MainSection" SEC01
	LogText "Current Language is: $LANGUAGE"
	
	Call CheckSCCM
	Call CheckNF
	Call ReadSCCMInstallDir
	Call SetPluginExtensionsDir
	Call SetPluginDBDir
	
	Delete "$PluginExtensionsDir\HuaWei.xml"
	Delete "$PluginExtensionsDir\HuaWei_en.xml"
	Delete "$PluginExtensionsDir\HuaWei_zh-cn.xml"
	LogText "Delete SCCM-Plugin menu while installing"
	
	Delete "$SCCMInstallPath\*.pdb"
	LogText "Delete pdb files while installing"
	
	SetOutPath "$SCCMInstallPath"
	
  SetOverwrite try
	File "${SOURCEDIR}\cef.pak"
	File "${SOURCEDIR}\cef_100_percent.pak"
	File "${SOURCEDIR}\cef_200_percent.pak"
	File "${SOURCEDIR}\cef_extensions.pak"
	File "${SOURCEDIR}\CefSharp.BrowserSubprocess.Core.dll"
	File "${SOURCEDIR}\CefSharp.BrowserSubprocess.exe"
	File "${SOURCEDIR}\CefSharp.Core.dll"
	File "${SOURCEDIR}\CefSharp.Core.xml"
	File "${SOURCEDIR}\CefSharp.dll"
	File "${SOURCEDIR}\CefSharp.WinForms.dll"
	File "${SOURCEDIR}\CefSharp.WinForms.xml"
	File "${SOURCEDIR}\CefSharp.xml"
	File "${SOURCEDIR}\d3dcompiler_43.dll"
	File "${SOURCEDIR}\d3dcompiler_47.dll"
	File "${SOURCEDIR}\devtools_resources.pak"
	File "${SOURCEDIR}\libeay32.dll"
	
	SetOverwrite on
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.CommonUtil.dll"
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.Core.dll"
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.DAO.dll"
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.Models.dll"
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.PluginUI.dll"
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.PluginUI.dll.config"
	File "${SOURCEDIR}\Huawei.SCCMPlugin.FusionDirector.LogUtil.dll"
	File "${SOURCEDIR}\NLog.dll.nlog"
	
	SetOverwrite try
	File "${SOURCEDIR}\icudtl.dat"
	File "${SOURCEDIR}\libcef.dll"
	File "${SOURCEDIR}\libEGL.dll"
	File "${SOURCEDIR}\libGLESv2.dll"
	File "${SOURCEDIR}\natives_blob.bin"
  File "${SOURCEDIR}\Newtonsoft.Json.dll"
	File "${SOURCEDIR}\NLog.dll"
	File "${SOURCEDIR}\snapshot_blob.bin"
	File "${SOURCEDIR}\System.Data.SQLite.dll"
	File "${SOURCEDIR}\System.Net.Http.dll"
	File "${SOURCEDIR}\widevinecdmadapter.dll"
	;VC++
	File "${SOURCEDIR}\msvcp120.dll"
	File "${SOURCEDIR}\msvcr120.dll"
	File "${SOURCEDIR}\vccorlib120.dll"
	
	SetOutPath "$SCCMInstallPath\locales"
	File /r "${SOURCEDIR}\locales\*"
	
	SetOverwrite on
	SetOutPath "$SCCMInstallPath\fd-plugin-webapp"
	File /r "${SOURCEDIR}\fd-plugin-webapp\*"
	
	SetOverwrite try
	SetOutPath "$SCCMInstallPath\x64"
  File "${SOURCEDIR}\x64\SQLite.Interop.dll"
	
	SetOutPath "$SCCMInstallPath\x86"
  File "${SOURCEDIR}\x86\SQLite.Interop.dll"
	
	SetOutPath "$PluginExtensionsDir"
	${If} $LANGUAGE == 1033
		File "${SOURCEDIR}\HuaWei_en.xml"
	${Else}
		File "${SOURCEDIR}\HuaWei_zh-cn.xml"
	${EndIf}
  
	SetOverwrite off
	SetOutPath "$DBDir"
	File "${SOURCEDIR}\FusionDirectorDB.sqlite"
	
	;Language
	SetOverwrite on
	SetOutPath "$SCCMInstallPath\fd-plugin-webapp\huawei\js"
	${If} $LANGUAGE == 1033
		File "/oname=lang.js" "${SOURCEDIR}\lang-en.js"
	${Else}
		File "/oname=lang.js" "${SOURCEDIR}\lang-zhCN.js"
	${EndIf}
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\${UninstName}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\${UninstName}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
	${If} $LANGUAGE == 1033
	  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Lang" "en"
	${Else}
		WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Lang" "cn"
	${EndIf}
SectionEnd


Function un.onUninstSuccess
  HideWindow
	${If} $LANGUAGE == "1033"
	  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) has been successfully removed from your computer."
	${Else}
	  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) 已经从你的计算机中卸载。"
	${EndIf}
 
FunctionEnd

Function un.onInit
  #!insertmacro MUI_UNGETLANGUAGE
	${If} ${RunningX64} 
		SetRegView 64
	${Else} 
		SetRegView 32
	${EndIf}
	ReadRegDWORD $R1 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Lang" 
	${If} $R1 == "en"
			StrCpy $LANGUAGE  1033
	${Else}
			StrCpy $LANGUAGE  2052
	${EndIf}

	${nsProcess::FindProcess} "Microsoft.ConfigurationManagement.exe" $R0
	StrCmp $R0 "0" On_Abort more_Abort
	On_Abort:
		${If} $R1 == "en"
			MessageBox MB_USERICON|MB_OK|MB_TOPMOST "Microsoft.ConfigurationManagement.exe is running, Please close it before uninstall"
		${Else}
			MessageBox MB_USERICON|MB_OK|MB_TOPMOST "Microsoft.ConfigurationManagement.exe 正在运行, 请在卸载前先关闭程序"
		${EndIf}
		Abort
	more_Abort:
	    ${nsProcess::Unload}
			
	${If} $R1 == "en"
		MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to remove $(^Name)?" IDYES +4
	${Else}
		MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你确定要卸载 $(^Name) 吗？" IDYES +2
	${EndIf}
  Abort
FunctionEnd

Section Uninstall
	${UnStrRep} $MenuDir $INSTDIR "bin" "XmlStorage\Extensions\Nodes\f10d0965-4b26-4e37-aab5-5400fbbc8eaa"
	LogText "MenuDir is: $MenuDir"
	ReadEnvStr $0 Public
	StrCpy $DBDir "$0\Huawei\SCCM Plugin For Fusion Director\DB"
	ReadEnvStr $1 HomePath
	StrCpy $DBDir2 "$1\Huawei\SCCM Plugin For Fusion Director\DB"
	
  Delete "$INSTDIR\${UninstName}"
	Delete "$INSTDIR\uninst.exe" ;兼容之前的程序
	Delete "$INSTDIR\cef.pak"
	Delete "$INSTDIR\cef_100_percent.pak"
	Delete "$INSTDIR\cef_200_percent.pak"
	Delete "$INSTDIR\cef_extensions.pak"
	Delete "$INSTDIR\CefSharp.BrowserSubprocess.Core.dll"
	Delete "$INSTDIR\CefSharp.BrowserSubprocess.exe"
	Delete "$INSTDIR\CefSharp.Core.dll"
	Delete "$INSTDIR\CefSharp.Core.xml"
	Delete "$INSTDIR\CefSharp.dll"
	Delete "$INSTDIR\CefSharp.WinForms.dll"
	Delete "$INSTDIR\CefSharp.WinForms.xml"
	Delete "$INSTDIR\CefSharp.xml"
	Delete "$INSTDIR\d3dcompiler_43.dll"
	Delete "$INSTDIR\d3dcompiler_47.dll"
	#Delete "$INSTDIR\db.sqlite"
	Delete "$INSTDIR\devtools_resources.pak"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.CommonUtil.dll"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.Core.dll"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.DAO.dll"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.Models.dll"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.PluginUI.dll"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.PluginUI.dll.config"
	Delete "$INSTDIR\Huawei.SCCMPlugin.FusionDirector.LogUtil.dll"
	Delete "$INSTDIR\NLog.dll.nlog"
	Delete "$INSTDIR\icudtl.dat"
	Delete "$INSTDIR\libcef.dll"
	Delete "$INSTDIR\libEGL.dll"
	Delete "$INSTDIR\libGLESv2.dll"
	Delete "$INSTDIR\natives_blob.bin"
  #Delete "$INSTDIR\Newtonsoft.Json.dll"
	Delete "$INSTDIR\NLog.dll"
	Delete "$INSTDIR\snapshot_blob.bin"
	Delete "$INSTDIR\System.Data.SQLite.dll"
	Delete "$INSTDIR\System.Net.Http.dll"
	Delete "$INSTDIR\widevinecdmadapter.dll"
	Delete "$INSTDIR\libeay32.dll"
	;VC++
	Delete "$INSTDIR\msvcp120.dll"
	Delete "$INSTDIR\msvcr120.dll"
	Delete "$INSTDIR\vccorlib120.dll"
	
	;Delete "$INSTDIR\en\Huawei.SCCMPlugin.FusionDirector.PluginUI.resources.dll"
	Delete "$INSTDIR\x64\SQLite.Interop.dll"
	Delete "$INSTDIR\x86\SQLite.Interop.dll"
	;Delete "$INSTDIR\zh-cn\Huawei.SCCMPlugin.FusionDirector.PluginUI.resources.dll"
	;Delete "$INSTDIR\zh-cn\Huawei.SCCMPlugin.FusionDirector.PluginUI.resources.dll"
	RMDir /r "$INSTDIR\locales"
	RMDir /r "$INSTDIR\fd-plugin-webapp"
	#MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(Lan_DeleteData_Msg)" IDNO +4
	ReadRegDWORD $5 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}""Lang" 
	${If} $5 == "en"
		MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Do you want to delete the data before" IDNO +4
	${Else}
		MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你想要删除之前的数据吗？" IDNO +4
	${EndIf}
	Delete "$DBDir\FusionDirectorDB.sqlite"
	Delete "$DBDir2\FusionDirectorDB.sqlite"
	RMDir /r "C:\Users\*\Huawei\SCCM Plugin For Fusion Director"
	
  Delete "$MenuDir\HuaWei.xml"
	Delete "$MenuDir\HuaWei_en.xml"
	Delete "$MenuDir\HuaWei_zh-cn.xml"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd