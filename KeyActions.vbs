'*******************************************************************************************************************************************************************************************
'*   Script Name:   	KeyAction
'*   Written by:   			DXC
''*
'*    Description:		 This is the repeated action used in keyword-driven scripts 
'*									 1)    Sets the local table to the KeyAction as data table.
'*
'*									 2)   Executes the action using the action passed from the Main (Driver) script, which is read from the data table
'*										   test script.   Each action corresponds to a Case selection in this script.   If the data table row passed
'*										  contains a Test Step ID - then the full details from the execution are passed to the results.
'*
'*******************************************************************************************************************************************************************************************

'Option Explicit

Public Function KeyActions(rsTestData,rsTestCaseData)
	
	'Declaring global Variables 
	Dim Action, strTestStepID,strBrowserTitle, strOracleFormName, strTabName, strObjectName
	Dim strParam1, strParam2, strParam3, strParam4, strParam5, strParam6, strComments
	Dim BrowserName, FormName, TabName, ObjName, IndexNum, strValue,  RowNumber, ColumnName, CellData
	Dim ArrayPosition, PropertyName, strValidateMsg, ObjClass, TableName, bUniqueValues, TextValue
	Dim ListValue, OracleListName, strMessage, KeyValue, strTextToVerify
	Dim bSuccess
	'==================ravikanth 26-sep-2014
	Dim ButtonName
	'==================ravikanth 26-sep-2014
	
	'Assigning Values
	Action 								 		= rsTestData("Action").Value
	strTestStepID 			   	   	 	= rsTestData("TestStepID").Value
	strBrowserTitle 				    = rsTestData("BrowserTitle").Value
	strOracleFormName 	   	   = rsTestData("OracleFormName").Value
	strTabName 						   = rsTestData("TabName").Value
	strObjectName 					 = rsTestData("ObjectName").Value
	strParam1 						  	   = rsTestData("Param1").Value
	strParam2 						   	   = rsTestData("Param2").Value
	strParam3 						   	   = rsTestData("Param3").Value
	strParam4 						   	   = rsTestData("Param4").Value
	strParam5 						   	   = rsTestData("Param5").Value
	strParam6 						   	   = rsTestData("Param6").Value
	strComments						   = rsTestData("Comments").Value
	
	Call gfReportExecutionStatus(micDone,"RunAction:"&Action,"Executing the following action: " & Action)

	Select Case Action
'	    Case "Login"
'				Dim  strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow			
'				strResponsibility = strObjectName
'				strLink = strParam1		'Link - text property
'				strIndex = strParam2
'				strBrowserWindow = strBrowserTitle		'Browser - name property, Page - title property
'				strFormWindow = strOracleFormName
'		
'				If InStr(strResponsibility,"<<") > 0 Then
'					strResponsibility = Replace(Replace(strResponsibility,"<<",""),">>","") 
'					strResponsibility = rsTestCaseData(strResponsibility).Value
'				End If
'
'				If InStr(strLink,"<<") > 0 Then
'					strLink = Replace(Replace(strLink,"<<",""),">>","") 
'					strLink = rsTestCaseData(strLink).Value
'				End If
'		
'				bSuccess = Login(strTabName, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow)
'				If strComments <> "" Then ObjName = strComments
'
'				If bSuccess = "PASSED" Then
'					Call gfReportExecutionStatus(micDone,"Login to Application","Login is successfull")                   
'				Else
'					Call gfReportExecutionStatus(micFail,"Login to Application","Unable to Login to application")                   
'				End If
		Case "OracleSSOLogin"
				Dim  strResponsibility, strLink 		
'				strResponsibility = strObjectName
				strLink = strParam1		'Link - text property
				strIndex = strParam2
				strBrowserWindow = strBrowserTitle		'Browser - name property, Page - title property
				strFormWindow = strOracleFormNam
		
				If InStr(strResponsibility,"<<") > 0 Then
					strResponsibility = Replace(Replace(strResponsibility,"<<",""),">>","") 
					strResponsibility = rsTestCaseData(strResponsibility).Value
				End If

				If InStr(strLink,"<<") > 0 Then
					strLink = Replace(Replace(strLink,"<<",""),">>","") 
					strLink = rsTestCaseData(strLink).Value
				End If
		
				bSuccess = OracleSSOLogin(strTabName,strLink)
				If strComments <> "" Then ObjName = strComments

				If bSuccess = "PASSED" Then
					Call gfReportExecutionStatus(micDone,"Login to Application","Login is successfull")                   
				Else
					Call gfReportExecutionStatus(micFail,"Login to Application","Unable to Login to application")                   
				End If
				
		Case "DOHLogOut"
						
'				strResponsibility = strObjectName
				UserName = strParam1		'UserName - Logged in User Mail id
				
				If InStr(UserName,"<<") > 0 Then
					UserName = Replace(Replace(UserName,"<<",""),">>","") 
					UserName = rsTestCaseData(UserName).Value
				End If
		
				bSuccess = bfuncDOHLogOut(UserName)
				
				If bSuccess = "True" Then
					Call gfReportExecutionStatus(micPass,"Logout from Application","Logout is successfull")                   
				Else
					Call gfReportExecutionStatus(micFail,"Logout from Application","Logout is not successfull")                   
				End If		

		Case "SSOLogin"
				'Dim  strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow			
				strResponsibility = strObjectName
				strLink = strParam1			'Link - text property
				strIndex = strParam2
				strBrowserWindow = strBrowserTitle			'Browser - name property, Page - title property
				strFormWindow = strOracleFormName
				
				If InStr(strResponsibility,"<<") > 0 Then
					strResponsibility = Replace(Replace(strResponsibility,"<<",""),">>","") 
					strResponsibility = rsTestCaseData(strResponsibility).Value
				End If

				If InStr(strLink,"<<") > 0 Then
					strLink = Replace(Replace(strLink,"<<",""),">>","") 
					strLink = rsTestCaseData(strLink).Value
				End If
		
				bSuccess = SSOLogin(strTabName, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow)
				If strComments <> "" Then ObjName = strComments			'-------------------------------Ravikanth 22-Aug-2014

				If bSuccess = "PASSED" Then
					Call gfReportExecutionStatus(micDone,"Login to SSO Application","SSOLogin is successfull")           '-------------------------------Ravikanth 22-Aug-2014        
				Else
					Call gfReportExecutionStatus(micFail,"Login to SSO Application","Unable to Login to SSO application")  '-------------------------------Ravikanth 22-Aug-2014
				End If
					
		Case "SwitchResponsibility"
				Dim strSwitchResponsibility
				strSwitchResponsibility = strParam1			'Responsibility name
				
				If InStr(strSwitchResponsibility,"<<") > 0 Then
					strSwitchResponsibility = Replace(Replace(strSwitchResponsibility,"<<",""),">>","") 
					strSwitchResponsibility = rsTestCaseData(strSwitchResponsibility).Value
				End If
	
				strFunctionStatus = SwitchResponsibility(strSwitchResponsibility)
	
		Case "NavigateTo"
				Dim strNavigation
				strNavigation  = strObjectName		'navigation example - Payments:Entry:Payment Manager
		
				bSuccess = funcNavigateTo(strNavigation)
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Navigate To","Navigation to : " & strNavigation &" is successful")
				Else
					Call gfReportExecutionStatus(micFail,"Navigate To","Navigation to : " & strNavigation &" is failed")
				End If
	
		Case "BusinessFunction"
				Dim strFunctionName, strFunctionArg, strOutparam
				strFunctionName  = strParam1		'function name example - funcRandomNumber
				strFunctionArg = strParam2				'arguments example - "1000","9999","12345","ts011"

				If instr(UCase(strFunctionArg),"OUTPARAM") > 0 Then
					If inStr(strFunctionArg,",") > 0 Then
						strOutparam = Mid(strFunctionArg,inStr(strFunctionArg, "OUTPARAM#"),14) 
						strFunctionArg = Replace(strFunctionArg, strOutparam,GetValueFromGlobalDictionary(strOutparam))
					Else
						strFunctionArg = GetValueFromGlobalDictionary(strFunctionArg)
					End If
				End If

				If InStr(strFunctionArg,"<<") > 0 Then
					strFunctionArg = Replace(Replace(strFunctionArg,"<<",""),">>","") 
					strFunctionArg = rsTestCaseData(strFunctionArg).Value
				End If

				eval(strFunctionName & "(" & strFunctionArg & " )")

		Case "CheckPrepaymentNumber"
				FormName = strOracleFormName
				ObjName = strObjectName			'OracleTable - block name property
				strValue = strParam1
		
				' Check for OUTPARAM in ObjName
				If instr(UCase(strValue),"OUTPARAM") > 0 Then
					strValue = GetValueFromGlobalDictionary(strValue)
				End If
		
				bsuccess = funcCheckPrepaymentNumber(FormName,ObjName,strValue)
				If bsuccess Then
					Call gfReportExecutionStatus(micDone,"CheckPrepaymentNumber","Invoice num : " & strValue & " is present in the prepayment numbers")                      
				Else
					Call gfReportExecutionStatus(micFail,"CheckPrepaymentNumber","Invoice num  : " & strValue & " is not present in the prepayment numbers")                      
				End If
		
		Case "CheckBrowserName"
				Dim ReportName
				BrowserName= strBrowserTitle
				PropertyName= strParam1
				ReportName= strParam2
		
				bSuccess = funcCheckBrowserName(BrowserName,PropertyName)
	
				If bSuccess Then
						Call gfReportExecutionStatus(micDone, "ReportGeneration", "Successfully generated the report : " &ReportName)
				Else
						Call gfReportExecutionStatus(micFail, "ReportGeneration", "Failed to  generated the report	:  "& ReportName)
				End If	
	
		Case "VerifyExistence"
				BrowserName= strBrowserTitle
				FormName = strOracleFormName							
				TabName = strTabName
				ObjName = strObjectName			'example - WebElement / WebTable /  Link
				PropertyName = strParam1		'WebElement - innertext  property, WebTable - column names  property, Link - name property
				IndexNum = strParam2
				strTextToVerify = strParam3
				RowNumber = strParam4
				ColumnName = strParam5

				If InStr(PropertyName,"<<") > 0 Then
					PropertyName = Replace(Replace(PropertyName,"<<",""),">>","") 
					PropertyName = rsTestCaseData(PropertyName).Value
				End If
			
				If InStr(strTextToVerify,"<<") > 0 Then
					strTextToVerify = Replace(Replace(strTextToVerify,"<<",""),">>","") 
					strTextToVerify = rsTestCaseData(strTextToVerify).Value
				End If

				' Check for OUTPARAM in PropertyName
				If instr(UCase(PropertyName),"OUTPARAM") > 0 Then
					PropertyName = GetValueFromGlobalDictionary(PropertyName)
				End If

				' Check for OUTPARAM in PropertyName
				If instr(UCase(strTextToVerify),"OUTPARAM") > 0 Then
					strTextToVerify = GetValueFromGlobalDictionary(strTextToVerify)
				End If

				Call funcVerifyExistence(BrowserName,FormName, TabName, strObjectName, PropertyName, IndexNum, strTextToVerify, RowNumber, ColumnName)
		
		Case "ClickFlexbutton"
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName			'OracleButton - label property
				IndexNum = strParam1
		
				'Capture Image
				If CBool(Environment("CaptureImage")) Then lfCaptureImage()
		
				bSuccess =funcClickFlexbutton(FormName,TabName, ObjName,IndexNum)
				If strComments <> "" Then ObjName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Click on FlexButton ","Click the flex button: " & ObjName)
				Else
					Call gfReportExecutionStatus(micFail,"Click on FlexButton ","Failed to click the flex button: " & ObjName)
				End If
		
		Case "ClickButton"
				BrowserName= strBrowserTitle
				TabName = strTabName				
				ObjName = strObjectName				'WebButton - name property, OracleButton - description property, OracleNotification - title property
				IndexNum = strParam1
				ButtonName = strParam2
				HtmlId = strParam3
				'Capture Image
				If CBool(Environment("CaptureImage")) Then lfCaptureImage()
			
				'============================ravikanth 26-sep-2014			
				' Call the function that clicks the button
				'bSuccess = funcClickButton(BrowserName,FormName,TabName, ObjName,IndexNum,HtmlId)
                bSuccess = funcClickButton(BrowserName,FormName,TabName, ObjName,IndexNum,ButtonName, HtmlId)
				'============================ravikanth 26-sep-2014
				'============================ravikanth 08-jul-2015
				If FormName = "OracleNotification" Then
					ObjName = "'OK' of 'Forms Notification' window"
				ElseIf strComments <> "" Then
					ObjName = strComments
				End If
				'============================ravikanth 08-jul-2015

				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Click Button","Clicked on button	: " & ObjName & " "&HtmlId)
				Else
					Call gfReportExecutionStatus(micFail,"Click Button","Failed to click the button	: " & ObjName & " "&HtmlId)
				End If	
				
''To Click on the Text box
	Case "ClickTextBox"
			BrowserName= strBrowserTitle
			TabName = strTabName				
			ObjName = strObjectName				'WebEdit - name property, 
			IndexNum = strParam1
			TextFieldName = strParam2
			
			'Capture Image
			If CBool(Environment("CaptureImage")) Then lfCaptureImage()
		
			'============================		
			' Call the function that clicks the button
			
	        bSuccess = funcClickTextBox(BrowserName, ObjName)
			
			If bSuccess Then
				Call gfReportExecutionStatus(micPass,"Click Textbox","Clicked on Textbox	: " & ObjName)
			Else
				Call gfReportExecutionStatus(micFail,"Click Textbox","Failed to click the Textbox	: " & ObjName)
			End If
		
		
		Case "ClickImage"
				BrowserName= strBrowserTitle
				FormName= strOracleFormName
				ObjName=strObjectName				'Image - file name/alt property
				IndexNum=strParam1
		
				'Capture ImageBrowser("Welcome").Page("Oracle Applications").Image("Search").Click

				If CBool(Environment("CaptureImage")) Then lfCaptureImage()
		
				bSuccess = funcClickImage(BrowserName,FormName,ObjName,IndexNum)
				If strComments <> "" Then ObjName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micDone, "Click Image", "Clicked  Image:  "& ObjName & "  in the page " &BrowserName)
				Else
					Call gfReportExecutionStatus(micFail, "Click on Image", "Failed to click Image:  " & ObjName & " in the page " &BrowserName)
				End If 
		
		Case "ClickLink"
				BrowserName = strBrowserTitle
				ObjName = strObjectName			'Link - name property
				IndexNum = strParam1
		
				' Check for OUTPARAM in ObjName
				If instr(UCase(ObjName),"OUTPARAM") > 0 Then
					ObjName = GetValueFromGlobalDictionary(ObjName)
				End If
		
				'Capture Image
				If CBool(Environment("CaptureImage")) Then lfCaptureImage()

				If InStr(ObjName,"<<") > 0 Then
					ObjName = Replace(Replace(ObjName,"<<",""),">>","") 
					ObjName = rsTestCaseData(ObjName).Value
				End If

				'Click on the link
				bSuccess = funcClickLink(BrowserName,ObjName,IndexNum)

				'========================ravikanth 03-sep-2014
				'If strComments <> "" Then ObjName = strComments
				If ObjName <> "" Then
					If InStr(ObjName,"<<") > 0 Then
						ObjName = Replace(Replace(ObjName,"<<",""),">>","") 
					End If
				ElseIf strComments <> "" Then
					ObjName = strComments
				End If
				'========================ravikanth 03-sep-2014
		
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Click Link", "Clicked on Link :	" & ObjName)
				Else
					Call gfReportExecutionStatus(micFail,"Click Link","Failed to click the Link : " & ObjName)
				End If
		
		Case "Comment"
				''Ignoring this line - used to allow comments in the excel spreadsheet
		
		Case "CloseOracleForm"
				FormName = strOracleFormName
				IndexNum = strParam1
		
				bSuccess = funcCloseOracleForm(FormName, IndexNum)
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Close Oracle Form","Closed the form	" & FormName)
				Else
					Call gfReportExecutionStatus(micFail,"Close Oracle Form","Failed to close  the Form  " & FormName)
				End If
		
		Case "CheckScreenMessage"
				BrowserName = strBrowserTitle
				ObjName = strObjectName				'WebElement - html tag property
				strMessage = strParam1
				ArrayPosition=strParam2
		
				bSuccess = funcGetScreenMessage(BrowserName,ObjName,strMessage,ArrayPosition, strTestStepID)
				'If strComments <> "" Then ObjName = strComments
				If (bSuccess  and (dicGlobalOutput.Exists(strTestStepID))) Then
					Call gfReportExecutionStatus(micPass,"CheckScreenMessage","Message	'" & strMessage & " " & dicGlobalOutput(strTestStepID) &"' is displayed.")
				ElseIf Not bSuccess Then
					Call gfReportExecutionStatus(micFail,"CheckScreenMessage","Failed to verify the message	'" & strMessage & "'")
				End If
		
		Case "GetTableBoxValue"
				BrowserName = strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName			'WebTable - name property, OracleTable - block name property
				IndexNum = strParam1
				RowNumber = strParam2
				ColumnName = strParam3
				strValidateMsg = strParam4

				' Check for OUTPARAM in RequestID 
				If Instr(UCase(strValidateMsg),"OUTPARAM") > 0 Then 
					strValidateMsg = GetValueFromGlobalDictionary(strValidateMsg) 
				End If
'=======================================ravikanth 15-mar-2015
				If InStr(strValidateMsg,"<<") > 0 Then
					strValidateMsg = Replace(Replace(strValidateMsg,"<<",""),">>","") 
					strValidateMsg = rsTestCaseData(strValidateMsg).Value
				End If
'=======================================ravikanth 15-mar-2015
				strActualMsg =  funcGetTableBoxValue(BrowserName, FormName,TabName, ObjName, IndexNum, RowNumber, ColumnName, strTestStepID)
		
				If strActualMsg <> "" AND strValidateMsg <> "" Then
					If inStr(strActualMsg, strValidateMsg) >0 Then
						Call gfReportExecutionStatus(micPass,"Compare Text"," Got the message '"& strActualMsg  & "'")
					Else
						Call gfReportExecutionStatus(micFail,"Compare Text"," Verification failed Expected text: "& strValidateMsg &" Got the text " & strActualMsg)
					End If
				Else

					If strComments <> "" Then
						ObjName = strComments
						Call gfReportExecutionStatus(micPass,ObjName,ObjName & " is : '"& strActualMsg  & "'")
					Else
						Call gfReportExecutionStatus(micPass,ColumnName,ColumnName & " is : '"& strActualMsg  & "'")
					End If
				End If

		Case "WaitForCompleteStatus"
				Dim RequestID
				BrowserName=strBrowserTitle
				RequestID = strParam1
				bCheckOutput = strParam2

				If InStr(RequestID,"<<") > 0 Then
					RequestID = Replace(Replace(RequestID,"<<",""),">>","") 
					RequestID = rsTestCaseData(RequestID).Value
				End If

				' Check for OUTPARAM in RequestID
				If Instr(UCase(RequestID),"OUTPARAM") > 0 Then
					RequestID = GetValueFromGlobalDictionary(RequestID)
				End If

				Call  funcWaitForCompleteStatus(BrowserName,RequestID,bCheckOutput)
	
		Case "GetTextBoxValue"
				BrowserName=strBrowserTitle
				FormName = strOracleFormName
				ObjName = strObjectName				'WebEdit - name property, OracleTextField - description property
				TabName = strTabName
				IndexNum = strParam1
				strValidateMsg = strParam2

				' Check for OUTPARAM in RequestID 
                If Instr(UCase(strValidateMsg),"OUTPARAM") > 0 Then 
					strValidateMsg = GetValueFromGlobalDictionary(strValidateMsg) 
                End If

				If InStr(strValidateMsg,"<<") > 0 Then
					strValidateMsg = Replace(Replace(strValidateMsg,"<<",""),">>","") 
					strValidateMsg = rsTestCaseData(strValidateMsg).Value
				End If

				strActualMsg = funcGetTextBoxValue(BrowserName, FormName,TabName, ObjName,IndexNum,strTestStepID)
		
				If strActualMsg <> "" Then
					If inStr(strActualMsg, strValidateMsg) >0 Then
						Call gfReportExecutionStatus(micPass,"Compare Text","Got the message '"& strActualMsg  & "'")
					Else
						Call gfReportExecutionStatus(micFail,"Compare Text"," Verification failed Expected text  '"& strValidateMsg &"' Got the text '" & strValidateMsg & "'")
					End If
				'=============================ravikanth 17-feb-2014==========
				Else
					If ObjName <> "" Then
						If InStr(ObjName,"<<") > 0 Then
							ObjName = Replace(Replace(ObjName,"<<",""),">>","")
						End If
						Call gfReportExecutionStatus(micPass,ObjName,ObjName & " is : '"& strActualMsg  & "'")
					ElseIf  strComments <> "" Then
						Call gfReportExecutionStatus(micPass,ColumnName,ColumnName & " is : '"& strActualMsg  & "'")
					End If
				'=============================ravikanth 17-feb-2014==========
				End If
		
		Case "GetListValue"	
				OracleListName = strObjectName			'OracleListOfValues - title property
				ListValue = strParam1
				IndexNum=strParam2

				' Check for OUTPARAM in ListValue
				If instr(UCase(ListValue),"OUTPARAM") > 0 Then
					ListValue = GetValueFromGlobalDictionary(ListValue)
				End If
				
				' Check list value exists in the listbox
				bSuccess = funcGetListValue( OracleListName,IndexNum, ListValue)
                If strComments <> "" Then OracleListName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"List Value Verification"," Expected Value	: "&ListValue &" Available in the list box "& OracleListName)
				Else
					Call gfReportExecutionStatus(micFail,"List Value Verification"," Expected Value	: "&ListValue&"  Not available in the list box "& OracleListName)
				End If
		
		Case "GetBrowserTableValue"
				Dim strCompText
				BrowserName = strBrowserTitle
				TableName = strObjectName			'WebTable - name property or other property							 							 
				IndexNum = strParam1
				RowNumber = strParam2
				ColumnName = strParam3
				strCompText = strParam4
				ArrayPosition=strParam5
		
				' Check for OUTPARAM in ObjName
				If instr(UCase(strCompText),"OUTPARAM") > 0 Then
					strCompText = GetValueFromGlobalDictionary(strCompText)
				End If
		
				Call funcGetBrowserTableValue(BrowserName,TableName,IndexNum,RowNumber,ColumnName,strCompText,ArrayPosition,strTestStepID)
		
		Case "SelectBrowserTableObject"
				Dim ObjIndex, strVal
				BrowserName = strBrowserTitle
				ObjClass =  strOracleFormName 			'class - WebTableCheckbox/WebTableRadioButton
				TableName= strObjectName			'WebTable - name property
				IndexNum=strParam1
				RowNumber=strParam2     
				ColumnName = strParam3 
				ObjIndex = strParam4
				strVal = strParam5

				bSuccess =  funcWebTableSelectObj(BrowserName,TableName,IndexNum,RowNumber,ColumnName,ObjClass,ObjIndex,strVal)

				If strComments <> "" Then strVal = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micPass, " Select " & ObjClass,"Selected : " & strVal)
				Else
					Call gfReportExecutionStatus(micFail, " Select " & ObjClass,"Failed to Select : " & strVal)
				End If
		
		Case "OracleTree"
				Dim ItemVal, TreeAction
				BrowserName= strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName						
				ObjName=strObjectName				'OracleTree - developer name property
				IndexNum = strParam1
				ItemVal= strParam2
				TreeAction=strParam3
	
				bSuccess = funcTreeOperations(BrowserName,FormName,TabName,ObjName,IndexNum,ItemVal,TreeAction)
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Tree Operations","Performed the "& TreeAction & " for OracleTree in form: " & FormName & " for item: "& ItemVal)
				Else
					Call gfReportExecutionStatus(micFail,"Tree Operations","Failed to perform the "& TreeAction & " for OracleTree in form: " & FormName & " for item " & ItemVal )
				End If
				
		Case "VerifyBrowserObject"
				BrowserName = strBrowserTitle
				ObjName = strObjectName				'Link - innertext property
				ObjClass= strParam1				 		'class - LINK
				IndexNum=strParam2

				' Check for OUTPARAM in ObjName
				If instr(UCase(ObjName),"OUTPARAM") > 0 Then
					ObjName = GetValueFromGlobalDictionary(ObjName)
				End If

				bSuccess = funcVerifyBrowserObject(BrowserName,ObjName,ObjClass,IndexNum)

				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Verify Browser Object","Object : " & ObjName & " of Class " & ObjClass & " is found ")
				Else
					Call gfReportExecutionStatus(micFail,"Verify Browser Object","Object  : " & ObjName & " of Class " & ObjClass & " not found ")
				End If
	
		Case "VerifyFieldValue"
				BrowserName=strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName		'OracleTable - block name, OracleTextField - description, OracleCheckbox - label/description, OracleList - description, 
																		   'OracleRadioGroup - developer name, WebTable - column names, WebEdit - name
				KeyValue = strParam1
				IndexNum = strParam2
				objClass = strParam3
				RowNumber = strParam4
				ColumnName = strParam5
		
				If Instr(KeyValue,"<<") > 0 Then
					KeyValue = Replace(Replace(KeyValue,"<<",""),">>","") 
					KeyValue = rsTestCaseData(KeyValue).Value
				End If
		
				' Check for outparam entry
				If instr(UCase(KeyValue),"OUTPARAM") > 0 Then
					KeyValue = GetValueFromGlobalDictionary(KeyValue)	
				End If
		
				bSuccess = funcVerifyFieldValue(BrowserName,FormName,TabName,ObjName, KeyValue,IndexNum,objClass,RowNumber,ColumnName)
				'===================================ravikanth 02-jul-2015
				'If strComments <> "" Then ObjName = strComments
				If strParam3 = "OracleTable" and Not IsNumeric(strParam5) Then
						ObjName = strParam5
				ElseIf strParam3 = "OracleTable" and IsNumeric(strParam5) Then
						If Instr(strParam1,"<<") > 0 Then
							ObjName = Replace(Replace(strParam1,"<<",""),">>","") 
						End If
				End If
				'===================================ravikanth 02-jul-2015
				'===================================ravikanth 12-sep-2014
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Verify Field Value : "&ObjName,"Value : " &KeyValue & " matches")
				Else
					Call gfReportExecutionStatus(micFail,"Verify Field Value : "&ObjName, "Failed to match the value : " &KeyValue&" for the object	: " & ObjName)
				End If
				'===================================ravikanth 12-sep-2014
		
		Case "EnterFlexTextValue"
				BrowserName=strBrowserTitle
				FormName = strOracleFormName			'OracleFlexWindow - title
				TabName = strTabName
				ObjName = strObjectName			'OracleTextField - prompt property
				TextValue = strParam1
				IndexNum = strParam2			
				bUniqueValues = strParam3
				bOpenDialog = strParam4
	
				If Instr(TextValue,"<<") > 0 Then
					TextValue = Replace(Replace(TextValue,"<<",""),">>","") 
					TextValue = rsTestCaseData(TextValue).Value
				End If
					
				' Check for OUTPARAM in TextValue
				If instr(UCase(TextValue),"OUTPARAM") > 0 Then
					TextValue = GetValueFromGlobalDictionary(TextValue)
				End If
		
				' Call function to set text in a flex Window
				bSuccess = funcFlexWindowSetText(BrowserName,FormName,TabName,ObjName,IndexNum,TextValue, bUniqueValues,bOpenDialog, strTestStepID)
                If strComments <> "" Then ObjName = strComments
				If UCase(cStr((bUniqueValues))) = "TRUE" Then TextValue = dicGlobalOutput(strTestStepID)
		
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Enter " & ObjName, ObjName &" : "& TextValue)
				Else
					Call gfReportExecutionStatus(micFail,"Enter "& ObjName,"Failed to enter enter the value : "& TextValue)
				End If
		
		Case "EnterFormattedSystemDate"	
				Dim strDateFormat
				BrowserName=strBrowserTitle
				FormName = strOracleFormName
				ObjName = strObjectName				'WebEdit - name, OracleTextField - description/prompt, OracleTable - block name property
				TabName = strTabName
				strDateFormat = strParam1
				RowNumber =  strParam2
				ColumnName = 	strParam3
		
				bSuccess = funcSetFormattedCurrentDate(BrowserName,FormName,TabName,ObjName,strDateFormat,RowNumber,ColumnName)
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Enter Formatted Date","Entered the formatted date in the Field  : " & ObjName)
				Else
					Call gfReportExecutionStatus(micFail,"Enter Formatted Date","Failed to enter the formatted date in the Field  : " & ObjName)
				End If
			
		Case "EnterTextValue"
				BrowserName = strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName 		'WebEdit - name property, OracleTextField - description property
				TextValue = strParam1
				IndexNum = strParam2
				bUniqueValues = strParam3
				bOpenDialog = strParam4
		
				If instr(TextValue,"<<") > 0 Then
					TextValue = Replace(Replace(TextValue,"<<",""),">>","") 
					TextValue = rsTestCaseData(TextValue).Value
				End If
		
				' Check for OUTPARAM in TextValue
				If instr(UCase(TextValue),"OUTPARAM") > 0 Then
					TextValue = GetValueFromGlobalDictionary(TextValue)
				End If
		
				' Call function to set text in a text field
				bSuccess = funcTextBoxSetText(BrowserName,FormName,TabName,ObjName,IndexNum,TextValue,bUniqueValues,bOpenDialog,strTestStepID)
				If UCase(cStr((bUniqueValues))) = "TRUE" Then TextValue = dicGlobalOutput(strTestStepID)
				
				'================================ravikanth 03-sep-2014
				'If strComments <> "" Then ObjName = strComments
				If TextValue <> "" Then
					If Instr(TextValue,"<<") > 0 Then
						TextValue = Replace(Replace(TextValue,"<<",""),">>","") 
						ObjName = TextValue
					End If
				Elseif strComments <> "" Then
					ObjName = strComments
				End If
				'================================ravikanth 03-sep-2014
	
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Enter "& ObjName, ObjName &" : "& TextValue)
				Else
					Call gfReportExecutionStatus(micFail,"Enter "& ObjName,"Failed to enter value : "&TextValue&"  in "& ObjName)	
				End If
	
		Case "EnterOracleTableTextValue"
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName			'OracleTable - block name property
				RowNumber = strParam1
				ColumnName = strParam2				 
				CellData = strParam3
				bUniqueValues = strParam4
				bOpenDialog = strParam5
	
				If Instr(CellData,"<<") > 0 Then
					CellData = Replace(Replace(CellData,"<<",""),">>","") 
					CellData = rsTestCaseData(CellData).Value
				End If
		
				If Instr(UCase(CellData),"OUTPARAM") > 0 Then
					CellData = GetValueFromGlobalDictionary(CellData)
				End If
		
				' Call function to set text in Oracle Table
				bSuccess = funcEnterValuesInOracleTable(FormName,TabName,ObjName,RowNumber, ColumnName,CellData, bUniqueValues,bOpenDialog,strTestStepID)
				If UCase(Cstr(bUniqueValues)) = "TRUE" Then CellData = dicGlobalOutput(strTestStepID) 
				'================================ravikanth 30-jun-2015
				'If strComments <> "" Then ColumnName = strComments
				If strParam3 <> "" Then
                	If Instr(strParam3,"<<") > 0 Then
						strParam3 = Replace(Replace(strParam3,"<<",""),">>","") 
						ColumnName = strParam3
					End If
				Elseif strComments <> "" Then
					ColumnName = strComments
				End If
				'================================ravikanth 30-jun-2015
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Enter "& ColumnName, ColumnName&" : " & CellData)
				Else
					Call gfReportExecutionStatus(micFail,"Enter "&ColumnName,"Failed to enter the value : " & CellData & " in "& ColumnName )
				End If
				Wait 1

		Case "GetWindowPopUpMessage"
				Dim WindowName
				WindowName = strObjectName			'OracleNotification - title property
				ArrayPosition = strParam1
				ButtonName = strParam2
		
				strMessage = funcGetPopUpWindowMessage(WindowName,ArrayPosition,strTestStepID,ButtonName)
				If strMessage <> "" Then
					'Call gfReportExecutionStatus(micPass,"Get Popup Message","Got the Message:	 " & strMessage)
					Call gfReportExecutionStatus(micPass,"Get Popup Message","Got the Message:	" & strMessage & " and clicked on 'OK' button of "& WindowName &" window")
				Else
					Call gfReportExecutionStatus(micFail,"Get Popup Message","Failed to get the Popup message")
				End If
		
		Case "LaunchBrowser"
				BrowserName = strBrowserTitle
				IndexNum = strParam2
	
				Result = funcLaunchBrowser(BrowserName,IndexNum)
	
				If Result=True Then
					If BrowserName = "COSTAR" Then
						Call gfReportExecutionStatus(micPass,"LaunchBrowser","Browser Launched with URL	: "&Environment.Value("COSTRURL"))
					Else
						Call gfReportExecutionStatus(micPass,"LaunchBrowser","Browser Launched with URL	: http://"&Environment.Value("URL"))
					End If
				Elseif TestStepID <> "" Then
					If BrowserName = "COSTAR" Then
						Call gfReportExecutionStatus(micFail,"LaunchBrowser","Failed to launch the Browser Launched with URL	: "&Environment.Value("COSTRURL"))
					Else
						Call gfReportExecutionStatus(micFail,"LaunchBrowser","Failed to launch the Browser Launched with URL	: http://"&Environment.Value("URL"))
					End If
				End If
		
		Case "QTPWaitTime"
				Dim strTime
				strTime = strParam1
				
				If instr(strTime,"<<") > 0 Then
					strTime = Replace(Replace(strTime,"<<",""),">>","") 
					strTime = rsTestCaseData(strTime).Value
				End If
				
				Wait (Cint(Trim(strTime)))
		
		Case "SelectListValue"
				BrowserName=strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName
				OracleListName = strObjectName		'WebList - name, OracleList - description, OracleListOfValues - title
				ListValue = strParam1
				IndexNum=strParam2
	
				If instr(ListValue,"<<") > 0 Then
					ListValue = Replace(Replace(ListValue,"<<",""),">>","") 
					ListValue = rsTestCaseData(ListValue).Value
				End If
		
				If instr(UCase(ListValue),"OUTPARAM") > 0 Then
					ListValue = GetValueFromGlobalDictionary(ListValue)
				End If
		
				' Call function to select the value from ListBox
				bSuccess = funcSelectListValue(BrowserName,FormName,TabName, OracleListName, IndexNum, ListValue)
				'==========================Ravikanth 3-sep-2014
				'If strComments <> "" Then OracleListName = strComments
				'If strParam1 <> "" Then
				'		If Instr(strParam1,"<<") > 0 Then
				'			strParam1 = Replace(Replace(strParam1,"<<",""),">>","")
				'			OracleListName = strParam1
				'		End If
				'Else
				If strComments <> "" Then
					OracleListName = strComments
				End If
				'==========================Ravikanth 3-sep-2014
		
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Select "& OracleListName,"Selected the value : " & ListValue)
				Else 
					Call gfReportExecutionStatus(micFail,"Select "& OracleListName,"Failed to select the value : " & ListValue)
				End If
		
		Case "SelectCheckBox"
				Dim CheckBoxName, Status
				BrowserName = strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName
				CheckBoxName = strObjectName			'WebCheckBox - name, OracleCheckbox - label property
				Status = strParam1
				IndexNum = strParam2	

				If instr(CheckBoxName,"<<") > 0 Then
					CheckBoxName = Replace(Replace(CheckBoxName,"<<",""),">>","") 
					CheckBoxName = rsTestCaseData(CheckBoxName).Value
				End If
		
				' Calls a function to check or uncheck a checkBox 
				bSuccess = funSetCheckBoxStatus(BrowserName,FormName,TabName, CheckBoxName,IndexNum,Status)
				'==========================Ravikanth 3-sep-2014
				'If strComments <> "" Then CheckBoxName = strComments
				If CheckBoxName <> "" Then
					If Instr(CheckBoxName,"<<") > 0 Then
						CheckBoxName = Replace(Replace(CheckBoxName,"<<",""),">>","")
					End If
				Elseif strComments <> "" Then
					CheckBoxName = strComments
				End If
				'==========================Ravikanth 3-sep-2014

				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Select CheckBox","CheckBox : "&  CheckBoxName  & " is " & Status&"ed") '============ravikanth 3-sep-2014
				Else
					Call gfReportExecutionStatus(micFail,"Select CheckBox","Failed to " & Status &" CheckBox : "&  CheckBoxName)
				End If
		
		Case "SelectMenuOption"
				Dim MenuName, SubMenu, SubMenu1
				FormName = strOracleFormName
				MenuName = strParam1
				SubMenu = strParam2
				SubMenu1 = strParam3
		
				bSuccess = funcSelectMenu(FormName,MenuName,SubMenu,SubMenu1)
'======================================ravikanth 15-sep-2014
'                If bSuccess Then
'						Call gfReportExecutionStatus(micDone,"Select Menu","Selecting the Menu '" & MenuName & " -> " & SubMenu & " -> " &SubMenu1 & "' in the form  "&FormName)
'					Else 
'						Call gfReportExecutionStatus(micFail,"Select Menu","Failed to Select the Menu '" & MenuName & " -> " & SubMenu & " -> " &SubMenu1 & "' in the form  "&FormName)
'				End If

				If bSuccess Then
					If SubMenu = "Save" Then
						Call gfReportExecutionStatus(micDone,"Select Menu","Selecting the Menu '" & MenuName & " -> " & SubMenu & " -> " &SubMenu1 & "' in the form  "&FormName)
					Else 
						Call gfReportExecutionStatus(micPass,"Select Menu","Selecting the Menu '" & MenuName & " -> " & SubMenu & " -> " &SubMenu1 & "' in the form  "&FormName)
					End If
                Else
						Call gfReportExecutionStatus(micFail,"Select Menu","Failed to Select the Menu '" & MenuName & " -> " & SubMenu & " -> " &SubMenu1 & "' in the form  "&FormName)
				End If
'======================================ravikanth 15-sep-2014
		
		Case "SelectRadioButton"
				Dim RadioButtonToSelect
				BrowserName = strBrowserTitle
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName 'WebRadioGroup - name property, OracleRadioGroup - developer name property
				IndexNum = strParam1
				RadioButtonToSelect = strParam2 '1 - First radiobutton,  2 - second radiobutton

				If instr(RadioButtonToSelect,"<<") > 0 Then
					RadioButtonToSelect = Replace(Replace(RadioButtonToSelect,"<<",""),">>","") 
					RadioButtonToSelect = rsTestCaseData(RadioButtonToSelect).Value
				End If

				If instr(UCase(RadioButtonToSelect),"OUTPARAM") > 0 Then
					RadioButtonToSelect = GetValueFromGlobalDictionary(RadioButtonToSelect)
				End If

				bSuccess = funcSelectRadioButton(BrowserName,FormName,TabName,ObjName,IndexNum, RadioButtonToSelect)
				'==============Ravikanth 3-sep-2014
				If  RadioButtonToSelect <> "" Then
					If Instr(RadioButtonToSelect,"<<") > 0 Then
						RadioButtonToSelect = Replace(Replace(RadioButtonToSelect,"<<",""),">>","") 
					End If
                ElseIf strComments <> "" Then
					RadioButtonToSelect = strComments
				End If

				'If strComments <> "" Then RadioButtonToSelect = strComments

'				If bSuccess  Then
'					Call gfReportExecutionStatus(micPass,"Select RadioButton","Selected radio button	: " & RadioButtonToSelect & " in " & ObjName)
'				Else
'					Call gfReportExecutionStatus(micFail,"Select RadioButton","Failed to select radio button	: " & RadioButtonToSelect & " in " & ObjName )
'				End If
				If bSuccess  Then
					Call gfReportExecutionStatus(micPass,"Select RadioButton","Selected radio button	: " & RadioButtonToSelect & " in " & FormName & " window")
				Else
					Call gfReportExecutionStatus(micFail,"Select RadioButton","Failed to select radio button	: " & RadioButtonToSelect & " in " & FormName  & " window")
				End If
				'==============Ravikanth 3-sep-2014
		
		Case "SetFocus"
				BrowserName = strBrowserTitle
				FormName = strOracleFormName			'OracleFlexWindow - title property
				TabName = strTabName
				ObjName = strObjectName			'OracleTextField - description, OracleTextField - prompt, .OracleTable - block name, WebEdit - name
				objClass=strParam1
				IndexNum=strParam2
				RowNumber=strParam3
				ColumnName=strParam4
		
				bSuccess = funcSetFocus(BrowserName, FormName,TabName,ObjName,IndexNum,objClass,RowNumber,ColumnName)
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"SetFocus","Focused on " & ObjName & " in the " & FormName)
				Else
					Call gfReportExecutionStatus(micFail,"SetFocus","Failed to set focus on " & ObjName & " in the " & FormName)
				End If
			
		Case "StatusBarMessage"
				strMessage = strParam1
                ArrayPosition = strParam2
               bSuccess = funcVerifyStatusBarMessage(strMessage, ArrayPosition, strTestStepID)
			
		Case "FormattedRandomNumber"
				Dim LowerBound1, UpperBound1, LowerBound2, UpperBound2, LowerBound3, UpperBound3, Term
				LowerBound1= strObjectName
				UpperBound1= strParam1                                       
				LowerBound2= strParam2
				UpperBound2= strParam3
				LowerBound3= strParam4
				UpperBound3= strParam5    
				Term=strTabName
	
				Call funcFormattedRandomNumber(LowerBound1,UpperBound1,LowerBound2,UpperBound2,LowerBound3,UpperBound3,Term,strTestStepID)

		Case "SelectTabValue"
				FormName = strOracleFormName
				TabName = strTabName
		
				bSuccess = funcTabSelect(FormName,TabName)
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Select Tab","Selected the Tab : " &TabName)
				Else
					Call gfReportExecutionStatus(micFail,"Select Tab","Failed to select the Tab : "&TabName)
				End If
		
		Case "UseSendKeys"
				Dim RepeatNumber
				KeyValue = strParam1
				RepeatNumber = strParam2
		
				bSuccess = funcSendKeys(KeyValue,RepeatNumber)
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"UseSendKeys","SendKeys : " & KeyValue)
				Else 
					Call gfReportExecutionStatus(micFail,"UseSendKeys","Failed to use SendKeys	: " & KeyValue)
				End If
		
		Case "SelectOracleTableListValue"
				FormName = strOracleFormName
				TabName = strTabName
				ObjName = strObjectName				'OracleTable - block name property
				RowNumber = strParam1
				ColumnName = strParam2
				CellData = strParam3

				If Instr(CellData,"<<") > 0 Then
					CellData = Replace(Replace(CellData,"<<",""),">>","") 
					CellData = rsTestCaseData(CellData).Value
				End If
		
				If Instr(UCase(CellData),"OUTPARAM") > 0 Then
					CellData = GetValueFromGlobalDictionary(CellData)
				End If

				' Call function to selectlistvalue in a table field 
				bSuccess = funcEnterValuesInOracleTable(FormName,TabName,ObjName,RowNumber, ColumnName,CellData,"","","")
				If strComments <> "" Then ColumnName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Select OracleTable ListValue","Selected value : "& CellData & " in the Listbox	" & ColumnName)
				Else
					Call gfReportExecutionStatus(micFail,"Select OracleTable ListValue","Failed to select list value : " & CellData & " in the Column	" & ColumnName)
				End If				
		
		Case "BusinessReporting"
				If strParam1 <>  "" Then
					Call funcBusinessReporting(strParam1)
				End If
		
		Case "EditFrame"														' Key word has changed from EditOracleFrame
				BrowserName = strBrowserTitle
				ObjName = strObjectName				'Frame - html id property
				TextValue = strParam1				
				 
				bSuccess = funcEditOracleFrame(BrowserName,ObjName,TextValue)		
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Edit Frame","Entered value : " & TextValue & " in the frame " & ObjName)
				Else
					Call gfReportExecutionStatus(micFail,"Edit Frame","Failed to enter text value : " & TextValue & " in the frame " & ObjName)
				End If
		
		Case "CloseBrowser"
				BrowserName= strBrowserTitle
				IndexNum = strParam1
	
				bSuccess = funcCloseBrowser(BrowserName,IndexNum)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Close the Browser","Closed the Browser "&BrowserName)
				Else
					Call gfReportExecutionStatus(micFail,"Close the Browser","Failed to close the Browser "&BrowserName)
				End If
	
		Case "VerifyTableRowValue"
				Dim ColumnNames, ReportColumn, strReportText, CoulmnNameToVerify
				BrowserName= strBrowserTitle
				FormName = strOracleFormName							
				TabName = strTabName
				ObjName = strObjectName					'WebTable - column names property
				ColumnNames = strParam1
				ReportColumn = strParam2
				strReportText = strParam3
				CoulmnNameToVerify = strParam4
				strTextToVerify = strParam5

				If InStr(strReportText,"<<") > 0 Then
					strReportText = Replace(Replace(strReportText,"<<",""),">>","") 
					strReportText = rsTestCaseData(strReportText).Value
				End If

				If InStr(strTextToVerify,"<<") > 0 Then
					strTextToVerify = Replace(Replace(strTextToVerify,"<<",""),">>","") 
					strTextToVerify = rsTestCaseData(strTextToVerify).Value
				End If

				' Check for OUTPARAM in strReportText
				If instr(UCase(strReportText),"OUTPARAM") > 0 Then
					strReportText = GetValueFromGlobalDictionary(strReportText)
				End If

				' Check for OUTPARAM in strTextToVerify
				If instr(UCase(strTextToVerify),"OUTPARAM") > 0 Then
					strTextToVerify = GetValueFromGlobalDictionary(strTextToVerify)
				End If

				bSuccess = funcVerifyTableRowValue(BrowserName, FormName, TabName, ObjName, ColumnNames, ReportColumn, strReportText, CoulmnNameToVerify, strTextToVerify)
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Verify Report status","Status of Report  " & strReportText & " is "  & strTextToVerify)
				Else
					Call gfReportExecutionStatus(micFail,"Verify Report status","Failed to Verfy the Status of Report  " & strReportText & " is "  & strTextToVerify)
				End If
	
		Case "ClickWebElement"
				BrowserName= strBrowserTitle
				ObjName = strObjectName					'WebElement - innertext  property
				IndexNum = strParam1
				HtmlId = strParam2
				Clas = strParam3
				If InStr(ObjName,"<<") > 0 Then
					ObjName = Replace(Replace(ObjName,"<<",""),">>","") 
					ObjName = rsTestCaseData(ObjName).Value
					'Setting.WebPackage("ReplayType") = 2
				End If
	
				bSuccess = funcClickOnWebElement(BrowserName, ObjName, IndexNum, HtmlId,Clas)
				If strComments <> "" Then ObjName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Click WebElement","Clicked on WebElement  " & ObjName )
				Else
					Call gfReportExecutionStatus(micFail,"Click WebElement","Failed to click on WebElement  " & ObjName )
				End If
				
			Case "VerifyErrorExistance"
				BrowserName= strBrowserTitle 								
				Existance = strParam1 'Error message should exist or not(True or False)
				
				If InStr(ObjName,"<<") > 0 Then
					ObjName = Replace(Replace(ObjName,"<<",""),">>","") 
					ObjName = rsTestCaseData(ObjName).Value
				
				End If
	
				bSuccess = gfuncVerifyErrorExistance(BrowserName, Existance)
				
				If strComments <> "" Then ObjName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Verify Error Existance","Error Existance  " & bSuccess )
				Else
					Call gfReportExecutionStatus(micFail,"Verify Error Existance","Error Existance  " & bSuccess )
				End If
				'####################################################
	
		Case "FindTableRowAndClickObject"
				Dim ColumnNameToSearch, strText, ColumnNameToAct, ClassIndex
				BrowserName= strBrowserTitle
				ObjName = strObjectName		'WebTable - column names property
				ColumnNameToSearch = strParam1
				strText = strParam2
				ColumnNameToAct = strParam3
				ObjClass = strParam4
				ClassIndex = strParam5

				If InStr(strText,"<<") > 0 Then
					strText = Replace(Replace(strText,"<<",""),">>","") 
					strText = rsTestCaseData(strText).Value
				End If
	
				' Check for OUTPARAM in strText
				If InStr(UCase(strText),"OUTPARAM") > 0 Then
					strText = GetValueFromGlobalDictionary(strText)
				End If

				'Call funcFindTableRowAndClickObject(BrowserName, ObjName, ColumnNameToSearch, strText, ColumnNameToAct, ObjClass,ClassIndex)
				bSuccess = funcFindTableRowAndClickObject(BrowserName, ObjName, ColumnNameToSearch, strText, ColumnNameToAct, ObjClass,ClassIndex)
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Click "& ObjClass & " in a WebTable","Found in table row " & ColumnNameToAct & " and clicked on " & strText & " " & ObjClass)
				Else
					Call gfReportExecutionStatus(micFail,"Click "& ObjClass & " in a WebTable","Failed to found in table row  " & ColumnNameToAct & " and click on " & strText & " " & ObjClass)
				End If

		Case "RunRequest"
				Dim strParameters, strParameter
				StepID = strTestStepID
				BrowserName= strBrowserTitle
				FormName = strOracleFormName							
				TabName = strTabName
				strRequestName = strObjectName
				intParamCount = Cint(strParam1)
				strParameterName = strParam2
				strParameterValue = strParam3
				strViewOutput = strParam4
				strViewLog = strParam5

'				If InStr(strParameterValue,"<<") > 0 Then
'					If InStr(strParameterValue,";") Then
'                        strParameters = Split(strParameterValue,";")
'						strParameterValue = ""
'						For Each strParameter in strParameters
'							If InStr(strParameter,"<<") > 0 Then
'								strParameter  = Replace(Replace(strParameter,"<<",""),">>","") 
'								strParameter = rsTestCaseData(strParameter).Value
'							End If
'							strParameterValue = strParameterValue & ";" & strParameter
'						Next
'						strParameterValue = Mid(strParameterValue,2)
'					Else
'						strParameterValue  = Replace(Replace(strParameterValue,"<<",""),">>","")
'						strParameterValue = rsTestCaseData(strParameterValue).Value
'					End If
'				End If

				If InStr(strParameterValue,"<<") > 0 Then
					If InStr(strParameterValue,";") Then
                        strParameters = Split(strParameterValue,";")
						strParameterValue = ""
						For Each strParameter in strParameters
							If InStr(strParameter,"<<") > 0 Then
								strParameter  = Replace(Replace(strParameter,"<<",""),">>","") 
								If InStr(UCase(strParameter),"OUTPARAM") > 0 Then 						'--------------------Ravikanth 14-Feb-2014---------
									strParameter = GetValueFromGlobalDictionary(strParameter)		'--------------------Ravikanth 14-Feb-2014---------
								Else																'--------------------Ravikanth 14-Feb-2014---------
									strParameter = rsTestCaseData(strParameter).Value
								End If																'--------------------Ravikanth 14-Feb-2014---------
							End If
							strParameterValue = strParameterValue & ";" & strParameter
						Next
						strParameterValue = Mid(strParameterValue,2)
					Else
						strParameterValue  = Replace(Replace(strParameterValue,"<<",""),">>","")
						strParameterValue = rsTestCaseData(strParameterValue).Value
					End If
				End If
			    
				If InStr(UCase(strParameterValue),"OUTPARAM") > 0 Then
                    Do while InStr(strParameterValue,"OUTPARAM") > 0
						If InStr(strParameterValue,";") > 0 Then
                            strOutparam = Mid(strParameterValue,InStr(strParameterValue, "OUTPARAM#"),14) 
                            strParameterValue = Replace(strParameterValue, strOutparam,GetValueFromGlobalDictionary(strOutparam))
                        Else
                            strParameterValue = GetValueFromGlobalDictionary(strParameterValue)
                        End If
                    Loop
                End If

				bSuccess = bfuncRunRequest(StepID, BrowserName, FormName, TabName, strRequestName, intParamCount, strParameterName, strParameterValue, strViewOutput, strViewLog)

		Case "RunRequestNoTimeout"
				'Dim strParameters, strParameter
				StepID = strTestStepID
				BrowserName= strBrowserTitle
				FormName = strOracleFormName							
				TabName = strTabName
				strRequestName = strObjectName
				intParamCount = Cint(strParam1)
				strParameterName = strParam2
				strParameterValue = strParam3
				strViewOutput = strParam4
				strViewLog = strParam5

				If InStr(strParameterValue,"<<") > 0 Then
					If InStr(strParameterValue,";") Then
                        strParameters = Split(strParameterValue,";")
						strParameterValue = ""
						For Each strParameter in strParameters
							If InStr(strParameter,"<<") > 0 Then
								strParameter  = Replace(Replace(strParameter,"<<",""),">>","") 
								strParameter = rsTestCaseData(strParameter).Value
							End If
							strParameterValue = strParameterValue & ";" & strParameter
						Next
						strParameterValue = Mid(strParameterValue,2)
					Else
						strParameterValue  = Replace(Replace(strParameterValue,"<<",""),">>","")
						strParameterValue = rsTestCaseData(strParameterValue).Value
					End If
				End If
				
				If InStr(UCase(strParameterValue),"OUTPARAM") > 0 Then
                    Do while InStr(strParameterValue,"OUTPARAM") > 0
						If InStr(strParameterValue,";") > 0 Then
                            strOutparam = Mid(strParameterValue,InStr(strParameterValue, "OUTPARAM#"),14) 
                            strParameterValue = Replace(strParameterValue, strOutparam,GetValueFromGlobalDictionary(strOutparam))
                        Else
                            strParameterValue = GetValueFromGlobalDictionary(strParameterValue)
                        End If
                    Loop
                End If
				
				bSuccess = bfuncRunRequestNoTimeout(StepID, BrowserName, FormName, TabName, strRequestName, intParamCount, strParameterName, strParameterValue, strViewOutput, strViewLog)
	
		Case "ViewRequest"
				StepID = strTestStepID
				BrowserName= strBrowserTitle
				FormName = strOracleFormName							
				TabName = strTabName
				strType = strObjectName
				strRequestNo = strParam1
				strViewOutput = strParam2
				strOutputSearchString = strParam3
				strViewLog = strParam4
				strLogSearchString = strParam5
	
				'Check for OUTPARAM in strRequestNo
				If instr(UCase(strRequestNo),"OUTPARAM") > 0 Then
					strRequestNo = GetValueFromGlobalDictionary(strRequestNo)
				End If
	
				'Check for OUTPARAM in strOutputSearchString
				If instr(UCase(strOutputSearchString),"OUTPARAM") > 0 Then
					strOutputSearchString = GetValueFromGlobalDictionary(strOutputSearchString)
				End If
	
				'Check for OUTPARAM in strLogSearchString
				If instr(UCase(strLogSearchString),"OUTPARAM") > 0 Then
					strLogSearchString = GetValueFromGlobalDictionary(strLogSearchString)
				End If

				If instr(strRequestNo,"<<") > 0 Then
					strRequestNo = Replace(Replace(strRequestNo,"<<",""),">>","") 
					strRequestNo = rsTestCaseData(strRequestNo).Value
				End If
			
				bSuccess = bfuncViewRequest(StepID, BrowserName, FormName, TabName, strType, strRequestNo, strViewOutput, strOutputSearchString, strViewLog, strLogSearchString)

		Case "ViewRequestNoTimeout"
				StepID = strTestStepID
				BrowserName= strBrowserTitle
				FormName = strOracleFormName							
				TabName = strTabName
				strType = strObjectName
				strRequestNo = strParam1
				strViewOutput = strParam2
				strOutputSearchString = strParam3
				strViewLog = strParam4
				strLogSearchString = strParam5
	
				'Check for OUTPARAM in strRequestNo
				If instr(UCase(strRequestNo),"OUTPARAM") > 0 Then
					strRequestNo = GetValueFromGlobalDictionary(strRequestNo)
				End If
	
				'Check for OUTPARAM in strOutputSearchString
				If instr(UCase(strOutputSearchString),"OUTPARAM") > 0 Then
					strOutputSearchString = GetValueFromGlobalDictionary(strOutputSearchString)
				End If
	
				'Check for OUTPARAM in strLogSearchString
				If instr(UCase(strLogSearchString),"OUTPARAM") > 0 Then
					strLogSearchString = GetValueFromGlobalDictionary(strLogSearchString)
				End If

				If instr(strRequestNo,"<<") > 0 Then
					strRequestNo = Replace(Replace(strRequestNo,"<<",""),">>","") 
					strRequestNo = rsTestCaseData(strRequestNo).Value
				End If
			
				bSuccess = bfuncViewRequestNoTimeout(StepID, BrowserName, FormName, TabName, strType, strRequestNo, strViewOutput, strOutputSearchString, strViewLog, strLogSearchString)

		Case "PageSync"	
				BrowserName= strBrowserTitle
				Call funcPageSync(BrowserName)

		Case "VerifyObjectAndPerformAction"
				BrowserName= strBrowserTitle
				FormName = strOracleFormName                                                                                                           
				TabName = strTabName
				ObjName = strObjectName				'any property name we can take
				IndexNum = strParam1
				ObjClass = strParam2
				strProperty = strParam3
				intTimeOut = strParam4
				'strAction = strParam5

				Call funcVerifyObjectAndPerformAction(BrowserName,FormName,TabName,ObjName,IndexNum,ObjClass,strProperty,intTimeOut)

		Case "AppendString"
				strPrefix = strParam1

				If InStr(strPrefix,"<<") > 0 Then
					strPrefix = Replace(Replace(strPrefix,"<<",""),">>","") 
					strPrefix = rsTestCaseData(strPrefix).Value
				End If

				Call funcAppendString(strPrefix, strTestStepID)

		Case "ClickOracleListOfValuesButton"
				FormName = strOracleFormName			'OracleListOfValues - title property
                ObjName = strObjectName							'Cancel or Find
                ValueToFind = strParam1

				'Check for OUTPARAM in ValueToFind
				If instr(UCase(ValueToFind),"OUTPARAM") > 0 Then
					ValueToFind = GetValueFromGlobalDictionary(ValueToFind)
				End If

				'Capture Image
				If CBool(Environment("CaptureImage")) Then lfCaptureImage()
		
				bSuccess =funcClickOracleListOfValuesButton(FormName,ObjName,ValueToFind )
				If strComments <> "" Then ObjName = strComments

				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Click on Oracle List of Values button ","Click the Oracle List of Values button: " & ObjName)
				Else
					Call gfReportExecutionStatus(micFail,"Click on Oracle List of Values button ","Failed to click the Oracle List of Values button: " & ObjName)
				End If

		Case "AppendReverseString"
				strActualText = strParam1
		
				If InStr(strActualText,"<<") > 0 Then
					strActualText = Replace(Replace(strActualText,"<<",""),">>","") 
					strActualText = rsTestCaseData(strActualText).Value
				End If
		
				If Instr(UCase(strActualText),"OUTPARAM") > 0 Then
					strActualText = GetValueFromGlobalDictionary(strActualText)
				End If
		
				Call funcAppendStringReverse(strActualText, strTestStepID)

		Case "LoginAndVerifyBrowser"
				BrowserName= strBrowserTitle
				strUser	= strTabName
		
				Call funcLoginAndVerifyBrowserExistence(BrowserName, strUser)

		Case "func_ICX_Setups"

				Call func_ICX_Setups()

		Case "func_AP_Setups"

				Call func_AP_Setups()

		Case "func_AR_Setups"

				Call func_AR_Setups()

		Case "func_FA_Setups"

				Call func_FA_Setups()
		
		Case "func_FA_Setups_CA"

				Call func_FA_Setups_CA()

		Case "func_AR_TransTypes_Setups"

				Call func_AR_TransTypes_Setups()
				
		Case "func_iExpen_Setups"

				Call func_iExpen_Setups()

		Case "func_iProc_Setups"

				Call func_iProc_Setups()

		Case "func_Other_Setups"

				Call func_Other_Setups()
				
		Case "funcAddResponsibilitiesforMultipleUsers"

				Call funcAddResponsibilitiesforMultipleUsers()
		
		Case "funcRemoveEndDateForResponsibilities"

				Call funcRemoveEndDateForResponsibilities()

		Case "func_GL_Setups"

				Call func_GL_Setups()

		Case "func_Projects_Setups"

				Call func_Projects_Setups()	
				
'1-April-2016 *****************************************************************************************************************************************

		Case "HandleBrowserDialog"
		
				DialogTitle = strObjectName
				ButtonName = strParam1
	
				bSuccess = funcHandleBrowserDialogWindow(DialogTitle, ButtonName)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micDone,"Close the Browser popup message window","Closed the Browser popup message window")
				Else
					Call gfReportExecutionStatus(micFail,"Close the Browser popup message window","Failed to close the Browser popup message window")
				End If
				
'*************************************************************************************************************************************************************
				
		Case "DownloadPdfCoStar"
		
				BrowserName = strBrowserTitle
				AbstractType = strParam1
				
				If InStr(AbstractType,"<<") > 0 Then
					AbstractType = Replace(Replace(AbstractType,"<<",""),">>","") 
					AbstractType = rsTestCaseData(AbstractType).Value
				End If
	
				bSuccess = funcDownloadPDFCoStar(BrowserName, strTestStepID, AbstractType)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Download PDF file after clicking Actions->Print to PDF or Actions->Run Report","Downloaded PDF file successfully")
				Else
					Call gfReportExecutionStatus(micFail,"Download PDF file after clicking Actions->Print to PDF or Actions->Run Report","Unable to download PDF file successfully")
				End If
				
'*************************************************************************************************************************************************************

		Case "UploadPdfCoStar"
		
				BrowserName = strBrowserTitle
				strFileName = strParam1
		
				' Check for OUTPARAM in ObjName
				If instr(UCase(strFileName),"OUTPARAM") > 0 Then
					strFileName = GetValueFromGlobalDictionary(strFileName)
				End If
	
				bSuccess = funcUploadPDFCoStar(BrowserName,strFileName)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micPass,"Upload PDF file","Uploaded PDF file successfully")
				Else
					Call gfReportExecutionStatus(micFail,"Upload PDF file","Unable to upload PDF file successfully")
				End If
				
		'' IN PHub -To Approve the Items/CO based on NPR request number's or CO number		
		Case "UserActionOnItemReq"		
				
				NPRRequestID = strParam1
				Notification = strParam2
				UserAction = strParam3
				
				' Check for OUTPARAM in strParam1
				If instr(UCase(NPRRequestID),"OUTPARAM") > 0 Then
					NPRRequestID = GetValueFromGlobalDictionary(NPRRequestID)
				End If
				
	
				bSuccess = UserActionOnItemReq(NPRRequestID,Notification, UserAction )
				
				If bSuccess Then
					Call gfReportExecutionStatus(micDone, "UserAction On Item Request", "User Action :  "& UserAction & "  Performed")
				Else
					Call gfReportExecutionStatus(micFail, "UserAction On Item Request", "User Action :  "& UserAction & " not Performed")
				End If 
			
		Case "COCreationandApproval"		
				
				ProductID = strParam1
				StatusToBeChanged = strParam2
				SSOUsertoCheckCOWrkFlow = strParam3
				StepId = strTestStepID
		
				' Check for OUTPARAM in strParam1
				If instr(UCase(ProductID),"OUTPARAM") > 0 Then
					ProductID = GetValueFromGlobalDictionary(ProductID)
				End If
	
				bSuccess = bfuncCOCreationandApproval(ProductID,StatustoBeChanged,SSOUsertoCheckCOWrkFlow, StepId)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micPass, "Change Order Creation and approval ", "CO for Product id:  "& ProductID & " is Approved")
				Else
					Call gfReportExecutionStatus(micFail, "Change Order Creation and approval ", "CO for Product id:  "& ProductID & " is not Approved")
				End If 
				
		Case "EditProduct"		
			
				ProductID = strParam1
					
				' Check for OUTPARAM in strParam1
				If instr(UCase(ProductID),"OUTPARAM") > 0 Then
					ProductID = GetValueFromGlobalDictionary(ProductID)
				End If
	
				bSuccess = bfuncEditProduct(ProductID)
				
								
				If bSuccess Then
					Call gfReportExecutionStatus(micPass, "Edit Product ", "Product :  "& ProductID & " Edited for changes")
				Else
					Call gfReportExecutionStatus(micFail, "Edit Product ", "Product :  "& ProductID & " not Edited for changes")
				End If 

			Case "AccessCO"		
				
				COId = strParam1
						
				' Check for OUTPARAM in strParam1
				If instr(UCase(COId),"OUTPARAM") > 0 Then
					COId = GetValueFromGlobalDictionary(COId)
				End If
	
				bSuccess = AccessCOWF(COId)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micPass, "Change Order accessed ", "CO id:  "& COId & " is Accessed")
				Else
					Call gfReportExecutionStatus(micFail, "Change Order Access ", "CO id:  "& COId & " is not Accessed")
				End If 
				
			Case "CreateItem"
			
				OverviewpageDetails = strParam1
				ProductAttributesDetails = strParam2
				BrandInformationDetails = strParam3
				StorageHandlinginformationDetails = strParam4
				RegulatoryInformationDetails = strParam5
				ApprovalsDetails = strParam6
				StepID = strTestStepID 
		
		
				
					If InStr(OverviewpageDetails,"<<") > 0 Then
							OverviewpageDetails = Replace(Replace(OverviewpageDetails,"<<",""),">>","") 
							OverviewpageDetails = rsTestCaseData(OverviewpageDetails).Value
					End If
					
					If InStr(ProductAttributesDetails,"<<") > 0 Then
							ProductAttributesDetails = Replace(Replace(ProductAttributesDetails,"<<",""),">>","") 
							ProductAttributesDetails = rsTestCaseData(ProductAttributesDetails).Value
					End If
					
					If InStr(BrandInformationDetails,"<<") > 0 Then
							BrandInformationDetails = Replace(Replace(BrandInformationDetails,"<<",""),">>","") 
							BrandInformationDetails = rsTestCaseData(BrandInformationDetails).Value
					End If
					
					If InStr(StorageHandlinginformationDetails,"<<") > 0 Then
							StorageHandlinginformationDetails = Replace(Replace(StorageHandlinginformationDetails,"<<",""),">>","") 
							StorageHandlinginformationDetails = rsTestCaseData(StorageHandlinginformationDetails).Value
					End If
					
					If InStr(RegulatoryInformationDetails,"<<") > 0 Then
							RegulatoryInformationDetails = Replace(Replace(RegulatoryInformationDetails,"<<",""),">>","") 
							RegulatoryInformationDetails = rsTestCaseData(RegulatoryInformationDetails).Value
					End If
					
					If InStr(ApprovalsDetails,"<<") > 0 Then
							ApprovalsDetails = Replace(Replace(ApprovalsDetails,"<<",""),">>","") 
							ApprovalsDetails = rsTestCaseData(ApprovalsDetails).Value
					End If
				
						
				' Check for OUTPARAM in strParam1
				If instr(UCase(ProductID),"OUTPARAM") > 0 Then
					ProductID = GetValueFromGlobalDictionary(ProductID)
				End If
	
				bSuccess = bfuncCreateItem(OverviewpageDetails, ProductAttributesDetails,BrandInformationDetails, StorageHandlinginformationDetails, RegulatoryInformationDetails, ApprovalsDetails, StepID)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micPass, "Create item ", "Item created successfully")
				Else
					Call gfReportExecutionStatus(micFail, "Create item ", "Item not created: Error is"&Err.Description)
				End If 	
'****************************************************************************************************************
			Case "FetchProductIDfromNPR"		
				
				NPRID = strParam1
				StepID = 	strTestStepID
				' Check for OUTPARAM in strParam1
				If instr(UCase(NPRID),"OUTPARAM") > 0 Then
					NPRID = GetValueFromGlobalDictionary(NPRID)
				End If
	
				bSuccess = gfunFetchProductIDfromNPR(NPRID, StepID)
				
				If bSuccess Then
					Call gfReportExecutionStatus(micPass, "FetchProductIDfromNPR ", "Product ID: from NPR captured")
				Else
					Call gfReportExecutionStatus(micFail, "FetchProductIDfromNPR ", "Product from NPR not captured")
				End If 		
'****************************************************************************************************************

			Case "ReassignItemRequest"
				
				RequestID = strParam1
				ReassignedUser = strParam2
	 
	 			If instr(UCase(RequestID),"OUTPARAM") > 0 Then
						RequestID = GetValueFromGlobalDictionary(RequestID)
					End If
		
					bSuccess = gfunReassignItemRequest(RequestID, ReassignedUser)
					
					If bSuccess Then
						Call gfReportExecutionStatus(micPass, "Reassign ItemRequest ", "New Item request id: "&RequestID &"  reassigned ")
					Else
						Call gfReportExecutionStatus(micFail, "Reassign ItemRequest ", "New Item request id: "&RequestID &"not reassigned to user: "&ReassignedUser)
					End If 	

'*************************************************************************************************************************************************************

		Case Else

				Call gfReportExecutionStatus(micFail,"Keyword ",  Action & " not available"  )
	
	End Select
	
	'  OnFail - Error Handling
	If Err.Number <> 0 Then
		Environment("StepFail") = True
		Environment("TCFail") = True
		Call gfReportExecutionStatus(micFail,"Executing the Keyword: "& Action, "Got Error " & Err.Description)
		On Error GoTo 0
		Err.Clear
	End If

End Function
