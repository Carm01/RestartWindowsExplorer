#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Downloads\Subvert-Windows-Explorer.ico
#AutoIt3Wrapper_Outfile=Restart_Explorer.exe
#AutoIt3Wrapper_Outfile_x64=Restart_Explorer.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=refreshes reg icons and restarts explorer gracefully
#AutoIt3Wrapper_Res_Description=refreshes reg icons and restarts explorer gracefully
#AutoIt3Wrapper_Res_Fileversion=1.0.0.1
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.1
#AutoIt3Wrapper_Res_LegalCopyright=NULL
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WinAPI.au3>
;~ #include <WinAPISys.au3>
#include <WinAPIShellEx.au3>
#include <SendMessage.au3>
;~ Global Const $shcne_AssocChanged = 134217728
; ref: https://msdn.microsoft.com/en-us/library/bb762118.aspx
;https://helgeklein.com/blog/2007/11/free-tool-refresh-the-desktop-programmatically/
; https://www.autoitscript.com/forum/topic/189906-restart-explorerexe/
;_Restart_Explorer()
ConsoleWrite("! Explorer PID: " & _Restart_Explorer() & "  *  Error: " & @error & @CRLF)

Func _Restart_Explorer()
	Local $ifailure = 100, $zfailure = 100, $rPID = 0, $iExplorerPath = @WindowsDir & "\Explorer.exe"
	_WinAPI_ShellChangeNotify($shcne_AssocChanged, 0, 0, 0) ; Save icon positions
	Local $hSystray = _WinAPI_FindWindow("Shell_TrayWnd", "")
	_SendMessage($hSystray, 1460, 0, 0) ; Close the Explorer shell gracefully
	While ProcessExists("Explorer.exe") ; Try Close the Explorer
		Sleep(10)
		$ifailure -= ProcessClose("Explorer.exe") ? 0 : 1
		If $ifailure < 1 Then Return SetError(1, 0, 0)
	WEnd
	RegDelete("HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify", "IconStreams")
	RegDelete("HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify", "PastIconsStream")
;~  _WMI_StartExplorer()
	While (Not ProcessExists("Explorer.exe")) ; Start the Explorer
		If Not FileExists($iExplorerPath) Then Return SetError(-1, 0, 0)
		Sleep(500)
		$rPID = ShellExecute($iExplorerPath)
		$zfailure -= $rPID ? 0 : 1
		If $zfailure < 1 Then Return SetError(2, 0, 0)
	WEnd
	Return $rPID
EndFunc   ;==>_Restart_Explorer


