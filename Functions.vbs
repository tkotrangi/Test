'********************************************************************************************************************************************************************************************
'*   Script Name:   	Functions
'*   Written by:   			DXC
'*
'*    Description:		 This file contains the 
'* 									1. Generic Functions
'* 									2. Application Functions
'* 									3. Reporting Functions
'*******************************************************************************************************************************************************************************************
Private strTotalTime
Public gstrPrevMATCName
Public gintLogSNo
Public dicGlobalOutput
Private strPvtTestCaseName 									'This is used to store the TestCaseName
Public gintLogSNOForMul
Public strAppendValueToScript

gintLogSNo = 1
gintLogSNOForMul = 0 'Modified/added to handle multiple data condition - 28th Mar 2016
Set dicGlobalOutput = CreateObject("Scripting.Dictionary")														' Create Global Dictionary


'*******************************************************************************************************************************************************************************************
'# Function: gfOnInitialize(ByVal strTestCaseName)
'# Function is used to initialize startup Resources like loading the Environment Repository and closing all the
'# existing browsers except Quality center and Webex
'#
'# Parameters:
'# Input Parameters:
'# strTestCaseName - Name of the Test Case
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Use this procedure at the starting of the script to ensure all the browsers are closed and loading the environment variables 
'#
'# Usage:> Call gfOnInitialize("BackOrder")
'*******************************************************************************************************************************************************************************************
Public Function gfOnInitialize(ByVal strTestCaseName)

	'UnLock WorkStation
	'Call lpLockWorkStation("Disable")
	'For HTML Reporting purpose Testcase name is stored in private variable so it will access in this vbs only
	strPvtTestCaseName = strTestCaseName

	'Create AutomationReport Folder Structure
	Call lpCreateFolderStructure(Environment("executionReportPath")& "\ScreenShots")
	
	'Create Output Folder Structure
	If CBool(Environment("SaveOutput")) Then lpCreateFolderStructure(Environment("executionReportPath")& "\ViewOutput")

	'This will Enable all the reporting stuff
	Reporter.Filter = rfEnableAll

	'Reporting Test Case Name for providing more details only in QTP Report
	Reporter.ReportEvent micInfo, "TestCase: "&strTestCaseName, "TestCase: "& strTestCaseName

	'For InBuilt QTP Reporting Purpose
	'Call lpCustomReport(micInfo, strTestCaseName, strTestCaseName)

	'This will disable all the reporting stuff
	Reporter.Filter = rfDisableAll
	
	'Close All Open Browsers
	'Call gFuncCloseAllBrowsers

	'Load Environment
	Call  procLoadEnvironmentRepository()

End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcCheckPrepaymentNumber(FormName,ObjName,strValue)
'# Function is used to verify the Prepayment Number in Oracle Table
'#
'# Parameters:
'# Input Parameters:
'# FormName - Name of the Oracle form
'# ObjName -Oracle Table Block Name
'# strValue -value to found in Oracle Table Block Name
'#
'# OutPut Parameters: True/False
'#
'# Usage: >  funcCheckPrepaymentNumber(FormName,ObjName,strValue)
'*******************************************************************************************************************************************************************************************
Function funcCheckPrepaymentNumber(ByVal FormName,ByVal ObjName,ByVal strValue)
	Dim objForm
	Dim intRows
	Dim intLoop
	Dim bFound
	bFound = False

	On Error Resume next
	Err.Clear

	' Create Page and Table object
	Set objForm = funcCreateFormObj(FormName,TabName)
	Set tblObject = objForm.OracleTable("block name:="&ObjName)
	intRows  = 	tblObject.GetROProperty("visible rows")

	' Check for text strValue in the table
	For intLoop= 1 to intRows
		If Instr(tblObject.GetFieldValue(intLoop,"Prepayment Number"),strValue)>0 Then
			bFound = True
			Exit For
		End If	
	Next

	' Return the value
	funcCheckPrepaymentNumber = bFound

	'Clean Up
	Set objForm = Nothing
	Set tblObject = Nothing
End function

'*******************************************************************************************************************************************************************************************
'# Function: funcGetBrowserTableValue(ByVal BrowserName,ByVal TableName,ByVal IndexNum, ByVal RowNumber, ByVal ColumnNumber,ByVal strCompText, ByVal ArrayPosition,ByVal TestStepID)
'# Function is used to get the value from the table in a web browser or Check the string exists in a particular column
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# TableName:-Table name
'# IndexNum:-Index number if needed
'# RowNumber:- Row number from where the value has to be fetched
'# ColumnNumber:-Column number from where the value has to be fetched
'# strCompText:-Check the table value in a particular cloumn
'# ArrayPosition:-postion of the text to be captured from the table
'# TestStepID:- Test Step ID
'#
'# Output Parameters:- True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcGetBrowserTableValue(ByVal BrowserName,ByVal TableName,ByVal IndexNum, ByVal RowNumber, ByVal ColumnNumber,ByVal strCompText, ByVal ArrayPosition,ByVal TestStepID)
	Dim objPage
	Dim NumRows
	Dim txtData 
	Dim intLoop
	Dim bFound

	On Error Resume Next
	Err.Clear

	bFound = False
	Set objPage = funcCreatePageObj(BrowserName)										' Create the Page object

	'RowNumber and ColumnNumber are converted to integer
	If isNumeric(RowNumber) Then RowNumber = Cint(RowNumber)
	If isNumeric(ColumnNumber) Then ColumnNumber = Cint(ColumnNumber)

	If objPage.WebTable("html tag:=TABLE","name:="&TableName,"index:="&IndexNum).Exist(gLONGWAIT) Then
		NumRows = objPage.WebTable("html tag:=TABLE","name:="&TableName,"index:="&IndexNum).GetROProperty("rows")
		txtData = objPage.WebTable("html tag:=TABLE","name:="&TableName,"index:="&IndexNum).GetCellData(RowNumber,ColumnNumber)
        If ArrayPosition <> "" Then  
			txtData = funcSearchPattern(txtData, "[+0-9]+",ArrayPosition )					' Get integer part from cell data
		End If
		dicGlobalOutput.add TestStepID , txtData													' Add to global dictionary
	End If

    If Instr(TableName,"#") > 0 Then
		TableName = Split(TableName,"#")(1)
		If objPage.WebTable("html tag:=TABLE",TableName,"index:="&IndexNum).Exist(gLONGWAIT) Then
			NumRows = objPage.WebTable("html tag:=TABLE",TableName,"index:="&IndexNum).GetROProperty("rows")
			txtData = objPage.WebTable("html tag:=TABLE",TableName,"index:="&IndexNum).GetCellData(RowNumber,ColumnNumber)
			If ArrayPosition <> "" Then  
				txtData = funcSearchPattern(txtData, "[+0-9]+",ArrayPosition )					' Get integer part from cell data
			End If
			dicGlobalOutput.add TestStepID , txtData													' Add to global dictionary
		End If
	End If

	' Return value
	If txtData <>"" Then
		'Call gfReportExecutionStatus(micDone,"Verify Table Value",  "Successfully got the value from Row " & RowNumber &" and Column "& ColumnNumber )
		Call gfReportExecutionStatus(micPass,"Verify Table Value",  "Got the value " & txtData & " from Row " & RowNumber &" and Column "& ColumnNumber )
		funcGetBrowserTableValue = True
	Else
		Call gfReportExecutionStatus(micFail,"Verify Table Value",  "Failed to get the value from Row " & RowNumber & " and Column "& ColumnNumber )
		funcGetBrowserTableValue = False
	End If

	' To check the text present  in the table in column ColumnNumber
	If strCompText <> "" Then
    	For intLoop = 1 to NumRows
			txtData = objPage.WebTable("html tag:=TABLE","name:="&TableName,"index:="&IndexNum).GetCellData(intLoop,ColumnNumber)
			If strcomp(Trim(txtData),strCompText) = 0 Then	
				bFound = True								' Found required text
				Exit For
			End If
		Next

		' Return the value
		If bFound Then
			Call gfReportExecutionStatus(micDone,"Verify Table Value",  "Got the table value as '"&txtData & "' from Row: " & intLoop)
			funcGetBrowserTableValue = True
		Else
			Call gfReportExecutionStatus(micFail,"Verify Table Value",  "Failed to get the value '" & strCompText  & "'")
			funcGetBrowserTableValue = False
		End If
	End If

	'Clean Up
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcWebTableSelectObj(ByVal BrowserName,ByVal TableName,ByVal IndexNum,ByVal RowNumber,ByVal ColumnNumber,ByVal ObjClass,ByVal ObjIndex, ByVal strVal)
'# Function is used to selects the required object existing in the browser table
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# TableName:-Name of the table
'# IndexNum:-Index Number (if needed)
'# RowNumber:-Row Number Value
'# ColumnNumber:-Column Number Value
'# ObjClass:-Class of Object
'# ObjIndex:-Index Number (if needed)
'# strVal:-Value in the desired column
'#
'# Output Parameters:True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcWebTableSelectObj(ByVal BrowserName,ByVal TableName,ByVal IndexNum,ByVal RowNumber,ByVal ColumnNumber,ByVal ObjClass,ByVal ObjIndex, ByVal strVal)
	Dim objPage
	Dim txtDescription
	Dim bSuccess

	On Error Resume Next
	Err.Clear
	bSuccess = False

	' Create the page object
	Set objPage = funcCreatePageObj(BrowserName)
	Set tblObject = objPage.WebTable("html tag:=TABLE","name:="&TableName,"index:="&IndexNum)

	' RowNumber and ColumnNumber are converted to integer
	If isNumeric(RowNumber) Then RowNumber = Cint(RowNumber)
	If isNumeric(ColumnNumber) Then ColumnNumber = Cint(ColumnNumber)

	If tblObject.Exist(gLONGWAIT) Then
			txtDescription = tblObject.GetCellData(RowNumber,ColumnNumber)

			Select Case ObjClass
				Case "WebTableCheckbox" 									' For webTable Checkbox
						tblObject.ChildItem (RowNumber,ColumnNumber,"WebCheckBox",objIndex).Set strVal
						Call gfReportExecutionStatus(micDone,"Select the Checkbox","Selected the checkbox: " & txtDescription)
						bSuccess =True

				Case "WebTableRadioButton"									' For webTable RadioButton
						tblObject.ChildItem (RowNumber, ColumnNumber, "WebRadioGroup", objIndex).select strVal
						Call gfReportExecutionStatus(micDone,"Select the Radio button",  "Selected  the Radio button: "& txtDescription)
						bSuccess =True

			End Select
																																		   																			
	End If

	'Retrun value
	funcWebTableSelectObj = bSuccess

	' Clean Up
	Set objPage = Nothing
	Set tblObject = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSearchPattern(ByVal MsgString,ByVal strPattern, ByVal ArrayPosition)
'# Function is used to capture Integer/Character from string based on the search pattern
'#
'# Input Parameters:
'# MsgString:- String you captured
'# strPattern:-To capture integer/character 
'# ArrayPosition:- Which value to return
'#
'# Output Parameters: 
'# intValue: Captured vale based on regular expression. 
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcSearchPattern(ByVal MsgString,ByVal strPattern, ByVal ArrayPosition)
	Dim colMatches
	Dim objMatch
	Dim objRE
	Dim intVal
	Dim intCount

	On Error Resume Next
	Err.Clear

    ' Default if no numbers are found
    intVal = 0
    intCount = 1

    Set objRE = New RegExp						' Create regular expression object.
    objRE.Pattern=strPattern					' Set pattern.
    objRE.IgnoreCase= True						' Set case insensitivity.
    objRE.Global=True								' Set global applicability: True  => return last match only,  False => return first match only.
    Set colMatches = objRE.Execute( MsgString ) 
	' Iterate Matches collection.
    For Each objMatch In colMatches             
		If intCount = Cint(ArrayPosition) Then
			intVal = objMatch.Value
			Exit For
		End If
		intCount = intCount + 1
    Next

	' Return integer from string
	funcSearchPattern = intVal

	' Clean Up
    Set objRE= Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSendKeys(ByVal KeyValue,ByVal RepeatNumber)
'# Function is used Send keyboard input to the applciation
'#
'# Input Parameters:
'# KeyValue:-Keys name to be operated
'# RepeatNumber:-Number of time actions to be performed.
'#
'# Output Parameters: None
'#
'# Usage:>  funcSendKeys(KeyValue,RepeatNumber)
'*******************************************************************************************************************************************************************************************
Function funcSendKeys(ByVal KeyValue,ByVal RepeatNumber)
	Dim wsh
	Dim intLoop

	On Error Resume Next
	Err.Clear

	' Create the shell object
    Set wsh = CreateObject("Wscript.Shell")
	' For Repeated key press
	If RepeatNumber <> "" Then
		For intLoop=1 To cInt(RepeatNumber)
			wsh.SendKeys KeyValue
		Next
		funcSendKeys = True
	Else
		' Retrieve the value from global dict
		If Instr(KeyValue , "#" ) > 1 Then
			KeyValue = GetValueFromGlobalDictionary(KeyValue)
		End If
		wsh.SendKeys KeyValue
		wait(3)
		funcSendKeys = True		
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcGetListValue(ByVal BrowserName,ByVal FormName, ByVal TabName, ByVal OracleListName, ByVal IndexNum, ByVal ListValue)
'# Function is used get item from the list of items
'#
'# Input Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of Form
'# TabName:Tab Value (if any)
'# OracleListName:-List item name
'# ListValue:-Value to be seleced from list of item
'# IndexNum:-Index number (if needed)
'#
'# Output Parameters: True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcGetListValue(ByVal OracleListName, ByVal IndexNum, ByVal ListValue)
	Dim formObj
	Dim strVal
	Dim arrListContent
	Dim intCounter
	Dim bSuccess

    On Error Resume Next
	Err.Clear
	bSuccess = False

	' Find value ListValue in OracleListName
	If OracleListOfValues("title:="&OracleListName).Exist(gMEDIUMWAIT) Then
		strVal = OracleListOfValues("title:="&OracleListName).GetROProperty("list content")
		arrListContent=Split(strVal,";") 
    	For intCounter = 0 To Ubound(arrListContent)-1
			If Strcomp (arrListContent(intCounter), ListValue) = 0 Then
					bSuccess = True
			End If
		Next
	End If

	' Click on Ok/Cancel button and return value
	If bSuccess Then
		OracleListOfValues("title:="&OracleListName).OracleButton("label:=OK").Click
		funcGetListValue = True	
	Else
		OracleListOfValues("title:="&OracleListName).OracleButton("label:=Cancel").Click
		funcGetListValue = False
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSelectListValue(ByVal BrowserName, ByVal FormName,ByVal TabName, ByVal OracleListName,ByVal IndexNum, ByVal ListValue)
'# Function is used select item from the ListBox
'#
'# Input Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of Form
'# TabName:Tab Value (if any)
'# OracleListName:-List item name
'# ListValue:-Value to be seleced from list of item
'# IndexNum:-Index number (if needed)
'#
'# Output Parameters: True/False
'#
'# Usage:> funcSelectListValue(BrowserName,FormName,TabName,OracleListName,IndexNum,ListValue)
'*******************************************************************************************************************************************************************************************
Function funcSelectListValue(ByVal BrowserName, ByVal FormName,ByVal TabName, ByVal OracleListName,ByVal IndexNum, ByVal ListValue)
	Dim objPage
	Dim objForm
	Dim objList
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	If BrowserName <> "" Then																			' For ListBox in the brower
		Set objPage = funcCreatePageObj(BrowserName)						' Create the page object			
		If objPage.WebList("name:="&OracleListName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then		
			Set objList = objPage.WebList("name:="&OracleListName,"index:="&IndexNum)
		End If	
	End If

	If FormName <> ""  Then																							' For Oracle ListBox in a form
			Set objForm = funcCreateFormObj(FormName,TabName)				' Create form object
	
			' Check for OracleListName with property description
			If objForm.OracleList("description:="&OracleListName,"index:="&IndexNum).Exist(gMEDIUMWAIT) then
				Set objList = objForm.OracleList("description:="&OracleListName,"index:="&IndexNum)
			End If
	
			'When the OracleListName is not having the description value use the avaliable property starting with an "#"(For EG.#developer name:=dhgf )
			If Instr(OracleListName,"#")>0 Then
				OracleListName = Split(OracleListName,"#")(1)	
				If objForm.OracleList(OracleListName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					Set objList = objForm.OracleList(OracleListName,"index:="&IndexNum)
				End If
			End If

	' For Oracle list of values
	ElseIf OracleListOfValues("title:="&OracleListName).Exist(gMEDIUMWAIT) Then
		Set objList = OracleListOfValues("title:="&OracleListName)
	End If

	If objList.Exist(gSHORTWAIT) Then
	
		'------------------------------------------------------------commented by Ravikanth 08-Jun-2016
		'-------------------Cint(ListValue) is converting '10.000,00' number to numeric '10' due to which script is unable to select the value
		' Change the ListValue to numeric if it is a number
		'Uncommented as not working for rest of the scripts
		If IsNumeric(ListValue) Then
			ListValue=Cint(ListValue)
		End If
		'------------------------------------------------------------commented by Ravikanth 08-Jun-2016
		' Select the value in ListBox
		objList.Select ListValue
		bSuccess = True
	Else
		bSuccess = False
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Retrun the value
	funcSelectListValue = bSuccess

	' Clean Up
	Set objList = Nothing
	Set objPage = Nothing
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcClickImage(ByVal BrowserName,ByVal FormName,ByVal ObjName,ByVal IndexNum)
'# Function is used Click image object in the browser or Form
'#
'# Parameters:
'# BrowserName:-Name of Broswer
'# FormName:- Name of the Oracle form
'# ObjName	:- Image object name
'# IndexNum:-Index number if needed
'#
'# Output Parameters: True/False
'#
'# Remarks:None
'#
'# Usage: >  funcClickImage(BrowserName,FormName,ObjName,IndexNum)
'*******************************************************************************************************************************************************************************************
Function funcClickImage(ByVal BrowserName,ByVal FormName,ByVal ObjName,ByVal IndexNum)
	Dim objPage 
	Dim objImage
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	If BrowserName <> "" Then				' For images  displayed in web

		Set objPage=funcCreatePageObj(BrowserName)
		If Instr(ObjName,"#") > 0 Then
			ObjName = Split(ObjName,"#")(1)
			If objPage.Image(ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then
				Set objImage=objPage.Image(ObjName,"index:="&IndexNum)										' Set the image object
			End If                                         			

		ElseIf objPage.Image("html tag:=IMG|INPUT","file name:="&ObjName,"Index:="&IndexNum).Exist(gLONGWAIT) Then
			Set objImage=objPage.Image("html tag:=IMG|INPUT","file name:="&ObjName,"Index:="&IndexNum)                 ' Set the image object                                                       			

		ElseIf objPage.Image("html tag:=IMG|INPUT","alt:="&ObjName,"Index:="&IndexNum).Exist(gLONGWAIT) Then
			Set objImage=objPage.Image("html tag:=IMG|INPUT","alt:="&ObjName,"Index:="&IndexNum)					' Set the image object
		End If

	End If

	' Click on Image if exiss
	If objImage.Exist(10) Then
		objImage.Click
		bSuccess = True			
	Else
		bSuccess = False			
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

    ' Retrun the value
	funcClickImage = bSuccess	

	'	Clean Up
	Set objImage = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcCheckBrowserName(ByVal BrowserName,ByVal PropertyName)
'# Function is used to check captured browser name with expected browser name
'#
'# Parameters:
'# BrowserName:- Name of the Browser
'# PropertyName:- title
'# ReportName :- User defined 
'#
'# Output Parameters: None
'#
'# Usage:> funcCheckBrowserName(BrowserName,PropertyName)
'*******************************************************************************************************************************************************************************************
Function funcCheckBrowserName(ByVal BrowserName,ByVal PropertyName)
	Dim strTempBrowserName

	On Error Resume Next
	Err.Clear

	' Get the browser Name
	strTempBrowserName = Window("regexpwndclass:=IEFrame","index:=" & vCtr).GetROproperty(PropertyName)

	' Check the Temp browser name with expected  browser name
	If inStr(1, strTempBrowserName, BrowserName) > 0 Then
		funcCheckBrowserName = True
	Else
		funcCheckBrowserName = False
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcGetPopUpWindowMessage(ByVal WindowName, ByVal ArrayPosition, ByVal TestStepID)
'# Function is used to capture the message from pop window and integer value from popup message
'#
'# Parameters:
'# WindowName:-Name of window
'# ArrayPosition:-Position of the text to be captured
'# TestStepID :- Step ID
'#
'# Output Parameters: Message
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcGetPopUpWindowMessage(ByVal WindowName, ByVal ArrayPosition, ByVal TestStepID, ByVal ButtonName)
	Dim strPopUpMessage

	On Error Resume Next
	Err.Clear

	strPattern = "[+0-9]+"						  		' Search pattern for integers
	strPopUpMessage = ""						' intialise the strPopUpMessage

	If ButtonName <> "" Then
		If OracleNotification("title:="&WindowName).Exist(gLONGWAIT) Then
			strPopUpMessage = OracleNotification("title:="&WindowName).GetROProperty("message")
			OracleNotification("title:="&WindowName).Choose(ButtonName)
		End If
	Else
		If OracleNotification("title:="&WindowName).Exist(gLONGWAIT) Then
			strPopUpMessage = OracleNotification("title:="&WindowName).GetROProperty("message")
			OracleNotification("title:="&WindowName).Approve
		End If
	End If

	If ArrayPosition <> "" Then
		strPopUpMessage = funcSearchPattern(strPopUpMessage, strPattern,ArrayPosition)
	End If

	' Add to global dictionary
	dicGlobalOutput.add TestStepID , strPopUpMessage

	' Return the message
	funcGetPopUpWindowMessage = strPopUpMessage
End Function
'*******************************************************************************************************************************************************************************************
'# Function: funcWaitForCompleteStatus(ByVal BrowserName, ByVal RequestID,ByVal bCheckOutput)
'# Function is used to getting the data from Request ID table wait till the status 'Completed' for given Request Id and verify the output
'#
'# Parameters:
'# BrowserName:-			Name of Browser
'# RequestID:- 					Request Id
'# bCheckOutput:- 			To Check ouput
'#
'# Output Parameters: True/False
'#
'# Usage > 
'*******************************************************************************************************************************************************************************************
Function funcWaitForCompleteStatus(ByVal BrowserName, ByVal RequestID,ByVal bCheckOutput)
	Dim objPage
	Dim tblObject
	Dim intRowNum
	Dim intRow
	Dim strStatus, strPhase
	Dim intCounter
	Dim objExcel
	Dim objActiveXL
	Dim strSheet

	On Error Resume Next
	Err.Clear

	'Intialisation
	strPhase = ""
	intCounter = 1

	'Create page object for browser
	Set objPage = funcCreatePageObj(BrowserName)
	Set tblObject = objPage.WebTable("name:=Request ID")

	'Click on Refresh Button
	objPage.WebButton("name:=Refresh","index:=0").Click
	tblObject.RefreshObject

	If tblObject.Exist(gMEDIUMWAIT) Then

		'Find the Row no with request id
		For intRow = 1 to tblObject.RowCount
			If StrComp(Trim(tblObject.GetCellData( intRow,"1")), Trim(RequestID)) = 0 Then
				intRowNum = intRow
				Exit For
			End If
		Next
	
		' wait till the status changed to Completed
		Do While strPhase <> "Completed"
			Wait 2
			tblObject.RefreshObject

			'If new request come row no changes, confirm before proceeding
			If StrComp(Trim(tblObject.GetCellData( intRowNum,"1")), Trim(RequestID)) <> 0 Then
				For intRow = 1 to tblObject.RowCount
					If StrComp(Trim(tblObject.GetCellData( intRow,"1")), Trim(RequestID)) = 0 Then
						intRowNum = intRow
						Exit For
					End If
				Next
			End If

			strPhase = Trim(tblObject.GetCellData(intRowNum, "3"))
			strStatus = Trim(tblObject.GetCellData(intRowNum, "4"))	

			If (intCounter >300 Or strStatus = "Error" Or strStatus = "Warning") Then
				Exit Do										'Max wait time 10 mins
			End If

			objPage.WebButton("name:=Refresh","index:=0").Click
			intCounter = intCounter +1
		Loop

	End If

	If (strPhase = "Completed" And strStatus = "Normal") Or (strPhase = "Completed" And strStatus = "Warning") Then
		Call gfReportExecutionStatus(micPass,"Verify Phase and Status for "&RequestID,"Phase is " & strPhase & " and Status is " &strStatus)
		funcWaitForCompleteStatus = True
	Else
		Call gfReportExecutionStatus(micFail,"Verify Phase and Status for "&RequestID,"Phase is " & strPhase & " and Status is " &strStatus)
		funcWaitForCompleteStatus = False
	End If

	' To check the output for browser or xl file
	If UCase(bCheckOutput) = "TRUE" Then
		tblObject.RefreshObject
		strName = Trim(tblObject.GetCellData(intRowNum, "2"))
		tblObject.ChildItem(intRowNum,7,"Image",0).Click
	
		Wait gMEDIUMWAIT
		If Browser("name:=.*temp_id=.*").Exist(gMEDIUMWAIT) Then
			Call gfReportExecutionStatus(micPass,"Verify OutPut", "Output browser " & Browser("name:=.*temp_id=.*").GetROProperty("title") & " appeared")
	
		Else
	
			Call funcProcessDownloadWindow()
			Wait gMEDIUMWAIT

			Set objExcel = GetObject("","Excel.Application")										' Don't change this line though it give the syntax error.
			objExcel.Visible = True
			objExcel.DisplayAlerts = False
			strSheet = objExcel.ActiveWorkbook.Name
			
			If InStr(strSheet, ".") >0 Then
				strSheet = Split(strSheet,".")(0)
				strSheet = Replace(strSheet," ","")
				If InStr(strSheet,"_") > 0 Then
					strSheet = Mid(strSheet,1, InStrRev(strSheet,"_"))
				End If
			End If

			Set objActiveXL = objExcel.ActiveWorkbook.Worksheets(strSheet)

			If StrComp(Trim(objActiveXL.Cells(1,1).Value),strName) Then
				Call gfReportExecutionStatus(micPass,"Verify OutPut", "Output xl file " & strName & " appeared")
				funcWaitForCompleteStatus = True
			Else
				Call gfReportExecutionStatus(micFail,"Verify OutPut", "Output xl file " & strName & " not appeared")
				funcWaitForCompleteStatus = False
			End If

			' Close active workbook
			objExcel.ActiveWorkbook.Close
		End If
	
	End If

	'Clean Up
	Set tblObject = Nothing
	Set objPage = Nothing
	Set objActiveXL = Nothing
	Set objExcel = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcGetTableBoxValue(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum, ByVal RowNumber,ByVal ColumnName,ByVal TestStepID)
'# Function is used to Get value from the browser web table or form table
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of Form
'# TabName:-Tab value (if any)
'# ObjName:-table name
'# IndexNum: - Index number
'# RowNumber:-row number from where the data has to be fetched
'# ColumnName:-Column name from where value has to be taken
'#
'# Output Parameters: Value
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcGetTableBoxValue(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum, ByVal RowNumber,ByVal ColumnName,ByVal TestStepID)
	Dim objForm
	Dim objPage
	Dim strTextVal
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	' Convert the Row and column to integers
	If isNumeric(RowNumber) Then RowNumber = cInt(RowNumber)
	If isNumeric(ColumnName) Then ColumnName =Browser("Welcome").Page("Product Information Management").WebTable("Type").GetCellData
 cInt(ColumnName)

	' Get the value for web table
	If BrowserName <> "" Then
		Set objPage = funcCreatePageObj(BrowserName)

		If InStr (ObjName,"#") >0 Then				' This is to handle the special case when name property is not unique, use the property 'Column names'
			If objPage.WebTable(Mid(ObjName,2),"index:="&IndexNum).Exist(gLONGWAIT) Then
				strTextVal = objPage.WebTable(Mid(ObjName,2),"index:="&IndexNum).GetCellData(RowNumber, ColumnName)
				Call gfReportExecutionStatus(micDone," Retrieve Table Value", " Got Web Table "&strTextVal )
				bSuccess = True
			End If
		ElseIf objPage.WebTable("html tag:=TABLE","name:="& ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then
			strTextVal = objPage.WebTable("html tag:=TABLE","name:="&ObjName,"index:="&IndexNum).GetCellData(RowNumber, ColumnName)
			Call gfReportExecutionStatus(micDone," Retrieve Table Value", " Got Web Table "&strTextVal )
			bSuccess = True
		End If

		If Not bSuccess Then
				Call gfReportExecutionStatus(micFail," Retrieve Table Value", "Web Table "& ObjName & " not exists.")
				Exit Function
		End If
	End If

	' Get the value for Oracle table
	If FormName <> "" Then
		Set objForm = funcCreateFormObj(FormName,TabName)

		If objForm.OracleTable("block name:="& ObjName).Exist(gLONGWAIT) Then
			strTextVal = objForm.OracleTable("block name:="& ObjName,"index:="&IndexNum).GetFieldValue(RowNumber,ColumnName)
			Call gfReportExecutionStatus(micDone," Retrieve Table Value", " Got Web Table "&strTextVal )
		Else
			Call gfReportExecutionStatus(micFail," Retrieve Table Value", "Table "& ObjName & " not exists.")
			Exit Function
		End If

'		' If Object name contains '#' 
'		If Instr(ObjName,"#") > 0  Then
'			If objForm.OracleTable("block name:="& Split(ObjName,"#")(0) ,"Index:="& Split(ObjName,"#")(1)).Exist(gLONGWAIT)  Then
'				strTextVal = objForm.OracleTable("block name:="& Split(ObjName,"#")(0) ,"Index:="& Split(ObjName,"#")(1)).GetFieldValue(RowNumber,ColumnName)
'				Call gfReportExecutionStatus(micDone," Retrieve Table Value", " Got Web Table "&strTextVal )
'			Else
'				Call gfReportExecutionStatus(micFail," Retrieve Table Value", "Table "& ObjName & " not exists.")
'				Exit Function
'			End If
'		End If

	End If

	'Adding strTextVal to Global dict
	dicGlobalOutput.add TestStepID , strTextVal

	' Return value
	funcGetTableBoxValue = strTextVal

	' Clean Up
	Set objForm = Nothing
	Set FormName = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcVerifyBrowserObject(ByVal BrowserName,ByVal ObjClass,ByVal ObjName,ByVal IndexNum)
'# Function is used to Verify object existence in a page
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# ObjName:-Name of field to be verified
'# IndexNum:-Index number (if required)
'# objClass:-Class of the object to be verified
'#
'# Output Parameters: True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************

Function funcVerifyBrowserObject(ByVal BrowserName, ByVal ObjName, ByVal ObjClass, ByVal IndexNum)

	Dim objPage

	On Error Resume Next
	Err.Clear

	' Create the page Object
	Set objPage = funcCreatePageObj(BrowserName)
	Select Case UCase(ObjClass)
		Case "LINK"													' Check for Link existence
				If objPage.Link("html tag:=A","innertext:="&ObjName,"Index:="&IndexNum).Exist(gSYNCWAIT) Then
					funcVerifyBrowserObject = True
                Else
					funcVerifyBrowserObject = False
				End If
		Case Else														' Can extended for other object types
				Call gfReportExecutionStatus(micWarning,"Verify Browser object", "Object "& ObjClass & " not handled")
	End Select

	' Clean Up
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcVerifyFieldValue(BrowserName,FormName,ObjName,TabName,KeyValue,IndexNum,objClass,RowVal,ColumnVal)
'# Function is used Verify Value in the text/Table Field
'#
'# Parameters:
'# BrowserName:-		 Name of Browser
'# FormName:-				Name of Form
'# TabName:-				Tab Name to be selected
'# ObjName:-				Field where we have to verify
'# KeyValue:-				Value existing in the field
'# IndexNum:-				Index Number (if needed)
'# objClass:-				Class of Field where we have to verify the data
'# RowVal:-					Row Number
'# ColumnValue:-	Column Name/Header
'#
'# Output Parameters: True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function  funcVerifyFieldValue(ByVal BrowserName, ByVal FormName,ByVal TabName,ByVal ObjName, ByVal KeyValue,ByVal IndexNum,ByVal objClass,ByVal RowVal,ByVal ColumnVal)
	Dim objForm
	Dim objPage
	Dim strText

	On Error Resume Next
	Err.Clear

	' Initialisation
	strText = ""
	funcVerifyFieldValue= False

	'  Create Page object
	If BrowserName <> "" Then
		Set objPage = funcCreatePageObj(BrowserName)		
	End If

	'Create from object
	If FormName <> "" Then
		Set objForm = funcCreateFormObj(FormName,TabName)		
	End If

	If isNumeric(RowVal) Then	
		RowVal =  cInt(RowVal)			'	Convert the row to numeric
	End If

	If isNumeric(ColumnVal) Then	
		ColumnVal =  cInt(ColumnVal)			'	Convert the Column to numeric
	End If

	Select Case UCase(objClass)
		Case "ORACLETABLE"																		'	For Oracle Table		

				'	Check the cell Existence and get the value
				If objForm.OracleTable("block name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					strText = objForm.OracleTable("block name:="& ObjName).GetFieldValue(RowVal,ColumnVal)
				End If

		Case "ORACLETEXTFIELD"																'	For Oracle Textfield

				If objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					If Trim(Ucase(KeyValue))="TRUE" Or Trim(Ucase(keyValue)) = "FALSE" Then
						'	To check Oracle Textfield is editable or not
						strText = objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).GetROProperty("editable")
					Else
						'	To retrieve the value of Oracle Textfield
						strText = objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).GetROProperty("value")
					End If
				End If 

		Case "ORACLECHECKBOX"																'	For Oracle Checkbox

				If objForm.OracleCheckbox("label:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					' Check the status of Checkbox using the property label
					strText = objForm.OracleCheckbox("label:="&ObjName,"index:="&IndexNum).GetROProperty("selected")
				ElseIf	objForm.OracleCheckbox("description:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					' Check the status of Checkbox using the property description
					strText = objForm.OracleCheckbox("description:="&ObjName,"index:="&IndexNum).GetROProperty("selected")					
				End If
							
		Case "ORACLELIST"																			'	For Oracle List

				If objForm.OracleList("description:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					'	Get the list value
					strText = objForm.OracleList("description:="& ObjName,"index:="&IndexNum).GetROProperty("selected item")
				End If

		Case "ORACLERADIOGROUP"														'	For Oracle Radio buttons

				If objForm.OracleRadioGroup("developer name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					'	Get the Radio group value
					strText = objForm.OracleRadioGroup("developer name:="&ObjName,"index:="&IndexNum).GetROProperty("enabled") 
				End If

		Case "WEBTABLE"																			'  	For WebTable

				If objPage.WebTable("column names:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					strText = objPage.WebTable("column names:="& ObjName,"index:="&IndexNum).GetCellData(RowVal, ColumnVal)
				End If

		Case "WEBEDIT"

				If objPage.WebEdit("name:=" &ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					strText = objPage.WebEdit("name:=" &ObjName,"index:="&IndexNum).GetROProperty("value")
				End If

		Case "ORACLEFLEXTEXTFIELD"		'               For Oracle Flexfield
				Set objOracleFlexForm = OracleFlexWindow("title:="&FormName)
				If objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					If Trim(Ucase(KeyValue))="TRUE" Or Trim(Ucase(keyValue)) = "FALSE" Then
						'To check Oracle Textfield is editable or not
						strText = objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).GetROProperty("editable")
					Else
						' To retrieve the value of Oracle Textfield
						strText = objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).GetROProperty("value")
					End If
				End If

'31-MAR-2016**********************************************************************************************************************


		Case "WEBCHECKBOX"
		
				If objPage.WebCheckBox("name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
				
					strText = objPage.WebCheckBox("name:="& ObjName,"index:="&IndexNum).GetROProperty("checked")
					
					If UCASE(KeyValue) = "CHECKED" Then
						If strText = 1 Then
							strText = "Checked"
						ElseIf strText = 0 Then
							strText = "Unchecked"
						End If					
						
					ElseIf UCASE(KeyValue) = "UNCHECKED" Then
						If strText = 0 Then
							strText = "Unchecked"
						ElseIf strText = 1 Then
							strText = "Checked"
						End If	
						
					End If
					
				End If
								
		Case "WEBRADIOGROUP"
		
				If objPage.WebRadioGroup("name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
				
					strText = objPage.WebRadioGroup("name:="& ObjName,"index:="&IndexNum).GetROProperty("checked")
					
					If UCASE(KeyValue) = "CHECKED" Then
						If strText = 1 Then
							strText = "Checked"
						ElseIf strText = 0 Then
							strText = "Unchecked"
						End If					
						
					ElseIf UCASE(KeyValue) = "UNCHECKED" Then
						If strText = 0 Then
							strText = "Unchecked"
						ElseIf strText = 1 Then
							strText = "Checked"
						End If	
						
					End If	
					
				End If

		Case "WEBLIST"																			'	For Oracle List

				If objPage.WebList("name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					'	Get the list value
					strText = objPage.WebList("name:="& ObjName,"index:="&IndexNum).GetROProperty("default value")
				End If
				
				
'End*************************************************************************************************************************************
				
'		Case "LINK"
'				'Set objPage = funcCreatePageObj(BrowserName)
''				Set odesc1 = Description.Create
''				odesc1("micclass").value = "Link"
''				odesc1("html tag").value = ObjName
'				Set objLink = Browser("name:="&BrowserName).Page("title:="&BrowserName).Link("micclass:=Link","html tag:="&ObjName)
'				For iCnt=0 to objLink.Count-1
'					strText = objPage.Link("micclass:=Link","html tag:="&ObjName,"index:="&iCnt).GetROProperty("name")
'					If Instr(strText, KeyValue) > 0  Then
'						funcVerifyFieldValue = True
'					End If
'				Next

		Case Else														' Can extended for other object types
				Call gfReportExecutionStatus(micWarning,"Verify FieldValue", "Object "& ObjClass & " not handled")

	End Select

	' Verify the Actual value with Expected value
	If strText <> "" Then
		If strComp(Trim(cStr(strText)),Trim(cStr(KeyValue)))=0 then
			Call gfReportExecutionStatus(micDone,"Verify the FieldValue","Verified the value " & strText & " for "& objClass)
			funcVerifyFieldValue= True
		Else
			Call gfReportExecutionStatus(micFail,"Verify the FieldValue","Verification failed, Got " & strText & " and Expected " & KeyValue & " for " & objClass)
			funcVerifyFieldValue= False
		End If
	End If

	If UCase(KeyValue) = "NULL" Then
		If strText  = "" Then
			Call gfReportExecutionStatus(micDone,"Verify the FieldValue","Verified the Empty field value " & " for "& objClass)
			funcVerifyFieldValue= True
		Else
			Call gfReportExecutionStatus(micFail,"Verify the FieldValue","Verification failed, Got " & strText & " and Expected " & KeyValue & " for " & objClass)
			funcVerifyFieldValue= False
		End If
	End If

	'	Clean Up
	Set objForm = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcCloseOracleForm(FormName)
'# Function is used to close oracel form
'#
'# Parameters:
'# FormName:-Name of Form
'# intIndex		: Form Index
'#
'# Output Parameters: True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcCloseOracleForm(ByVal FormName, ByVal intIndex)
	Dim objForm

	On Error Resume Next
	Err.Clear

	'	Set Oracle Form object
	Set objForm=OracleFormWindow("short title:="& FormName,"Index:="& intIndex)		

	'	Check for form existence and close the form
	If objForm.Exist(gMEDIUMWAIT) Then
		objForm.CloseWindow
		funcCloseOracleForm= True
	Else
		funcCloseOracleForm= False
	End If

	'	Clean Up
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcLaunchBrowser(Customer,IndexNumber))
'# Function is used launch browser
'#
'# Parameters:
'# Customer:-Name of Form
'#IndexNumber:- Index (if applicable)
'#
'# Output Parameters: True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcLaunchBrowser(Customer,IndexNumber)
	Dim IE
	Dim BrowserObj,URL
	Dim vcol_Handles, vCtr, vHwnd, Flag, vLastHWnd, vbrowser,cbrowser
	If Customer<>"" Then
		vCtr = 0 
		Flag = 1 
		Set vcol_Handles = CreateObject("Scripting.Dictionary") 
		Do While (Window("regexpwndclass:=IEFrame","index:=" & vCtr).Exist ) 
			wait 1
			vHwnd = Window("regexpwndclass:=IEFrame","index:=" & vCtr).getroproperty("Hwnd")
			If (vLastHWnd=vHwnd) Then 
				Flag = 0 
				Exit do
			Else 
				vcol_Handles.Add CStr(vcol_Handles.Count),vHwnd 
				vCtr = vCtr+1 
			End If 
			vLastHWnd = vHwnd 
		Loop

		For vCtr = vcol_Handles.Count-1 to 0 step-1
			Wait 1 
			vHwnd = vcol_Handles.Item(CStr(vCtr)) 
			vBrowser = Window("regexpwndclass:=IEFrame","index:=" & vCtr).getroproperty("title") 
			If Instr(vBrowser, "Oracle Applications Home Page") or Instr (vBrowser,"Oracle Applications R12") Or Instr (vBrowser,"Login") Then 
				Window("hwnd:=" & vHwnd).Close 
			End If 
		Next

		Set vcol_Handles = Nothing
		Wait(gSHORTWAIT)

		'To get IE browser version
        Const HKEY_LOCAL_MACHINE = &H80000002
		strComputer = "."
		Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
		strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
		strValueName = "Version"
		oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue

		If cInt(Left(strValue,1)) >=8 Then
			If Customer="Oracle" Then
				URL=Environment.Value("URL")
			ElseIf Customer="SSOURL" Then
				URL=Environment.Value("SSOURL")
			ElseIf Customer="COSTAR" Then
				URL=Environment.Value("COSTRURL")
			End If
			SystemUtil.Run "iexplore.exe", "-noframemerging "&URL,"","","3" ' for IE 8 and above
			funcLaunchBrowser=True
			Exit Function
		Else
			SystemUtil.Run "iexplore.exe",URL,"","","3"' for IE7 and below
			funcLaunchBrowser=True
			Exit Function
			'Set IE = nothing
		End If

'		If Customer="Oracle" Then
'			URL="http://" & Environment.Value("URL")
'		ElseIf Customer="SSOURL" Then
'			URL=Environment.Value("SSOURL")
'		End If
'		Set IE = CreateObject ("InternetExplorer.Application")
'    	IE.Visible = true
'		IE.Navigate URL
'		funcLaunchBrowser=True
'		Exit Function
'		'Set IE = nothing
	End If
	funcLaunchBrowser=False

End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcCreateFrameObj(BrowserName,FrameName)
'# Function is used launch browser
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FrameName:- Frame Name
'#
'# Output Parameters: True/False
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcCreateFrameObj(ByVal BrowserName,ByVal FrameName)
	If Browser("micclass:=Browser","title:="&BrowserName).Exist(gLONGWAIT) Then
		Set funcCreateFrameObj= Browser("micclass:=Browser","title:="&BrowserName).Page("micclass:=Page","title:="&BrowserName).Frame("miclass:=Frame","title:="&FrameName)
	Else
		Call gfReportExecutionStatus(micFail,"OpenBrowser","Failed to open the browser	:" & BrowserName)							
		funcCreateFrameObj=False
    End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcCreatePageObj(BrowserName)
'# Function is used to create a page object
'#
'# Parameters:
'# BrowserName:-Name of Browser
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function  funcCreatePageObj(ByVal BrowserName)
	Dim intLen
	Dim odesc 
	Dim Frameobj 
	Dim frmTitle
	Dim intCounter
	Dim arrBrowserNames
	Dim intSize
	Dim tmpBrowserName

	On Error Resume Next
	Err.Clear

	If Instr(BrowserName,"#") > 0 Then

		intLen=Len(BrowserName)
		BrowserName = Right(BrowserName,intLen- 1)
		If Browser("micclass:=Browser","name:="&BrowserName).Exist(gLONGWAIT)  Then
			Set odesc = description.Create
			odesc("micclass").value = "Frame"
			odesc("html tag").value = "Frame"
			Set Frameobj = Browser("micclass:=Browser","name:="&BrowserName).Page("micclass:=Page","title:="&BrowserName).Childobjects(odesc)			
			For intCounter=0 To (Frameobj.Count- 1)
				frmTitle = Frameobj(intCounter).GetROProperty("title")
			Next
			Set funcCreatePageObj= Browser("micclass:=Browser","name:="&BrowserName).Page("micclass:=Page","title:="&BrowserName).Frame("title:="&frmTitle,"html tag:=FRAME")
			Exit Function
		Else
			Call gfReportExecutionStatus(micFail,"OpenBrowser","Failed to open the browser	:" & BrowserName)							
			funcCreatePageObj=False
		End If

	End If

	arrBrowserNames=Split("AppLab,Ace Glass Inc",",")
	For intCounter=0 to Ubound(arrBrowserNames)-1
		If Instr (BrowserName,arrBrowserNames(intCounter))> 0 Then

			Do While (Window("regexpwndclass:=IEFrame","index:=" & vCtr).Exist(gMEDIUMWAIT)) 
				tmpBrowserName = Window("regexpwndclass:=IEFrame","index:=" & vCtr).GetROProperty("title")
				intSize = Len(tmpBrowserName)
				BrowserName = Left(tmpBrowserName,(intSize-48))
				If InStr(BrowserName,arrBrowserNames(intCounter))>0 Then Exit Do
			Loop

		End If
		If Instr(BrowserName,arrBrowserNames(intLoop))>0 Then Exit For
	Next

	If Browser("micclass:=Browser","name:="&BrowserName).Exist(gLONGWAIT)  Then
	Readyst = Browser("micclass:=Browser","name:="&BrowserName).Object.ReadyState
		Do While Readyst <> "4"
		Wait(1)
		Readyst = Browser("micclass:=Browser","name:="&BrowserName).Object.ReadyState
		Loop
	Wait(gSYNCWAIT)
		Set funcCreatePageObj= Browser("micclass:=Browser","name:="&BrowserName).Page("micclass:=Page","title:="&BrowserName)
	Else
		Call gfReportExecutionStatus(micFail,"OpenBrowser","Failed to open the browser	:" & BrowserName)							
		funcCreatePageObj=False
	End If

	' Error Handling
	If Err.Number <> 0 Then		
		Call gfReportExecutionStatus(micFail,"Error in funcCreatePageObj", "Got Error: "& Err.Description)
		On Error GoTo 0
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcSetFocus(ByVal BrowserName, ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum,ByVal objClass,ByVal RowVal, ByVal ColVal)
'# Function is used to set the focus to the desired cell or text field
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FormName:- Name of the Form
'# TabName:-Tab ValueCheck/Uncheck
'# ObjName:-Name of the cell to be set           
'# ObjClass:-OracleTable/Oracletext field        
'# IndexNumber:-Index No 
'# RowVal:-Row number
'# ColVal:-Column Number"
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcSetFocus(ByVal BrowserName, ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum,ByVal objClass,ByVal RowVal, ByVal ColVal)
    Dim objForm
	Dim objOracleFlexForm
	Dim objPage
	Dim bSuccess

   On Error Resume Next
   Err.Clear

	bSuccess = False
	If BrowserName <> "" Then
		Set objPage = funcCreatePageObj(BrowserName)
	End If

	If FormName <> "" Then
		Set objForm = funcCreateFormObj(FormName,TabName)
	End If

	Select Case UCase(objClass)
		Case "ORACLETEXTFIELD"						'	For Oracle Text Filed
				If Instr(ObjName,"#") > 0 Then
					ObjName = Split(ObjName,"#")(1)
					If objForm.OracleTextField(ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
						objForm.OracleTextField(ObjName,"index:="&IndexNum).SetFocus
						bSuccess = True
					End If
				Else
					If objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
						objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).SetFocus 
                    	bSuccess = True
                    End If
				End If
                ''''If objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					'''objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).SetFocus 
                   '' bSuccess = True
				'''End If

		Case "ORACLEFLEXWINDOW"					'	For Oracle Flex Window
				Set objOracleFlexForm = OracleFlexWindow("title:="&FormName)
				'If objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					'objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).SetFocus 
					'bSuccess = True
				If Instr(ObjName,"#") > 0 Then 
					ObjName = Split(ObjName,"#")(1) 
					If objForm.OracleTextField(ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then 
						objForm.OracleTextField(ObjName,"index:="&IndexNum).SetFocus 
						bSuccess = True 
					End If 
				ElseIf objForm.OracleTextField("description:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then 
					objForm.OracleTextField("description:="& ObjName,"index:="&IndexNum).SetFocus 
					bSuccess = True 
				End if

		Case "ORACLEFORMWINDOW"					'	For Oracle Form Window
				If objForm.Exist(gMEDIUMWAIT) Then				
					objForm.SetFocus 
					bSuccess = True
				End If

		Case "ORACLETABLE"									'	For Oracle Table
				If isNumeric(RowVal) Then	
					RowVal =  cInt(RowVal)			'	Convert the row to numeric
				End If
				If isNumeric(ColVal) Then	
					ColVal =  cInt(ColVal)				'	Convert the Column to numeric
				End If

				If objForm.OracleTable("block name:="& ObjName, "index:="&IndexNum).Exist(gMEDIUMWAIT) Then
					objForm.OracleTable("block name:="& ObjName, "index:="&IndexNum).SetFocus RowVal, ColVal
					bSuccess = True
				End If

		Case "WEBEDIT"													' 	For WebEdit
'========================================================ravikanth on 24-nov-2014
				If Instr(ObjName,"#") > 0 Then
					ObjName = Split(ObjName,"#")(1)
					If objPage.WebEdit(ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
						objPage.WebEdit(ObjName,"index:="&IndexNum).Click
						bSuccess = True
					End If
				Else
'========================================================ravikanth on 24-nov-2014
					If objPage.WebEdit("name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
						objPage.WebEdit("name:="& ObjName,"index:="&IndexNum).Click
						bSuccess = True
					End If
				End If

		Case Else										'	No Match found
				Call gfReportExecutionStatus(micWarning,"Set focus","Incorrect option " & objClass & " Check the Usage of Keyword: SetFocus")

	End Select

	' Return value
	funcSetFocus = bSuccess

	' Clean Up
	Set objForm = Nothing
	Set objOracleFlexForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSubledger_JournalEntryLines(BrowserName,ObjName)
'# Function is used to 
'#
'# Parameters:
'# BrowserName:- Name of the Browser
'# ObjName:-Name of the object
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcSubledger_JournalEntryLines(BrowserName,ObjName)
	Dim objPage,objForm,sObj
	Dim TextGLDate
	Dim currentdate
	Dim TextAccountingClass
	Dim TextAccountingDr
	Dim TextAccountingCr

	If BrowserName <> "" Then
		Set objPage= funcCreatePageObj(BrowserName)
		If objPage.WebTable("name:="&ObjName).Exist(gSHORTWAIT) Then			
			For intLoop=2 to objPage.WebTable("name:="&ObjName).GetROProperty("rows")
				TextGLDate=objPage.WebTable("name:="&ObjName).GetCellData(intLoop,5)
				currentdate=split(TextGLDate,"-")
				TextAccountingClass=objPage.WebTable("name:="&ObjName).GetCellData(intLoop,6)
				TextAccountingDr=objPage.WebTable("name:="&ObjName).GetCellData(intLoop,7)
				TextAccountingCr=objPage.WebTable("name:="&ObjName).GetCellData(intLoop,8)
				Call gfReportExecutionStatus(micPass,"Subledger Journal Entry Lines"," The accounting entries for the month "  &currentdate(1)&  " are,AccountingClass: " &TextAccountingClass& "   AccountingDr: "   &TextAccountingDr& "    AccountingCr: " &TextAccountingCr)
			Next
			funcSubledger_JournalEntryLines=True
		Else
			Call gfReportExecutionStatus(micFail,"WebTable"," Table object does not exist so not able to get accounting entries for table:" & ObjName)
			funcSubledger_JournalEntryLines=False
		End If
	Else
		funcSubledger_JournalEntryLines=False
	End If	
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcCreateFormObj(FormName,TabName)
'# Function is used to Creates Oracle form 
'#
'# Parameters:
'# FormName:- Name of the Form
'# TabName:-Oracle Tab Name
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function  funcCreateFormObj(FormName,TabName)

	On Error Resume Next
	Err.Clear

	' If forn name contans the "#"
	If InStr(FormName,"#")  > 0 Then

		If OracleFormWindow("short title:="& Split(FormName,"#")(0),"Index:="& Split(FormName,"#")(1)).Exist(gMEDIUMWAIT) Then
				If TabName = "" Then
						Set funcCreateFormObj = OracleFormWindow("short title:="& Split(FormName,"#")(0),"Index:="& Split(FormName,"#")(1))
				ElseIf Instr(TabName,"#") > 0 Then
						Set funcCreateFormObj = OracleFormWindow("short title:="& Split(FormName,"#")(0) ,"Index:="& Split(FormName,"#")(1)).OracleTabbedRegion("label:=" & Split(TabName,"#")(0),"index:=" & Split(TabName,"#")(1))
				Else
						Set funcCreateFormObj=OracleFormWindow("short title:="& Split(FormName,"#")(0) ,"Index:="& Split(FormName,"#")(1)).OracleTabbedRegion("label:="&TabName)
				End If
		Else
				Call gfReportExecutionStatus(micFail,"OpenOracleForm","Failed to open the the Oracle Form	:"  & FormName)							
				funcCreateFormObj = False
		End If

	ElseIf OracleFormWindow("short title:="& FormName).Exist(gMEDIUMWAIT)  Then	' If form finds with property short title

			If TabName = "" Then
					Set funcCreateFormObj= OracleFormWindow("short title:=" & FormName)
			ElseIf InStr(TabName,"#") > 0 Then
					Set funcCreateFormObj= OracleFormWindow("short title:=" & FormName).OracleTabbedRegion("label:=" & Split(TabName,"#")(0) , "index:="& Split(TabName,"#")(1))  
			Else
					If OracleFormWindow("short title:=" & FormName).OracleTabbedRegion("label:="&TabName).Exist(gMEDIUMWAIT) Then
						Set funcCreateFormObj= OracleFormWindow("short title:=" & FormName).OracleTabbedRegion("label:="&TabName)
					End If
			End If

	ElseIf OracleFlexWindow("title:="& FormName).Exist(gMEDIUMWAIT)  Then				' for Oracle Flex window.
			Set funcCreateFormObj= OracleFlexWindow("title:=" & FormName)

	Else																																									' not able to find the form
			Call gfReportExecutionStatus(micFail,"OpenOracleForm","Failed to open the the Oracle Form	:" &FormName)							
			funcCreateFormObj = False
	End If

	' Error Handling
	If Err.Number <> 0 Then		
		Call gfReportExecutionStatus(micFail,"Error in CreateFormObj", "Got Error: "& Err.Description)
		On Error GoTo 0
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: gfReplaceSpChar(strSearch,SplCharacterToSearch, replChr)
'# Function is used to replace specialcharacters
'#
'# Parameters:
'# strSearch:- String to search
'# SplCharacterToSearch:-Special character to Search
'# replChr:-Character to replace
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function gfReplaceSpChar(strSearch,SplCharacterToSearch,replChr)
	Dim tmpChar
	Dim intLoop 

	tmpChar = Split(SplCharacterToSearch,";",-1,1)
	For intLoop = 0 to UBound(tmpChar)
		strSearch = Replace(strSearch,tmpChar(intLoop ),"\" & tmpChar(intLoop ) )
	Next

	gfReplaceSpChar = strSearch
End Function

'*******************************************************************************************************************************************************************************************
'# Function: gfRegReplaceSpChar(strSearch, replStr)
'#
'# Parameters:
'# Input Parameters: 
'# strSearch
'# replStr
'#
'# OutPut Parameters: N/A
'#
'# Usage: 
'*******************************************************************************************************************************************************************************************
Function gfRegReplaceSpChar(strSearch, replStr)	
	Dim regEx

	' Create regular expression.
	Set regEx = New RegExp
    regEx.Pattern = "(\:)|(\[)|(\])|(\/)"
	regEx.IgnoreCase = True
	regEx.Global = True

    Set Matches = regEx.Execute(strSearch)   ' Execute search.

	For Each Match in Matches      ' Iterate Matches collection.
		'RetStr =  Match.Value 	
		RetStr =  regEx.Replace(strSearch,replStr)'replStr & Match.Value
	Next

	'RegExpTest = RetStr
	gfReplaceSpChar= RetStr
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcFlexWindowSetText(ByVal BrowserName, ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum, ByVal TextValue, ByVal bUniqueValues, ByVal strTestStepID)
'# This function is used to enter value in the Oracle flex textbox field
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of Form
'# TabName:-Tab value (if any)
'# ObjName:-Field name where the value has to be entered
'# TextValue:-captured value to be  entered in the flex field
'# IndexNum:-Index number (if needed)
'# bUniqueValues :- To make TextValue as Unique appends the timeStamp True/False
'#bOpenDialog:- To open dialog associted with textbox True/False
'# strTestStepID:- Step Id to store the text value in global dict for futher reference
'# 
'# OutPut Parameters: True/False
'#
'# Usage: funcFlexWindowSetText(BrowserName,FOrmName,TabName,ObjName,TextValue,IndexNum,bUniqueValues, strTestStepID)
'*******************************************************************************************************************************************************************************************
Function funcFlexWindowSetText(ByVal BrowserName, ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum, ByVal TextValue, ByVal bUniqueValues,ByVal bOpenDialog,ByVal strTestStepID)
	Dim objOracleFlexForm

	On Error Resume Next
	Err.Clear

	'Create Oracle flex form object
	Set objOracleFlexForm = OracleFlexWindow("title:="&FormName)

	'  To make the unique values for TextValue
	If UCase(bUniqueValues) = "TRUE" Then
		TextValue = TextValue & Day(Now) & Hour(Now)& Minute(Now) & Second(Now)

		'	Store the value in Global dict
		dicGlobalOutput.Add strTestStepID, TextValue
	End If

	' Check the field is editable or not
	If objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).GetROProperty("editable") Then
		objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).Enter TextValue

		If UCase(bOpenDialog) = "TRUE" Then
			objOracleFlexForm.OracleTextField("prompt:="&ObjName,"index:="&IndexNum).OpenDialog			' Opens the dialog associated with textfield
		End If

		funcFlexWindowSetText = True
	Else
		funcFlexWindowSetText = False        
	End If 

	' Clean Up
	Set objOracleFlexForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcClickLink(BrowserName,ObjName,IndexNum)
'# This function is used to Click link in the browser
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# ObjName:- Link name to click
'# IndexNum:-Index number (if needed)
'#
'# OutPut Parameters: True/False
'#
'# Usage: > funcLinkClick(BrowserName,ObjName,IndexNum)
'*******************************************************************************************************************************************************************************************
Function funcClickLink(ByVal BrowserName,ByVal ObjName,ByVal IndexNum)
	Dim objPage
	Dim objLink
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	
	' Create Page Object
	bSuccess = False
	If BrowserName <> "" Then
		Set objPage = funccreatePageObj(BrowserName)
	End If

	'Check for Page link
    If objPage.Link("name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then					
		Set objLink = objPage.Link("name:="& ObjName,"index:="&IndexNum)
	ElseIf InStr(ObjName,"#") > 0Then
		Set objLink = objPage.Link(Split(ObjName,"#")(1),"index:="&IndexNum)
    Else
		' Look for the link .*ObjName.* in do loop, by clicking the next link. Ends the loop if next link doesn't appear.
		Do
			If objPage.Link("name:=.*" & ObjName &".*","index:="&IndexNum).Exist(gMEDIUMWAIT) Then
				set objLink = objPage.Link("name:=.*" & ObjName &".*","index:="&IndexNum)
				Exit Do
			Else
				objPage.Link("name:=Next.*","index:="&IndexNum).Click
			End If
		Loop While objPage.Link("name:=Next.*","index:="&IndexNum).Exist(gMEDIUMWAIT)
    End If

	' Click on Link if exists
	If objLink.Exist(gMEDIUMWAIT) Then
		objLink.Click
		bSuccess = True
	Else
		bSuccess = False
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Return value
	funcClickLink = bSuccess
	
	' Clean Up
	Set objPage = Nothing
	Set objLink = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSelectMenu(ByVal FormName, ByVal MenuName,ByVal SubMenu,ByVal SubMenu1)
'# This function is used to Selecting toolbar option in the form
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# MenuName:-Name of the menu
'# SubMenu:-Sub item in sub menu as needed.
'# SubMenu1:-Sub item in sub menu as needed.
'#
'# OutPut Parameters: True/False
'#
'# Usage: funcSelectMenu(FormName,MenuName,SubMenu,SubMenu1)
'*******************************************************************************************************************************************************************************************
Function funcSelectMenu(ByVal FormName, ByVal MenuName,ByVal SubMenu,ByVal SubMenu1)
	Dim strMenu
	Dim objForm

	On Error Resume Next
	Err.Clear

	'	Check FormName is not null
	If FormName <>"" Then
		Set objForm = funcCreateFormObj(FormName,"")
	End If

	' Wait till the Form Exists      
	If objForm.Exist(gLONGWAIT) Then
		' Select  on Menu
		objForm.SelectMenu  MenuName & "->" & SubMenu  & "->" & SubMenu1
		funcSelectMenu=True
    Else
		funcSelectMenu=False
	End If

	' Clean Up
	Set objForm = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function: funSetCheckBoxStatus(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal CheckBoxName,ByVal Status,ByVal IndexNum)
'# This function is used to Check/Uncheck the checkBox in Browser & Oracle forms
'#
'# Parameters:
'# BrowserName:- Name of the Browser
'# FormName:-Name of the Oracle form C
'# CheckBoxName:-Property of checkbox 
'# Status:- Check/Uncheck            
'# IndexNum:-Index Number        
'# TabName:-Tabname of the browser/Oracleform
'# 
'# OutPut Parameters: True/False
'#
'# Usage: funSetCheckBoxStatus( BrowserName, FormName, TabName,  CheckBoxName, Status, IndexNum)
'*******************************************************************************************************************************************************************************************
Function funSetCheckBoxStatus(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal CheckBoxName,ByVal IndexNum, ByVal Status)
	Dim objPage
	Dim objForm
	Dim objCheckBox
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	If BrowserName <> "" Then																			' For Checkbox browser in Web
		Set objPage= funcCreatePageObj(BrowserName)

		If InStr(CheckBoxName,"#") > 0  Then
			If objPage.WebCheckBox(Split(CheckBoxName,"#")(1),"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
				Set objCheckBox = objPage.WebCheckBox(Split(CheckBoxName,"#")(1),"index:="&IndexNum)
			End If
		ElseIf objPage.WebCheckBox("name:="&CheckBoxName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
			Set objCheckBox = objPage.WebCheckBox("name:="&CheckBoxName,"index:="&IndexNum)
		End If

	End If
			
	If FormName <> "" Then																			' For Checkbox in oracle form
		Set objForm = funcCreateFormObj(FormName,TabName)

		'When the checkbox is not having any label value give the avaliable property for to identify the check box For Eg. "#developername:=xyz"
		If InStr(CheckBoxName,"#") > 0  Then
			If objForm.OracleCheckbox( Split(CheckBoxName,"#")(1),"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
				Set objCheckBox= objForm.OracleCheckbox(CheckBoxName,"index:="&IndexNum)
			End If
		ElseIf objForm.OracleCheckbox("label:="&CheckBoxName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then
			Set objCheckBox=objForm.OracleCheckbox("label:="&CheckBoxName,"index:="&IndexNum)
		End If

	End If

	' Check the checkbox
	If UCase(Status) = "CHECK" Then
		If BrowserName <> "" Then
			objCheckBox.Set "ON"
		Else
			objCheckBox.Select
		End If
		bSuccess = True
	End If

	' UnCheck the checkbox
	If UCase(Status) = "UNCHECK" Then
		If BrowserName <> "" Then
			objCheckBox.Set "OFF"
		Else
			objCheckBox.Clear
		End If
		bSuccess = True
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Retrun value
	funSetCheckBoxStatus = bSuccess

	'Clean Up
	Set objCheckBox = Nothing
	Set objForm = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSelectRadioButton(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum,ByVal RadioButtonToSelect)
'# This function is used to Select radio button in oracle browser or form
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of form
'# TabName:-Tab value (if any)
'# ObjName:-Name of radio button to be selected
'# IndexNum:-Index Number (if needed)
'# RadioButtonToSelect:-Name of the radio button displaying in the open screen
'# 
'# OutPut Parameters: True/False
'#
'# Usage:funcSelectRadioButton(BrowserName,FormName,TabName,ObjName,IndexNum, RadioButtonToSelect)
'*******************************************************************************************************************************************************************************************
Function funcSelectRadioButton(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum,ByVal RadioButtonToSelect)
	Dim objPage
	Dim objForm
	Dim objRadioBtn
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	' Check for radiobuton in web
	bSuccess = False
	If BrowserName <> "" Then
		Set objPage= funcCreatePageObj(BrowserName)
		If objPage.WebRadioGroup("name:="&ObjName,"index:="&IndexNum).Exist (gLONGWAIT) Then
			Set objRadioBtn = objPage.WebRadioGroup("name:="&ObjName,"index:="&IndexNum)
		'====================================================ravikanth 21-sep-2014
		ElseIf Instr(ObjName,"#") > 0 Then
			ObjName = Split(ObjName,"#")(1)
			Set objRadioBtn = objPage.WebRadioGroup(ObjName,"index:="&IndexNum)
		'====================================================ravikanth 21-sep-2014
		End If
	End If

	' Check for radiobuton in form
	If FormName <>"" Then
		Set objForm = funcCreateFormObj(FormName,TabName)
		If objForm.OracleRadioGroup("developer name:="& ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then			
			Set objRadioBtn = objForm.OracleRadioGroup("developer name:="& ObjName,"index:="&IndexNum)
		'====================================================ravikanth 21-sep-2014
		ElseIf Instr(ObjName,"#") > 0 Then
			ObjName = Split(ObjName,"#")(1)
			Set objRadioBtn = objForm.OracleRadioGroup(ObjName,"index:="&IndexNum)
		'====================================================ravikanth 21-sep-2014
		End If
	End If

	'	Get the item name at the runtime based on the index, if 'all item' property is available
   If IsNumeric(RadioButtonToSelect) And InStr(objRadioBtn.GetROProperty("all items"),";")>0  Then
        RadioButtonToSelect = Cint(RadioButtonToSelect)-1
        RadioButtonToSelect = Split(objRadioBtn.GetROProperty("all items"),";")(RadioButtonToSelect)
	'====================================================ravikanth 21-sep-2014
	ElseIf IsNumeric(RadioButtonToSelect) And InStr(objRadioBtn.GetROProperty("all items"),";")=0 And objRadioBtn.GetROProperty("selected item")="All Currencies" Then
		RadioButtonToSelect = 1
	'====================================================ravikanth 21-sep-2014		
	'====================================================CSC - 17-Jul-2015
	ElseIf IsNumeric(RadioButtonToSelect) And InStr(objRadioBtn.GetROProperty("all items"),";")=0 And objRadioBtn.GetROProperty("selected item")="Import" Then
		RadioButtonToSelect = 3
	'====================================================CSC - 17-Jul-2015		

	ElseIf IsNumeric(RadioButtonToSelect) And InStr(objRadioBtn.GetROProperty("all items"),";")=0 Then
		RadioButtonToSelect = 0
    End If
	
	If objRadioBtn.Exist(10) Then
		'Select the radio button and return the value
		objRadioBtn.Select RadioButtonToSelect
		bSuccess = True
	Else
		bSuccess = False		
	End If

    ' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Retrun the value
	funcSelectRadioButton = bSuccess

	'Clean Up
	Set objRadioBtn = Nothing
	Set objPage = Nothing
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcGetTextBoxValue(ByVal BrowserName, ByVal FormName,ByVal TabName, ByVal ObjName, ByVal IndexNum, ByVal strStepID)
'# This function is To get the textbox value
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of Form
'# ObjName:-Name of textfield from where value has to be read
'# TabName:-Tab value (if any)
'# IndexNum:-Index number (if needed)
'# strStepID:- Step ID
'# 
'# OutPut Parameters: True/False
'#
'# Usage: funcGetTextBoxValue(BrowserName,FormName,TabName,ObjName,IndexNum, strStepID)
'*******************************************************************************************************************************************************************************************
Function funcGetTextBoxValue(ByVal BrowserName, ByVal FormName,ByVal TabName, ByVal ObjName, ByVal IndexNum, ByVal strStepID)
	Dim objPage
	Dim objForm
	Dim strText

	On Error Resume Next
	Err.Clear
	strText = ""			' initalisation

	' Get the textbox value in a browser
	If BrowserName <> "" Then
		Set objPage = funcCreatePageObj(BrowserName)
'========================================================ravikanth on 24-nov-2014
		If InStr(ObjName,"#") >0 Then
			If objPage.WebEdit(ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then
				strText = objPage.WebEdit(ObjName,"index:="&IndexNum).GetROProperty("value")
			End If
		Else
'========================================================ravikanth on 24-nov-2014
			If objPage.WebEdit("name:="& ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then
				strText = objPage.WebEdit("name:="& ObjName,"index:="& IndexNum).GetROProperty("value")
			Else
				Call gfReportExecutionStatus(micFail, "Get the Textbox Value", "Textbox " & ObjName & " not exists in the browser " &BrowserName)
				Exit Function
			End If
		End If
	End If

	' Get the textbox value in a form
	If FormName <> "" Then
		Set objForm = funcCreateFormObj(FormName,TabName)

		If InStr(ObjName,"#") >0 Then																								' For flex TextField controls

			If objForm.OracleTextField(Split(ObjName,"#")(1),"index:="&IndexNum).Exist(gLONGWAIT) Then
				strText = objForm.OracleTextField(Split(ObjName,"#")(1),"index:="&IndexNum).GetROProperty("value")
			Else
				Call gfReportExecutionStatus(micFail, "Get the Flex Textbox Value", "Flex Textbox " & ObjName & " not exists in the flex form " & FormName)
				Exit Function
			End If

		ElseIf objForm.OracleTextField("description:="& ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then		' For Oracle TextField controls

			strText = objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum).GetROProperty("value")

		Else

			Call gfReportExecutionStatus(micFail, "Get the Textbox Value", "Textbox " & ObjName & " not exists in the form " & FormName)
			Exit Function

		End If
	End If


	'Adding to Global dicitionary
	dicGlobalOutput.Add strStepID, strText

	'Return Value
	funcGetTextBoxValue	= strText

	'Clean Up
	Set objPage = Nothing
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcClickFlexbutton(ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum)
'# This function to click on Flex button
'# 
'# Parameters:
'# FormName:-Name of Form
'# ObjName:-Name of field from where value has to be read
'# TabName:-Tab value (if any)
'# IndexNum:-Index number (if needed)
'# 
'# OutPut Parameters: True/False
'#
'# Usage: funcClickFlexbutton(FormName,TabName, ObjName,IndexNum)
'*******************************************************************************************************************************************************************************************
Function funcClickFlexbutton(ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum)
	Dim objOracleFlexForm

	On Error Resume Next
	Err.Clear

	' Set the Oracle Flex Object
	Set objOracleFlexForm =OracleFlexWindow("title:="&FormName)

	'Check for Oracle flex button and click on it if exists.
    If objOracleFlexForm.OracleButton("label:="&ObjName,"index:="&IndexNum).Exist(gLONGWAIT) Then		
		objOracleFlexForm.OracleButton("label:="&ObjName,"index:="&IndexNum).Click
		funcClickFlexbutton = True		
	Else
		funcClickFlexbutton = False		
	End If

	' Clean Up
	Set objOracleFlexForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:funcClickButton(BrowserName,FormName,TabName, ObjName,IndexNum,HtmlId)
'# This function to click on button
'# Parameters:
'# BrowserName:-Name of the Browser
'# FormName:-Name of Form
'# ObjName:-Name of field from where value has to be read
'# TabName:-Tab value (if any)
'# IndexNum:-Index number (if needed)
'# HtmlId:- Html id (If nam and index not helps to identify the object uniquely
''#ButtonName:-Name of the button, in OracleNotification window, that needs to be clicked (use when we to click button other than OK/Yes)
'# 
'# OutPut Parameters: True/False
'#
'# Usage:
'*******************************************************************************************************************************************************************************************
'============================ravikanth 26-sep-2014
'Function funcClickButton(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum)
Function funcClickButton(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum,ByVal ButtonName, ByVal HtmlId)
'============================ravikanth 26-sep-2014
	Dim objButton
	Dim objForm
	Dim objBrowser
	Dim bSuccess

    On Error Resume Next
	Err.Clear

	'	For web button
	bSuccess = False
	If BrowserName <> "" Then
			Set objBrowser= funcCreatePageObj(BrowserName)      
			Set objButton = objBrowser.WebButton("name:="&ObjName,"index:="&IndexNum, "visible:=True")
	End If

If HtmlId <> "" Then
	Set objButton = objBrowser.WebButton("Html id:="&HtmlId)
End If
	'======================================ravikanth. 26-sep-2014
	'Added on 23rd Sep 2014 - To accomodate clicking button other than 'Yes/OK' - Note: Modified the ClickButton function parameters in 'Functions and KeyActions' files
	If FormName = "OracleNotification" AND ButtonName <> "" Then
			'OracleNotification("title:="& ObjName).Decline
			OracleNotification("title:="& ObjName).Choose(ButtonName)
			funcClickButton = True
			Exit Function
	End If
	'======================================ravikanth. 26-sep-2014
	'======================================ravikanth. 09-mar-2015
	If ucase(FormName) = ucase("OracleListOfValues") AND ButtonName = "Cancel" Then
			OracleListOfValues("title:="& ObjName).Cancel
			funcClickButton = True
			Exit Function
	ElseIf ucase(FormName) = ucase("OracleListOfValues") AND ButtonName = "OK" Then
			OracleListOfValues("title:="& ObjName).select 1
			funcClickButton = True
			Exit Function
	End If
	'======================================ravikanth. 09-mar-2015
	'	For the Oracle Notification form
	If FormName = "OracleNotification" Then
			OracleNotification("title:="& ObjName).Approve
			funcClickButton = True
			Exit Function
	End If

	'	For Oracle button
	If FormName <> "" Then
			Set objForm = funcCreateFormObj(FormName,TabName)
			If InStr(ObjName,"#") >0 Then
				Set objButton = objForm.OracleButton(Split(ObjName,"#")(1),"index:="&IndexNum)
			Else
				Set objButton = objForm.OracleButton("description:="&ObjName,"index:="&IndexNum)
			End If
	End If

	'Check the existance of the button object and click on it.
	If objButton.Exist(gSYNCWAIT) Then
		objButton.Click
		wait(3)
		bSuccess = True
	Else
		bSuccess = False
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Return Value
	funcClickButton = bSuccess

	'	Clean up
	Set objBrowser = Nothing
	Set objButton = Nothing
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:funcEnterValuesInOracleTable(FormName,TabName,ObjName,ColumnName,ColumnValue,RepeatInputs, bUniqueValues,strTestStepID)
'# This function to enter value in Oracle table
'# Parameters:
'# FormName:- Name of the Oracleform
'# TabName:- Name of the Oracletab
'# ObjName:- Name of the Oracletable
'# ColumnName:- Name of column
'# ColumnValue:-Value to be enter in the field
'# RepeatInputs:- Row number"
'# 
'# OutPut Parameters: True/False
'#
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcEnterValuesInOracleTable(ByVal FormName,ByVal TabName,ByVal ObjName,ByVal RowNumber, ByVal ColumnName,ByVal CellValue, ByVal bUniqueValues,ByVal bOpenDialog, ByVal strTestStepID)
	Dim objForm
	Dim tblObject
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	Set objForm = funcCreateFormObj(FormName,TabName)

	' 	Create the table object
	If InStr(1,ObjName,"#")>0 Then
		Set tblObject = objForm.OracleTable("index:="&Replace(ObjName,"#",""))
	Else
		Set tblObject = objForm.OracleTable("block name:="&ObjName)
	End If

	'	To Check the row is numeric
	If isNumeric(RowNumber) Then
		 RowNumber =  cInt(RowNumber)
	End If

	'	To Check the column is numeric
	If isNumeric(ColumnName) Then
		 ColumnName =  cInt(ColumnName)
	End If
 
	'  To make the unique values for ColumnValue
	If (bUniqueValues <> "" And UCase(bUniqueValues) = "TRUE") Then
		'CellValue = CellValue & Day(Now) & Hour(Now)& Minute(Now) & Second(Now)
		CellValue = CellValue & Minute(Now) & Second(Now)

		'	Store the value in Global dict
		dicGlobalOutput.Add strTestStepID,CellValue
	End If

	'	Enter the value in table with row and column number
	If tblObject.Exist(gSYNCWAIT) Then
		'	Set the focus in the cell before entering the text
		tblObject.SetFocus RowNumber, ColumnName
		Wait 2

		tblObject.EnterField RowNumber, ColumnName, CellValue,False

		If UCase(bOpenDialog) = "TRUE" Then											
			tblObject.OpenDialog RowNumber, ColumnName				' Opens the dialog associated with textfield
		End If

		bSuccess = True
	Else
		bSuccess = False
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Return Value
	funcEnterValuesInOracleTable = bSuccess

	'	Clean Up
	Set tblObject = Nothing
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcTabSelect(ByVal FormName,ByVal TabName)
'# This function to Select the tab
'# Parameters:
'# FormName:-Name of Form
'# TabName:-Tab Value (If any)
'# 
'# OutPut Parameters: True/False
'#
'# Usage:funcTabSelect(FormName,TabName)
'*******************************************************************************************************************************************************************************************
Function funcTabSelect(ByVal FormName,ByVal TabName)
	Dim  objForm

	On Error Resume Next
	Err.Clear

	'Create the form object
	Set objForm = funcCreateFormObj(FormName,TabName)

	'Check for from existence and select the tab.
	If objForm.Exist(gLONGWAIT) Then
		objForm.Select 
		funcTabSelect = True			
	Else
		funcTabSelect = False			
	End If

	' Clean up
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcGetScreenMessage(ByVal BrowserName,ByVal ObjName,ByVal StrMessage,ByVal ArrayPosition,ByVal TestStepID)
'# This function captures the messege from browser screen
'# Parameters:
'# BrowserName:-Name of Browser
'# ObjName:- Property 'html tag' value
'# StrMessage:-some text of the expected messege
'# ArrayPosition:-postion of the created number of any value
'# TestStepID:- Test Step ID
'# 
'# OutPut Parameters: True/False
'#
'# Usage:  funcGetScreenMessage(BrowserName,ObjName,StrMessage,ArrayPosition,TestStepID)
'*******************************************************************************************************************************************************************************************
Function funcGetScreenMessage(ByVal BrowserName,ByVal ObjName,ByVal StrMessage,ByVal ArrayPosition,ByVal TestStepID)
	Dim oDesc
	Dim objPage
	Dim objWebElements
	Dim intRequestId
	Dim strText
	Dim intCounter
	Dim arrSrtingVals
	Dim strValue
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	Set objPage= funcCreatePageObj(BrowserName)
	Set oDesc = Description.Create
	oDesc("micclass").value = "WebElement"
	oDesc("html tag").value = ObjName
	Set objWebElements = objPage.ChildObjects(oDesc)

	' Verify the message, if ArrayPosition not null and store the integer in a global dict
	For intCounter=0 To objWebElements.Count-1
		strText = objWebElements(intCounter).GetROProperty("innerText")

		If Instr (strText,StrMessage)>0 Then

			If ArrayPosition <> "" And IsNumeric(ArrayPosition) Then
				intRequestId = funcSearchPattern(strText,  "[+0-9]+", ArrayPosition)
				dicGlobalOutput.add TestStepID, intRequestId

			ElseIf ArrayPosition <> "" And Not IsNumeric(ArrayPosition) Then						' This is to process the request with IEXP12345
				arrSrtingVals = Split(strText," ")
				For each strValue in arrSrtingVals
					If InStr(1,strValue,ArrayPosition,0)>0 Then
						dicGlobalOutput.add TestStepID, strValue
						Exit For
					End If
				Next
			End If

			bSuccess = True
			Exit For
		End If		
	Next

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Return Value
	funcGetScreenMessage = bSuccess

	'Clean Up
	Set objWebElements = Nothing
	Set oDesc = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function funcTextBoxSetText(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum,ByVal TextValue,ByVal bUniqueValues,ByVal bOpenDialog, ByVal strTestStepID)
'# This function is used to set text value in the field 
'# 
'# Parameters:
'# BrowserName:-Name of Broswer
'# FormName:-Name of Form
'# TabName:-Tab Value (If any)
'# ObjName:-Name of Field where to enter
'# IndexNum:-Index no. if needed
'# TextValue:-Value to be entered
'#bUniqueValues:- To make the TextValue unique by appending the timestamp True/False
'#bOpenDialog:- To open dialog associted with textbox True/False
'#strTestStepID:- Step Id
'# 
'# OutPut Parameters: True/False
'#
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcTextBoxSetText(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal IndexNum,ByVal TextValue,ByVal bUniqueValues,ByVal bOpenDialog, ByVal strTestStepID)
	Dim objPage
	Dim objForm
	Dim objTextBox
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	'	Enter textvalue for browser
	If BrowserName <> "" Then
		Set objPage = funcCreatePageObj(BrowserName)		
		 objPage.Sync
'		 wait(gSYNCWAIT)

		If Instr(ObjName,"#") > 0 Then
			ObjName = Split(ObjName,"#")(1)
			Set objTextBox = objPage.WebEdit(ObjName,"index:="&IndexNum)
		Else
			Set objTextBox = objPage.WebEdit("name:="&ObjName,"index:="&IndexNum)
		End If

	End If

	'	Enter textvalue for Form
	If FormName <> "" Then
		Set objForm = funcCreateFormObj(FormName,TabName)
		'================================================ravikanth 12-sep-2014
		If Instr(ObjName,"#") > 0 Then
			ObjName = Split(ObjName,"#")(1)
			Set objTextBox = objForm.OracleTextField(ObjName,"index:="&IndexNum)
		Else
			Set objTextBox = objForm.OracleTextField("description:="&ObjName,"index:="&IndexNum)
		End If
		'================================================ravikanth 12-sep-2014
	End If

	'	Check the textbox is editable or not
'	If (objTextBox.GetROProperty("editable") =False And  FormName <> "" ) Or  (objTextBox.GetROProperty("disabled") =1 And  BrowserName <> "") Then
'		gfReportExecutionStatus micWarning,"Enter Text " &ObjName, "Filed " & ObjName& " not editable"
'		funcTextBoxSetText = False
'		Exit Function
'    End If	

	'  To make the unique values for TextValue
	If bUniqueValues <> "" Then
		'Randomize
		'TextValue = TextValue &  Day(Now) & Hour(Now)& Minute(Now) & Second(Now)
		'TextValue = TextValue &  RandomNumber.Value(1,9) & Hour(Now)& Minute(Now) & Second(Now)
		TextValue = TextValue &  RandomNumber.Value(1000000,9999999)

		'	Store the value in Global dict
		dicGlobalOutput.Add strTestStepID,TextValue
	End If

	If objTextBox.Exist(gSYNCWAIT) Then
		If BrowserName <> "" Then
		objTextBox.highlight
			objTextBox.Set TextValue					' Set the value for webEdit

		Else
			objTextBox.Enter TextValue				' Set the value for Oracle text box

			If UCase(bOpenDialog) = "TRUE" Then											
				objTextBox.OpenDialog				' Opens the dialog associated with textfield
			End If

		End If
		bSuccess = True
	Else
		bSuccess = False
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Return value
	funcTextBoxSetText = bSuccess

	'	Clean Up
	Set objPage = Nothing
	Set objForm = Nothing
	Set objTextBox = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcSetFormattedCurrentDate(BrowserName,FormName,TabName,ObjName,strDateFormat,RowNumber,ColumnName)
'# This function is used to set current formatted Date in the field 
'# 
'# Parameters:
'# BrowserName:-Name of Broswer
'# FormName:-Name of Form
'# TabName:-Tab Value (If any)
'# ObjName:-Name of Field where to enter
'# strDateFormat:- Date Format
'# RowNumber:-Name of the Row in Oracle Table
'# ColumnName:-Name of the Column in Oracle Table
'# 
'# OutPut Parameters: True/False
'#
'# Usage:  funcSetFormattedCurrentDate(BrowserName,FormName,TabName,ObjName,strDateFormat,RowNumber,ColumnName)
'*******************************************************************************************************************************************************************************************
Function funcSetFormattedCurrentDate(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName,ByVal strDateFormat,ByVal RowNumber,ByVal ColumnName)
	Dim objPage
	Dim objForm
	Dim objOracleFlexform
    Dim objFlexTextField
	Dim objTable
	Dim strDateReformat
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	' Reformat current system date in the format defined in the input test flow designer sheet
	strDateReformat = gfFormatDate(Now(), strDateFormat) 
	bSuccess = False

	'Create page object and enter date
	If BrowserName <> "" Then
		Set objPage= funcCreatePageObj(BrowserName)
		If objPage.WebEdit("name:="&ObjName).Exist(gLONGWAIT) Then
			objPage.WebEdit("name:="&ObjName).Set strDateReformat
			bSuccess = True
		End If
	End If

	' Create form object and set date in TextField
	Set objForm = funcCreateFormObj(FormName,TabName)
	If objForm.OracleTextField("description:="&ObjName).Exist(gMEDIUMWAIT) Then
		objForm.OracleTextField("description:="&ObjName).Enter strDateReformat
		bSuccess = True
	End If

		' Convert Row and cloumn name to integer
	If IsNumeric(RowNumber) Then	RowNumber=Cint(RowNumber)
	If IsNumeric(ColumnName) Then	ColumnName=Cint(ColumnName)

	' Create Table object and set date in table
	Set objTable=objForm.OracleTable("block name:="& ObjName)
	If objTable.Exist(gMEDIUMWAIT) Then
		objTable.EnterField RowNumber,ColumnName,strDateReformat
		bSuccess = True
	End If

	' Create Oracle Flex window object and enter date
	Set objOracleFlexform =OracleFlexWindow("title:=" & FormName)	
	Set objFlexTextField=objOracleFlexform.OracleTextField("prompt:="& ObjName)
	If objFlexTextField.Exist(gMEDIUMWAIT) Then
		If objFlexTextField.GetROProperty("editable") Then
			objFlexTextField.Enter strDateReformat 
    		bSuccess = True
		End If
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	'Return value
	funcSetFormattedCurrentDate = bSuccess

	'Clean Up
	Set objOracleFlexform=Nothing
	Set objFlexTextField=Nothing
	Set objTable=Nothing
	Set objForm=Nothing
	Set objPage=Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcTreeOperations(BrowserName,FormName,TabName, ObjName,IndexNum,ItemVal,Action)
'# This function is used to handle oracle tree in the oracle Browser/form
'#
'# Parameters:
'# BrowserName:-Name of Browser
'# FormName:-Name of Form
'# FormName:-Name of Tab (if needed)
'# ObjName:-Name of Tree                                                                                                    
'# ItemVal:-item to be selected in the tree
'# Action:-Action to be performed to the tree item (either select or expand)
'# IndexNum:-Index no (if needed)
'# 
'# OutPut Parameters: True/False
'#
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcTreeOperations(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum,ByVal ItemVal,ByVal Action)
	Dim objForm
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	If FormName <> "" Then
		' Create the form object
		Set objForm = funcCreateFormObj(FormName,TabName)
		If IsNumeric(ItemVal) Then ItemVal = cInt(ItemVal)

		If objForm.OracleTree("developer name:="& ObjName,"index:="&IndexNum).Exist(gMEDIUMWAIT) Then

			Select Case UCase(Action)
				Case "EXPAND"
						objForm.OracleTree("developer name:="& ObjName,"index:="&IndexNum).Expand ItemVal
						bSuccess = True
				Case "SELECT"
						objForm.OracleTree("developer name:="&ObjName,"index:="&IndexNum).Select ItemVal
						bSuccess = True
				Case "COLLAPSE"
						objForm.OracleTree("developer name:="&ObjName,"index:="&IndexNum).Collapse ItemVal
						bSuccess = True
				Case Else
						Call gfReportExecutionStatus(micWarning,"Oracle Tree Operations", "in Correct option " &Action)
						bSuccess = False
			End Select
			
		End If
	End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	' Return value
	funcTreeOperations = bSuccess

	'Clean Up
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcVerify_ViewAdjustments(FormName,TabName,ObjName)
'# This function is used 
'# Parameters:
'# FormName:-Name of Form
'# TabName:- name of the Oracle Tab
'# ObjName:-Name of 
'# 
'# OutPut Parameters: True/False
'#
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcVerify_ViewAdjustments(FormName,TabName,ObjName)
	Dim formObj
	Set formObj = funcCreateFormObj(FormName,TabName)
	Set ObjTbl=formObj.OracleTable("block name:="&ObjName)
	If ObjTbl.Exist(gSHORTWAIT) Then		
		For intLoop=1 To ObjTbl.GetROProperty("Visible rows")
			txtModNum=ObjTbl.GetFieldValue(intLoop,2)
			If eval(txtModNum = gTextValue) Then
				txtType=ObjTbl.GetFieldValue(intLoop,4)
				txtAmtReduced=ObjTbl.GetFieldValue(intLoop,7)
				Call gfReportExecutionStatus(micPass,"DefineManagerQualifier","The Modifier Number is"  &txtModNum&  " for the Type "  &txtType& " and the amount reduced to "  &txtAmtReduced)
				funcVerify_ViewAdjustments=True
				Exit Function
			End If
		Next
		Call gfReportExecutionStatus(micFaile,"DefineManagerQualifier",  " Not able to display  the Modifier  Number	:"&gTextValue&"  in the table "& ObjName)
		funcVerify_ViewAdjustments=False
	End If
	Set formObj=Nothing
	Set ObjTbl=Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: gfFormatDate(ByVal strDateTime, ByVal strFormat) 
'# Converts date as per the specified format
'#
'# Parameters:
'# strDateTime - Date Time string
'# strFormat - Format to which the date time need to be converted
'#
'# Function Return Value:
'# Returns the date converted to specified format.
'#
'#
'# Usage:
'# Below is the example to retrieve DateTime coverted to a specific format
'# 
'# strNewDate = gf_date (now(), "yyyy-mm-dd")
'# strNewDate = gf_date (time(), "hh:mm")
'*******************************************************************************************************************************************************************************************
Public Function gfFormatDate(ByVal strDateTime, ByVal strFormat) 
	Dim objFmt											'StdDataFormat object
	Dim ObjADORecordSet					'Resultset object

	On Error Resume Next
	Err.Clear

	Set objFmt = CreateObject("MSSTDFMT.StdDataFormat") 
	Set ObjADORecordSet = CreateObject("ADODB.Recordset") 

	objFmt.Format = strFormat
    ObjADORecordSet.Fields.Append "fldExpression", 12  
	ObjADORecordSet.Open 
	ObjADORecordSet.AddNew 
	Set ObjADORecordSet("fldExpression").DataFormat = objFmt 
	ObjADORecordSet("fldExpression").Value = strDateTime 

	' return the date in specified format
	gfFormatDate  = ObjADORecordSet("fldExpression").Value 

	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "Error in gfFormatDate():", "Got Error "& Err.Description) 
		On Error GoTo 0
	End If

	' Clean Up
	ObjADORecordSet.Close
	Set ObjADORecordSet = Nothing
	Set objFmt = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: lpCreateFolderStructure(strStructurePath)
'# This Function is used to Create Folder Structure
'#
'# Parameters:
'# Input Parameters:strStructurePath - folder path that needs to be created
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# This Function is used to Create Folder Structure
'#
'# Usage:
'# The usage of this procedure is
'# > Call lpCreateFolderStructure("C:\ZurichAutomationResult\ScreenShots")
'*******************************************************************************************************************************************************************************************
Private Function lpCreateFolderStructure(strStructurePath)
	Dim arrFolderName
	Dim strDrive
	Dim strBuildPath
	Dim intIndexNumber
	Dim intIndex
	Dim strFuncName	'Procedure Name is stored for displaying the Fail error message details

	On Error Resume Next
	Err.Clear
    
	strFuncName = "Error in lpCreateFolderStructure():"

	If(Instr(strStructurePath,":") > 0) Then
		strDrive = Split(strStructurePath,":")(0)
		intIndexNumber = 1
	Else
		strDrive = Split(Environment("ProductDir"),":")(0)
		intIndexNumber = 0
	End If

	arrFolderName = Split(strStructurePath,"\")
	strBuildPath = strDrive & ":\"

	For intIndex = intIndexNumber To UBound(arrFolderName)
		strBuildPath = ObjFSOReport.BuildPath(strBuildPath,arrFolderName(intIndex)) 
		If(Not(ObjFSOReport.FolderExists(strBuildPath))) Then
			ObjFSOReport.createFolder(strBuildPath)
		End If
	Next

	If(Err.Number <> 0) Then
		On Error GoTo 0
'		Call gfExitAction(strFuncName & "Unable to Create Reporting Folder Structure")
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Fucntion: lpGenerateHtmlReport()
'# This Procedure is used to Generate Html Report
'#
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'# Generates the HTML report
'# 
'# Usage: > Call lpGenerateHtmlReport()
'*******************************************************************************************************************************************************************************************
Function lpGenerateHtmlReport()
	Dim qtApp 
	Dim qtLibraries
	Dim strHTMLReport
	Dim intCount
	Dim blnFound
	
	Err.Clear
	'On Error Resume Next

	Dim strExecutionReportPath,strTxtFilePath,strHtmlFilePath,strDateTime,strTxtFileName,strHtmlFileName

	'strDateTime = Year(Now) &"-" & Month(Now) & "-" & Day(Now) & "_" & Hour(Now) & "-" & Minute(Now) & "-" & Second(Now)
    'Execution Report path,Text file name and Html file name

   	If(Instr(Environment("executionReportPath"),":") > 0) Then
		strExecutionReportPath = Split(Environment("executionReportPath"),"ScreenShots")(0)
	Else
		strExecutionReportPath = Split(Environment("ProductDir"),":")(0) & Split(Environment("executionReportPath"),"ScreenShots")(0)
	End If

	'strExecutionReportPath =Environment("executionReportPath")
	strTxtFileName = Environment("reportTxtFileName")
	strHtmlFileName = Environment("reportHtmlFileName")

	strTxtFilePath = strExecutionReportPath & Chr(92) & strTxtFileName & ".txt"
	'strHtmlFilePath = strExecutionReportPath & Chr(92) & strHtmlFileName &"_"& strDateTime & ".html"
	strHtmlFilePath = strExecutionReportPath & Chr(92) & strHtmlFileName & ".html"

	'Loading the Report the HTMLReport.QFL file at run time
	blnFound=False
	Set qtApp = CreateObject("QuickTest.Application")
	Set qtLibraries = qtApp.Test.Settings.Resources.Libraries
	For intCount = 1 To qtLibraries.Count
		If InStr(UCase(qtLibraries.Item(intCount)),UCase("CommonLibrary.qfl")) > 0 Then
			blnFound=True
			strHTMLReport = Replace(qtLibraries.Item(intCount),"CommonLibrary.qfl","HTMLReport.qfl")
			Call LoadFunctionLibrary(strHTMLReport)
			Exit For
		End If
	Next

	If blnFound=True Then
		'initialize Html Report
		Call lpInitializeHtmlReport(strTxtFilePath,strHtmlFilePath)
	End If

	'Execution Result Upload to QC
	'Call gfUpLoadAttachmentToQC(strHtmlFilePath)
	Err.Clear
End Function

'*******************************************************************************************************************************************************************************************
'# Sub: lpGenerateTxtReport(ByVal intStatus,ByVal strStepName,ByVal StrStepDescription)
'# Sub is used to Generate Text Report
'#
'# Input Parameters:
'# intStatus - Pass/Fail status
'# strStepName-Step Name
'# StrStepDescription - Step description
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'# Generates text report 
'#
'# Usage: > Call lpGenerateTxtReport("micPass","verify the mesage displayed in Shopping Cart page","Failed to find the expected message")
'*******************************************************************************************************************************************************************************************
Private Sub lpGenerateTxtReport(ByVal intStatus,ByVal strStepName,ByVal StrStepDescription)

	Err.Clear
	'On Error Resume Next
	
	Dim objTxtFile 							 'Object to reference a file
	Dim strStatus 						 	   'String variable to hold the status of an action	
	Dim strOSInfo 							 'String variable to hold the Operating system information
	Dim blnNewResult			 	   'Boolean variable to hold the result
	Dim strReportFileName 	 	 'String variable to hold the log file name
	Dim strLogFileName			 	 'String variable to hold the log file name including path
	Dim strReportPath				   'String variable to hold the path of log file folder
	Dim strMATCName				     'String variable to hold the Module,Action and TestCaseName
	Dim objDateTime
	
'	Dim ObjFSOReport

	Set objDateTime = DotNetFactory("System.DateTime")

	'strMATCName = Replace(DataTableBook,".xls","") &" $"&DataTableSheet&" $"&DataTableSheet
	
	'Adding code to handle-multiple iterations - 28th Mar 2016 - From here
	If(gintLogSNOForMul = 1) Then
		'Select Case gMultipleEntries
		'	Case 3
		'		strMATCName = Replace(DataTableBook,".xls","") &" $"&DataTableSheet&"_For_FranchiseeNewRest $"&DataTableSheet&"_For_FranchiseeNewRest"
		'	Case 2
		'		strMATCName = Replace(DataTableBook,".xls","") &" $"&DataTableSheet&"_For_McOpCoExistRest $"&DataTableSheet&"_For_McOpCoExistRest"
		'	Case 1
		'		strMATCName = Replace(DataTableBook,".xls","") &" $"&DataTableSheet&"_For_FranchiseeExistRest $"&DataTableSheet&"_For_FranchiseeExistRest"
		'	Case Else
		'		Call gfReportExecutionStatus(micFail,"Multiple Iterations ",  "No more iterations available"  )
		'End Select
		strMATCName = Replace(DataTableBook,".xls","") &" $"&DataTableSheet&"_"&strAppendValueToScript&" $"&DataTableSheet&"_"&strAppendValueToScript
	Else
		strMATCName = Replace(DataTableBook,".xls","") &" $"&DataTableSheet&" $"&DataTableSheet
	End If
	'strMATCName = Replace(DataTable.Value("DataTableBook", "Driver"),".xls","") &"$"&DataTable.Value("DataTableSheet", "Driver")&"$"&DataTable.Value("DataTableSheet", "Driver")
'	strMATCName = DataTable.Value("DataTableBook", "Driver")&"$"&DataTable.Value("DataTableBook", "Driver")&"$"&DataTable.Value("DataTableBook", "Driver")

	If(Instr(Environment("executionReportPath"),":") > 0) Then
		strReportPath = Split(Environment("executionReportPath"),"ScreenShots")(0)
	Else
		strReportPath = Split(Environment("ProductDir"),":")(0) & Split(Environment("executionReportPath"),"ScreenShots")(0)
	End If

	'strReportPath = Environment("executionReportPath")
	strReportFileName = Environment("reportTxtFileName")
    blnNewResult = False

	strLogFileName = strReportPath & Chr(92) & strReportFileName & ".txt"
	
	If (intStatus = 0) Then
		strStatus = "Pass"
	ElseIf (intStatus = 1) Then
		strStatus = "Fail"
	ElseIf (intStatus = 2) Then
		strStatus = "Done"
	ElseIf (intStatus = 3) Then
		strStatus = "Warning"
	End If

	'Appending log to the report
'	strStepName = Chr(34) & strStepName & Chr(34)
'	StrStepDescription = Chr(34) & StrStepDescription & Chr(34)

	'Create Txt Log File if not exists
'	Set ObjFSOReport = CreateObject("Scripting.FileSystemObject") 'Create FileSystem Object
	If (Not(ObjFSOReport.FileExists(strLogFileName))) Then
		Set objTxtFile = ObjFSOReport.OpenTextFile(strLogFileName,8,True)
		objTxtFile.WriteLine ""
		objTxtFile.WriteLine  vbTab & Environment("htmlReportSuiteName") & " Automation Test Suite Log"
		objTxtFile.Close
		Set objTxtFile = Nothing
		blnNewResult = True
	End If

	'Opens the Text file
	Set objTxtFile = ObjFSOReport.OpenTextFile(strLogFileName,8,True)
	If(strMATCName <> gstrPrevMATCName) Then
		'End of every TestCase it's generate End time
		If(ObjFSOReport.FileExists(strLogFileName) And blnNewResult = False) Then
			objTxtFile.WriteLine "End Time:" & vbTab & objDateTime.Now.toString("MM/dd/yyyy hh:mm:ss tt")
			objTxtFile.WriteLine ""
		End If
		'At the time of  new TestCase starts
		objTxtFile.WriteLine "Test Case Name: " & vbTab  & strMATCName
'		objTxtFile.WriteLine "Test Case Name: " & vbTab  &  DataTable.Value("DataTableSheet", "Driver")&"$"&DataTable.Value("DataTableSheet", "Driver")&"$"&DataTable.Value("DataTableSheet", "Driver")
		strOSInfo = Environment("LocalHostName") & " " & Environment("OS") & " " & Environment("OSVersion") 
		objTxtFile.WriteLine "Environment Name: " & vbTab & """" & Trim(Mid(strOSInfo, InStr(1, strOSInfo, ":") + 1)) & """"
		objTxtFile.WriteLine "Start Time:" & vbTab &  objDateTime.Now.toString("MM/dd/yyyy hh:mm:ss tt")
		objTxtFile.WriteLine ""
		objTxtFile.WriteLine "S.No" & vbTab & "Status" & vbTab & "Step Name" & vbTab & "Description" & vbTab & "Date/Time"
		gstrPrevMATCName = strMATCName
		gintLogSNO = 1
	End If
	'Generate Log messages into text file
	objTxtFile.WriteLine gintLogSNO & vbTab & strStatus & vbTab &  Replace(Replace(Replace(strStepName,VbTab,""),vbCr,""),vbLf,"") & vbTab & Replace(Replace(Replace(StrStepDescription,VbTab,""),vbCr,""),vbLf,"") & vbTab & objDateTime.Now.toString("MM/dd/yyyy hh:mm:ss tt")
	gintLogSNo = gintLogSNO + 1
	If Action = "BusinessReporting" Then
		objTxtFile.WriteLine "End Time:" & vbTab & objDateTime.Now.toString("MM/dd/yyyy hh:mm:ss tt")
	End If
	objTxtFile.Close

	Set objTxtFile = Nothing
	Set objDateTime = Nothing
	Err.Clear
End Sub


'*******************************************************************************************************************************************************************************************
'# Function: gfNumberFormat(ByVal intNumber,ByVal strFormat)
'# Function is used to get the number formatted as required format
'#
'# Input Parameters: 
'# intNumber - Integer number
'# strFormat -  Format. Ex: "00"
'#  
'# OutPut Parameters:
'# Returns String in the required format
'#
'# Usage: strDay = gfNumberFormat(Day(Date),"0000")
'*******************************************************************************************************************************************************************************************
Public Function gfNumberFormat(ByVal intNumber,ByVal strFormat)
	Dim strTemp	

	strTemp = CStr(intNumber)
	If Len(strTemp) >= Len(strFormat) Then
		gfNumberFormat = strTemp
	Else
		gfNumberFormat = Left(strFormat, Len(strFormat)-Len(strTemp)) & strTemp
	End If

End Function

'*******************************************************************************************************************************************************************************************
'# Function: lfCaptureImage()
'# Procedure used to save application failure image when the script fails
'#
'# Input Parameters: N/A
'#
'# OutPut Parameters: N/A 
'# 
'# Remarks:
'# Captures the Image and Stores in the folder CaptureImages under executionReportPath
'#
'# Usage: > Call lfCaptureImage()
'*******************************************************************************************************************************************************************************************
Private Function lfCaptureImage()
	Dim strImagesLoc
	Dim strImage
	Dim strImageSno
	Dim strReportPath

	On Error Resume Next
	Err.Clear

	lfCaptureImage = ""
	If(InStr(Environment("executionReportPath"),":")>0) Then
		strImagesLoc = Environment("executionReportPath")&"\ScreenShots"
	Else
		strImagesLoc = Split(Environment("ProductDir"),":")(0) & ":\" & Environment("executionReportPath")
	End If
	
	strImageSno = DataTableSheet  & "_" & Year(Now) & gfNumberFormat(Month(Now),"00") & gfNumberFormat(Day(Now),"00") & "_" & gfNumberFormat(Hour(Now) ,"00") & gfNumberFormat(Minute(Now),"00") & gfNumberFormat(Second(Now),"00") & ".png"

	'Saves a screen capture of the deskTop as a .png Image
	strImage = strImagesLoc & Chr(92) & strImageSno

	Desktop.CaptureBitmap strImage,True
	lfCaptureImage = strImage

	'Check and Report Runtime Errors If any
	If (Err.Number<>0) Then
		Call gfReportExecutionStatus(micFail,"Run Time Error Details : " & Chr(34) & "Error in lfCaptureImage()" & Err.Description & Chr(34))
		Err.Clear
	End If

End Function

'*******************************************************************************************************************************************************************************************
'# Function: gfReportExecutionStatus(ByVal ResultCode, ByVal StepName, ByVal Desc)
'# Function is used to report Pass/Fail/Done/Warning messages in QTP inbuilt report and also in text report.
'#
'# Parameters:
'# Input Parameters:
'# ResultCode - Pass/Fail/Info/Warned Status
'# StepName - Step details to report
'# Desc		- Step description
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'# ResultCode Parameter can be 0/1/2/3 or micPass,micFail,micDone,micWarning
'# 
'# Usage: > Call gfReportExecutionStatus(micPass,"Expected object displayed in Shopping cart page")
'*******************************************************************************************************************************************************************************************
Public Function gfReportExecutionStatus(ByVal ResultCode, ByVal StepName, ByVal Desc)
	Dim strImagePath	'Stores Image Path

	'This will enable all the reporting stuff For InBuilt QTP Reporting Purpose
	Reporter.Filter = rfEnableAll

	'This will report Pass/Fail/Done/Warning messages in QTP inbuilt report and Text File 
	Select Case ResultCode
		Case 0,micPass:
			'This will generate Custom QTP inBuilt Report
			Reporter.ReportEvent micPass,StepName,Desc			

			'This will report into txt report
            Call lpGenerateTxtReport(0,Replace(StepName,vbCr,""),Replace(Desc,vbCr,""))

		Case 1,micFail:
			Environment("TCFail") = True
			Environment("StepFail") = True
			strImagePath = lfCaptureImage()
			Desc = Desc & " - - For More Details, Refer Screenshot at " & strImagePath
			'This will generate Custom QTP inBuilt Report
			Reporter.ReportEvent micFail,StepName,Desc,strImagePath

			'This will report into txt report
            Call lpGenerateTxtReport(1,Replace(StepName,vbCr,""),Replace(Desc,vbCr,""))

		Case 2,micDone:
			If(CBool (Environment("debugMode"))) Then		' This will report only if debug mode is enabled.
				'This will generate Custom QTP inBuilt Report
				Reporter.ReportEvent micDone,StepName,Desc

				'This will report into txt report
				Call lpGenerateTxtReport(2,Replace(StepName,vbCr,""),Replace(Desc,vbCr,""))
			End If

		Case 3,micWarning:
			'This will generate Custom QTP inBuilt Report
			Reporter.ReportEvent micWarning,StepName,Desc

			'This will report into txt report
			Call lpGenerateTxtReport(3,Replace(StepName,vbCr,""),Replace(Desc,vbCr,""))

	End Select
	
	'This will disable all the reporting stuff
	Reporter.Filter = rfDisableAll
End Function

'*******************************************************************************************************************************************************************************************
'# Function: gfOnTerminate()
'# Function is used to terminate the resources like closing all the existing browsers and Generating HTML Report
'#
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Call this procedure at the end of the script to Close the browser and generate the HTML report
'#
'# Usage:> Call gfOnTerminate()
'*******************************************************************************************************************************************************************************************
Public Function gfOnTerminate()
	Dim wsh
	Dim gLangObjIDRs

	'Cleaning up recordset memory
	Set gLangObjIDRs = Nothing

	'Exit Oracle Application
    'If(OracleApplications(OracleApplications).Exist(gMEDIUMWAIT)) Then
	'	OracleApplications(OracleApplications).Exit
	'End If
	'Exit Oracle cloud internet application
'	If Browser("name:=Oracle Applications").Page("title:=Oracle Applications").Exist(15) Then
'		Browser("name:=.*").Page("title:=.*").Link("name:=test user2" and "index:= 0").Click
'		Browser("name:=.*").Page("title:=.*").Link("name:=Sign Out").Click
'	End  If
'	If Browser("name:=Single Sign-Off consent").Page("title:=Single Sign-Off consent").Exist(15) Then
'		Browser("name:=Single Sign-Off consent").Page("title:=Single Sign-Off consent").WebButton("name:=Confirm").Click 
'	End If 
    'Close all open browsers
    
	Call gFuncCloseAllBrowsers()

	'This is used to generate Html report
	Call lpGenerateHtmlReport()
	Call lpDeleteFolders()

	'Clean Up memory
	strPvtTestCaseName = Empty

End Function

'*******************************************************************************************************************************************************************************************
'# Function: gFuncCloseAllBrowsers
'# This Function is used to close all open browsers except Quality center and WebEx.
'#
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'# This Function is used to close all open browsers except Quality center and WebEx.
'# 
'# Usage:> blnStatus = gFuncCloseAllBrowsers()
'*******************************************************************************************************************************************************************************************
Public Function gFuncCloseAllBrowsers()
	Dim objDesc
	Dim browserElements
	Dim intCnt
	Dim browserTitles
	Dim blnCloseBrowser
	Dim titleIndex

	On Error Resume Next
	Err.Clear

	'Close all the Dialogs and Windows that are open
	Call gFuncCloseAllDialogs()

	gFuncCloseAllBrowsers = False
	blnCloseBrowser = False
    
	'Retrive all Browsers from Desktop
	Set objDesc = Description.Create()
	objDesc("micClass").Value = "Browser"
	Set browserElements = Desktop.ChildObjects(objDesc)
	browserTitles = Split(Environment("browserTitles"),",")
		
	'Closes the Browser window (or tab) except Quality Center and WebEX
	For intCnt = 0 To browserElements.Count - 1
		blnCloseBrowser = False

		For titleIndex = 0 To UBound(browserTitles)
			If (InStr(browserElements(intCnt).GetROProperty("title"),browserTitles(titleIndex)) > 0) Then
				blnCloseBrowser = True
				Exit For
			End If

'			'Click on Logout Link
'			If browserElements(intCnt).Page("title:=.*").Link("text:=Logout","index:=0").Exist(0) Then
'				browserElements(intCnt).Page("title:=.*").Link("text:=Logout","index:=0").Click
'			End If
		Next

		If(Not blnCloseBrowser) Then
			browserElements(intCnt).Close
		End If

	Next

	' Return value
	gFuncCloseAllBrowsers = True
    
	'Check and Report Runtime Errors If any
	If (Err.Number<>0) Then
        Err.Clear
	End If

	'Release objects
	Set browserElements = Nothing
	Set objDesc = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: gFuncCloseAllDialogs
'# This Function is used to close all open Dialogs.
'#
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'#  This Function is used to close all open Dialogs.
'# 
'# Usage:> blnStatus = gFuncCloseAllDialogs()
'*******************************************************************************************************************************************************************************************
Public Function gFuncCloseAllDialogs()
	Dim objDialogs
	Dim objDesc
	Dim intCount
	
	On Error Resume Next
	Err.Clear

 	Set objDesc = Description.Create()
	objDesc("nativeClass").Value = "#32770"
 	Set objDialogs = Desktop.ChildObjects(objDesc)

	' Close all the dialogs
 	For intCount = 0 To objDialogs.Count - 1
		If(objDialogs(intCount).GetROProperty("enabled") = True And Len(Trim(objDialogs(intCount).GetROProperty("text")))>0) Then
	  		objDialogs(intCount).Close()
			Wait gSYNCWAIT
		End If
 	Next

	' Error Handling
	If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micWarning, "Error in gFuncCloseAllDialogs: ", "Got Error " & Err.Description) 
		On Error GoTo 0
	End If

	'Release objects
	Set objDesc = Nothing
	Set objDialogs = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Procedure: procLoadEnvironmentRepository()
'# This Procedure is used to Load Environment Repository
'#
'# Parameters:
'# Input Parameters: N/A
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'# Loads the environment variables values present in the environment repository to the global variables
'#
'# Usage:
'# The usage of this procedure is
'# > Call procLoadEnvironmentRepository()
'*******************************************************************************************************************************************************************************************
Private Sub procLoadEnvironmentRepository()

	On Error Resume Next
    Err.Clear
	
	'Read from Environment and Store in Global variables
	gBrowserType = Environment("browserType")
    gSYNCWAIT = CInt(Environment("syncWait"))
	gSHORTWAIT =CInt(Environment("shortWait"))
	gMEDIUMWAIT = CInt(Environment("mediumWait"))
	gLONGWAIT = CInt(Environment("longWait"))
    gTIMEOUT = CInt(Environment("timeOut"))
    
	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "Error in procLoadEnvironmentRepository():", "Got Error "& Err.Description) 
		On Error GoTo 0
	End If
End Sub

'*******************************************************************************************************************************************************************************************
'# Function: getNumofInstances(BrowserName,ObjName,IndexNum,Item,InstanceNumber)
'# Function is used to terminate the resources like closing all the existing browsers and Generating HTML Report
'#
'# Parameters:
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Call this procedure at the end of the script to Close the browser and generate the HTML report
'#
'# Usage:
'# The usage of this procedure is
'# > Call gfOnTerminate()
'*******************************************************************************************************************************************************************************************
Function funcgetNumofInstances(BrowserName,ObjName,IndexNum,Item,InstanceNumber)
	Dim PageObj
	Dim txtItemVal
	Dim intInstanceNum

	If BrowserName <> "" Then
		Set PageObj= funcCreatePageObj(BrowserName)
		Set objTbl=pageObj.WebTable("html tag:=TABLE","name:="&ObjName,"index:="&IndexNum)
		If objTbl.Exist(gSHORTWAIT) Then			
			For intLoop=2 to objTbl.RowCount
				txtItemVal=objTbl.GetCellData(intLoop,Item)
				intInstanceNum=objTbl.GetCellData(intLoop,InstanceNumber)
				Call gfReportExecutionStatus(micPass,"funcgetNumofInstances"," The item  "&txtItemVal& " holds instance number " &intInstanceNum)
			Next
			funcgetNumofInstances=True
		Else
			Call gfReportExecutionStatus(micFail,"funcgetNumofInstances"," Table object does not exist so not able to get accounting entries for  table  : "& ObjName)
			funcgetNumofInstances=False
		End If
	End If 
	Set objTbl=Nothing
	Set PageObj=Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcgetRequestIdFrmTextBox(ArrayPosition,FormName,ObjName,IndexNum)
'# Function is used to Capture Integer from string
'#
'# Parameters:
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Call this procedure at the end of the script to Close the browser and generate the HTML report
'#
'# Usage:
'# The usage of this procedure is
'# > Call gfOnTerminate()
'*******************************************************************************************************************************************************************************************
Function funcgetRequestIdFrmTextBox(ArrayPosition,FormName,ObjName,IndexNum)
	Environment("intPosition")= ArrayPosition
	Set formObj = funcCreateFormObj(FormName,TabName)
	IdMsg=Split(formObj.OracleTextField("description:="&ObjName,"index:="&IndexNum).GetROProperty("value"),"request")
    'Search patter set to only  numeric value
	strPattern = "[+0-9]+"' Numbers positive and negative; use  '  "ˆ[-+0-9]+" to emulate Rexx' Value() ' function, which returns 0 unless the 
    requestId=funcSearchPattern(IdMsg(1),strPattern)
	funcgetRequestIdFrmTextBox=requestId
    Call gfReportExecutionStatus(micPass,"InterfaceTripStopRequestID","Successfully got the Interface Trip Stop RequestID	:" &requestId)   	
End Function

'*******************************************************************************************************************************************************************************************
'# Function: ExtractIntFromString(myString)
'# Function is used to terminate the resources like closing all the existing browsers and Generating HTML Report
'#
'# Parameters:
'# Input Parameters:myString - Search String from which integer needs to be extracted
'#
'# OutPut Parameters: Integer portion of the search string. If a string does not have any integer then it returns '0'
'# 		     as output.	 
'# Remarks:
'# Call this function when you need to extract integer from a string.
'# Limitaiton - Currently function will return only the last matched integer in the string.
'# Usage:
'# The usage of this procedure :
'# strString = " my number gentest .  .12345. . ..test is succefflul."
'# strMsg =  ExtractIntFromString( strString )  -  In the above string it returns "12345" as output.
'*******************************************************************************************************************************************************************************************
Function ExtractIntFromString(myString)
   Dim strPattern 
	strPattern = "[+0-9]+"
	ExtractIntFromString =funcSearchPattern(myString,strPattern)
End Function

'*******************************************************************************************************************************************************************************************
'# Function: lpDeleteFolders()
'# Procuder is used to Delete temperoroy folders 
'#
'# Parameters:
'# Input Parameters:None
'# 
'# OutPut Parameters: N/A
'# 
'#
'# Usage:
'# The usage of this procedure is
'# > Call lpDeleteFolders()
'*******************************************************************************************************************************************************************************************
Private Sub lpDeleteFolders()
	Dim objFSO
	Dim strTempPath
	Dim objFolder 
	Dim strPath

    On Error Resume Next
	Err.Clear

	'Create the file system object
	Set objFSO= CreateObject("Scripting.FileSystemObject")
	strTempPath=Environment.Value("SystemTempDir")
	Set objFolder = objFSO.GetFolder(strTempPath)

	For Each objFolder In objFolder.SubFolders
		' Note : Only use *lowercase* letters in the folder names below:
		If Instr(UCase(objFolder.Name),Ucase("Temporary Directory 1"))>0 Then
			strPath=objFolder.Path 
			objFSO.DeleteFolder strPath,True
		End If
	Next

	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "From the function lpDeleteFolders", "Got Error "& Err.Description) 
		On Error GoTo 0
	End If
End Sub


'*******************************************************************************************************************************************************************************************
'# Procedure: lpGenerateHtmlReport()
'# This Procedure is used to Generate Html Report
'#
'# Parameters:
'# Input Parameters:N/A
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'# Generates the HTML report
'# 
'# Usage:
'# The usage of this Procedure is
'# > Call lpGenerateHtmlReport()
'*******************************************************************************************************************************************************************************************
Sub lpGenerateHtmlReport()
Dim qtApp 
Dim qtLibraries
Dim strHTMLReport
Dim intCount
Dim blnFound
	
	Err.Clear

	Dim strExecutionReportPath,strTxtFilePath,strHtmlFilePath,strDateTime,strTxtFileName,strHtmlFileName

   	If(Instr(Environment("executionReportPath"),":") > 0) Then
		strExecutionReportPath = Split(Environment("executionReportPath"),"ScreenShots")(0)
	Else
		strExecutionReportPath = Split(Environment("ProductDir"),":")(0) & Split(Environment("executionReportPath"),"ScreenShots")(0)
	End If

	'strExecutionReportPath =Environment("executionReportPath")
	strTxtFileName = Environment("reportTxtFileName")
	strHtmlFileName = Environment("reportHtmlFileName")

	strTxtFilePath = strExecutionReportPath & Chr(92) & strTxtFileName & ".txt"
	'strHtmlFilePath = strExecutionReportPath & Chr(92) & strHtmlFileName &"_"& strDateTime & ".html"
	strHtmlFilePath = strExecutionReportPath & Chr(92) & strHtmlFileName & ".html"

	'Loading the Report the HTMLReport.QFL file at run time
	blnFound=False
	Call lpInitializeHtmlReport(strTxtFilePath,strHtmlFilePath)
	'Execution Result Upload to QC
	'Call gfUpLoadAttachmentToQC(strHtmlFilePath)
	Err.Clear
End Sub

'*******************************************************************************************************************************************************************************************
'# Function: GetValueFromGlobalDictionary(ByVal strStepNumer)
'# This function is used to retreive value from Global Dictionary with Step ID
'#
'# Parameters:
'# Input Parameters:
'#	strStepNumer	:	 Step ID
'# OutPut Parameters: N/A
'#
'# Remarks:
'# 
'# Usage:
'# The usage of this Procedure is
'# > 
'*******************************************************************************************************************************************************************************************
Function GetValueFromGlobalDictionary(ByVal strStepNumer)
	Dim arrStepID
	Dim strStepID
	Dim intIncrement
	
	intIncrement=""			' Initialize 
	arrStepID = Split(strStepNumer,"#")

	' Chek if any additional integer needs to be incremented before returning back the value
	If UBound(arrStepID) > 1 Then
		strStepID = arrStepID(1)
		intIncrement = arrStepID(2)
	Else
		strStepID = arrStepID(1)
	End If

	' Check the global dictionary to return the matching  dictionary key value
	If dicGlobalOutput.Exists(strStepID) Then
		If intIncrement = "" Then
			' Get value from global dictionary
			GetValueFromGlobalDictionary = dicGlobalOutput(strStepID)
		Else
			' Get value from global dictionary - Increment the value stored for the variable before returning
			GetValueFromGlobalDictionary = CInt(dicGlobalOutput(strStepID)) +CInt(intIncrement)
		End If
	Else
		' Incorrectt Step ID entered
		Call gfReportExecutionStatus(micFail,"Function GetValueFromGlobalDictionary" ,"Retrieve value from dicGlobalOutput for stepID "& strStepID)
		'Msgbox "Please enter the correct step number in the param column. Current Step number entered - " & strStepNumer	&  vbCrlf & " Exiting the test case execution."
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcNavigateTo(ByVal strNavigationFlow)
'# Function is used to navigate to specific Oracle Form from the Oracle Navigator window
'#
'# Parameters:
'# Input Parameters:
'# strNavigationFlow - Navigation Hierarchy
'#
'# OutPut Parameters: True/False
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:
'# The usage of this procedure is
'# >  funcNavigateTo(strNavigationFlow)
'*******************************************************************************************************************************************************************************************
Function funcNavigateTo(ByVal strNavigationFlow)
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	If strNavigationFlow<> "" Then
		'If OracleNavigator("short title:=Navigator").Exist Then				' If Oracle Navigator window exists.
		If OracleNavigator("short title:=Navigator").Exist(10) Then				' If Oracle Navigator window exists.
			OracleNavigator("short title:=Navigator").Activate
			  'Collapse menu before select
			OracleNavigator("short title:=Navigator").SelectMenu "Tools->Collapse All"

			' Select navigation flow
			OracleNavigator("short title:=Navigator").SelectFunction strNavigationFlow		' Select the form from Oracle Navigator window 
			wait (gSHORTWAIT)
			bSuccess = True
		End If	

	Else
		Call gfReportExecutionStatus(micFail,"Navigate To","Check the form name : "& strNavigationFlow)
		bSuccess = False
	End If

	' Return the value of bSuccess
	funcNavigateTo = bSuccess
End Function

'*******************************************************************************************************************************************************************************************
'# Function: GenerateReportString(strReport)
'# Function is used to evaluate report string
'#
'# Input Parameters:
'# strReport : input string from excel param1 column for test business flow reporting.
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:> This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************
Function funcGenerateReportString(strReport)
	Dim strReportString
	Dim intNumberVar
	Dim arrString
	Dim intCount
	Dim strFinalReportString

	' Check the imput string for generating the report
	If strReport >  ""  Then
	
		strReportString = strReport
		' Check if the input string has some variable - Global Or Global Dictionary object which needs to be evaluated.
		If inStr(strReportString,"#") > 1 Then										
		
			arrString = Split(strReportString,"#")
			intNumberVar = UBound(arrString)
			For intCount = 0 To intNumberVar
				If (intCount Mod 2) <> 0 Then
					If instr(arrString(intCount),"dicGlobalOutput") > 0 Then
						  strFinalReportString = strFinalReportString  & Eval(Split(arrString(intCount),"(")(0) &"("& Chr(34) & Trim(Replace(Split(arrString(intCount),"(")(1),")","")) & Chr(34) & ")"  )
					Else
						  ' strFinalReportString = strFinalReportString  & Eval(arrString(intCount))
						   strFinalReportString = strFinalReportString  & (arrString(intCount))	
					End If
				Else
						strFinalReportString = strFinalReportString  & arrString(intCount)
				End If
			Next
		Else
			strFinalReportString = strReportString
		End If		
	
	End If

	' Return the formatted string
	funcGenerateReportString = strFinalReportString
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcCompareDictionary(strDic,strDic1,strCase, strVerifyText)
'# Function is used to compare the two items in  global dictionary
'#
'# Input Parameters:
'# strDic : First Dictionary object
'# strDic1 : Second Dictionary object
'# strCase : Select Case
'# strVerifyText : Verify text
'#
'# OutPut Parameters: None
'#
'# Usage:> This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************
Function funcCompareDictionary(ByVal strDic,ByVal strDic1,ByVal strCase, ByVal strVerifyText)
	Dim strTemp

	On Error Resume Next
	Err.Clear

	Select Case UCase(strCase)
		Case "EQUAL"

				' Check for the key existence
				If dicGlobalOutput.Exists(strDic) And dicGlobalOutput.Exists(strDic1)  Then
						If strComp(dicGlobalOutput(strDic),dicGlobalOutput(strDic1)) = 0 Then						
							Call gfReportExecutionStatus(micPass,"Function: CompareDictionary() - CompareFieldValues"," Successfully matched the values. Actual Value "& dicGlobalOutput(strDic) & " Expected Value : " &dicGlobalOutput(strDic1))
						Else
							Call gfReportExecutionStatus(micFail,"Function: CompareDictionary() - CompareFieldValues", " Failed to match the values: Actual Value " & dicGlobalOutput(strDic) &  " Expected Value : " &  dicGlobalOutput(strDic1))
						End If
				Else
						Call gfReportExecutionStatus(micFail,"Function: CompareDictionary() - CompareFieldValues", "Incorrect step id entered in the function argument. Step ID entered as input : " & strDic  & " And " & strDic1)
				End If

		Case "GREATER"

				' Check for the key existence
				If dicGlobalOutput.Exists(strDic) AND dicGlobalOutput.Exists(strDic1)  Then
					If cDbl (dicGlobalOutput(strDic)) > cDbl(dicGlobalOutput(strDic1)) Then						
							Call gfReportExecutionStatus(micPass,"Function: CompareDictionary() - CompareFieldValues"," Correctly Verified the value "& dicGlobalOutput(strDic) & " is Greater than: "&dicGlobalOutput(strDic1))
						Else
							Call gfReportExecutionStatus(micFail,"Function: CompareDictionary() - CompareFieldValues",  " Failed to Verify the Value " & dicGlobalOutput(strDic) &  " is Greater than : " &  dicGlobalOutput(strDic1))
						End If
					Else
						Call gfReportExecutionStatus(micFail,"Function: CompareDictionary() - CompareFieldValues",  "Incorrect step id entered in the function argument. Step ID entered as input : " & strDic  & " And " & strDic1)
				End If

		Case "ADD"

				' Check for the key existence
				If dicGlobalOutput.Exists(strDic) AND dicGlobalOutput.Exists(strDic1)  Then
					strTemp = dicGlobalOutput(strDic) + cint(dicGlobalOutput(strDic1)) 			
					Call gfReportExecutionStatus(micPass,"Adding Dictionary Objects"," Added the values	'"&dicGlobalOutput(strDic)&"' And '"&dicGlobalOutput(strDic1),"' and got the total as : " & strTemp)	
				Else
					Call gfReportExecutionStatus(micFail,"Function: CompareDictionary() - Adding Field values",  "Incorrect step id entered in the function argument. Step ID entered as input : " & strDic  & " And " & strDic1)
				End If

		Case "SUBTRACT_VERIFY"

				If dicGlobalOutput.Exists(strDic) AND dicGlobalOutput.Exists(strDic1)  Then
					strTemp = dicGlobalOutput(strDic) - dicGlobalOutput(strDic1)
					If strComp(strTemp,strVerifyText)=0 Then
						Call gfReportExecutionStatus(micPass,"On-HandQuantity"," Successfully displayed the on-hand quantity by Subtracting the values	'"&dicGlobalOutput(strDic1)&"' from '"&dicGlobalOutput(strDic),"' and got the total as : " & strTemp)
					Else
						Call gfReportExecutionStatus(micFail,"On-HandQuantity",  "Failed to display the correct on-hand quantity ; Actual Quantity	: "& strTemp &"Displayed quantity	: " & strVerifyText)
                    End If
				End If
				
	End Select

	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "From the funcCompareDictionary", "Got Error "& Err.Description) 
		On Error GoTo 0
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: Insert_CompanyID_Name(FormName,TabName,ObjName,ColumnName,ColumnValue,RepeatInputs)
'# Function is used to evaluate report string
'#
'# Parameters:
'# Input Parameters:
'# strReport : input string from excel param1 column for test business flow reporting.
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:
'# The usage of this procedure is
'# > This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************
Function Insert_CompanyID_Name(FormName,TabName,ObjName,ColumnName,ColumnValue,RepeatInputs)
	Dim formObj
	Set formObj = funcCreateFormObj(FormName,TabName)
	wait gSHORTWAIT
	If formObj.OracleTable("block name:="&ObjName).Exist(1) Then
		ColumnValue =   getRndSec
		formObj.OracleTable("block name:="&ObjName).highlight
		formObj.OracleTable("block name:="&ObjName).EnterField RepeatInputs,ColumnName,cstr(ColumnValue) 
		While OracleNotification("title:=Error").Exist(gSHORTWAIT)
			OracleNotification("title:=Error").OracleButton("label:=OK").Click		
			Call funcSendKeys("{BACKSPACE}",1)
			formObj.select 
			wait gSHORTWAIT
			ColumnValue = getRndSec
			formObj.OracleTable("block name:="&ObjName).EnterField RepeatInputs,ColumnName,cstr(ColumnValue)	
		Wend
		
		formObj.select 
		ColumnValue = "Test Company"&ColumnValue
		formObj.OracleTable("block name:="&ObjName).EnterField RepeatInputs,"Description",ColumnValue
		Call gfReportExecutionStatus(micPass,"EnteringCoNumberAndName","Successfully entered Company Number	:"&getRndSec()&" And Company Description as:" & ColumnValue)
		Insert_CompanyID_Name=True
	Else
		Call gfReportExecutionStatus(micFail,"EnteringCoNumberAndName","The table	:"&ObjName&"Does not exist")
		Insert_CompanyID_Name=False
	End If
End Function

'*******************************************************************************************************************************************************************************************
'# Function: LaunchContractForm
'# Function is used to evaluate report string
'#
'# Parameters:
'# Input Parameters:
'# strReport : input string from excel param1 column for test business flow reporting.
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:
'# The usage of this procedure is
'# > This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************

Function LaunchContractForm()
	
	Dim NumofJavaList,NumofAdminis,NumofEffectivities
    For NumofJavaList=0 To 5 
		javaWindow("label:=Oracle Applications").JavaInternalFrame("label:=Search Templates and Contracts").JavaList("toolkit class:=oracle.apps.jtf.table.AccessibleTableGrid").Select  "#2"
		javaWindow("label:=Oracle Applications").JavaInternalFrame("label:=Search Templates and Contracts").JavaList("toolkit class:=oracle.apps.jtf.table.AccessibleTableGrid").Select  "#"&NumofJavaList
		OracleFormWindow("short title:=Search Templates and Contracts").SelectMenu "Tools->Open"
		If OracleFormWindow("short title:=Service Contracts Authoring").OracleTabbedRegion("label:=Parties").OracleButton("description:=Open for Update").Exist(gLONGWAIT) Then
			OracleFormWindow("short title:=Service Contracts Authoring").OracleTabbedRegion("label:=Parties").OracleButton("description:=Open for Update").Click
			If OracleNotification("title:=Error").Exist(gSHORTWAIT) Then
				strNote=OracleNotification("title:=Error").GetROProperty("message")
				If Instr(strNote,"This Contract has been renewed, if you wish to make changes, they will not be reflected in the renewed contract")=0 then
					OracleNotification("title:=Error").Approve
					OracleFormWindow("short title:=Service Contracts Authoring").CloseWindow
				End if		
			Elseif OracleNotification("title:=Note").Exist(2) Then
				strNote=OracleNotification("title:=Note").GetROProperty("message")
				If Instr(strNote,"This Contract has been renewed, if you wish to make changes, they will not be reflected in the renewed contract")=1 then
					OracleNotification("title:=Note").Approve
					Call funcServiceContractsAuthoring()
					Exit function
				End If
			Else
				Call funcServiceContractsAuthoring()
				Exit function
			End If
		Else 
			Call funcServiceContractsAuthoring()
			Exit function
		End If	
	Next	
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcServiceContractsAuthoring()
'# Function is used to evaluate report string
'#
'# Parameters:
'# Input Parameters:
'# strReport : input string from excel param1 column for test business flow reporting.
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:
'# The usage of this procedure is
'# > This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************
Function funcServiceContractsAuthoring()
	Set objForm=OracleFormWindow("short title:=Service Contracts Authoring")
	Set objOracleTable =objForm.OracleTabbedRegion("label:=Pricing / Products").OracleTable("block name:=OKS_LINES_SERVICE_PRICING")
	If Not objForm.Exist(0) Then 
		funcServiceContractsAuthoring=False 
		Exit Function
	End If
	objForm.OracleTabbedRegion("label:=Lines","index:=0").Select 	
	objForm.OracleTabbedRegion("label:=Pricing / Products").Select
	objForm.OracleTabbedRegion("label:=Administration","index:=0").Select
	 For NumofAdminis=1 To OracleTableGetRowCount(objOracleTable ,"Subline Renewal Type")
		objForm.OracleTabbedRegion("label:=Pricing / Products").OracleTable("block name:=OKS_LINES_SERVICE_PRICING").EnterField NumofAdminis,"Subline Renewal Type","Do Not Renew"
	 Next
	objForm.OracleTabbedRegion("label:=Effectivities","index:=0").Select
    Set objOracleTable = objForm.OracleTabbedRegion("label:=Lines","index:=1").OracleTable("block name:=OKS_LINES")
	row=OracleTableGetRowCount(objOracleTable ,"Renewal Type")
	 For NumofEffectivities=1 To OracleTableGetRowCount(objOracleTable ,"Renewal Type")
		objForm.OracleTabbedRegion("label:=Lines","index:=1").OracleTable("block name:=OKS_LINES").EnterField NumofEffectivities,"Renewal Type","Do Not Renew"
	 Next
	objForm.SelectMenu "File->Save"		
	funcServiceContractsAuthoring=True
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcOracleTableGetRowCount(objOracleTable,strColumn)
'# Function is used get the oracle table RowCount upto 100
'#
'# Parameters:
'# Input Parameters:
'# strReport : input string from excel param1 column for test business flow reporting.
'#
'# OutPut Parameters: N/A
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:
'# The usage of this procedure is
'# > This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************
Function funcOracleTableGetRowCount(ByRef objOracleTable, ByVal strColumn)
	Dim intCounter

	On Error Resume Next
	Err.Clear

	'Get row count - Set defaul couter max upto 100
	If objOracleTable.Exist(gMEDIUMWAIT) Then
		For intCounter =1 To 100
			If objOracleTable.IsFieldEditable(intCounter, strColumn)<>True Then
            		'Return the total row count for the oracle table
				funcOracleTableGetRowCount = intCounter-1
				Exit Function
			End If
		Next
	End If

	Call gfReportExecutionStatus(micFail,"Oracle Table ","Oracle Table Object Does not exist :")				  
	funcOracleTableGetRowCount=False

	'Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "From the function funcOracleTableGetRowCount", "Got Error "& Err.Description) 
		On Error GoTo 0
	End If
End function

'*******************************************************************************************************************************************************************************************
'# Function:  selectjavalist(ByVal Windowname,ByVal FrameName,ByVal ListName,ByVal Index)
'# Function is used to select from java listbox.
'#
'# Parameters:
'# Input Parameters:
'# Window:- Window Name
'# FrameName:- Frame Name
'# ListName:- List Name
'# Index:- index value if required
'#
'# OutPut Parameters: True/False
'#  
'# Remarks:
'# Use this procedure to navigate to any specific form when the Navigator window is already displayed
'#
'# Usage:
'# The usage of this procedure is
'# > This is an internal funciton called only through business action
'*******************************************************************************************************************************************************************************************
Function selectjavalist(ByVal Windowname,ByVal FrameName,ByVal ListName,ByVal Index)
	Dim objWindow
	
	On Error Resume Next
	Err.Clear

	' Create the object
	Set objWindow = javaWindow("label:="& Windowname).JavaInternalFrame("label:="& FrameName)

	'Check for list existence and select the list value
	If objWindow.Exist(gMEDIUMWAIT) Then
		objWindow.JavaList("toolkit class:="& ListName).Select "#"&Index
		selectjavalist = True
		Call gfReportExecutionStatus(micDone,"selectjavalist","Successfully selected the list	:" & ListName)				  
	Else
		Call gfReportExecutionStatus(micFail,"selectjavalist","List Object Does not exist :" & ListName)				  
		selectjavalist = False
	End If
	
	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "From the function selectjavalist", "Got Error "& Err.Description) 
		On Error GoTo 0
	End If

	'Clean Up
	Set objWindow = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcFormattedRandomNumber(LowerBound1,UpperBound1,LowerBound2,UpperBound2,LowerBound3,UpperBound3,Term, TestStepID)
'# This function is used to give a random number in the desired format
'#
'# Parameters:
'# LowerBound:- Lower Bound
'# UpperBound:- Upper Bound
'# Term:- Term Value
'#
'# OutPut Parameters: None
'#
'# Usage:
'# The usage of this procedure is> To be used if a partular format is necessary   Ex : 976-678-09 ; 987,678,234
'*******************************************************************************************************************************************************************************************
Function funcFormattedRandomNumber(ByVal LowerBound1,ByVal UpperBound1,ByVal LowerBound2,ByVal UpperBound2,ByVal LowerBound3,ByVal UpperBound3,ByVal Term, ByVal TestStepID)
	Dim intFinalRandVal
    intFinalRandVal= RandomNumber(LowerBound1,UpperBound1) & Term & RandomNumber(LowerBound2,UpperBound2) & Term & RandomNumber(LowerBound3,UpperBound3)
	dicGlobalOutput.add TestStepID,intFinalRandVal	
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcRandomNumber(LowerBound,UpperBound)
'# This function is used to give a random number
'#
'# Parameters:
'# LowerBound:- Lower Bound
'# UpperBound:- Upper Bound
'#
'# OutPut Parameters: Random Number
'#
'# Usage:
'# The usage of this procedure is>
'*******************************************************************************************************************************************************************************************
Function funcRandomNumber(ByVal LowerBound,ByVal UpperBound, ByVal strPrefix, ByVal strStepID)
   Dim intRand
    Randomize					'	Initializes the random-number generator.

	intRand = cint(int(UpperBound-cint(LowerBound)+1)*Rnd+cint(LowerBound))
	intRand = strPrefix & intRand
	dicGlobalOutput.Add strStepID,intRand
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcEditOracleFrame(ByVal BrowserName,ByVal FrameName,ByVal TextValue)
'# This function is used to edit oracle frame text
'#
'# Parameters:
'# BrowserName:- Name of the browser
'# FrameName:- Name of the Frame
'# TextValue:- Text Value to enter in frame
'#
'# OutPut Parameters: True/False
'#
'# Usage:
'# The usage of this procedure is> funcEditOracleFrame(BrowserName,FrameName,TextValue)
'*******************************************************************************************************************************************************************************************
Function funcEditOracleFrame(ByVal BrowserName,ByVal FrameName,ByVal TextValue)
	Dim objPage

	On Error  Resume Next
	Err.Clear

	If BrowserName <> "" Then
		' Create the page object
		Set objPage = funcCreatePageObj(BrowserName)
		If objPage.Frame("html id:="&FrameName).Exist(gLONGWAIT) Then					' Check for Frame object and write value
			objPage.Frame("html id:="&FrameName).Object.writeln TextValue
            funcEditOracleFrame= True																			' Return value
		Else
			funcEditOracleFrame = False
		End If	
	End If

	'Clean Up
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcCloseBrowser(ByVal BrowserName,ByVal IndexNum)
'# Function will close the Browser
'#
'# Parameters:
'# Input Parameters:
'# BrowserName
'#
'# OutPut Parameters: True/False
'#
'# Usage:
'# The usage of this procedure is
'# > funcCloseBrowser(BrowserName)
'*******************************************************************************************************************************************************************************************
Function funcCloseBrowser(ByVal BrowserName,ByVal IndexNum)
	Dim bSuccess

	' Check for browser and close if exists
	If Browser("name:="&BrowserName, "index:="&IndexNum).Exist(gLONGWAIT) Then
        Browser("name:="&BrowserName, "index:="&IndexNum).Close
        bSuccess = True
	Else
		bSuccess = False
	End If

	' Return the value bSuccess
	funcCloseBrowser = bSuccess
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcVerifyExistence(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal strObjectName,ByVal PropertyName,ByVal IndexNum,ByVal strTextToVerify,ByVal strRowVal,ByVal strColumnVal)
'# Function is used to check the existence of an object
'#
'# Input Parameters:
'# BrowserName, FormName, TabName, strObjectName, PropertyName, IndexNum, strTextToVerify, strRowVal, strColumnVal
'#
'# OutPut Parameters: True/False
'#  
'# Remarks:
'# 
'#
'# Usage: >
'*******************************************************************************************************************************************************************************************
Function  funcVerifyExistence(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal strObjectName,ByVal PropertyName,ByVal IndexNum,ByVal strTextToVerify,ByVal strRowVal,ByVal strColumnVal)
	Dim bSuccess
	Dim strMessage

	On Error Resume Next
	Err.Clear
	bSuccess = False

	Wait(5)
	Select Case UCase(strObjectName)

			Case "BROWSER"							'	Check the existence of Browser
					bSuccess = Browser("name:="&BrowserName, "index:="&IndexNum).Exist(gLONGWAIT)
					If bSuccess Then
						Call gfReportExecutionStatus(micPass,"Verify Existence", BrowserName & " window is displayed")
					Else
						Call gfReportExecutionStatus(micFail,"Verify Existence", BrowserName & "  window not displayed")		
					End If
			
			Case "ORACLEFORMWINDOW"				'	Check the existence of Oracle Form Window
					bSuccess = OracleFormWindow("short title:="&FormName, "index:="&IndexNum).Exist(gLONGWAIT)
					If bSuccess Then
						Call gfReportExecutionStatus(micPass,"Verify Existence", FormName & " window is displayed")
					Else
						Call gfReportExecutionStatus(micFail,"Verify Existence", FormName & " window not displayed")					
					End If

			Case "ORACLEFLEXWINDOW"                                                                                                    '               Check the existence of Browser
					bSuccess = OracleFlexWindow("title:="&FormName, "index:="&IndexNum).Exist(gLONGWAIT)
					If bSuccess Then
						Call gfReportExecutionStatus(micPass,"Verify Existence", FormName & " flex window is displayed")
					Else
						Call gfReportExecutionStatus(micFail,"Verify Existence", FormName & "  flex window not displayed")                       
					End If

'=====================================ravikanth 09-mar-2015
			Case "ORACLELISTOFVALUES"                                                                                                    '               Check the existence of ORACLE LIST OF VALUES
					bSuccess = OracleListOfValues("title:="&FormName, "index:="&IndexNum).Exist(gLONGWAIT)
					If bSuccess Then
						Call gfReportExecutionStatus(micPass,"Verify Existence", FormName & " Oracle List of Values window is displayed")
					Else
						Call gfReportExecutionStatus(micFail,"Verify Existence", FormName & "  Oracle List of Values window not displayed")                       
					End If
'=====================================ravikanth 09-mar-2015

			Case "WEBELEMENT"					'	Check the existence of Web Element
					bSuccess = Browser("name:="&BrowserName).Page("title:="&BrowserName).WebElement("innertext:="&PropertyName,"index:="&IndexNum).Exist(gLONGWAIT)
					strMessage = Browser("name:="&BrowserName).Page("title:="&BrowserName).WebElement("innertext:="&PropertyName,"index:="&IndexNum).GetROProperty("innertext")
					If (bSuccess And (strTextToVerify = "")) Then
						Call gfReportExecutionStatus(micPass,"Verify Existence", strMessage & " is displayed.")
					ElseIf Not bSuccess Then
						Call gfReportExecutionStatus(micFail,"Verify Existence", "Object " &PropertyName & "  not displayed.")
					End If
			
					'Verify the WebElement message
					If (bSuccess And (strTextToVerify <> "")) Then
						strMessage = Browser("name:="&BrowserName).Page("title:="&BrowserName).WebElement("innertext:="&PropertyName,"index:="&IndexNum).GetROProperty("innertext")
						If inStr(Trim(strMessage),Trim(strTextToVerify)) > 0 Then
							Call gfReportExecutionStatus(micPass,"Verify Message "," Message " & strMessage & " is displayed.")
						Else
							Call gfReportExecutionStatus(micFail,"Verify Message ","Failed to verify the message Got " & strMessage & " Expected " &strTextToVerify)
							bSuccess = False		' Text verification failed
						End If
					End If
			
			Case "WEBTABLE"					'	Check the existence of Web Table
					bSuccess = Browser("name:="&BrowserName).Page("title:="&BrowserName).WebTable("column names:="&PropertyName,"index:="&IndexNum).Exist(gLONGWAIT)
					If (bSuccess And (strTextToVerify = "")) Then
						Call gfReportExecutionStatus(micPass,"Verify Existence","WebTable is displayed.")
					ElseIf Not bSuccess Then
						Call gfReportExecutionStatus(micFail,"Verify Existence","WebTable  " &PropertyName & "  is not displayed.")
					End If
					
					'Verify the WebElement message
					If (bSuccess And (strTextToVerify <> "")) Then
						strMessage = Browser("name:="&BrowserName).Page("title:="&BrowserName).WebTable("column names:="&PropertyName,"index:="&IndexNum).GetCellData(strRowVal, strColumnVal)
						If StrComp(Trim(strTextToVerify),Trim(strMessage),1) = 0 Then
							Call gfReportExecutionStatus(micPass,"Verify Message","Got message " & strMessage)
						Else
							Call gfReportExecutionStatus(micFail,"Verify Message ","Failed to verify the message Got " & strMessage & " Expected " &strTextToVerify)
							bSuccess = False		' Text verification failed
						End If
					End If
			
			Case "LINK"				'	Check the existence of Link
					bSuccess = Browser("name:="&BrowserName).Page("title:="&BrowserName).Link("name:="&PropertyName,"index:="&IndexNum).Exist(gLONGWAIT)
					If bSuccess Then
						Call gfReportExecutionStatus(micPass,"Verify Existence","Link " & PropertyName & "  is displayed")
					Else
						Call gfReportExecutionStatus(micFail,"Verify Existence ","Link " & PropertyName & "  not displayed")
					End If
			
			Case "DRMWEBELEMENT"					'	Check the existence of DRM Web Element
					intLen=Len(BrowserName)
					BrowserName = Right(BrowserName,intLen- 1)
'------------------------------------14-Dec-2014
					If Instr(PropertyName,"#") > 0 Then
						PropertyName = Split(PropertyName,"#")(1)
						bSuccess = Browser("micclass:=Browser","title:="&BrowserName).Page("micclass:=Page","url:="&BrowserName).WebElement(PropertyName,"index:="&IndexNum).Exist(gLONGWAIT)
						strMessage = Browser("micclass:=Browser","title:="&BrowserName).Page("micclass:=Page","url:="&BrowserName).WebElement(PropertyName,"index:="&IndexNum).GetROProperty("innertext")
						If (bSuccess And (strTextToVerify = "")) Then
							Call gfReportExecutionStatus(micPass,"Verify Existence", strMessage & " is displayed.")
						ElseIf Not bSuccess Then
							Call gfReportExecutionStatus(micFail,"Verify Existence", "Object " &PropertyName & "  not displayed.")
						End If
					Else
'------------------------------------14-Dec-2014
						bSuccess = Browser("micclass:=Browser","title:="&BrowserName).Page("micclass:=Page","url:="&BrowserName).WebElement("innertext:="&PropertyName,"index:="&IndexNum).Exist(gLONGWAIT)
						strMessage = Browser("micclass:=Browser","title:="&BrowserName).Page("micclass:=Page","url:="&BrowserName).WebElement("innertext:="&PropertyName,"index:="&IndexNum).GetROProperty("innertext")
						If (bSuccess And (strTextToVerify = "")) Then
							Call gfReportExecutionStatus(micPass,"Verify Existence", strMessage & " is displayed.")
						ElseIf Not bSuccess Then
							Call gfReportExecutionStatus(micFail,"Verify Existence", "Object " &PropertyName & "  not displayed.")
						End If
					End If

'3MAy2016######################################################################################################################################################

			Case "IMAGE"				'	Check the existence of Image
			
					bSuccess = Browser("name:="&BrowserName).Page("title:="&BrowserName).Image("file name:="&PropertyName,"index:="&IndexNum).Exist(gLONGWAIT)
					If bSuccess Then
						Call gfReportExecutionStatus(micPass,"Verify Existence","Image " & PropertyName & "  is displayed")
					Else
						Call gfReportExecutionStatus(micFail,"Verify Existence ","Image " & PropertyName & "  not displayed")
					End If
					
'#####################################################################################################################################################################					
					
					
			Case Else				' No match found
					Call gfReportExecutionStatus(micWarning,"Verify Existence","Incorrect option " & strObjectName & " Check the Usage of Keyword: VerifyExistence")

	End Select

	Wait(3)
	'return the value
	funcVerifyExistence = bSuccess
End Function

'*******************************************************************************************************************************************************************************************
'# Function: fgFuncReadExcel(ByVal strExcelFileName, ByVal strSheetName, ByVal strWhereClause,ByRef rsTestData)
'# Function is used to read the data from excel file
'#
'# Parameters:
'# strExcelFileName, strSheetName, strWhereClause, rsTestData
'#
'# OutPut Parameters: rsTestData
'#  
'# Usage: >
'*******************************************************************************************************************************************************************************************
Public Function gFuncReadExcel(ByVal strExcelFileName, ByVal strSheetName, ByVal strWhereClause,ByRef rsTestData)

	Err.Clear

    'Local variable declarations
	Dim objConnection 		'ADO Connection Object
	Dim strExcelConnString	'Excel Connection String
	Dim strExcelQuery 		'Stores SQL Query
    Dim strExcelFilePath	'Complete Excel File Path
	Dim qtApp				'QuickTestApplication Object
	Dim arrIndex
	Dim objADORecordSet
	Dim intFieldCount
    
	Set rsTestData = CreateObject("ADODB.Recordset")

	Set objDict = CreateObject("Scripting.Dictionary")
	gFuncReadExcel = "Error:gFuncReadExcel"
    
	'Download TestData Attachement
'	If(QCUtil.IsConnected) Then
'		Set qtApp = CreateObject("QuickTest.Application")
'		If(InStr(qtApp.Test.Location ,"[QualityCenter]") > 0) Then
'			strExcelFileName = gFuncQCAttachmentDownload(strExcelFileName)
'		End If
'		Set qtApp = Nothing
'	End If

	'Get Complete Path of TestData File
	If(InStr(strExcelFileName,"..\") > 0) Then
		strExcelFilePath = gFuncGetRelativePath(strExcelFileName)
	Else
		strExcelFilePath = strExcelFileName
	End If

    'Open the Database connection
	Set objConnection = CreateObject("ADODB.Connection")
	strExcelConnString = Replace(Environment("ExcelConnString"),"?sheetName",strExcelFilePath)
    objConnection.Open strExcelConnString
    
    strExcelQuery = "SELECT * FROM [" & strSheetName & "$]"
	If(Len(Trim(strWhereClause)) > 0) Then
		strExcelQuery = strExcelQuery & " WHERE " & CStr(strWhereClause)
	End If
    
    'Open the record set
    Set objADORecordSet = CreateObject("ADODB.Recordset")
    objADORecordSet.Open strExcelQuery,objConnection
	
	While(Not objADORecordSet.EOF)
		objADORecordSet.MoveFirst
		For arrIndex= 0 To objADORecordSet.Fields.Count-1
			If(Trim(objADORecordSet.Fields(arrIndex).value)&""="") Then
				Exit For
			Else
				rsTestData.Fields.Append Trim(objADORecordSet.Fields(arrIndex).Value), adVarChar, 1000
			End If
		Next
		intFieldCount = arrIndex
		rsTestData.Open
		objADORecordSet.MoveNext
		While(Not objADORecordSet.EOF)
			rsTestData.AddNew	 
			For arrIndex= 0 To intFieldCount-1
				If(IsNull(objADORecordSet.Fields(arrIndex).value)) Then
					rsTestData(arrIndex) = Empty
				Else
					rsTestData(arrIndex) = objADORecordSet.Fields(arrIndex).value
				End If
			Next
			objADORecordSet.MoveNext
		Wend
    Wend
End Function

'*******************************************************************************************************************************************************************************************
'# Function: gFuncGetRelativePath
'# This Function is used to Get actual path from the relative path of QTP
'#
'# Input Parameters:
'# strRelativePath - QTP Relative path as string
'# 
'# OutPut Parameters: N/A
'#
'# Remarks:
'# Returns string with the actual path from the function
'#
'# Usage: strActPath =  gFuncGetRelativePath(strRelativePath)
'*******************************************************************************************************************************************************************************************
Public Function gFuncGetRelativePath(strRelativePath)
	Dim strTemp

	Err.Clear

	strRelativePath = Trim(strRelativePath)
	gFuncGetRelativePath = "Error:gFuncGetRelativePath"

	If(InStr(strRelativePath, "..\") = 0) Then
	   gFuncGetRelativePath = strRelativePath
	   Exit Function
	End If

	If(Len(Trim(strRelativePath)) =0) Then
		Exit Function
	End If

	If(PathFinder.Locate(strRelativePath) = "") Then
		strRelativePath = "..\" & strRelativePath
	End If

	strRelativePath = PathFinder.Locate(strRelativePath)

	If(InStr(strRelativePath, "\\") > 0)  Then
		strTemp = Replace(Mid(strRelativePath,3), "\\", "\")
		If(Left(strRelativePath,2) =  "\\") Then
			strRelativePath = "\\" & strTemp
		End If
	End If
			
	gFuncGetRelativePath = strRelativePath

End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcVerifyStatusBarMessage(ByVal strMessage)
'# Function will check the status bar message
'#
'# Parameters:
'# Input Parameters:
'# strMessage
'#
'# OutPut Parameters: True/False
'#
'# Usage: > funcVerifyStatusBarMessage(strMessage)
'*******************************************************************************************************************************************************************************************
Function funcVerifyStatusBarMessage(ByVal strMessage, ByVal ArrayPosition, ByVal strStepID)
	Dim bSuccess
	Dim strActualMessage
	Dim iCnt

	On Error Resume Next
	Err.Clear

	strActualMessage = ""			'	Initialise
	iCnt = 0
	strActualMessage = OracleStatusLine("micclass:=OracleStatusLine").GetROProperty("message")

	Do Until strActualMessage <>""		' Wait till we get the message or timeout 300s i.e., 5 min
		Wait gSHORTWAIT
		strActualMessage = OracleStatusLine("micclass:=OracleStatusLine").GetROProperty("message")
		iCnt = iCnt+1
		If iCnt > 60 Then 						' Break loop if iCnt exceeds 60
			Exit Do
		End If
	Loop

	' Check the message exists in status bar
	If inStr(1, strActualMessage,strMessage,1)> 0 Then
		'Call gfReportExecutionStatus(micPass,"StatusBar Message","Got the message  :" & strActualMessage)
		Call gfReportExecutionStatus(micPass,"Status Bar Message","Got the message : '" & strActualMessage &"'")
		If IsNumeric(ArrayPosition) Then
			strActualMessage = funcSearchPattern(strActualMessage, "[+0-9]+",ArrayPosition )      
			dicGlobalOutput.Add strStepID,strActualMessage
		End If
		funcVerifyStatusBarMessage = True
	Else
		Call gfReportExecutionStatus(micFail,"StatusBar Message","Verify message Failed Got : " & strActualMessage & " and Expected: " & strMessage)
		 funcVerifyStatusBarMessage = False
	End If

End Function

'*******************************************************************************************************************************************************************************************
'# Function: QCGetResource
'# This Function is used to Download attachment from Resource tab
'#
'# Parameters:
'# Input Parameters:
'# strResourceName -  Name of the attachment to Download
'# saveTo:- Path to Save the dowenloaded resource file
'# 
'# OutPut Parameters: N/A
'#
'# Remarks:
'# Returns string with the actual path from the function
'#
'# Usage:
'# The usage of this function is
'# strActPath =  gFuncGetRelativePath(strRelativePath)
'*******************************************************************************************************************************************************************************************
Function QCGetResource(strResourceName,saveTo)
	Set qcConn = QCUtil.QCConnection
	Set oResource = qcConn.QCResourceFactory
	Set oFilter = oResource.Filter
	Set FSO=CreateObject("Scripting.FileSystemObject")
	strFilePath=saveTo&"\"&strResourceName
	If FSO.FileExists(strFilePath) Then
		QCGetResource=strFilePath
		Exit Function
	End If
	oFilter.Filter("RSC_FILE_NAME") = strResourceName	
	Set oResourceList = oFilter.NewList	
	If oResourceList.Count = 1 Then
		Set oFile = oResourceList.Item(1)
		oFile.FileName = strResourceName
		oFile.DownloadResource saveTo, True
		If Instr(strResourceName,"TestData")>0 Then
        	'Opening Test Data XL File and Save
			Call OpenAndSaveTestDataFiles(Replace(DataTableBook,".xls","")&"_TestData.xls",Environment.Value("TestDataPath"))
		End If
	End If
	strFilePath=saveTo&"\"&strResourceName
	QCGetResource=strFilePath
	Set qcConn = Nothing
	Set oResource = Nothing
	Set oFilter = Nothing
	Set oFlieList = Nothing
	Set oFile = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'* Function Name                 :funcGetTestDataFolderPath
'* Author                        :DXC                       
'* Purpose                       :Function used to get the mentioned file's absolute path
'* Dependencies                         : 
'* Preconditions                 :
'* Input Parameters                     :strFileName - Name of the file
'* Output Parameters                  :
'* Revision History              : 
'*******************************************************************************************************************************************************************************************
Public Function funcGetTestDataFolderPath()
   'Create a QC object
            Set otaTreeManager = QCUtil.TDConnection.TreeManager
            Set otaTest = QCUtil.CurrentTest
    QCSubjectPath = otaTreeManager.NodePath (otaTest.Field("TS_SUBJECT").NodeID)
            strQCFilePath=QCSubjectPath 
            If Err.Number=0 Then
                        funcGetTestDataFolderPath=QCSubjectPath 
'                       funcGetTestDataFolderPath=True
            Else
                        funcGetTestDataFolderPath= False
            End If
End Function

'*******************************************************************************************************************************************************************************************
'# Procedure: procBrowserMaximize
'# This Procedure is used to Maximize the Browser
'#
'# Parameters:
'# Input Parameters:
'# objBrowser - Browser to be maximized
'#
'# OutPut Parameters: N/A
'#
'# Remarks:
'#
'# Usage:
'# The usage of this procedure is
'# > Call procBrowserMaximize(Browser("brSOSDesignTools"))
'*******************************************************************************************************************************************************************************************
Public Function funcBrowserMaximize(objBrowser)

	Err.Clear
	On Error Resume Next
	
	Dim hWnd

	'Verify whether Browser type is firefox or Internet explorer
    hWnd = Browser("hwnd:=" & objBrowser.GetROProperty("hwnd")).Object.hWnd
	Window("hwnd:=" & hWnd).Activate()
	Window("hwnd:=" & hWnd).Maximize()
     	
	'Check and Report Runtime Errors If any
	If (Err.Number<>0) Then
        Err.Clear
	End If
	
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcVerifyTableRowValue(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName, ByVal ColumnNames,ByVal ReportColumn,ByVal strReportText, ByVal CoulmnNameToVerify,ByVal strTextToVerify)
'# Function is used to check the Report status with given iExpense number is Table.
'#
'# Input Parameters:
'# BrowserName:								Name of Browser
'# FormName:									Form name
'# TabName:										Tab Name if required
'# ObjName:										WebTable name property
'# ColumnNames:	 						Web Table property 'column names'
'# ReportColumn:						 Column name or number where IExpense Id exists
'# strReportText:							Expense Id
'# CoulmnNameToVerify:			Column name or number where verify text exists
'# strTextToVerify:							Verify text
'#
'# OutPut Parameters: True/False
'#
'# Usage:>
'*******************************************************************************************************************************************************************************************
Function  funcVerifyTableRowValue(ByVal BrowserName,ByVal FormName,ByVal TabName,ByVal ObjName, ByVal ColumnNames,ByVal ReportColumn,ByVal strReportText, ByVal CoulmnNameToVerify,ByVal strTextToVerify)
	Dim objPage
	Dim objTables
	Dim tblObject
	Dim iCount
	Dim intRowNum
	Dim arrCloumns

	On Error Resume Next
	Err.Clear
	
	intRowNo = -1

	If BrowserName <>"" Then
		'Create the Page object
		Set objPage = funcCreatePageObj(BrowserName)
		Wait(3)

		'If InStr(ObjName,"#") >0 Then
		If InStr(ObjName,"#") > 0 Then
			Set tblObject = objPage.WebTable("column names:="& Split(ObjName,"#")(0),"index:=" & Split(ObjName,"#")(1))
		Else
			'Set tblObject = objPage.WebTable("column names:="&ObjName)
			Set tblObject = objPage.WebTable("column names:="& ObjName)
		End If

		' Convert the column ColumnNameToSearch to integer
		arrCloumns = Split(tblObject.GetROProperty("column names"),";")

		If IsNumeric(ReportColumn) Then
			ReportColumn = CInt(ReportColumn)
		Else
			For iCount = 0 to Ubound(arrCloumns)
				If StrComp(arrCloumns(iCount), Trim(ReportColumn)) = 0 Then
					ReportColumn = iCount +1
					Exit For
				End If
			Next
		End If

		' Convert the column CoulmnNameToVerify to integer
		If IsNumeric(CoulmnNameToVerify) Then
			CoulmnNameToVerify = CInt(CoulmnNameToVerify)
		Else
			For iCount = 0 to Ubound(arrCloumns)
				If StrComp(arrCloumns(iCount), Trim(CoulmnNameToVerify)) = 0 Then
					CoulmnNameToVerify = iCount +1
					Exit For
				End If
			Next
		End If

'		If objTables.Exist(gLONGWAIT) Then
'				For iCount = 1 to  objTables.RowCount
'					If StrComp(objTables.GetCellData(iCount,ReportColumn),strReportText) = 0  then
'						intRowNum = iCount
'						Exit For
'					End If
'				Next
'
'				If StrComp(objTables.GetCellData(intRowNum,CoulmnNameToVerify),strTextToVerify) = 0 Then
'					funcVerifyTableRowValue = True								'return the value
'				Else
'					funcVerifyTableRowValue = False								'return the value
'				End If
'		End If

		If tblObject.Exist(gLONGWAIT) Then
				For iCount = 1 to  tblObject.RowCount
					'If StrComp(tblObject.GetCellData(iCount,ReportColumn),strReportText) = 0  then
					If Instr(tblObject.GetCellData(iCount,ReportColumn),strReportText) > 0  then
						intRowNo = iCount
						Exit For
					End If
				Next
				
				If intRowNo = -1 Then
						intRowNo = funcFindRowInWebTable(objPage,tblObject,ObjName,ReportColumn,strReportText)
						If  intRowNo = -1Then
							funcVerifyTableRowValue	 = False
							Call gfReportExecutionStatus(micFail,"Find the table row", "Table row not found with text :" &strText)
							Exit Function
						End If
				End If

				'If StrComp(tblObject.GetCellData(intRowNum,CoulmnNameToVerify),strTextToVerify) = 0 Then
				If Instr(tblObject.GetCellData(intRowNo,CoulmnNameToVerify),strTextToVerify) > 0 Then
					funcVerifyTableRowValue = True								'return the value
				Else
					funcVerifyTableRowValue = False								'return the value
				End If
		End If
	End If

	'Clean Up
	Set tblObject = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcClickOnWebElement(ByVal BrowserName,ByVal strObjectName,ByVal IndexNum)
'# Function is used to click on Web element
'#
'# Input Parameters:
'# BrowserName:								Name of Browser
'# strObjectName:								Web Element property
'# IndexNum:										Index number if required
'#
'# OutPut Parameters: True/False
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function  funcClickOnWebElement(ByVal BrowserName,ByVal strObjectName,ByVal IndexNum, ByVal Htmlid, ByVal Clas)
	Dim objPage
	Dim objElement
	Dim bSuccess
	
	 On Error Resume Next
	 Err.Clear

	 bSuccess = False
	 'Create Page object
	 Set objPage = funcCreatePageObj(BrowserName)
	 If InStr(strObjectName,"^")>0Then
		Set objElement =objPage.WebElement(Split(strObjectName,"^")(1),"index:="&IndexNum)
	 Else
	 	If InStr(BrowserName, "CoStar") > 0 Then
	 		Set objElement = objPage.WebElement("innertext:="&strObjectName,"visible:=True","index:="&IndexNum)
	 	Else
	 		Set objElement = objPage.WebElement("innertext:="&strObjectName, "visible:=True","index:="&IndexNum, "html id:="&Htmlid, "class:="&Clas)
	 	End If
	 End If

	'Check for Webelment and click on it
	 If objElement.Exist(gSYNCWAIT) Then
		objElement.Click
		wait(2)
		bSuccess = True
	 End If

	' Check for error no
	If Err.Number <> 0 Then bSuccess = False

	 ' Return the value
	 funcClickOnWebElement = bSuccess

	'Clean Up
	Set objElement = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcExportCart()
'# Function is used to check filedownlad while exporting the cart to xl file
'#
'# Input Parameters:None
'#
'# OutPut Parameters: None
'#  
'# Usage:call this function thru BusinessFunction keyword
'*******************************************************************************************************************************************************************************************
Function funcExportCart()
    Dim bSuccess
	Dim objExcel

	On Error Resume Next
	Err.Clear

	'Process the download window
	Call funcProcessDownloadWindow()
	Wait gMEDIUMWAIT

	'Verify file is exported and close xl file
	Set objExcel = GetObject("","Excel.Application")										' Don't change this line though it give the syntax error.
	objExcel.Visible = True
	objExcel.DisplayAlerts = False

	If InStr(objExcel.ActiveWorkbook.Name,"Cart_")>0 Then
		Call gfReportExecutionStatus(micPass,"Exporting Cart","Exported File " & objExcel.ActiveWorkbook.Name)
	Else
		Call gfReportExecutionStatus(micFail,"Exporting Cart","Failed to export file")
	End If

	' Close the xl workbook
	objExcel.ActiveWorkbook.Close

	' Close the XL process
	SystemUtil.CloseProcessByName("EXCEL.EXE")

	'Error Handling
	If Err.Number <> 0 Then
		On Error GoTo 0
	End If

	'Clean Up
	Set objExcel = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcProcessDownloadWindow
'# Function is used to process the download window
'#
'# Input Parameters:None
'#
'# OutPut Parameters: None
'#  
'# Usage:call this function thru BusinessFunction keyword
'*******************************************************************************************************************************************************************************************
Function funcProcessDownloadWindow()
	Dim objDialog
	Dim oDesc
	Dim objButtons
	Dim objButtonOpen
	Dim objButtonYes
	Dim intCnt
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	bSuccess = False
	Set objDialog = Dialog("regexpwndtitle:=File Download")
	Set oDesc = Description.Create
	oDesc("Micclass").Value = "WinButton"

	'Look for file download dialogbox
	If objDialog.Exist(gLONGWAIT) Then
		objDialog.Activate()
		Set objButtons = objDialog.ChildObjects(oDesc)
		For intCnt = 0 to objButtons.Count-1
			If Instr(objButtons(intCnt).GetROProperty("regexpwndtitle"),"Open")>0 Then
				Set objButtonOpen = objButtons(intCnt)
				Exit For
			End If
		Next
		
		'Click on Open button
		If objButtonOpen.Exist(gSYNCWAIT) Then
			objButtonOpen.Click 10,10,0
			bSuccess = True
		End If

		If objButtonOpen.Exist(gSYNCWAIT) Then					'in case not able to click first time
			objButtonOpen.Click 10,10,0
			bSuccess = True
		End If
	Else
		Call gfReportExecutionStatus(micFail,"Export Cart","FileDownload Dialog box doesn't exist")
		Exit Function
	End If
	Wait 5
	' Look Microsoft xl Message
	Set objDialog = Window("regexpwndtitle:=Microsoft Excel").Dialog("regexpwndtitle:=Microsoft Excel")
	If objDialog.Exist(gMEDIUMWAIT) Then
		objDialog.Activate()
		Set objButtons = objDialog.ChildObjects(oDesc)

		For intCnt = 0 to objButtons.Count-1
			If Instr(objButtons(intCnt).GetROProperty("regexpwndtitle"),"Yes")>0 Then
				Set objButtonYes = objButtons(intCnt)
				Exit For
			End If
		Next

		' Click on Yes button
		If objButtonYes.Exist(gSYNCWAIT) Then
			objButtonYes.Click 10,10,0
			bSuccess = True
		End If
		' Click on Yes button
		If objButtonYes.Exist(gSYNCWAIT) Then
			objButtonYes.Click 10,10,0
			bSuccess = True
		End If
	End If

	'Send Keys
	Set objWS = CreateObject("WScript.Shell")
	objWS.SendKeys "%{Y}"

	Wait 5

	'Error Handling
	If Err.Number <> 0 Then
		On Error GoTo 0
	End If

	'Clean Up
	Set objDialog = Nothing
	Set oDesc = Nothing
	Set objButtons = Nothing
	Set objButtonOpen = Nothing
	Set objButtonYes = Nothing
	Set objWS = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcFindTableRowAndClickObject(ByVal BrowserName,ByVal ObjName,ByVal ColumnNameToSearch,ByVal strText,ColumnNameToAct,ByVal ObjClass,ByVal ClassIndex)
'# Function is used to find the row and click on object
'#
'# Input Parameters:
'#BrowserName							:	Browser tile
'#ObjName									:	column names property of WebTable
'#ColumnNameToSearch		:	Which Column to search
'#strText											:	Search text
'#ColumnNameToAct				:	Which Column to act or destination column
'#ObjClass			:	MicClass of that Object
'#ClassIndex			:	index of that Object
'#  
'# OutPut Parameters: None
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcFindTableRowAndClickObject(ByVal BrowserName,ByVal ObjName,ByVal ColumnNameToSearch,ByVal strText,ColumnNameToAct,ByVal ObjClass,ByVal ClassIndex)
	Dim objPage
	Dim tblObject
	Dim objElement
	Dim arrCloumns
	Dim intRowNo, intCnt
	Dim strReportText

	On Error Resume Next
	Err.Clear

	intRowNo = -1

	' Creat page and table objects
	Set objPage = funcCreatePageObj(BrowserName)
	Wait(3)

	If InStr(ObjName,"#") >0 Then
		Set tblObject = objPage.WebTable("column names:="& Split(ObjName,"#")(0),"index:=" & Split(ObjName,"#")(1))
	Else
		Set tblObject = objPage.WebTable("column names:="&ObjName)
	End If


	' Convert the column ColumnNameToSearch to integer
	arrCloumns = Split(tblObject.GetROProperty("column names"),";")
	If IsNumeric(ColumnNameToSearch) Then
		ColumnNameToSearch = CInt(ColumnNameToSearch)
	Else
		For intCnt = 0 to Ubound(arrCloumns)
			If StrComp(Trim(arrCloumns(intCnt)), Trim(ColumnNameToSearch)) = 0 Then
				ColumnNameToSearch = intCnt +1
				Exit For
			End If
		Next
	End If

	For intCnt = 1 to tblObject.RowCount
		If inStr(Trim(tblObject.GetCellData(intCnt,ColumnNameToSearch)),Trim(strText)) > 0 Then
			intRowNo = intCnt
			Exit For
		End If
	Next

	If intRowNo = -1 Then
		intRowNo = funcFindRowInWebTable(objPage,tblObject,ObjName,ColumnNameToSearch,strText)
		If intRowNo = -1Then
			funcFindTableRowAndClickObject = False
			Call gfReportExecutionStatus(micFail,"Find the table row", "Table row not found with text :" &strText)
			Exit Function
		End If
	End If

	' Convert the column ColumnNameToAct to integer
	If IsNumeric(ColumnNameToAct) Then
		ColumnNameToAct = CInt(ColumnNameToAct)
	Else
		For intCnt = 0 to Ubound(arrCloumns)
			If StrComp(Trim(arrCloumns(intCnt)), Trim(ColumnNameToAct)) = 0 Then
				ColumnNameToAct = intCnt +1
				Exit For
			End If
		Next
	End If

	Set objElement = tblObject.ChildItem(intRowNo,ColumnNameToAct,ObjClass,CInt(ClassIndex))

	' Get the text for reporting only
	If ObjClass = "Image" Then
		strReportText = objElement.GetROProperty("alt")
	ElseIf ObjClass = "Link" Then
		strReportText = objElement.GetROProperty("innerText")
	ElseIf ObjClass = "WebRadioGroup" Then
		strReportText = objElement.GetROProperty("name") & " WebRadioGroup"
    ElseIf ObjClass = "WebCheckBox" Then
		strReportText = objElement.GetROProperty("html id")
	End If

	'Click on image or a link
	If objElement.Exist(2) Then

		If ObjClass = "WebRadioGroup" Then
			 intRowNo = intRowNo - 2
			objElement.Select intRowNo
		Else
			objElement.Click
		End If

		funcFindTableRowAndClickObject = True
		Call gfReportExecutionStatus(micDone,"Click on " &ObjClass,"Clicked on "&strReportText)
	Else
		funcFindTableRowAndClickObject = False
		Call gfReportExecutionStatus(micFail,"Click on " &ObjClass,"Failed to click on "&strReportText)
	End If


	'Clean Up
	Set objElement = Nothing
	Set tblObject = Nothing
	Set objPage = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function:  funcCheckPriceRangeForSpendSmart()
'# Function is used to check the price range for Spendsmart
'#
'# Input Parameters:
'#BrowserName							:	Browser tile
'#ObjName									:	column names property of WebTable
'#ColumnNameToSearch		:	Which Column to search
'#strText											:	Search text
'#ColumnNameToAct				:	Which Column to act or destination column
'#ObjClass									:	MicClass of that Object
'#ClassIndex							:	index of that Object
'#  
'# OutPut Parameters: True/False
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcCheckPriceRangeForSpendSmart()
	Dim objPage
	Dim tblObject
	Dim PriceRange
	Dim LowerBound
	Dim UpperBound
	Dim intCnt
	Dim ItemPrice
	Dim bSuccess
	
	bSuccess = True
	
	Set objPage = Browser("name:=Vinimaya SmartSearch Catalog Solutions.*")
	PriceRange = objPage.WebList("name:=Select").GetROProperty("value")
	
	LowerBound = Cint(Trim(Split(PriceRange,"~")(0)))
	UpperBound = Cint(Trim(Split(PriceRange,"~")(1)))

	Set tblObject = objPage.WebTable("column names:=;Product Image;Description;Unit;Supplier Supplier Name Supplier Part.*")
	For intCnt = 2 to tblObject.RowCount
		ItemPrice = tblObject.GetCellData(intCnt,7)
		If isNumeric(ItemPrice) Then
			ItemPrice = Cdbl(ItemPrice)

			'Check the price range
			If ItemPrice> LowerBound And ItemPrice < UpperBound Then
				Call gfReportExecutionStatus(micDone,"Check Price Range",ItemPrice & " is within the range.")
			Else
				Call gfReportExecutionStatus(micFail, "Check Price Range",ItemPrice & " not in the range. Lowerbound: "& LowerBound & " and UpperBound "&UpperBound)
				bSuccess = False
				Exit For
			End If
	
		End If
	Next

	If bSuccess Then
		Call gfReportExecutionStatus(micPass,"Check Price range", "Price Range Verification passed.")
		funcCheckPriceRangeForSpendSmart = True
	Else
		funcCheckPriceRangeForSpendSmart = False
	End If


	' Clean Up
	Set tblObject = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcPageSync(ByVal BrowserName)
'# Function is used to sync the page
'#
'# Input Parameters:
'#BrowserName							:	Browser tile
'#  
'# OutPut Parameters: None
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcPageSync(ByVal BrowserName)
	Dim objPage

	On Error Resume Next
	Err.Clear

	' wait till the page loads completely
	Set objPage = funcCreatePageObj(BrowserName)
	If objPage.Exist(gLONGWAIT*6) Then
		objPage.Sync
	End If
	Wait(gSYNCWAIT)

	' Clean Up
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcReleaseHold()
'# Function is used to release hold form Release table
'#
'# Input Parameters: None
'#  
'# OutPut Parameters: None
'#  
'# Usage:Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcReleaseHold()
	Dim objForm
	Dim tblObject
	Dim intRowCount
	Dim intCount

	On Error Resume Next
	Err.Clear

	' Create the form and table object
	Set objForm = OracleFormWindow("short title:=Invoice Workbench").OracleTabbedRegion("label:=3 Holds")
    Set tblObject = objForm.OracleTable("block name:=AP_HOLDS")

	If tblObject.Exist(gMEDIUMWAIT) Then
		intRowCount = tblObject.GetROProperty("visible rows")				' Returns the table row count

		'Check for rows in the table and release the Holds
		For intCount =1 to intRowCount

            If (tblObject.GetFieldValue(intCount,1) <> "") And (tblObject.GetFieldValue(intCount,5) =  "") Then
				tblObject.SetFocus intCount,1
				Wait gSYNCWAIT
				objForm.OracleButton("description:=Release...*").Click
                If OracleFormWindow("short title:=Release").Exist(gMEDIUMWAIT) Then
					OracleFormWindow("short title:=Release").OracleTextField("description:=Release Name").Enter "Invoice Quick Released"
					OracleFormWindow("short title:=Release").OracleTextField("description:=Release Reason").Enter "Holds released in Invoice Holds window"
					OracleFormWindow("short title:=Release").OracleButton("description:=OK").Click
					Call gfReportExecutionStatus(micDone,"Release Hold"," Released the Row " & intCount)
					Wait gSYNCWAIT
				Else
					Call gfReportExecutionStatus(micFail,"Release Hold","Release dialogbox not appeared")
				End If
			End If

		Next

	Else
		Call gfReportExecutionStatus(micFail,"Release Hold","Release table doesn't exist")
	End If

	' Print Error
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "Release Hold", "Got the error " & Err.Description)
	End If

	' Clean Up
	Set tblObject = Nothing
	Set objForm = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcBusinessReporting(strParam)
'# Function is used for business reporting
'#
'# Input Parameters: 
'# strParam:-		Report string
'#  
'# OutPut Parameters: None
'#  
'# Usage:>
'*******************************************************************************************************************************************************************************************
Function funcBusinessReporting(ByVal strParam)
	Dim strReportString
	Dim arrReport

	' Reformat report string
	arrReport = Split(strParam,";")

	If Ubound(arrReport) > 0 Then
		strReportString = funcGenerateReportString(arrReport(1))
	Else
		strReportString = funcGenerateReportString(arrReport(0))
	End If

	If Instr(UCase(arrReport (0)),"STARTING TEST") > 0 And Environment("TCFail") = False Then
		Call gfReportExecutionStatus(micPass, "*****" & arrReport(0) , "******For Scenario # '" & strReportString &"'")
	ElseIf Environment("TCFail") = False Then
		Call gfReportExecutionStatus(micPass,arrReport(0) ,  strReportString)
	Else
		Call gfReportExecutionStatus(micFail, "******** " & arrReport(0) , "Failed to '" & strReportString & "'")
	End If 	

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcEmptyShoppingCart()
'# Function is used to release hold form Release table
'#
'# Input Parameters: None
'#  
'# OutPut Parameters: None
'#  
'# Usage:Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcEmptyShoppingCart()
	Dim ObjPage
	Dim tblObject
	Dim objImage
	Dim intCnt
	Dim strPrice

	On Error Resume Next
	Err.clear

	Set ObjPage = Browser("name:=Oracle iProcurement: Shop").Page("title:=Oracle iProcurement: Shop")
	
	If Not ObjPage.WebTable("column names:=Your cart is empty.").Exist(gMEDIUMWAIT)  Then
		
			'If ObjPage.Link("name:=Shopping Cart","index:=0").Exist Then
			If ObjPage.Link("name:=Shopping Cart","index:=0").Exist(10) Then
				ObjPage.Link("name:=Shopping Cart","index:=0").Click
			End If

			Wait gMEDIUMWAIT

			Set ObjPage = Browser("name:=Oracle iProcurement: Checkout").Page("title:=Oracle iProcurement: Checkout")

			If ObjPage.WebTable("column names:=Line;Item Description;Special Info;Unit;Quantity;Price;Amount.*").Exist(gMEDIUMWAIT) Then
				Set tblObject = ObjPage.WebTable("column names:=Line;Item Description;Special Info;Unit;Quantity;Price;Amount.*")
				strPrice = tblObject.GetCellData(2,6)
				intCnt = 1
				Do until strPrice = ""
					Set objImage = tblObject.ChildItem(2,10,"Image",0)
					objImage.Click
					wait 5
					tblObject.RefreshObject
					strPrice = tblObject.GetCellData(2,6)
					intCnt = intCnt +1
					If intCnt >20 Then Exit Do
				Loop
				
			End If
			
			'If ObjPage.Link("name:=Shop","index:=0").Exist Then
			If ObjPage.Link("name:=Shop","index:=0").Exist(10) Then
				ObjPage.Link("name:=Shop","index:=0").Click
			End If

	End If

	' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"Shoping cart Empty","Got the Error : " & Err.Description)
	End If

	' Clean Up
	Set objImage = Nothing
	Set tblObject = Nothing
	Set ObjPage = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcVerifyOutputText(ByVal ObjName, ByVal Index, ByVal strVerifyText)
'# Function is used to verify the text in report output
'#
'# Input Parameters: 
'# ObjName			: 	Web element Object name
'# Index				:		Web Element index
'# strVerifyText	:		Text to verify
'#
'# OutPut Parameters: None
'#  
'# Usage:Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcVerifyOutputText(ByVal ObjName, ByVal Index, ByVal strVerifyText)
	Dim objPage
	Dim strText

	On Error Resume Next
	Err.Clear

	Set objPage = Browser("name:=.*temp_id.*").Page("title:=")
	Set objWebElement = objPage.WebElement("html tag:="&ObjName,"index:=" &Index)
	Set strText = objWebElement.GetROProperty("innerText")

	If objWebElement.Exist(gLONGWAIT) Then

		If InStr(strText, strVerifyText) > 0Then
			Call gfReportExecutionStatus(micPass," Verify the output text", " Text " & strVerifyText &" found")
		Else
			Call gfReportExecutionStatus(micFail," Verify the output text", " Text " & strVerifyText &" not found in the WebElement " & ObjName)
		End If

	Else
		Call gfReportExecutionStatus(micFail,"Verify output text", " WebElement " & ObjName & " not found.")
	End If

	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"Verify Output Text", "Verify output text failed")
	End If

	'Clean Up
	Set objWebElement = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcVerifyObjectAndPerformAction(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum,ByVal ObjClass,ByVal strProperty, ByVal intTimeOut)
'# Function is used to handle the exception conditions which are not covered in the keywords, Ex: if button or listbox appears randomly
'#
'# Input Parameters: 
'# BrowserName			: 	Browser Name
'# FormName				:		Form Name
'# TabName				:		Tab Name
'#  ObjName				:		Object name or Property Val
'#  IndexNum			: 		Index number
'#  ObjClass			:		Object class ex: OracleButton or OracleTextField
'#  strProperty			: 		Property name
'#  intTimeOut			:		Time out
'#
'# OutPut Parameters: None
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcVerifyObjectAndPerformAction(ByVal BrowserName,ByVal FormName,ByVal TabName, ByVal ObjName,ByVal IndexNum,ByVal ObjClass,ByVal strProperty, ByVal intTimeOut)
	Dim objParent
	Dim objControl
	Dim strControl

	On Error Resume Next
	Err.Clear

	'Create the browser object
	If BrowserName <> "" Then
		Set objParent = funcCreatePageObj(BrowserName)
	End If

	If FornName <> ""  Then
		Set objParent = funcCreateFormObj(FormName, TabName)
	End If

	If strProperty <> "" Then
		strControl = "objParent." & ObjClass & "(" &"""" & strProperty & ":=" & ObjName & """" & ","  &"""index:=" & IndexNum &"""" & ")"
		Set objControl = eval(strControl)
	Else
		Set objControl = objParent
	End If

	If isNumeric(intTimeOut) Then
		intTimeOut = cInt(intTimeOut)
	ElseIf intTimeOut = "" Then
		intTimeOut = 5
	End If

	Select Case UCase(ObjClass)

		Case "WEBBUTTON"
				If objControl.Exist(intTimeOut) Then
					objControl.Click
				End If
		Case "ORACLEFORMWINDOW","ORACLEFLEXWINDOW"
				If objControl.Exist(intTimeOut) Then
					objControl.SetFocus
				End If
	
	End Select

	' Error Handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"VerifyObject And PerformAction", "Verify Object And PerformAction failed")
		On Error GoTo 0
	End If

	'Clean Up
	Set objControl = Nothing
	Set objParent = Nothing
                
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcAppendString(ByVal strPrefix, ByVal StepID)
'# Function is used to Append the string with random numers and seconds in XXXX format, Store this in dictionary
'#
'# Input Parameters: 
'#	strPrefix			: 	Prefix string to append
'# StepID				:		Step ID
'#
'# OutPut Parameters: None
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcAppendString(ByVal strPrefix, ByVal StepID)
	Dim MyValue

	MyValue =cStr(RandomNumber(1,99) & Second(Now))

	Do Until Len(MyValue) >3
		 MyValue = "0" & MyValue
	Loop

	MyValue = strPrefix & MyValue
	dicGlobalOutput.Add StepID, MyValue
End Function

'*******************************************************************************************************************************************************************************************
'# Function: funcClickOracleListOfValuesButton(ByVal FormName, ByVal ObjName, ByVal Valuetofind)
'# This function to click on Oracle List of values button
'# 
'# Parameters:
'# FormName:-Name of the Oracle List of values
'# ObjName:-Name of field button to click
'# Valuetofind :- Value to find in OracleListOfValues
'# OutPut Parameters: True/False
'#
'# Usage: ffuncClickOracleListOfValuesButton(FormName, ObjName, Valuetofind)
'*******************************************************************************************************************************************************************************************
Function funcClickOracleListOfValuesButton(ByVal FormName, ByVal ObjName, ByVal ValueToFind)
	Dim objOracleListOfValues

	On Error Resume Next
	Err.Clear

	' Set the Oracle List of Values
	Set objOracleListOfValues =OracleListOfValues("title:="&FormName)

	'Check for Oracle flex button and click on it if exists.
	If objOracleListOfValues.Exist(gLONGWAIT) Then

		If UCase(ObjName) = "CANCEL" Then
			objOracleListOfValues.Cancel
		ElseIf UCase(ObjName) = "FIND" Then
			objOracleListOfValues.Find ValueToFind
			objOracleListOfValues.Select ValueToFind
		End If
		funcClickOracleListOfValuesButton = True
	Else
		funcClickOracleListOfValuesButton = False		
	End If

	' Clean Up
	Set objOracleListOfValues = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:    funcAppendStringReverse(ByVal strActualText, ByVal StepID)
'# Function is used to Append the string in the format "Reverses%XXXXXXX%" and store in an dictionary.
'#
'# Input Parameters: 
'#	strActualText			: 	String to append
'# StepID					:		Step ID
'#
'# OutPut Parameters: None
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcAppendStringReverse(ByVal strActualText, ByVal StepID)
	Dim strText

	StrText = "Reverses%" & strActualText & "%"
	dicGlobalOutput.Add StepID, StrText

End Function

'*******************************************************************************************************************************************************************************************
'# Function:    funcVerifyRespNonExistence(ByVal strResponsibility)
'# Function is used to check the non existence of a responsibility.
'#
'# Input Parameters: 
'#	strResponsibility			: 	Responsibility name
'#
'# OutPut Parameters: None
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcVerifyRespNonExistence(ByVal strResponsibility)
	Dim objListName
	Dim strVal
	Dim arrListContent
	Dim bFound

	On Error Resume Next
	Err.Clear

	bFound = False
	' Create OracleListName object
	Set objListName = OracleListOfValues("title:=Responsibilities")

	If objListName.Exist(gMEDIUMWAIT) Then
		strVal = objListName.GetROProperty("list content")
		arrListContent=Split(strVal,";")
    	For intCounter = 0 To Ubound(arrListContent)-1
			If Strcomp (arrListContent(intCounter), strResponsibility) = 0 Then
					bFound = True
					Exit For
			End If
		Next
	End If

	If Not bFound Then
		Call gfReportExecutionStatus(micPass," Verify the non existence of Responsibility"," Responsibility " & strResponsibility & "not available in the list.")
	Else
		Call gfReportExecutionStatus(micFail," Verify the non existence of Responsibility"," Responsibility " & strResponsibility & " available in the list.")
	End If

	objListName.OracleButton("label:=Cancel").Click

	' Error handling.
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail, "Got Error from Verify the non existence of Responsibility", "Error : " & Err.Description)
	End If

    ' Clean Up
	Set objListName = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:    funcVerifyARTransactionBrowserExistence()
'# Function is used by iReceveiables, Login if login page exists and wait for transaction browser.
'#
'# Input Parameters:  None
'#
'# OutPut Parameters: None
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcVerifyARTransactionBrowserExistence()
	Dim objLoginPg
	Dim strUserName
	Dim strPassword
	Dim strBrowserText
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	strUserName = Environment("EBSARUserName")
	strPassword = Environment("EBSARPassword")
	bSuccess = False

	If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(gMEDIUMWAIT) Then
			Set objLoginPg = Browser("name:=MCD Login").Page("title:=MCD Login")
			objLoginPg.WebEdit("name:=.*Username.*").Set strUserName
			objLoginPg.WebEdit("name:=.*Password.*").Set strPassword
			objLoginPg.WebButton("name:=Login").Click
			Wait gSHORTWAIT
	
			If objLoginPg.Exist(1) Then
					strBrowserText = objLoginPg.Object.body.innerText
					If Instr(strBrowserText, "Invalid user name or password.") > 0 Then
						Call gfReportExecutionStatus(micFail,"Check for Login Screen","Login failed")
						bSuccess = False
						Exit Function	
					Else
						Call gfReportExecutionStatus(micDone,"Check for Login Screen","Login successful")
						bSuccess = True
					End If
			End If

	End If

	If Browser("name:=Transaction.*").Page("title:=Transaction.*").Exist(gLONGWAIT) Then
		Call gfReportExecutionStatus(micPass,"Check for Transaction Browser","Transaction Browser appeared")
		Browser("name:=Transaction.*").Close
		bSuccess = True
	Else
		Call gfReportExecutionStatus(micFail,"Check for Transaction Browser","Transaction Browser not appeared")
		bSuccess = False
	End If

	' Stop the testcase execution if transaction browser not appears
	If Not bSuccess Then
		Environment("StepFail") = True
		Environment("TCFail") = True
	End If

	' Clean Up
	Set objLoginPg = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:    funcFindRowInWebTable(ByRef objPage, ByRef  tblObject, ByVal ColumnNameToSearch, ByVal strText)()
'# Function is used  to find the table row with particular text by navigating to other pages.
'#
'# Input Parameters:  None
'#
'# OutPut Parameters: None
'#  
'# Usage: 
'*******************************************************************************************************************************************************************************************
Function funcFindRowInWebTable(ByRef objPage, ByRef  tblObject, ByVal ObjName, ByVal ColumnNameToSearch, ByVal strText)
	Dim oDesc
	Dim objChild
	Dim oLink
	Dim oNextLink
	Dim objParent
	Dim objWebTableParent
	Dim PrevTableCount
	Dim iCnt
	Dim intRowNo

	intRowNo = -1

	On Error Resume Next
	Err.Clear

	Set oDesc = Description.Create
	Set oLink = Description.Create

	Do Until intRowNo <>-1																	' Navigate to other pages in the same table.

		'To find the WebTable parent to get the navigation controls.
'		Set objParent = tblObject.Object.parentNode
		
		'
		'		While objParent.tagName <> "TABLE"
		'			Set objParent = objParent.parentNode
		'		Wend

'		intCnt = 0
'		Do While (objParent.tagName <> "TABLE")  
'			Set objParent = objParent.parentNode
'			intCnt = intCnt +1
'			If intCnt >= 1000 Then
'				Set objWebTableParent = objPage.WebTable("source_Index:=" & objParent.sourceIndex)
'				Exit Do
'			End If
'		Loop
'
'		'Get the web table parent
'		If  objParent Is Nothing Then
'			Set objParent = Nothing
''			Exit Do
'		Else
'			Set objWebTableParent = objPage.WebTable("source_Index:=" & objParent.sourceIndex)
'		End If
		
		oDesc("MicClass").Value = "WebTable"
		oDesc("column names").Value = ";;Previous.*"
		Set objChild = objPage.ChildObjects(oDesc)

		oLink("MicClass").Value = "Link"
		oLink("name").Value = "Next.*"
		Set oNextLink = objChild(0).ChildObjects(oLink)
'Set oNextLink = objWebTableParent.ChildObjects(oLink)

		If oNextLink.count >0 Then
			oNextLink(0).Click										' Click on Next link
			Wait gMEDIUMWAIT

			' find the row with text strText
			If InStr(ObjName,"#") >0 Then
				Set tblObject = objPage.WebTable("column names:="& Split(ObjName,"#")(0),"index:=" & Split(ObjName,"#")(1))
			Else
				Set tblObject = objPage.WebTable("column names:="&ObjName)
			End If

			For intCnt = 1 to tblObject.RowCount
				If InStr (Trim(tblObject.GetCellData(intCnt,ColumnNameToSearch)),Trim(strText)) > 0 Then
					intRowNo = intCnt
					Exit For
				End If
			Next
		Else
			Exit Do
		End If
	Loop

	'Return the row no
	If  intRowNo  <> -1 Then
		funcFindRowInWebTable = intRowNo
		Call gfReportExecutionStatus(micDone,"Find Table Row", "Found the table row " & intRowNo)
	Else
		funcFindRowInWebTable = intRowNo
		Call gfReportExecutionStatus(micFail,"Find Table Row", "Table row not found with text " & strText)
	End If

	'Clean Up
	Set oNextLink = Nothing
	Set oLink = Nothing
	Set objChild = Nothing
	Set oDesc = Nothing
	Set objWebTableParent = Nothing
	Set objParent = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:    funcLoginAndVerifyBrowserExistence(ByVal BrowserName, ByVal strUser)
'# Function is used to Login if login page exists and verify the browser
'#
'# Input Parameters:  
'# BrowserName	: Browser name
'# strUser	: User Type
'#
'# OutPut Parameters: boolean
'#  
'# Usage: 
'*******************************************************************************************************************************************************************************************
Function funcLoginAndVerifyBrowserExistence(ByVal BrowserName, ByVal strUser)
	Dim objLoginPg
	Dim strUserName
	Dim strPassword
	Dim strBrowserText
	Dim bSuccess

	On Error Resume Next
	Err.Clear

	'Get the UserName and Password
	Select Case UCase(strUser)
			Case "MCDEBSUSER"
					strUserName = Environment("EBSUserName")
					strPassword = Environment("EBSPassword")
			Case "MCDEBSAPUSER"
					strUserName = Environment("EBSAPUserName")
					strPassword = Environment("EBSAPPassword")
			Case "MCDEBSARUSER"
					strUserName = Environment("EBSARUserName")
					strPassword = Environment("EBSARPassword")
			Case "MCDEBSFAUSER"
					strUserName = Environment("EBSFAUserName")
					strPassword = Environment("EBSFAPassword")
			Case "MCDEBSGLUSER"
					strUserName = Environment("EBSGLUserName")
					strPassword = Environment("EBSGLPassword")
			Case "MCDEBSTCAUSER"
					strUserName = Environment("EBSTCAUserName")
					strPassword = Environment("EBSTCAPassword")
			Case "MCDEBSSPUSER"
					strUserName = Environment("EBSSPUserName")
					strPassword = Environment("EBSSPPassword")
			Case "MCDEBSPROJECTSUSER"
					strUserName = Environment("EBSPROJECTSUserName")
					strPassword = Environment("EBSPROJECTSPassword")
			Case "MCDEBSIPROCUSER"
					strUserName = Environment("EBSIprocUserName")
					strPassword = Environment("EBSIprocPassword")
			Case "MCDEBSIRECUSER"
					strUserName = Environment("EBSIrecUserName")
					strPassword = Environment("EBSIrecPassword")
			Case "MCDEBSIEXPENSEUSER"
					strUserName = Environment("EBSIExpenseUserName")
					strPassword = Environment("EBSIExpensePassword")
			Case "MCDEBSIEXPCCUSER"
					strUserName = Environment("EBSIExpCCUserName")
					strPassword = Environment("EBSIExpCCPassword")
			Case "MCDEBSAPPROVER1"
					strUserName = Environment("EBSApprover1")
					strPassword = Environment("EBSApproverPwd1")
			Case "MCDEBSAPPROVER2"
					strUserName = Environment("EBSApprover2")
					strPassword = Environment("EBSApproverPwd2")
			Case "MCDEBSUSERIE"
				      	strUserName = Environment("EBSIEUserName")
					strPassword = Environment("EBSIEPassword")
			Case "MCDEBSUSERNO"
					strUserName = Environment("EBSNOUserName")
					strPassword = Environment("EBSNOPassword")
			Case Else
					strUserName = Environment("EBSUserName")
					strPassword = Environment("EBSPassword")
		End Select

	bSuccess = False
	'Login to MCD page if login window exists
	If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(gMEDIUMWAIT) Then
			Set objLoginPg = Browser("name:=MCD Login").Page("title:=MCD Login")
			objLoginPg.WebEdit("name:=.*Username.*").Set strUserName
			objLoginPg.WebEdit("name:=.*Password.*").Set strPassword
			objLoginPg.WebButton("name:=Login").Click
			Wait gSHORTWAIT
	
			If objLoginPg.Exist(1) Then
					strBrowserText = objLoginPg.Object.body.innerText
					If Instr(strBrowserText, "Invalid user name or password.") > 0 Then
						Call gfReportExecutionStatus(micFail,"Check for Login Screen","Login failed")
						bSuccess = False
						Exit Function	
					Else
						Call gfReportExecutionStatus(micDone,"Check for Login Screen","Login successful")
						bSuccess = True
					End If
			End If

	End If

	If Browser("name:=" & BrowserName).Page("title:=" & BrowserName).Exist(gLONGWAIT) Then
		Call gfReportExecutionStatus(micPass,"Check for Browser "&BrowserName,"Browser " & BrowserName &" appeared")
		bSuccess = True
	Else
		Call gfReportExecutionStatus(micFail,"Check for Browser "& BrowserName,"Browser " & BrowserName &" not appeared")
		bSuccess = False
	End If

	' Stop the testcase execution if transaction browser not appears
	If Not bSuccess Then
		Environment("StepFail") = True
		Environment("TCFail") = True
	End If

	' Clean Up
	Set objLoginPg = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:    ffuncHandleCancelQuery()
'# Function is used  to handle the Cancel Query window 
'#
'# Input Parameters:  None
'#
'# OutPut Parameters: None
'#  
'# Usage: Call funcHandleCancelQuery()
'*******************************************************************************************************************************************************************************************
Function funcHandleCancelQuery()
	
	On Error Resume Next
	Err.Clear

	' Waiting as Cancel Query popup window is dispalying after 5 secs
	Wait gSHORTWAIT

	'Handle Cancel Query popup window
	'While JavaWindow("title:=Oracle Applications.*").JavaInternalFrame("title:=Cancel Query").Exist 
	While JavaWindow("title:=Oracle Applications.*").JavaInternalFrame("title:=Cancel Query").Exist(10) 
		Wait gSYNCWAIT
    Wend

	' Error Handling
	If Error.Number <> 0 Then
		On Error GoTo 0
	End If
	
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcClearNeedActions(ByVal strLink1, ByVal strLink2)
'# Function is used to clear the Need Actions to zero.
'#
'# Input Parameters: 
'# strLink1: 	Responsibility
'# strLink2: 	Option link
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcClearNeedActions(ByVal strLink1, ByVal strLink2)
	Dim objPage
	Dim objTable
	Dim objLink
	Dim objImg
	Dim iNeedAction
	Dim bSuccess
	
	On Error Resume Next
	Err.Clear
	
	bSuccess = False
	Set objPage = Browser("name:=Payments Dashboard").Page("title:=Payments Dashboard")
	Set objTable = objPage.WebTable("column names:=Need Action;Program Errors;Processing;User Terminated;Completed;Total")
	Set objLink = objTable.ChildItem(2,1,"Link",0)
	
	iNeedAction = Cint(objLink.GetROProperty("innerText"))
	If iNeedAction >0 Then
		objLink.Click
		
		'Set objPage = Browser("name:=Payment Process Requests").Page("title:=Payment Process Requests")
		Set objPage = Browser("name:=Payment Process Request.*").Page("title:=Payment Process Request.*")
		Set objTable = objPage.WebTable("column names:=Details;Payment Process Request;Created Date;Payment Date;Selected Scheduled Payments.*")
		
		Do Until objTable.RowCount <=2

			If objTable.Exist(gMEDIUMWAIT) And objTable.RowCount =3 Then
				If Trim(objTable.GetCellData(2,2))= "No results found." Then 
					bSuccess = True
					Exit Do
				End If
			End If
			
			If objTable.Exist(gMEDIUMWAIT) Then
				Set objImg = objTable.ChildItem(2,10,"Image","0")
				objImg.Click
			End If

			'====================================ravikanth 11-mar-2015
			If objPage.WebElement("innertext:=Payment Process Request cannot be terminated because one or more.*","index:=1").Exist(gMEDIUMWAIT) Then
				'bSuccess = False
				'Set objPage = Browser("name:=Payment Process Requests").Page("title:=Payment Process Requests")
				'Set objTable = objPage.WebTable("column names:=Details;Payment Process Request;Created Date;Payment Date;Selected Scheduled Payments.*")
				Dim intRowCnt
				intRowCnt = objTable.RowCount
				If objTable.Exist(gMEDIUMWAIT) Then

					For intRC=1 to intRowCnt
						Set objLink1 = objTable.ChildItem(2,2,"Link","0")
						objLink1.Click

						If objPage.WebTable("column names:=Source Product Reference;;.*").Exist(10) Then
							Set objTable1 = objPage.WebTable("column names:=Source Product Reference;;.*")
							Set objLink1 = objTable1.ChildItem(2, 1, "Link",0)
							objLink1.Click
							Set objPage = Browser("name:=Payment Instruction.*").Page("title:=Payment Instruction.*")

							If objPage.WebTable("column names:=Reference;Reference Assigned by Administrator;Reference Assigned by Payment System;.*").Exist(10) Then
								Set objTable1 = objPage.WebTable("column names:=Reference;Reference Assigned by Administrator;Reference Assigned by Payment System;.*")
								Set objImage = objTable1.ChildItem(2, 6, "Image",0)
								objImage.Click
								Wait(200)

								If objPage.Exist(gSHORTWAIT) Then
									objPage.WebButton("name:=Record Print Status","index:=0").Click
									Wait(10)
									Set objPage = Browser("name:=Record Print Status.*").Page("title:=Record Print Status.*")	

									If objPage.Exist(gSHORTWAIT) Then
										objPage.WebButton("name:=Continue","index:=0").Click
										Wait(10)
										Set objPage = Browser("name:=Review Record Print Status.*").Page("title:=Review Record Print Status.*")	

										If objPage.Exist(gSHORTWAIT) Then
											'strWarning = objPage.WebElement("innerhtml:=Are you sure you want to confirm.*,index:=0").GetROProperty("innertext")
											objPage.WebButton("name:=Apply","index:=0").Click
											Wait(10)
											Set objPage = Browser("name:=Funds Disbursement Process Home.*").Page("title:=Funds Disbursement Process Home.*")	

											If objPage.Exist(gSHORTWAIT) Then
												'strWarning = objPage.WebElement("innerhtml:=Are you sure you want to confirm.*,index:=0").GetROProperty("innertext")
												objPage.WebButton("name:=Refresh","index:=0").Click
												Wait(5)
												Set objTable1 = objPage.WebTable("column names:=Process Type;Creation Date;Status;Take Action;Terminate;Date Action Needed.*")
												'intImgCnt = objTable1.ChildItemCount(2,4,"Image")
												'For j=1 to intImgCnt
														Set objImage = objTable1.ChildItem(2, 4, "Image",0)
														objImage.Click
														Wait(5)
														objImage.Click
												'Next
											End If

										End If

									End If	

								End If								

							End If

						End If

					Next

				End If

'				If Browser("name:=Warning").Page("title:=Warning").WebElement("innertext:=Are you sure you want to terminate this payment process.*","index:=1").Exist(gMEDIUMWAIT) Then
'					Browser("name:=Warning").Page("title:=Warning").WebButton("name:=Yes").Click
'				End If
'				
'				If objPage.WebButton("name:=Refresh Status").Exist(gMEDIUMWAIT) Then
'					objPage.WebButton("name:=Refresh Status").Click
'					objTable.RefreshObject
'				End If

				'Exit Do
			ElseIf objPage.WebElement("innertext:=This payment process request includes documents or payments that belong to.*","index:=1").Exist(gMEDIUMWAIT) Then

				Exit Do
				bSuccess= True

			End If
			'====================================ravikanth 11-mar-2015
			
			If Browser("name:=Warning").Page("title:=Warning").WebElement("innertext:=Are you sure you want to terminate this payment process.*","index:=1").Exist(gMEDIUMWAIT) Then
				Browser("name:=Warning").Page("title:=Warning").WebButton("name:=Yes").Click
			End If
			
			If objPage.WebButton("name:=Refresh Status").Exist(gMEDIUMWAIT) Then
				objPage.WebButton("name:=Refresh Status").Click
				objTable.RefreshObject
			End If

		Loop
	Else
		bSuccess= True
	End If
	
	objPage.Link("innerText:=Home","index:=0").Click
	Wait gMEDIUMWAIT
	
	If bSuccess Then
		Call gfReportExecutionStatus(micDone,"Clear Need Actions", iNeedAction & " Need Actions Cleared.")
		funcClearNeedActions = True
	Else
		Call gfReportExecutionStatus(micFail,"Clear Need Actions", "Failed to clear the Need Actions" & iNeedAction)
		funcClearNeedActions = False
	End If
	
	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gMEDIUMWAIT) And strLink1 <>"" Then
		If InStr(strLink1,"#") >0 Then
			Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("innertext:=" & Split(strLink1,"#")(0),"index:="&Split(strLink1,"#")(1)).Click
		Else
			Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("innertext:=" & strLink1).Click
		End If
	End If
	
	Wait gMEDIUMWAIT
	Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").RefreshObject
	
	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gMEDIUMWAIT)  And  strLink2 <>"" Then
		If InStr(strLink2,"#") >0 Then
			Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("innertext:=" & Split(strLink2,"#")(0),"index:="&Split(strLink2,"#")(1)).Click
		Else
			Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("innertext:=" & strLink2).Click
		End If
	End If
	
	Wait gMEDIUMWAIT
	
	'Clean Up
	Set objImg = Nothing
	Set objLink = Nothing
	Set objTable = Nothing
	Set objPage = Nothing
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcVerifyChargeAccount(ByVal strNickName, ByVal intChargeAccount)
'# Function is used to clear the Need Actions to zero.
'#
'# Input Parameters: 
'# strNickName: 	
'# intChargeAccount: 	
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************

Function funcVerifyChargeAccount(ByVal strNickName, ByVal intChargeAccount)
	Dim objPage
	Dim objPref
	Dim strWebTblName
	Dim strCnfmnMsg
	Dim bSuccess
	
	On Error Resume Next
	Err.Clear

	bSuccess = funcFindTableRowAndClickObject
	Set objPage = Browser("name:=Oracle iProcurement: Shop").Page("title:=Oracle iProcurement: Shop")
	objPage.Link("name:=Preferences","index:=0").Click
	Wait(3)

	Set objPage = Browser("name:=General Preferences").Page("title:=General Preferences")
	objPage.Link("name:=iProcurement Preferences","index:=0").Click

	Wait(5)

	Set objPref= Browser("name:=Oracle iProcurement: Preferences").Page("title:=Oracle iProcurement: Preferences")
	If objPref.WebTable("column names:=Select;\*Nickname;AFF_US;Primary;Delete","index:=0").Exist(gShortWait) Then
		strWebTblName=objPref.WebTable("column names:=Select;\*Nickname;AFF_US;Primary;Delete","index:=0").GetROProperty("name")
		If strWebTblName="t" Then
				If objPref.WebButton("name:=Add Another Row","index:=1").Exist(gShortWait) Then
					objPref.WebButton("name:=Add Another Row","index:=1").Click
				End If
				Wait(3)

				objPref.WebEdit("name:=N4:Nickname:.*","index:=0").Set strNickName
				Wait(3)
	
				objPref.WebEdit("name:=N4:ChargeAccountFlex_COMBINATION:.*","index:=0").Set intChargeAccount
				Wait(3)
	
				objPref.WebRadioGroup("name:=N4:selected","index:=0").Select 0
				Wait(3)
	
				If objPref.WebButton("name:=Set as Primary","index:=1").Exist(gShortWait) Then
					objPref.WebButton("name:=Set as Primary","index:=1").Click
				End If
				Wait(2)
					
				If objPref.WebButton("name:=Apply","index:=1").Exist(gShortWait) Then
					objPref.WebButton("name:=Apply","index:=1").Click
				End If
				Wait(2)

				strCnfmnMsg=objPref.WebElement("html tag:=TD","innertext:=Confirmation.*","index:=0").GetROProperty("innertext")
				If Instr(strCnfmnMsg,"The selected preferences will be applied next time you login")>0 Then
					objPref.Link("name:=Logout","index:=0").Click
					Wait(3)
					Call gfReportExecutionStatus(micPass,"Charge Account preferences setup ","Charge Account preferences setup is saved")
					bSuccess = True
				Else
					Call gfReportExecutionStatus(micFail,"Charge Account preferences setup ","Charge Account preferences setup is NOT saved")
					bSuccess = False
				End If
		Else if strWebTblName="N4:selected" Then
				Call gfReportExecutionStatus(micPass,"Charge Account setup","Charge Account setup already present")
				bSuccess = True
			Else
				Call gfReportExecutionStatus(micFail,"Charge Account setup","Charge Account setup is not done")
				bSuccess = False
			End If
		End If
	End If

	' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"Setup Charge Account","Got the Error : " & Err.Description)
	End If

	' Clean Up
	Set objPref = Nothing
	Set objPage = Nothing

	funcVerifyChargeAccount=bSuccess
	
End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcFileUpload()
'# Function is used to upload the Text File which has details regarding Blanket Purchase Agreements.
'#
'# Input Parameters: 
'# None
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcFileUpload()

	Dim objWebFile
	Dim objPage
	Dim intCnt
	Dim objChildWebfile
	Dim objDialog
	Dim bSuccess

	On Error Resume Next
	Err.Clear
	bSuccess = False

	strPath = Environment.Value("TestDataPath")
	strPath = strPath & "\Line_Types.txt"

	' Creating the txt file	
	Set objFile = CreateObject("Scripting.FileSystemObject")
	Set aFile = objFile.CreateTextFile(strPath,True)
	aFile.WriteLine("Line Types")
	aFile.WriteBlankLines(1)
	aFile.WriteLine("Line Type	Value Basis	Purchase Basis	Description")
	aFile.WriteBlankLines(1)
	aFile.WriteLine("Fixed Price Services	FIXED PRICE	SERVICES	Fixed Price Services")
	aFile.WriteLine("Fixed Price Temp Labor	FIXED PRICE	TEMP LABOR	Fixed Price Temporary Labor")
	aFile.WriteLine("Goods	QUANTITY	GOODS	All Goods that are individually recorded and printed out (by item class, unit, and unit price)")
	aFile.WriteLine("Rate Based Temp Labor	RATE	TEMP LABOR	Rate Based Temporary Labor")
	aFile.WriteLine("Services	AMOUNT	SERVICES	All Services including GC")
	aFile.Close
	wait(5)
    
	Set objWebFile=Description.Create
	objWebFile("micclass").value="WebFile"

	Set objPage = Browser("name:=Internet Procurement Catalog Administration").Page("title:=Internet Procurement Catalog Administration")
	Set objChildWebfile=objPage.ChildObjects(objWebFile)

	For intCnt=0 to objChildWebfile.Count-1
		If objPage.WebFile(objWebFile).Exist(gSHORTWAIT) Then
			If objPage.WebFile(objWebFile).GetROProperty("html id")="FileName_oafileUpload" Then
				objChildWebfile(0).Click
			End If
		End If
	Next

	Set objDialog=Dialog("regexpwndtitle:=Choose File to Upload")
	If objDialog.WinEdit("regexpwndclass:=Edit").Exist(gSHORTWAIT) Then
		objDialog.WinEdit("regexpwndclass:=Edit").Set strPath
		objDialog.WinButton("regexpwndtitle:=&Open").Click
		bSuccess=True
	End If

	'Retrun value
	funcFileUpload = bSuccess

	If bSuccess Then
		Call gfReportExecutionStatus(micPass,"File Upload","File was uploaded successfully")
	Else
		Call gfReportExecutionStatus(micFail,"File Upload","File was NOT uploaded successfully")
	End If

		' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"File Upload","Got the Error : " & Err.Description)
		On Error Goto 0
	End If

	'objFile.DeleteFile(strPath)

	' Clean Up
	Set objWebFile = Nothing
	Set objPage = Nothing
	Set objDialog = Nothing
	Set objFile = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcVerifyEnableDisable(strObjectType,strObjectElmntID,strObjState)
'# Function is used to check whether the object class is Enabled or Disabled.
'#
'# Input Parameters: 
'# strObjectType : 
'# strObjectElmntID :
'#strObjState :
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************

'ElementById Names
'---------------------------------
'AddApproverRadio
'AddViewerRadio
'ChangeRadio
'DeleteRadio
'ResetRadio

Function funcVerifyEnableDisable(strObjectType,strObjectElmntID,strObjState)

	Dim objState
	Dim blnFlag

	On Error Resume Next
	Err.Clear
	
	Set objState= Browser("name:=Checkout: Manage Approvals").Page("title:=Checkout: Manage Approvals").Object.getElementById(strObjectElmntID)

	If strComp(Lcase(strObjState),"disabled") = 0 Then
		blnFlag = True
	Else
		blnFlag = False
	End If

'	blnValue=objState.disabled

	If (blnFlag = objState.disabled) Then
		Call gfReportExecutionStatus(micPass,"Verification of " & strObjectType & " state", strObjectType & " " & strObjectElmntID & " is " & strObjState )
	Else
		Call gfReportExecutionStatus(micFail,"Verification of  " & strObjectType & " state",strObjectType & " " & strObjectElmntID & " is NOT " & strObjState)
	End If

	' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"Error Description","Got the Error : " & Err.Description)
	End If

	' Clean Up
	Set objState = Nothing 

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   verifyTableCellValue(ByVal strText,ByVal blnExist)
'# Function is used to verify the Table cell value.
'#
'# Input Parameters: 
'# strText : 
'#blnExist : 
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function verifyTableCellValue(ByVal strText,ByVal blnExist)

	Dim objPage
	Dim intRowCnt
	Dim intRowNo, intCnt
	Dim strReportText
	Dim bSucess, blnMatch

	bSucess=False

	On Error Resume Next
	Err.Clear

	Set Objpage =  Browser("name:=Oracle iProcurement: Shop").page("title:=Oracle iProcurement: Shop")
	intRowCnt=Objpage.webtable("innertext:=Requisition.*").RowCount


		If Objpage.webtable("innertext:=Requisition.*").Exist(gShortWait) Then
			For intCnt= 2 to intRowCnt
				If Instr(Objpage.webtable("innertext:=Requisition.*").GetCellData(intCnt,1),strText) > 0 Then
					blnMatch = Objpage.webtable("innertext:=Requisition.*").ChildItemCount(intCnt,7,"Image")

					If blnMatch = 0  Then
						blnMatch = False
					Else
						blnMatch = True
					End If

					If strcomp(cStr(blnMatch),blnExist,1) = 0 Then
						bSucess = True
						Exit For
					End If
				End If
			Next
		End If

		If bSucess Then
			If blnExist Then
				Call gfReportExecutionStatus(micPass,"Verifying Existence of Receipt icon ","Receipt icon is displayed")
			Else
				Call gfReportExecutionStatus(micPass,"Verifying Existence of Receipt icon ","Receipt icon is not displayed")
			End If
		Else
			If blnExist =false Then
				Call gfReportExecutionStatus(micFail,"Verifying Existence of Receipt icon ","Receipt icon is  displayed")
			Else
				Call gfReportExecutionStatus(micFail,"Verifying Existence of Receipt icon ","Receipt icon is not displayed")
			End If
		End If


	Set Objpage = Nothing

End Function


''*******************************************************************************************************************************************************************************************
''# Function:   Generate5DigitRandomNo()
''# Function is used to generate 5-digit Random No.
''#
''# Input Parameters:  None
''#
''# OutPut Parameters: Number
''#  
''# Usage: Function needs to be executed from BusinessFunction keyword.
''*******************************************************************************************************************************************************************************************
'Function funcGenerate5DigitRandomNo()
'
'	If UCase(bUniqueValues) = "TRUE" Then
'		RandNo = Hour(Now)& Minute(Now) & Second(Now)
'
'		'	Store the value in Global dict
'		dicGlobalOutput.Add strTestStepID, RandNo
'	End If
'
'
'End Function

'*******************************************************************************************************************************************************************************************
'########################################################################################################################
'
'           PROGRAM NAME        	=         VERIFY RESPONSIBILITY
'
'########################################################################################################################
'
'           PURPOSE:
'                                   To Switch the Responsibility  based on the Specified  parameter. 
'                                 
'
'           Initial State           = OracleNavigator
'           Final State             = OracleNavigator
'           
'           INPUT PARAMETERS        = strResponsibility
'           OUTPUT PARAMETERS       = 
'            MODULES CALLED         = Scenario.lib, generic.lib
'           
'            OWNER                  = Mc Donald's
'
'			Resource					 Date					Remarks
'          	  SR                       02/05/2012             Initial Version     
'
'########################################################################################################################

Function funcVerifyResponsibility(ByVal strResponsibility)
	Dim pstrStatus, pstrStatusMsg
    
    On Error Resume Next
	pstrStatus = "FAILED"
	
    'Select Switch Responsibility
	OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
	If Err.Number<>0 Then
        Call gfReportExecutionStatus(micFail,"Select Menu ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
        Exit Function
	End If

	If OracleListOfValues("title:=Responsibilities").Exist(5) Then
		'Select the specified Responsibility
		OracleListOfValues("title:=Responsibilities").Select strResponsibility
		If Err.Number<>0 Then
			Call gfReportExecutionStatus(micPass,"Verify Responsibility ", "Responsibility : "& strResponsibility& " is not available")
			OracleListOfValues("title:=Responsibilities").Cancel
			Err.Clear
		Else
			Call gfReportExecutionStatus(micFail,"Verify Responsibility ", "Responsibility : "& strResponsibility& " is available")
			Exit Function
		End If
	End If
    pstrStatus="PASSED"

End Function  'funcVerifyResponsibility

'*******************************************************************************************************************************************************************************************
'# Function:    SaveViewOutputFile(intRequestNo, strViewOutput_ViewLog)
'# Function is used  to Save the View output file
'#
'# Input Parameters:  None
'#
'# OutPut Parameters: None
'#  
'# Usage: SaveViewOutputFile(intRequestNo)
'*******************************************************************************************************************************************************************************************
Function SaveViewOutputFile(ByVal intRequestNo, ByVal strViewOutput_ViewLog)

	On Error Resume Next

	Dim inthnwd, wshell, hwndBrw, hwndWindow
	Dim objFSOFile, strOutputTextFile
	Dim strBodyText, strOutputLoc, strFormatType
	Dim objBrowser, hWnd					'----------------------------------------------------------------------ravikanth 08-Jul-2015

	Const GA_ROOT = 2

	Call lpCreateFolderStructure(Environment("executionReportPath")& "\ViewOutput")

	'Sync
	Browser("title:=.*temp_id.*").Sync

	Set objBrowser = Browser("title:=.*temp_id.*")				'----------------------------------------------------------------------ravikanth 08-Jul-2015			objBrowser
	
	If IsNull(objBrowser.Object.HWND) Then
''		'hWnd = Browser("hwnd:=" & objBrowser.GetROProperty("hwnd")).Object.hWnd
		hWnd = objBrowser.GetROProperty("hwnd")
		Window("hwnd:=" & hWnd).Activate()
		Window("hwnd:=" & hWnd).Maximize()
		objBrowser.WinMenu("Class:=WinMenu","menuobjtype:=4").Select "Maximize"
		'Browser("Browser").WinMenu("SystemMenu").Select "Maximize"
	Else
		hWnd = objBrowser.Object.HWND
		'Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Activate
		Window("hwnd:=" & hWnd).Activate()
		Window("hwnd:=" & hWnd).Maximize()
	End If
	Wait(gSYNCWAIT)

	If objBrowser.Page("name:=.*").Exist(gSHORTWAIT) Then			'----------------------------------------------------------------------ravikanth 08-Jul-2015			objBrowser
		'Body Text
		strBodyText = objBrowser.Page("name:=.*").Object.body.innerText
		If strBodyText<> Empty Then

			intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog &".txt"
			Wait(1)
			 'Output path
			 strOutputLoc = Environment("executionReportPath") & "\ViewOutput" & Chr(92) & intRequestNo
			'''strOutputLoc = Environment("executionReportPath") & "\ViewOutput" & Chr(92) & intRequestNo & "_" & strViewOutput_ViewLog &".txt"
	
			'Create File System Object
			Set objFSOFile = CreateObject("Scripting.FileSystemObject")
			
			'Create Text File
			Set strOutputTextFile = objFSOFile.CreateTextFile (strOutputLoc,True)
			'Write the text
			strOutputTextFile.Write(strBodyText)
			strOutputTextFile.Close
			
			Set strOutputTextFile = Nothing
			Set objFSOFile = Nothing
			Call gfReportExecutionStatus(micPass,"Save Output or Log file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
	
		ElseIf objBrowser.Dialog("text:=File Download").Exist(5) Then
	
			'Activate the 'File Download' dialog
			objBrowser.Dialog("text:=File Download").Activate
	
			'Click Save button on 'File Download' dialog window
			objBrowser.Dialog("text:=File Download").WinButton("text:=&Save").Click
			If objBrowser.Dialog("text:=File Download").WinButton("text:=&Save").Exist(2) Then
				objBrowser.Dialog("text:=File Download").WinButton("text:=&Save").Click
			End If
	
			Wait 5
	
			'Save As
			If Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").Exist(5) Then
	
				'Activate 'Save As' diablog
				Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").Activate
	
				'Check Format Type
				strFormatType = Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").WinComboBox("Class Name:=WinComboBox","nativeclass:=ComboBox","index:=1").GetROProperty("text")
	
				If Instr(strFormatType,"Excel")<>0 Then
					intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog &".xls"
					Wait(1)
					strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo
					Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
				ElseIf Instr(strFormatType,"Rich")<>0 Then
					intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog &".rtf"
					Wait(1)
					strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo
					Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
				Else
					intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog
					Wait(1)
					strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo
					Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
				End If
	
				Set wshell=CreateObject("Wscript.Shell")
				wshell.SendKeys "a"
	
				'Enter Path
				Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").WinEdit("nativeclass:=Edit","index:=0").Set strOutputLoc
				Wait 1
				'Click on Save button
				Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").WinButton("text:=&Save").Click
	
				Set wshell = Nothing
			End If 
	
		Else
			'Getting Handle
			hwndBrw = objBrowser.GetROProperty("hwnd")
	 
			'Declare Function GetAncestor Lib "user32.dll" (ByVal hwnd As Long, ByVal gaFlags As Long) As Long
			Extern.Declare micLong, "GetMainWindow", "user32" ,"GetAncestor",micLong, micLong
	 
			'Get the main IE window handle
			hwndWindow = Extern.GetMainWindow(hwndBrw, GA_ROOT)
			Window("hwnd:=" & hwndWindow).Maximize
	
			Set wshell=CreateObject("Wscript.Shell")
			wshell.SendKeys "%{F}+a"
			Wait 1
			wshell.SendKeys "a"
			Wait 2
			If objBrowser.Dialog("text:=Save a Copy...").Exist(10) Then
				intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog
				 'Output path
				strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo
				objBrowser.Dialog("text:=Save a Copy...").WinEdit("nativeclass:=Edit","attached text:=File &name:","index:=0").Set strOutputLoc
				'objBrowser.Dialog("text:=Save a Copy...").WinComboBox("ComboBox").Select "Webpage, HTML only (*.htm;*.html)"
				objBrowser.Dialog("text:=Save a Copy...").WinButton("text:=Save").Click
				Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
			End If
			
			Set wshell = Nothing
		End If 
'----------------------------------------------------------------------ravikanth 08-Jul-2015
	ElseIf objBrowser.WinObject("regexpwndtitle:=AVPageView","windowstyle:=1442840576").Exist(gSHORTWAIT) Then

			intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog &".pdf"
			Wait(1)
			 'Output path
			 strOutputLoc = Environment("executionReportPath") & "\ViewOutput" & Chr(92) & intRequestNo

			Set wshell=CreateObject("Wscript.Shell")
			wshell.SendKeys "^{END}"
			Wait(gSYNCWAIT)

            objBrowser.WinToolbar("regexpwndclass:=ToolbarWindow32","windowstyle:=1442895949").Press "&File"
			objBrowser.WinMenu("Class:=WinMenu","menuobjtype:=3").Select "Save As..."
			objBrowser.Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinEdit("regexpwndclass:=Edit").Set strOutputLoc
			objBrowser.Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinButton("regexpwndtitle:=&Save").Click

'			Browser("brOutputBrowser").WinToolbar("wtbToolbarWindow32").Press "&File"
'			Browser("brOutputBrowser").WinMenu("wmContextMenu").Select "Save As..."
'			Browser("brOutputBrowser").Dialog("dlgSaveAs").WinEdit("Edit").Set strOutputLoc
'			Browser("brOutputBrowser").Dialog("dlgSaveAs").WinButton("Save").Click

			Wait(gSYNCWAIT)

			Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
			Set wshell = Nothing

			'If the Addin "ActiveX' is selected, then this code will be useful for PDF type file saving
	ElseIf objBrowser.ActiveX("acx_name:=.*Adobe PDF.*").Exist(gSHORTWAIT) Then


			intRequestNo = intRequestNo & "_" & strViewOutput_ViewLog &".pdf"
			Wait(1)
			strOutputLoc = Environment("executionReportPath") & "\ViewOutput" & Chr(92) & intRequestNo

			objBrowser.Object.makeObjVisible

			Set wshell=CreateObject("Wscript.Shell")
			wshell.SendKeys "^{END}"
			Wait(gSYNCWAIT)

            objBrowser.WinToolbar("regexpwndclass:=ToolbarWindow32","windowstyle:=1442895949").Press "&File"
			objBrowser.WinMenu("Class:=WinMenu","menuobjtype:=3").Select "Save As..."
			objBrowser.Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinEdit("regexpwndclass:=Edit").Set strOutputLoc
			objBrowser.Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinButton("regexpwndtitle:=&Save").Click

			Wait(gSYNCWAIT)

			Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
			Set wshell = Nothing

	End If

	Set objBrowser = Nothing
'----------------------------------------------------------------------ravikanth 08-Jul-2015
	If Err.Number <>0 Then
		On Error Goto 0
	End If

End Function

'''''''''''''''Function SaveViewOutputFile(ByVal intRequestNo)
'''''''''''''''
'''''''''''''''	On Error Resume Next
'''''''''''''''
'''''''''''''''	Dim inthnwd, wshell, hwndBrw, hwndWindow
'''''''''''''''	Dim objFSOFile, strOutputTextFile
'''''''''''''''	Dim strBodyText, strOutputLoc , strFormatType
'''''''''''''''
'''''''''''''''	Const GA_ROOT = 2
'''''''''''''''
'''''''''''''''	'Sync
'''''''''''''''	Browser("title:=.*temp_id.*").Sync
'''''''''''''''	'Body Text
'''''''''''''''	strBodyText = Browser("title:=.*temp_id.*").Page("name:=.*").Object.body.innerText
'''''''''''''''
'''''''''''''''     If strBodyText<> Empty Then
'''''''''''''''
'''''''''''''''		 'Output path
'''''''''''''''		 strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo&".txt"
'''''''''''''''
'''''''''''''''		'Create File System Object
'''''''''''''''		Set objFSOFile = CreateObject("Scripting.FileSystemObject")
'''''''''''''''		
'''''''''''''''		'Create Text File
'''''''''''''''		Set strOutputTextFile = objFSOFile.CreateTextFile (strOutputLoc,True)
'''''''''''''''		'Write the text
'''''''''''''''		strOutputTextFile.Write(strBodyText)
'''''''''''''''		strOutputTextFile.Close
'''''''''''''''		
'''''''''''''''		Set strOutputTextFile = Nothing
'''''''''''''''		Set objFSOFile = Nothing
'''''''''''''''		Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&".txt' has been saved to OutPut folder.")
'''''''''''''''
'''''''''''''''	ElseIf Browser("title:=.*temp_id.*").Dialog("text:=File Download").Exist(5) Then
'''''''''''''''
'''''''''''''''		'Activate the 'File Download' dialog
'''''''''''''''		Browser("title:=.*temp_id.*").Dialog("text:=File Download").Activate
'''''''''''''''
'''''''''''''''		'Click Save button on 'File Download' dialog window
'''''''''''''''		Browser("title:=.*temp_id.*").Dialog("text:=File Download").WinButton("text:=&Save").Click
'''''''''''''''		If Browser("title:=.*temp_id.*").Dialog("text:=File Download").WinButton("text:=&Save").Exist(2) Then
'''''''''''''''			Browser("title:=.*temp_id.*").Dialog("text:=File Download").WinButton("text:=&Save").Click
'''''''''''''''		End If
'''''''''''''''
'''''''''''''''        Wait 5
'''''''''''''''
'''''''''''''''		'Save As
'''''''''''''''		If Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").Exist(5) Then
'''''''''''''''
'''''''''''''''			'Activate 'Save As' diablog
'''''''''''''''			Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").Activate
'''''''''''''''
'''''''''''''''			'Check Format Type
'''''''''''''''			strFormatType = Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").WinComboBox("Class Name:=WinComboBox","nativeclass:=ComboBox","index:=1").GetROProperty("text")
'''''''''''''''
'''''''''''''''			If Instr(strFormatType,"Excel")<>0 Then
'''''''''''''''				strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo&".xls"
'''''''''''''''				Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&".xls' has been saved to OutPut folder.")
'''''''''''''''			ElseIf Instr(strFormatType,"Rich")<>0 Then
'''''''''''''''				strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo&".rtf"
'''''''''''''''				Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&".rtf' has been saved to OutPut folder.")
'''''''''''''''			Else
'''''''''''''''				strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo
'''''''''''''''				Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&"' has been saved to OutPut folder.")
'''''''''''''''			End If
'''''''''''''''
'''''''''''''''			Set wshell=CreateObject("Wscript.Shell")
'''''''''''''''            wshell.SendKeys "a"
'''''''''''''''
'''''''''''''''			'Enter Path
'''''''''''''''			Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").WinEdit("nativeclass:=Edit","index:=0").Set strOutputLoc
'''''''''''''''            Wait 1
'''''''''''''''			'Click on Save button
'''''''''''''''			Dialog("text:=0% of FNDWRR.*").Dialog("text:=Save As").WinButton("text:=&Save").Click
'''''''''''''''
'''''''''''''''			Set wshell = Nothing
'''''''''''''''		End If 
'''''''''''''''
'''''''''''''''	Else
'''''''''''''''        'Getting Handle
'''''''''''''''		hwndBrw = Browser("title:=.*temp_id.*").GetROProperty("hwnd")
''''''''''''''' 
'''''''''''''''		'Declare Function GetAncestor Lib "user32.dll" (ByVal hwnd As Long, ByVal gaFlags As Long) As Long
'''''''''''''''		Extern.Declare micLong, "GetMainWindow", "user32" ,"GetAncestor",micLong, micLong
''''''''''''''' 
'''''''''''''''		'Get the main IE window handle
'''''''''''''''		hwndWindow = Extern.GetMainWindow(hwndBrw, GA_ROOT)
'''''''''''''''		Window("hwnd:=" & hwndWindow).Maximize
'''''''''''''''
'''''''''''''''		Set wshell=CreateObject("Wscript.Shell")
'''''''''''''''		wshell.SendKeys "%{F}+a"
'''''''''''''''		Wait 1
'''''''''''''''        wshell.SendKeys "a"
'''''''''''''''		Wait 2
'''''''''''''''		If Browser("title:=.*temp_id.*").Dialog("text:=Save a Copy...").Exist(10) Then
'''''''''''''''			 'Output path
'''''''''''''''			strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo
'''''''''''''''			Browser("title:=.*temp_id.*").Dialog("text:=Save a Copy...").WinEdit("nativeclass:=Edit","attached text:=File &name:","index:=0").Set strOutputLoc
'''''''''''''''			'Browser("title:=.*temp_id.*").Dialog("text:=Save a Copy...").WinComboBox("ComboBox").Select "Webpage, HTML only (*.htm;*.html)"
'''''''''''''''			Browser("title:=.*temp_id.*").Dialog("text:=Save a Copy...").WinButton("text:=Save").Click
'''''''''''''''			Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&".pdf' has been saved to OutPut folder.")
'''''''''''''''		End If
'''''''''''''''		
'''''''''''''''		Set wshell = Nothing
'''''''''''''''	End If 
'''''''''''''''
'''''''''''''''	If Err.Number <>0 Then
'''''''''''''''		On Error Goto 0
'''''''''''''''	End If
'''''''''''''''
'''''''''''''''End Function

''*******************************************************************************************************************************************************************************************
''# Function:    SaveViewOutputFile(intRequestNo)
''# Function is used  to Save the View output file
''#
''# Input Parameters:  None
''#
''# OutPut Parameters: None
''#  
''# Usage: SaveViewOutputFile(intRequestNo)
''*******************************************************************************************************************************************************************************************
'Function SaveViewOutputFile(ByVal intRequestNo)
'
'	On Error Resume Next
'
'	Dim inthnwd
'	Dim objFSOFile, strOutputTextFile
'	Dim strBodyText, strOutputLoc
'
'	'Sync
'	Browser("title:=.*temp_id.*").Sync
'	'Body Text
'	strBodyText = Browser("title:=.*temp_id.*").Page("name:=.*").Object.body.innerText
'
'	'Output path
'	strOutputLoc = Environment("executionReportPath")&"\ViewOutput"& Chr(92) &intRequestNo&".txt"
'
'	If strBodyText<> Empty Then
'
'		'Create File System Object
'		Set objFSOFile = CreateObject("Scripting.FileSystemObject")
'		
'		'Create Text File
'		Set strOutputTextFile = objFSOFile.CreateTextFile (strOutputLoc,True)
'		'Write the text
'		strOutputTextFile.Write(strBodyText)
'		strOutputTextFile.Close
'		
'		Set strOutputTextFile = Nothing
'		Set objFSOFile = Nothing
'		Call gfReportExecutionStatus(micPass,"Save Output file","File : '"&intRequestNo&".txt' has been saved to OutPut folder.")
'	Else
'		'Call gfReportExecutionStatus(micFail,"Save Output file","File : '"&intRequestNo&".txt' has not been saved.")
'	End If 
'
'	If Err.Number <>0 Then
'		On Error Goto 0
'	End If
'
'End Function

'*******************************************************************************************************************************************************************************************
'# Function:    OpenAndSaveTestDataFiles(strWorkBookName , strSheetName)
'# Function is used  to handle the Cancel Query window 
'#
'# Input Parameters:  None
'#
'# OutPut Parameters: None
'#  
'# Usage: OpenAndSaveTestDataFiles(strWorkBookName , strSheetName)
'*******************************************************************************************************************************************************************************************

Function OpenAndSaveTestDataFiles(ByVal strWorkBookName, ByVal strSheetName)
	Dim objExcel
	Dim objWorkSheet
	Dim objWorkbook
	Dim strTestDataFile

	On Error Resume Next
	Err.Clear

	'Create Excel object
	Set objExcel = CreateObject("Excel.Application")
	objExcel.Visible = False
	objExcel.DisplayAlerts = False
	strTestDataFile = Environment("TestDataPath") & "\" & strWorkBookName

	' Open the TestData file and WorkSheet
	Set objWorkbook = objExcel.Workbooks.Open(strTestDataFile)
	Set objWorkSheet = objExcel.Worksheets.Item(strSheetName)

	'Save the TestData file and quit excel
	objWorkbook.Save
	objWorkbook.Close
	objExcel.Quit
	If Err.Number <> 0 Then
		On Error Goto 0
	End If

	Set objWorkSheet = Nothing
	Set objWorkbook = Nothing
	Set objExcel = Nothing
End Function
'
''*******************************************************************************************************************************************************************************************

''New functions - 31-MAR-2016
'
'*******************************************************************************************************************************************************************************************
'# Function: funcGetInfoWindowMessage(ByVal TestStepID, ByVal ButtonName)
'# Function is used to capture the message from pop window and integer value from popup message and close the window
'#
'# Parameters:
'# strDialogTitle :- Message window title value
'# ButtonName :- Button name to click
'#
'# Usage: > 
'*******************************************************************************************************************************************************************************************
Function funcHandleBrowserDialogWindow(ByVal strDialogTitle, ByVal ButtonName)
	
	On Error Resume Next
	Err.Clear
	
	bSuccess = False
	
	If Dialog("nativeclass:=#32770", "regexpwndtitle:="&strDialogTitle).Exist(gSHORTWAIT) Then
		Dialog("nativeclass:=#32770", "regexpwndtitle:="&strDialogTitle).WinButton("Class Name:=WinButton", "text:="&ButtonName).Highlight
		Dialog("nativeclass:=#32770", "regexpwndtitle:="&strDialogTitle).WinButton("Class Name:=WinButton", "text:="&ButtonName).Click
		Call gfReportExecutionStatus(micPass, "Click button on dialog window", "Clicked " & ButtonName & " in the Dialog window")
		Wait gSYNCWAIT
		bSuccess = True
	End If

	' Return
	funcHandleBrowserDialogWindow = bSuccess

End Function

'3May2016

'*******************************************************************************************************************************************************************************************
'# Function:   funcFileUpload()
'# Function is used to upload attachment File
'#
'# Input Parameters: 
'# None
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcFileUpload(ByVal BrowserName, ByVal strFileName)

	Dim objWebFile
	Dim objPage
	Dim aFile
	Dim objDialog
	Dim bSuccess

	On Error Resume Next
	Err.Clear
	bSuccess = False

	
	strFileDown=QCGetResource("MCD-1.39MB.JPG",Environment.Value("TestDataPath"))
	strFileDown=QCGetResource("MCD-3.02MB.jpg",Environment.Value("TestDataPath"))
	
	strPath = Environment.Value("TestDataPath") & "\" & strFileName
	
	Wait(10)

	Set objDialog=Dialog("regexpwndtitle:=Choose File to Upload")
	If objDialog.WinEdit("regexpwndclass:=Edit").Exist(gSHORTWAIT) Then
		objDialog.WinEdit("regexpwndclass:=Edit").Set strPath
		objDialog.WinButton("regexpwndtitle:=&Open").Click
		bSuccess=True
	End If

	'Retrun value
	funcFileUpload = bSuccess

	If bSuccess Then
		Call gfReportExecutionStatus(micPass,"File Upload","File was uploaded successfully")
	Else
		Call gfReportExecutionStatus(micFail,"File Upload","File was NOT uploaded successfully")
	End If

		' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"File Upload","Got the Error : " & Err.Description)
		On Error Goto 0
	End If

	' Clean Up
	Set objWebFile = Nothing
	Set objPage = Nothing
	Set objDialog = Nothing
	Set objFile = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcDownloadPDFCoStar()
'# Function is used to upload attachment File
'#
'# Input Parameters: 
'# None
'#
'# OutPut Parameters: boolean
'#  
'# Usage: Function needs to be executed from BusinessFunction keyword.
'*******************************************************************************************************************************************************************************************
Function funcDownloadPDFCoStar(ByVal BrowserName, ByVal TestStepID, ByVal AbstractType)

	Dim objBrowser
	Dim objSubBrowser
	Dim objPage
	Dim bSuccess
	Dim strFileName
	Dim strOutFile
	Dim oshell

	On Error Resume Next
	Err.Clear
	bSuccess = False

	
	'We are going to click on actions and then download the file in pdf

	'Output file location folder creation
	Call lpCreateFolderStructure(Environment("executionReportPath")& "\PDFSaveOutput")
	'First click on 'Actions' button
	Set objPage = funcCreatePageObj(BrowserName)

	If (objPage.WebButton("html id:=btnAction","name:=Actions >","index:=0").Exist(2)) Then
		objPage.WebButton("html id:=btnAction","name:=Actions >","index:=0").Click
		bSuccess = True
	Else
		bSuccess = False
	End If
	
	'Now click on 'Print to PDF' or 'Run Report' link/button
	If (AbstractType <> "Lease") Then
		If (objPage.WebButton("html tag:=BUTTON","name:=Run Report","index:=0").Exist(2)) Then
			objPage.WebButton("html tag:=BUTTON","name:=Run Report","index:=0").Click
			bSuccess = True
		Else
			bSuccess = False
		End If
	Else
		If (objPage.WebButton("html tag:=BUTTON","name:=Print to PDF","index:=0").Exist(2)) Then
			objPage.WebButton("html tag:=BUTTON","name:=Print to PDF","index:=0").Click
			bSuccess = True
		Else
			bSuccess = False
		End If
	End If
	
	
	'Now verify for existence of browser/pop-up window for download exists
	Set objBrowser = Browser("micclass:=Browser","name:="&BrowserName)
	If (objBrowser.Exist(1)) Then
		Wait(30)
		Set oshell = CreateObject("Wscript.Shell")
		
		'Now check if we are downloading Lease type or other type
		If (AbstractType <> "Lease") Then
			Set objSubBrowser = Browser("micclass:=Browser","title:=https://mcdonalds\.costarremanager\.com.*PDF","index:=0")
			If (objSubBrowser.WinObject("regexpwndclass:=AVL_AVView","regexpwndtitle:=AVPageView").Exist(2)) Then
				oshell.SendKeys "+^s"
			Else
				bSuccess = False
			End If
		Else
			oshell.SendKeys "%N"
			oshell.SendKeys "{TAB}"
			oshell.SendKeys "{DOWN}"
			oshell.SendKeys "a"
		End If
		
		Wait(2)
		If (Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").Exist(2)) Then
			strFileName = Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinEdit("regexpwndclass:=Edit").GetROProperty("text")
			strOutFile = Environment("executionReportPath") & "\PDFSaveOutput" & Chr(92) & strFileName &".pdf"
			Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinEdit("regexpwndclass:=Edit").Set strOutFile
			Wait(1)
			Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinButton("regexpwndtitle:=&Save").Click
			Wait(2)
			If (Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").Exist(2)) Then
				bSuccess = False
			Else
				If (objSubBrowser.WinObject("regexpwndclass:=AVL_AVView","regexpwndtitle:=AVPageView").Exist(2)) Then
					objSubBrowser.Close
					Wait(1)
				End If
				bSuccess = True
				Call gfReportExecutionStatus(micPass,"Download PDF file status","Downloaded PDF file: "&strFileName& " successfully")
				dicGlobalOutput.add TestStepID, strFileName
			End If			
		Else
			bSuccess = False
		End If
	Else
		bSuccess = False					
	End If
	
	'Retrun value
	funcDownloadPDFCoStar = bSuccess

	' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"Download PDF","Got the Error : " & Err.Description)
		On Error Goto 0
	End If

	' Clean Up
	Set oshell = Nothing
	Set objSubBrowser = Nothing
	Set objBrowser = Nothing
	Set objPage = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcUploadPDFCoStar(ByVal BrowserName, ByVal strFileName)
'# Function is used to upload attachment File
'#
'# Input Parameters: 
'# None
'#
'# OutPut Parameters: boolean
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************
Function funcUploadPDFCoStar(ByVal BrowserName, ByVal strFileName)

	Dim objBrowser
	Dim objPage
	Dim bSuccess
	Dim strPath
	Dim oshell

	On Error Resume Next
	Err.Clear
	bSuccess = False

	
	'We are going to click on Select file and then upload the file in pdf

	'First click on 'Select File' button
	Set objPage = funcCreatePageObj(BrowserName)

	If (objPage.WebButton("name:=Select File","index:=0").Exist(2)) Then
		objPage.WebButton("name:=Select File","index:=0").Click
		bSuccess = True
	Else
		bSuccess = False
	End If
	
	'Now verify for existence of browser/pop-up window for download exists
	Set objBrowser = Browser("micclass:=Browser","name:="&BrowserName)
	If (objBrowser.Exist(1)) Then
		Wait(3)
		If (Dialog("regexpwndtitle:=Choose File to Upload","nativeclass:=#32770").Exist(2)) Then
			strPath = Environment("executionReportPath") & "\PDFSaveOutput" & Chr(92) & strFileName &".pdf"
			Dialog("regexpwndtitle:=Choose File to Upload","nativeclass:=#32770").WinEdit("regexpwndclass:=Edit").Set strPath
			Dialog("regexpwndtitle:=Choose File to Upload","nativeclass:=#32770").WinButton("regexpwndtitle:=&Open").Click
			Wait(2)
			If (Dialog("regexpwndtitle:=Choose File to Upload","nativeclass:=#32770").Exist(2)) Then
				bSuccess = False
			Else
				'Now click on 'Upload' and verify success message
				If (objPage.WebButton("name:=Upload","index:=0").Exist(2)) Then
					objPage.WebButton("name:=Upload","index:=0").Click
					Wait(5)
					If (funcVerifyExistence(BrowserName,"","","WEBELEMENT","File .*pdf.* was added succesfully.*","0","","","")) Then
						bSuccess = True
						Call gfReportExecutionStatus(micPass,"Upload PDF file status","Uploaded PDF file: "&strFileName& " successfully")
					Else
						bSuccess = False
					End If
				Else
					bSuccess = False
				End If
			End If			
		Else
			bSuccess = False
		End If
	Else
		bSuccess = False					
	End If
	
	
	
	'Retrun value
	funcUploadPDFCoStar = bSuccess

	' Error handling
	If Err.Number <> 0 Then
		Call gfReportExecutionStatus(micFail,"Upload PDF","Got the Error : " & Err.Description)
		On Error Goto 0
	End If

	' Clean Up
	Set oshell = Nothing
	Set objBrowser = Nothing
	Set objPage = Nothing

End Function

'*******************************************************************************************************************************************************************************************
'# Function:   funcClickTextbox(ByVal BrowserName, ByVal ObjName)
'# Function is used to click on WebEdit(textboxes)
'# Input Parameters: BrowserNAme and Textbox name property
'# None
'#
'# OutPut Parameters: boolean
'#  
'# Usage:
'*******************************************************************************************************************************************************************************************

Function funcClickTextbox(ByVal BrowserName, ByVal ObjName)	
	Dim objButton
	Dim objForm
	Dim objBrowser
	Dim bSuccess
	
	On Error Resume Next
	Err.Clear
	
	'	For Clicking on Textbox
	bSuccess = False
	If BrowserName <> "" Then
	Set objBrowser= funcCreatePageObj(BrowserName)      
	Set objText = objBrowser.WebEdit("name:="&ObjName)
	End If
	
	
	'Check the existance of the Textbox object and click on it.
	If objText.Exist(gSYNCWAIT) Then
	objText.Click
	bSuccess = True
	Else
	bSuccess = False
	End If
	
	' Check for error no
	If Err.Number <> 0 Then bSuccess = False
	
	' Return Value
	funcClickTextbox = bSuccess
	
	'	Clean up
	Set objBrowser = Nothing
	Set objText = Nothing	
End Function

Function gfuncVerifyErrorExistance(ByVal BrowserName, ByVal Existance)
err.clear
On error resume next
	
Set Errobj = Description.Create()
Errobj("column names").value = ".*Error.*"
Errobj("micclass").value = "WebTable"
Errobj("visible").value = "True"

Set ErrWEobj = Description.Create()
ErrWEobj("column names").value = ".*Error.*"
ErrWEobj("micclass").value = "WebTable"
ErrWEobj("visible").value = "True"
'
set Erobjs = Browser("name:="&BrowserName).Page("title:="&BrowserName).ChildObjects(Errobj)
set ErrWEobjs = Browser("name:="&BrowserName).Page("title:="&BrowserName).ChildObjects(ErrWEobj)

Select Case UCASE(Existance)
	
	Case "TRUE"
	
	if(Erobjs.count)>0 or (ErrWEobjs.count)>0 then
	bSuccess = "True"
	else 
	bSuccess = "False"
	end if
	
	Case "FALSE"
	
	if(Erobjs.count)>0 or (ErrWEobjs.count)>0 then
	bSuccess = "False"
	else 
	bSuccess = "True"
	end if  

End Select
End Function 
