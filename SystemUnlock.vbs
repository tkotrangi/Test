'###################################################################################
'Requirement                    : Hit Num Lock key based on condition and wait for 3 min.
'File Name           : SystemUnLock.vbs
'Version               : 1.0
'###################################################################################
Dim Process,Processes, strObject,IsProcessRunning ,wsh,i,objWService

On Error Resume Next
i=0
strComputer = "." 
IsProcessRunning = False
Set objWService = GetObject("winmgmts:"& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set wsh = CreateObject("wscript.Shell")

'Private Const VK_RCONTROL As Long = &HA3  'Right Ctrl

While  i<4800

	Set Processes = objWService.ExecQuery ("Select * from Win32_Process")
	For Each Process in Processes
		If InStr(UCase(Process.name),"EXPLORER")>0 Then
			IsProcessRunning = True
			Exit For
		End If
	Next
	If IsProcessRunning = False Then
		i=5000
	Else
		IsProcessRunning = False
		wsh.SendKeys "{RCTRL}"
		wscript.sleep 30000
		Wsh.SendKeys "{RCTRL}"
		wscript.sleep 60000
	End if
	i=i+1
Wend 

On Error GoTo 0
