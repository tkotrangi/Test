''########################################################################################################################
''
''           PROGRAM NAME        	=         OracleSSOLOGIN       
''
''########################################################################################################################
''
''           PURPOSE: Login to Oracle Application by directly launching the oracle forms based on the parameter. 
''           Initial State          = Desktop
''           Final State            = OracleNavigator
''           INPUT PARAMETERS       = sstrUserName,strPassword, strLink
''           OUTPUT PARAMETERS      = 
''            OWNER                 = DHO 
''			Resource					 Date					Remarks
''########################################################################################################################
'
Function OracleSSOLogin(strBrowser,TabName,strLink)
   'Declaration Part
   Dim pstrStatus, strURL, bcontinue, intElapsedTime

    Const FUNC_NAME="OracleSSOLogin"

	err.clear
    On Error Resume Next
    pstrStatus="FAILED"
    strURL = Environment.Value("URL")
     strUserName = Environment(TabName)
      strPassword = Environment(TabName&"PWD")
   
    	Select Case UCASE(strBrowser)
    		
    		Case ""
    			SystemUtil.Run "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",strURL,"","","3"
    			
    		Case "FIREFOX"
					SystemUtil.Run "C:\Program Files\Mozilla Firefox\firefox.exe",strURL,"","","3"
    			
    		Case "IE"
    			 'To get IE browser version
		        Const HKEY_LOCAL_MACHINE = &H80000002
		        strComputer = "."
		        Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
		        strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
		        strValueName = "Version"
		        oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
		        If cInt(Left(strValue,1)) >=8 Then
		            SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
		        Else
		            SystemUtil.Run "iexplore.exe",strURL,"","","3"' for IE7 and below
		        End If
					
			Case "CHROME"			
				SystemUtil.Run "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",strURL,"","","3"
				
		End Select
		
        
        If Err.Number<>0 Then
            On Error GoTo 0
        End If
   
   
 
    Call gfReportExecutionStatus(micPass,"Launch Browser","Browser Launched with URL    : "&strURL) 
    Browser("name:=Sign in to your account").Sync
    
    If Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebElement("innertext:=Use another account", "css:=div#otherTileText").Exist(15) Then
    	Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebElement("innertext:=Use another account", "css:=div#otherTileText").Click
    End If
    
	  If Browser("name:=Sign in to your account").Page("title:=Sign in to your account").Exist(20) Then
	  
    	''Enter the test user id  
    	Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebEdit("name:=loginfmt").Set strUserName
		'Click on Next button
		Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebButton("name:=Next").Click    	
    	    If Err.Number<>0 Then
            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
            Exit Function
         
        End If
        Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&UserName)  
    	''Enter the password
       	Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebEdit("name:=passwd").WaitProperty "visible", "True", 30000
		Wait 5
		Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebEdit("name:=passwd").WaitProperty "visible","True",5000
		Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebEdit("name:=passwd").Set strPassword
		wait(1)
		If Err.Number<>0 Then
            Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
            Exit Function
        End If
		''Click on Sign-In button
		Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebButton("name:=Sign in").Click
		 If Err.Number<>0 Then
            Call gfReportExecutionStatus(micFail,"Click on Signin Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
            Exit Function
        End If
        
        'Click on Yes buttoin in the pop up window
        If  Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebCheckbox("name:=DontShowAgain").Exist(20) Then
            Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebCheckbox("name:=DontShowAgain").Click
            Browser("name:=Sign in to your account").Page("title:=Sign in to your account").WebButton("name:=Yes").Click
         If Err.Number<>0 Then
            Call gfReportExecutionStatus(micFail,"Click on Yes Button in the POP UP window",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
            Exit Function
        End If
        End If
	
'   If Browser("name:=Sign In").Page("title:=Sign In").Exist(20) Then
'    
'
'		'Click on Company Single Sign-On
'		Browser("name:=Sign In").Page("title:=Sign In").WebButton("name:=Company Single Sign-On").Click 
'        'Enter UserName
'        Browser("name:=Sign In").Page("title:=Sign In").WebEdit("name:=.*Username.*").Set strUserName
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If
'        Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)    
'        'Enter  Password
'        Browser("name:=Sign In").Page("title:=Sign In").WebEdit("name:=.*Password.*").Set strPassword
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If
'        
'        'Click on 'Login Button
'        Browser("name:=Sign In").Page("title:=Sign In").WebElement("html id:=submitButton").Click
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Click on Login Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If

        'Checking Login failed
        If Browser("name:=Welcome").Page("title:=Welcome").Exist(15) Then
          strText = Browser("name:=Welcome").Page("title:=Welcome").Link("name:="&strLink).GetROproperty("innertext")
            If Instr(strText, "You have a new home page!") > 1 Then
                pstrStatus="FAILED"
                Exit Function
            End If
        End If
        
        'Sync
        Browser("name:=Welcome").Page("title:=Welcome").Sync
        Wait 5
		Browser("name:=Welcome").Page("title:=Welcome").Sync
        If Err.Number<>0 Then
            Call gfReportExecutionStatus(micFail,"Activate Browser",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
            Exit Function
        End If
	'Click on you have a new Home page !
	 	Browser("name:=Welcome").Page("title:=Welcome").Link("text:="&strLink,"index:=0").Click
	 	Call gfReportExecutionStatus(micPass,"Click Link","Clicked on Link : "&strLink)
	 	Wait 5
	 	If Err.Number<>0 Then
                    Call gfReportExecutionStatus(micFail,"Click on Link",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
                    Exit Function
                End If    

    	pstrStatus="PASSED"
    	OracleSSOLogin = pstrStatus
      Else
	      pstrStatus="FAILED"
	  End If
    End Function ' Login
'########################################################################################################################
''
''           PROGRAM NAME        	=         LOGIN       
''
''########################################################################################################################
''
''           PURPOSE: Login to Oracle Application by directly launching the oracle forms based on the parameter. 
''           Initial State          = Desktop
''           Final State            = OracleNavigator
''           INPUT PARAMETERS       = sstrUserName,strPassword, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow
''           OUTPUT PARAMETERS      = 
''            OWNER                 = DHO
''			Resource					 Date					Remarks
''########################################################################################################################
'
'Function Login(strTabName, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow)
'   'Declaration Part
'   Dim pstrStatus, strURL, bcontinue, intElapsedTime
'
'    Const FUNC_NAME="Login"
'
'    On Error Resume Next
'    pstrStatus="FAILED"
'    strURL = Environment.Value("URL")
'
'    'Get the UserName and Password
'    Select Case UCase(strTabName)
'            Case "MCDEBSUSER"
'                    strUserName = Environment("EBSUserName")
'                    strPassword = Environment("EBSPassword")
'            Case "MCDEBSAPUSER"
'                    strUserName = Environment("EBSAPUserName")
'                    strPassword = Environment("EBSAPPassword")
'            Case "MCDEBSARUSER"
'                    strUserName = Environment("EBSARUserName")
'                    strPassword = Environment("EBSARPassword")
'            Case "MCDEBSARWRITEOFFUSER"
'                    strUserName = Environment("EBSARWriteOffUserName")
'                    strPassword = Environment("EBSARWriteOffPassword")
'            Case "MCDEBSFAUSER"
'                    strUserName = Environment("EBSFAUserName")
'                    strPassword = Environment("EBSFAPassword")
'            Case "MCDEBSGLUSER"
'                    strUserName = Environment("EBSGLUserName")
'                    strPassword = Environment("EBSGLPassword")
'            Case "MCDEBSTCAUSER"
'                    strUserName = Environment("EBSTCAUserName")
'                    strPassword = Environment("EBSTCAPassword")
'            Case "MCDEBSSPUSER"
'                    strUserName = Environment("EBSSPUserName")
'                    strPassword = Environment("EBSSPPassword")
'            Case "MCDEBSPROJECTSUSER"
'                    strUserName = Environment("EBSPROJECTSUserName")
'                    strPassword = Environment("EBSPROJECTSPassword")
'            Case "MCDEBSPROJECTSUSER_1"
'                    strUserName = Environment("EBSPROJECTSUserName_1")
'                    strPassword = Environment("EBSPROJECTSPassword_1")
'            Case "MCDEBSIPROCUSER"
'                    strUserName = Environment("EBSIprocUserName")
'                    strPassword = Environment("EBSIprocPassword")
'            Case "MCDEBSIRECUSER"
'                    strUserName = Environment("EBSIrecUserName")
'                    strPassword = Environment("EBSIrecPassword")
'            Case "MCDEBSIEXPENSEUSER"
'                    strUserName = Environment("EBSIExpenseUserName")
'                    strPassword = Environment("EBSIExpensePassword")
'            Case "MCDEBSIEXPCCUSER"
'                    strUserName = Environment("EBSIExpCCUserName")
'                    strPassword = Environment("EBSIExpCCPassword")
'            Case "MCDEBSAPPROVER1"
'                    strUserName = Environment("EBSApprover1")
'                    strPassword = Environment("EBSApproverPwd1")
'            Case "MCDEBSAPPROVER2"
'                    strUserName = Environment("EBSApprover2")
'                    strPassword = Environment("EBSApproverPwd2")
'	    Case "MCDEBSSSOAPPROVER"
'                    strUserName = Environment("EBSSOUserNameAppr")
'                    strPassword = Environment("EBSSOPasswordAppr")
'            Case "MCDEBSUATUSER1"
'                    strUserName = Environment("EBSUATUserName1")
'                    strPassword = Environment("EBSUATPassword1")
'            Case "MCDEBSUATUSER2"
'                    strUserName = Environment("EBSUATUserName2")
'                    strPassword = Environment("EBSUATPassword2")                                
'            Case "MCDEBSUATUSER1"
'                    strUserName = Environment("EBSUATUserName1")
'                    strPassword = Environment("EBSUATPassword1")
'            Case "MCDEBSiEXPCCDKUSER"
'                    strUserName = Environment("EBSiExpCCUserName")
'                    strPassword = Environment("EBSiExpCCPassword")
'                    
'            Case "MCDEBSUSERIE"
'                    strUserName = Environment("EBSIEUserName")
'                    strPassword = Environment("EBSIEPassword")
'            Case "MCDEBSUSERNO"
'                    strUserName = Environment("EBSNOUserName")
'                    strPassword = Environment("EBSNOPassword")
'			Case "MCDEBSRCMDK"
'                    strUserName = Environment("EBSRCMDKUserName")
'                    strPassword = Environment("EBSRCMDKPassword")	
'                    
'            Case Else
'                    strUserName = Environment("EBSUserName")
'                    strPassword = Environment("EBSPassword")
'                    
'            
'        End Select
'
'        'To get IE browser version
'        Const HKEY_LOCAL_MACHINE = &H80000002
'        strComputer = "."
'        Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
'        strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
'        strValueName = "Version"
'        oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
'        If cInt(Left(strValue,1)) >=8 Then
'            SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
'        Else
'            SystemUtil.Run "iexplore.exe",strURL,"","","3"' for IE7 and below
'        End If
'        
'        If Err.Number<>0 Then
'            On Error GoTo 0
'        End If
'
'    Call gfReportExecutionStatus(micPass,"Launch Browser","Browser Launched with URL    : "&strURL)    
'
'    If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(20) Then
'    
'        'Enter UserName
'        Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Username.*").Set strUserName
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If
'        Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)    
'        'Enter  Password
'        Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Password.*").Set strPassword
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If
'        
'        'Click on 'Login Button
'        Browser("name:=MCD Login").Page("title:=MCD Login").WebButton("name:=Login").Click
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Click on Login Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If
'
'        'Checking Login failed
'        If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(15) Then
'            strText = Browser("name:=MCD Login").Page("title:=MCD Login").Object.body.innerText
'            If Instr(strText, "Invalid user name or password.") > 0 Then
'                pstrStatus="FAILED"
'                Exit Function
'            End If
'        End If
'        
'        'Sync
'        Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Sync
'        Wait 5
'        If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Activate Browser",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'        End If
'
'        If strResponsibility<>"" Then
'            'Click on Responsibility Link
'            Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strResponsibility, "html tag:=A").Click
'            If Err.Number<>0 Then
'                Call gfReportExecutionStatus(micFail,"Select Responsibility","Responsibility '"&strResponsibility&"' is not available for this user")
'                Exit Function
'            End If
'            Call gfReportExecutionStatus(micPass,"Select Responsibility","Selected Responsibility : "&strResponsibility)    
'            Wait 30
'            If strLink <> "" Then
'                Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Sync
'                'Click on Link
'                If Trim(strIndex) = "" Then
'                    Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strLink,"index:=0").Click
'                Else
'                    Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strLink,"index:="&strIndex).Click
'                End If
'
'                Call gfReportExecutionStatus(micPass,"Click Link","Clicked on Link : "&strLink)
'
'                If Err.Number<>0 Then
'                    Call gfReportExecutionStatus(micFail,"Click on Link",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'                End If
'            End If
'
'            If Trim(strFormWindow)<> "" Then
'                bcontinue=True
'                'Starting Mercury Timers
'                MercuryTimers.Timer("Login").Start
'                'Activate FinalWindow
'                While bcontinue
'                    If OracleFormWindow("short title:="&strFormWindow).Exist(15)  Then
'                        bcontinue=False
'                    '=========================================ravikanth.l 08-sep-2014
'                    ElseIf OracleListOfValues("title:="&strFormWindow).Exist(15)  Then
'                        bcontinue=False
'                    ElseIf OracleFlexWindow("title:="&strFormWindow).Exist(15)  Then
'                        bcontinue=False
'                        '=========================================ravikanth.l 08-sep-2014
'                    Else
'                        bcontinue=True
'                        Wait 5
'                    End If
'                    'Elapsed Time
'                    intElapsedTime = MercuryTimers.Timer("Login").ElapsedTime/1000
'                    If intElapsedTime > gTIMEOUT Then
'                        Call gfReportExecutionStatus(micFail,"Login","Login to application is timed out")
'                        pstrStatus="FAILED"
'                        MercuryTimers.Timer("Login").Stop
'                        Login = pstrStatus
'                        Exit Function
'                    End If
'                Wend
'                'Stoping Meruchry Timers
'                MercuryTimers.Timer("Login").Stop
'                Wait 5
'                Call gfReportExecutionStatus(micPass,strFormWindow&" window",strFormWindow& " window is displayed.")
'            Else
'                'Sync
'                Browser("name:="&strBrowserWindow).Page("title:="&strBrowserWindow).Sync
'                Wait 5
'                If Err.Number<>0 Then
'                    Call gfReportExecutionStatus(micFail,"Activate Browser "&strBrowserWindow,FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'                End If
'                Call gfReportExecutionStatus(micPass,strBrowserWindow&" window",strBrowserWindow& " window is displayed.")
'            End If
'        End If
''---------------------------------------ravikanth 14-Jul-2015
'        pstrStatus="PASSED"
'        Login = pstrStatus
''---------------------------------------ravikanth 14-Jul-2015
'    Else
'        pstrStatus="FAILED"
'    End If
''        pstrStatus="PASSED"            '---------------------------------------ravikanth 14-Jul-2015
''        Login = pstrStatus            '---------------------------------------ravikanth 14-Jul-2015
'
'    End Function ' Login
'
''########################################################################################################################
''
''           PROGRAM NAME        	=          SSOLOGIN       
''
''########################################################################################################################
''
''           PURPOSE: Login to Oracle Application by directly launching the oracle forms based on the parameter. 
''           Initial State          = Desktop
''           Final State            = OracleNavigator
''           INPUT PARAMETERS       = sstrUserName,strPassword, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow
''           OUTPUT PARAMETERS      = 
''            OWNER                 = DHO
''			Resource					 Date					Remarks
''########################################################################################################################
'
'Function SSOLogin(strTabName, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow)
'   'Declaration Part
'   Dim pstrStatus, strURL, bcontinue, intElapsedTime
'
'    Const FUNC_NAME="SSOLogin"
'
'	On Error Resume Next
'	pstrStatus="FAILED"
'	strURL = Environment.Value("SSOURL")
'
'    'Get the UserName and Password
'	Select Case UCase(strTabName)
'			Case "MCDEBSSSOUSER"
'					strUserName = Environment("EBSSSOUserName")
'					strPassword = Environment("EBSSSOPassword")
'			Case "MCDEBSSSOIPROCUSER"
'					strUserName = Environment("EBSSSOIprocUserName")
'					strPassword = Environment("EBSSSOIprocPassword")
'			Case "MCDEBSSSOIPROCUSER1"
'					strUserName = Environment("EBSSSOIprocUserName1")
'					strPassword = Environment("EBSSSOIprocPassword1")
'			Case "MCDEBSSSOIPROCUSER2"
'					strUserName = Environment("EBSSSOIprocUserName2")
'					strPassword = Environment("EBSSSOIprocPassword2")
'			Case "MCDEBSSSOIPROCAPPROVER"
'					strUserName = Environment("EBSSSOIprocApprover")
'					strPassword = Environment("EBSSSOIprocApproverPassword")
'			Case "MCDEBSSSOIPROCAPPROVER1"
'					strUserName = Environment("EBSSSOIprocApprover1")
'					strPassword = Environment("EBSSSOIprocApproverPassword1")
'			Case "MCDEBSSSOIRECFRANCHUSER"
'					strUserName = Environment("EBSSSOIRecFranchUserName")
'					strPassword = Environment("EBSSSOIRecFranchPassword")
'			Case "MCDEBSSSOPROJAPPROVER"
'					strUserName = Environment("EBSSSOProjUserName")
'					strPassword = Environment("EBSSSOProjPassword")
'			Case "MCDEBSSSOIPROCMULGBLUSER"
'					strUserName = Environment("EBSSSOIProcMulGBLUserName")
'					strPassword = Environment("EBSSSOIProcMulGBLUserPassword")
'			Case "MCDEBSSSOAPPROVER2"
'					strUserName = Environment("EBSSSOApprover2")
'					strPassword = Environment("EBSSSOApproverPwd2")
'			Case "MCDEBSSSOAPPROVER3" '-------------------------------------------------------ravikanth 17-sep-2014   'also added in Environment file
'					strUserName = Environment("EBSSSOApprover3")
'					strPassword = Environment("EBSSSOApproverPwd3")'--------------------------ravikanth 17-sep-2014
'			Case "MCDEBSIEXPSSOAPPROVER" '----------------------------------------------------ravikanth 8-NOV-2014   'also added in Environment file
'					strUserName = Environment("EBSiExpSSOApprover")
'					strPassword = Environment("EBSiExpSSOApproverPwd")'-----------------------ravikanth 8-NOV-2014
'			Case "MCDEBSIEXPUSER"
'					strUserName = Environment("EBSSSOiExpUserName")
'					strPassword = Environment("EBSSSOiExpPassword")
'			Case "MCDEBSIEXPUSERFIRSTAPPROVER"
'					strUserName = Environment("EBSSSOiExpFirstApprover")
'					strPassword = Environment("EBSSSOiExpFirstApproverPassword")
'			Case "MCDEBSIEXPUSERSECONDAPPROVER"
'					strUserName = Environment("EBSSSOiExpSecondApprover")
'					strPassword = Environment("EBSSSOiExpSecondApproverPassword")
'			Case "MCDEBSSSOJOURNALAPPROVER"
'					strUserName = Environment("EBSSSOJrnlApprover")
'					strPassword = Environment("EBSSSOJrnlApproverPwd")
'			Case "MCDEBSSSSUPERVISORUSER"
'					strUserName = Environment("EBSSSOProjSupervisor")
'					strPassword = Environment("EBSSSOProjSupervisorPwd")
'			Case "MCDEBSIEXPUSERUS"
'					strUserName = Environment("EBSSSOiExpUserNameUS")
'					strPassword = Environment("EBSSSOiExpPasswordUS")
'					
'			Case "MCDEBSIEXPAPPROVERUS"
'					strUserName = Environment("EBSSSOiExpAPPROVERNameUS")
'					strPassword = Environment("EBSSSOiExpAPPROVERPasswordUS")
'
'			Case "MCDEBSISUPPLIERCA"
'					strUserName = Environment("EBSSSOiSupplierUserCA")
'					strPassword = Environment("EBSSSOiSupplierUserPasswordCA")	
'			Case "MCDEBSISUPPLIERUS"
'					strUserName = Environment("EBSSSOiSupplierUserUS")
'					strPassword = Environment("EBSSSOiSupplierUserPasswordUS")	
'
'			Case "MCDEBSISUPPLIERDK"
'					strUserName = Environment("EBSSSOiSupplierUserDK")
'					strPassword = Environment("EBSSSOiSupplierUserPasswordDK")
'			Case "MCDEBSRCMDK"
'                    strUserName = Environment("EBSRCMDKUserName")
'                    strPassword = Environment("EBSRCMDKPassword")	
'			'included Login fn users
'			Case "MCDEBSUSER"
'                    strUserName = Environment("EBSUserName")
'                    strPassword = Environment("EBSPassword")
'            Case "MCDEBSAPUSER"
'                    strUserName = Environment("EBSAPUserName")
'                    strPassword = Environment("EBSAPPassword")
'            Case "MCDEBSARUSER"
'                    strUserName = Environment("EBSARUserName")
'                    strPassword = Environment("EBSARPassword")
'            Case "MCDEBSARWRITEOFFUSER"
'                    strUserName = Environment("EBSARWriteOffUserName")
'                    strPassword = Environment("EBSARWriteOffPassword")
'            Case "MCDEBSFAUSER"
'                    strUserName = Environment("EBSFAUserName")
'                    strPassword = Environment("EBSFAPassword")
'            Case "MCDEBSGLUSER"
'                    strUserName = Environment("EBSGLUserName")
'                    strPassword = Environment("EBSGLPassword")
'            Case "MCDEBSTCAUSER"
'                    strUserName = Environment("EBSTCAUserName")
'                    strPassword = Environment("EBSTCAPassword")
'            Case "MCDEBSSPUSER"
'                    strUserName = Environment("EBSSPUserName")
'                    strPassword = Environment("EBSSPPassword")
'            Case "MCDEBSPROJECTSUSER"
'                    strUserName = Environment("EBSPROJECTSUserName")
'                    strPassword = Environment("EBSPROJECTSPassword")
'            Case "MCDEBSPROJECTSUSER_1"
'                    strUserName = Environment("EBSPROJECTSUserName_1")
'                    strPassword = Environment("EBSPROJECTSPassword_1")
'            Case "MCDEBSIPROCUSER"
'                    strUserName = Environment("EBSIprocUserName")
'                    strPassword = Environment("EBSIprocPassword")
'            Case "MCDEBSIRECUSER"
'                    strUserName = Environment("EBSIrecUserName")
'                    strPassword = Environment("EBSIrecPassword")
'            Case "MCDEBSIEXPENSEUSER"
'                    strUserName = Environment("EBSIExpenseUserName")
'                    strPassword = Environment("EBSIExpensePassword")
'            Case "MCDEBSIEXPCCUSER"
'                    strUserName = Environment("EBSIExpCCUserName")
'                    strPassword = Environment("EBSIExpCCPassword")
'            Case "MCDEBSAPPROVER1"
'                    strUserName = Environment("EBSApprover1")
'                    strPassword = Environment("EBSApproverPwd1")
'            Case "MCDEBSAPPROVER2"
'                    strUserName = Environment("EBSApprover2")
'                    strPassword = Environment("EBSApproverPwd2")
'            Case "MCDEBSUATUSER1"
'                    strUserName = Environment("EBSUATUserName1")
'                    strPassword = Environment("EBSUATPassword1")
'            Case "MCDEBSUATUSER2"
'                    strUserName = Environment("EBSUATUserName2")
'                    strPassword = Environment("EBSUATPassword2")                                
'            Case "MCDEBSUATUSER1"
'                    strUserName = Environment("EBSUATUserName1")
'                    strPassword = Environment("EBSUATPassword1")
'            Case "MCDEBSiEXPCCDKUSER"
'                    strUserName = Environment("EBSiExpCCUserName")
'                    strPassword = Environment("EBSiExpCCPassword")                 
'            Case "MCDEBSUSERIE"
'                    strUserName = Environment("EBSIEUserName")
'                    strPassword = Environment("EBSIEPassword")
'            Case "MCDEBSUSERNO"
'                    strUserName = Environment("EBSNOUserName")
'                    strPassword = Environment("EBSNOPassword")
'	    Case "MCDEBSSSOAPPROVER"
'                    strUserName = Environment("EBSSOUserNameAppr")
'                    strPassword = Environment("EBSSOPasswordAppr")
'			'Login fn users end
'       		Case Else
'					strUserName = Environment("EBSSSOUserName")
'					strPassword = Environment("EBSSSOPassword")
'		End Select
'
'		'To get IE browser version
'        Const HKEY_LOCAL_MACHINE = &H80000002
'		strComputer = "."
'		Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
'		strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
'		strValueName = "Version"
'		oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
'		If cInt(Left(strValue,1)) >=8 Then
'			SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
'		Else
'			SystemUtil.Run "iexplore.exe",strURL,"","","3"' for IE7 and below
'		End If
'        
'		If Err.Number<>0 Then
'			On Error GoTo 0
'		End If
'
'    Call gfReportExecutionStatus(micPass,"Launch Browser","Browser Launched with URL	: "&strURL)	
'
'    If Browser("name:=Login").Page("title:=Login").Exist(15) Then
'	
'		'Enter UserName
'		Browser("name:=Login").Page("title:=Login").WebEdit("name:=usernameField").Set strUserName
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)	
'		'Enter  Password
'		Browser("name:=Login").Page("title:=Login").WebEdit("name:=passwordField*").Set strPassword
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		'Click on 'Login Button
'		Browser("name:=Login").Page("title:=Login").WebButton("name:=Login").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Click on Login Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        'Checking Login failed
'		If Browser("name:=Change Password").Page("title:=Change Password").Exist(15) Then  '-----------------------------------ravikanth 17-sep-2014
'			Set objPage = Browser("name:=Change Password").Page("title:=Change Password")
'			strPassword1 = "summer49"
'			objPage.WebEdit("name:=password").Set strPassword
'			objPage.WebEdit("name:=newPassword").Set strPassword1
'			objPage.WebEdit("name:=newPassword2").Set strPassword1
'			objPage.WebButton("name:=Submit").Click
'		ElseIf Browser("name:=Login").Page("title:=Login").Exist(15) Then					'-----------------------------------ravikanth 17-sep-2014
'		'If Browser("name:=Login").Page("title:=Login").Exist(5) Then
'			strText = Browser("name:=MCD Login").Page("title:=MCD Login").Object.body.innerText
'			If Instr(strText, "Login failed. Please verify your login information or contact the system administrator.") > 0 Then
'				pstrStatus="FAILED"
'				Exit Function
'			End If
'		End If
'        
'        'Sync
'		Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Sync
'		Wait 5
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Activate Browser",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        If strResponsibility<>"" Then
'			'Click on Responsibility Link
'			Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strResponsibility, "html tag:=A").Click
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Select Responsibility","Responsibility '"&strResponsibility&"' is not available for this user")
'                Exit Function
'			End If
'			Call gfReportExecutionStatus(micPass,"Select Responsibility","Selected Responsibility : "&strResponsibility)	
'			Wait 30
'             If strLink <> "" Then
'				
'				'Click on Link
'				If Trim(strIndex) = "" Then
'					Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strLink,"index:=0").Click
'				Else
'					Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strLink,"index:="&strIndex).Click
'				End If
'
'				Call gfReportExecutionStatus(micPass,"Click Link","Clicked on Link : "&strLink)
'
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Click on Link",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'			End If
'
'			If Trim(strFormWindow)<> "" Then
'				bcontinue=True
'				'Starting Mercury Timers
'				MercuryTimers.Timer("Login").Start
'				'Activate FinalWindow
'				While bcontinue
'					If OracleFormWindow("short title:="&strFormWindow).Exist(15)  Then
'                        bcontinue=False
'					Else
'						bcontinue=True
'						Wait 5
'					End If
'					'Elapsed Time
'					intElapsedTime = MercuryTimers.Timer("Login").ElapsedTime/1000
'					If intElapsedTime > gTIMEOUT Then
'						Call gfReportExecutionStatus(micFail,"Login","Login to application is timedout")
'						pstrStatus="FAILED"
'						MercuryTimers.Timer("Login").Stop
'						Login = pstrStatus
'						Exit Function
'					End If
'				Wend
'				'Stoping Meruchry Timers
'				MercuryTimers.Timer("Login").Stop
'				Wait 5
'				Call gfReportExecutionStatus(micPass,strFormWindow&" window",strFormWindow& " window is displayed.")
'			Else
'				'Sync
'				Browser("name:="&strBrowserWindow).Page("title:="&strBrowserWindow).Sync
'				Wait 5
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Activate Browser "&strBrowserWindow,FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,strBrowserWindow&" window",strBrowserWindow& " window is displayed.")
'			End If
'		End If
'	Else
'		pstrStatus="FAILED"
'	End If
'    pstrStatus="PASSED"
'	SSOLogin = pstrStatus
'End Function ' SSOLogin
'
''########################################################################################################################
''
''           PROGRAM NAME        	=          ExternalLogin       
''
''########################################################################################################################
''
''           PURPOSE:
''                                   Login to Oracle Application by directly launching the oracle forms by passing the URL
''                                   
''           Initial State          = Desktop
''           Final State            = OracleNavigator
''           
''           INPUT PARAMETERS       = sstrUserName,strPassword, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow
''           OUTPUT PARAMETERS      = 
'       
''            OWNER                 = DHO
''
''			Resource					 Date					Remarks
''########################################################################################################################
'Function ExternalLogin(strURL,strTabName, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow)
'   'Declaration Part
'   Dim pstrStatus, bcontinue, intElapsedTime
'
'    Const FUNC_NAME="Login"
'
'	On Error Resume Next
'	pstrStatus="FAILED"
''	strURL = "https://external-sdtsx.mcd.com/"
'
'    'Get the UserName and Password
'	Select Case UCase(strTabName)
'			Case "MCDEBSUSER"
'					strUserName = Environment("EBSUserName")
'					strPassword = Environment("EBSPassword")
'			Case "MCDEBSAPUSER"
'					strUserName = Environment("EBSAPUserName")
'					strPassword = Environment("EBSAPPassword")
'			Case "MCDEBSARUSER"
'					strUserName = Environment("EBSARUserName")
'					strPassword = Environment("EBSARPassword")
'			Case "MCDEBSARWRITEOFFUSER"
'					strUserName = Environment("EBSARWriteOffUserName")
'					strPassword = Environment("EBSARWriteOffPassword")
'			Case "MCDEBSFAUSER"
'					strUserName = Environment("EBSFAUserName")
'					strPassword = Environment("EBSFAPassword")
'			Case "MCDEBSGLUSER"
'					strUserName = Environment("EBSGLUserName")
'					strPassword = Environment("EBSGLPassword")
'			Case "MCDEBSTCAUSER"
'					strUserName = Environment("EBSTCAUserName")
'					strPassword = Environment("EBSTCAPassword")
'			Case "MCDEBSSPUSER"
'					strUserName = Environment("EBSSPUserName")
'					strPassword = Environment("EBSSPPassword")
'			Case "MCDEBSPROJECTSUSER"
'					strUserName = Environment("EBSPROJECTSUserName")
'					strPassword = Environment("EBSPROJECTSPassword")
'			Case "MCDEBSIPROCUSER"
'					strUserName = Environment("EBSIprocUserName")
'					strPassword = Environment("EBSIprocPassword")
'			Case "MCDEBSIRECUSER"
'					strUserName = Environment("EBSIrecUserName")
'					strPassword = Environment("EBSIrecPassword")
'			Case "MCDEBSIEXPENSEUSER"
'					strUserName = Environment("EBSIExpenseUserName")
'					strPassword = Environment("EBSIExpensePassword")
'			Case "MCDEBSIEXPCCUSER"
'					strUserName = Environment("EBSIExpCCUserName")
'					strPassword = Environment("EBSIExpCCPassword")
'			Case "MCDEBSAPPROVER1"
'					strUserName = Environment("EBSApprover1")
'					strPassword = Environment("EBSApproverPwd1")
'			Case "MCDEBSAPPROVER2"
'					strUserName = Environment("EBSApprover2")
'					strPassword = Environment("EBSApproverPwd2")
'			Case Else
'					strUserName = Environment("EBSUserName")
'					strPassword = Environment("EBSPassword")
'		End Select
'
'
'		'To get IE browser version
'        Const HKEY_LOCAL_MACHINE = &H80000002
'		strComputer = "."
'		Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
'		strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
'		strValueName = "Version"
'		oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
'		If cInt(Left(strValue,1)) >=8 Then
'			SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
'		Else
'			SystemUtil.Run "iexplore.exe",strURL,"","","3"' for IE7 and below
'		End If
'        
'		If Err.Number<>0 Then
'			On Error GoTo 0
'		End If
'
'    Call gfReportExecutionStatus(micPass,"Launch Browser","Browser Launched with URL	: "&strURL)	
'
'    If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(10) Then
'	
'		'Enter UserName
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Username.*").Set strUserName
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)	
'		'Enter  Password
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Password.*").Set strPassword
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		'Click on 'Login Button
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebButton("name:=Login").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Click on Login Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		Wait(15)
'
'        'Checking Login failed
'		If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(0) Then
'			strText = Browser("name:=MCD Login").Page("title:=MCD Login").Object.body.innerText
'			If Instr(strText, "Invalid user name or password.") > 0 Then
'				pstrStatus="FAILED"
'				Exit Function
'			End If
'		End If
'        Wait(15)
'        'Sync
'		Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Sync
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Activate Browser",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        If strResponsibility<>"" Then
'			Wait 10
'			'Click on Responsibility Link
'			Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strResponsibility, "html tag:=A").Click
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Select Responsibility","Responsibility '"&strResponsibility&"' is not available for this user")
'                Exit Function
'			End If
'			Call gfReportExecutionStatus(micPass,"Select Responsibility","Selected Responsibility : "&strResponsibility)	
'             If strLink <> "" Then
'				 Wait 30
'				'Click on Link
'				If Trim(strIndex) = "" Then
'					Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strLink,"index:=0").Click
'				Else
'					Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link("text:="&strLink,"index:="&strIndex).Click
'				End If
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Click on Link",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'			End If
'
'			If Trim(strFormWindow)<> "" Then
'				bcontinue=True
'				'Starting Mercury Timers
'				MercuryTimers.Timer("Login").Start
'				'Activate FinalWindow
'				While bcontinue
'					If OracleFormWindow("short title:="&strFormWindow).Exist(1)  Then
'                        bcontinue=False
'					Else
'						bcontinue=True
'						Wait 5
'					End If
'					'Elapsed Time
'					intElapsedTime = MercuryTimers.Timer("Login").ElapsedTime/1000
'					If intElapsedTime > gTIMEOUT Then
'						Call gfReportExecutionStatus(micFail,"Login","Login to application is timedout")
'						pstrStatus="FAILED"
'						MercuryTimers.Timer("Login").Stop
'						Login = pstrStatus
'						Exit Function
'					End If
'				Wend
'				'Stoping Meruchry Timers
'				MercuryTimers.Timer("Login").Stop
'				Wait 5
'				Call gfReportExecutionStatus(micPass,strFormWindow&" window",strFormWindow& " window is displayed.")
'			Else
'				Wait 5
'				'Sync
'				Browser("name:="&strBrowserWindow).Page("title:="&strBrowserWindow).Sync
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Activate Browser "&strBrowserWindow,FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,strBrowserWindow&" window",strBrowserWindow& " window is displayed.")
'			End If
'		End If
'	Else
'		pstrStatus="FAILED"
'	End If
'    pstrStatus="PASSED"
'	ExternalLogin = pstrStatus
'End Function ' Login
'
'
'
'
''########################################################################################################################
''
''           PROGRAM NAME        	=         SWITCH RESPONSIBILITY
''
''########################################################################################################################
''
''           PURPOSE: To Switch the Responsibility  based on the Specified  parameter. 
''           Initial State           = OracleNavigator
''           Final State             = OracleNavigator
''           INPUT PARAMETERS        = strResponsibility
''           OUTPUT PARAMETERS       = 
''            MODULES CALLED         = Scenario.lib, generic.lib
''            OWNER                  = DOH
''			Resource					 Date					Remarks
''########################################################################################################################
'
'Function SwitchResponsibility(strSwitchResponsibility)
'	Dim pstrStatus, pstrStatusMsg
'    
'	Const FUNC_NAME = "Switch Responsibility"
'    
'	On Error Resume Next
'	pstrStatus = "FAILED"
'	
'    'Select Switch Responsibility
'	OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'	If Err.Number<>0 Then
'        Call gfReportExecutionStatus(micFail,"Select Menu ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'        Exit Function
'	End If
'
'	If OracleListOfValues("title:=Responsibilities").Exist(5) Then
'		'Select the specified Responsibility
'		OracleListOfValues("title:=Responsibilities").Select strSwitchResponsibility
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Switch Responsibility ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		Call gfReportExecutionStatus(micPass,"Switch Responsibility","Selected Responsibility is: "&strSwitchResponsibility)
'	End If
'    pstrStatus="PASSED"
'
'End Function
'
''########################################################################################################################
''
''           PROGRAM NAME        	=         RUN REQUEST
''
''########################################################################################################################
''
''           PURPOSE:
''                                   The Purpose of this function is to submit a request via Oracle Applications with the flexiblity of:
''		                            - Any type of navigation whether it be Menu or Navigator
''		                            - Ability to handle various windows for which Requests are sent 
''		                            - Ability to enter any no. of parameters
''                                    
''           INPUT PARAMETERS        = StepID, BrowserName, FormName, TabName, strRequestName, intParamCount, strParameterName, strParameterValue, 
''																		strViewOutput, strViewLog
''           OUTPUT PARAMETERS       = intRequestNo
''           MODULES CALLED          = 
''           OWNER                   =          DHO
''			Resource					 Date					Remarks
''########################################################################################################################
'
'Function bfuncRunRequest(StepID, BrowserName, FormName, TabName, strRequestName, intParamCount, strParameterName, strParameterValue, strViewOutput, strViewLog)
'
'		'Declaration
'		Dim intRequestNo, strPhase, strStatus, strMessage, pstrStatus
'		Const FUNC_NAME="Run Request"
'		
'		On Error resume next
'		pstrStatus="FAILED"
'        	
'        If Ucase(FormName)="NAVIGATOR" Then
'            'Navigate To 'View->Requests"
'			OracleNavigator("short title:=Navigator").SelectMenu "View->Requests"
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'			'Click on 'Submit a New Request...
'			OracleFormWindow("short title:=Find Requests").OracleButton("label:=Submit a New Request...").Click
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'		End If
'		'Click on 'OK' button.
'		OracleFormWindow("short title:=Submit a New Request").OracleButton("label:=OK").Click
'		If Err.Number<>0 Then
'		   Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		'Submit Request Window
'		If OracleFormWindow("short title:=Submit Request").Exist(gSYNCWAIT) Then
'        	Call gfReportExecutionStatus(micPass,"Submit Request window","Submit Request window is displayed")
'		End If
'
'		If InStr(strRequestName,"<<") > 0 Then
'			strRequestName = Replace(Replace(strRequestName,"<<",""),">>","") 
'			strRequestName = rsTestCaseData(strRequestName).Value
'		End If
'
'		'Enter Request Name
'		OracleFormWindow("short title:=Submit Request").OracleTextField("description:=Name").Enter strRequestName
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'		'Request Name
'		Call gfReportExecutionStatus(micPass,"Enter Request Name","Request Name : '"&strRequestName&"'")
'        If (intParamCount>0 ) Then
'				
'			' Parse parrParameterID if it contain "." 
'				If Instr(strParameterName,";") > 0 Then
'					arrParamName = Split(strParameterName,";")
'					arrParamValue = Split(strParameterValue,";")
'				Else
'					ReDim arrParamName(iPIndex), arrParamValue(iPIndex)
'					arrParamName(iPIndex) = strParameterName
'					arrParamValue(iPIndex) = strParameterValue
'				End If
'
'			' Enter Parameters
'			For iPIndex=0 To intParamCount-1
'                'Enter 'Parameter
'				OracleFlexWindow("title:=Parameters").OracleTextField("prompt:="&arrParamName(iPIndex)).Enter arrParamValue(iPIndex)
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				If OracleListOfValues("title:="&arrParamName(iPIndex)).Exist(1) Then
'					OracleListOfValues("title:="&arrParamName(iPIndex)).Select 1
'				End If
'				'Parameter Name
'				Call gfReportExecutionStatus(micPass,"Enter Parameter "&arrParamName(iPIndex),arrParamName(iPIndex)&" : "&arrParamValue(iPIndex))	
'			 Next ' End For
'			 'Click on 'OK'
'			OracleFlexWindow("title:=Parameters").OracleButton("label:=OK").Click
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'		Else
'			If OracleFlexWindow("title:=Parameters").Exist(gSYNCWAIT) Then
'        		'Click on 'OK'
'				OracleFlexWindow("title:=Parameters").OracleButton("label:=OK").Click
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'			End If
'		End If 
'
'        'Click on 'Submit' button
'		OracleFormWindow("short title:=Submit Request").OracleButton("label:=Submit").Click
'		Wait 10
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'		'Check for Caution notification
'		If OracleNotification("title:=Caution").Exist(gSYNCWAIT) Then
'			'Click on 'OK' button
'			OracleNotification("title:=Caution").Approve
'		End If
'
'		If OracleFormWindow("short title:=Requests").Exist(5) Then
'			'Get Request Id from 'Requests' window
'			intRequestNo= OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS").GetFieldValue(1,"Request ID")   
'			If intRequestNo<>"" Then
'				'Request No
'				Call gfReportExecutionStatus(micPass,"Submit Request","'"&strRequestName&"' is submitted. Request ID  : "&intRequestNo)
'				'Store the value in Global dict
'				dicGlobalOutput.Add StepID,intRequestNo
'			Else
'				Call gfReportExecutionStatus(micFail,"Submit Request","'"&strRequestName&" is not submitted. Request ID  : "&intRequestNo)
'				Exit Function
'			End If
'		End If
'
'		'Click on 'Find Requests' button
'		OracleFormWindow("short title:=Requests").OracleButton("label:=Find Requests").Click
'		If Err.Number<>0 Then
'		   Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'			Exit Function
'		End If
'
'		'Selet Specific Requests
'		OracleFormWindow("short title:=Find Requests").OracleRadioGroup("selected item:=All My Requests").Select 4
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        'Enter Request Number
'		OracleFormWindow("short title:=Find Requests").OracleTextField("description:=Request ID").Enter intRequestNo
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'			Exit Function
'		End If
'
'		'Click on 'Find' button
'		OracleFormWindow("short title:=Find Requests").OracleButton("label:=Find").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'			Exit Function
'		End If
'
'	'Check Phase and Status
'	Set objRequest = OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS")
'	If objRequest.Exist(gLONGWAIT) Then
'		'Get Phase
'		strPhase = objRequest.GetFieldValue(1,"Phase")
'		'Get Status
'		strStatus = objRequest.GetFieldValue(1,"Status")
'		intRequestTimeOut = 1
'        Do While intRequestTimeOut<3600 'Increased to 1 hr due to application requests issue
'		'Do While intRequestTimeOut<600 
'			If strPhase="Completed" And (strStatus="Normal" or strStatus="Warning") Then
'				Call gfReportExecutionStatus(micPass,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'				Exit Do
'			ElseIf strStatus="Error" or strStatus="No Manager"Then
'				Call gfReportExecutionStatus(micFail,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'                Exit Function
'			End If
'			Wait 3
'			'Click on Refresh button
'			OracleFormWindow("short title:=Requests").OracleButton("description:=Refresh Data").Click
'			strPhase = objRequest.GetFieldValue(1,"Phase")
'			strStatus = objRequest.GetFieldValue(1,"Status")
'			intRequestTimeOut = intRequestTimeOut + 1
'		Loop 'Do 
'		'Check if request is timedout
'		If intRequestTimeOut>=3600 Then 'Increased to 1 hr due to application requests issue
'		'If intRequestTimeOut>=600 Then
'			Call gfReportExecutionStatus(micFail,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'			Call gfReportExecutionStatus(micFail,"Request Timed Out","Request has been timed out. Timeout value : "&(intRequestTimeOut*3)& " secs")
'			Exit Function
'		End If
'
'		If strPhase="Completed" And strStatus="Normal" Then
'		
'			'Check View Output
'			If UCase(strViewOutput) = "VIEWOUTPUT" Then
'				'Click on 'View Output' button
'				OracleFormWindow("short title:=Requests").OracleButton("description:=View Output").click
'				If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'					strMessage = OracleNotification("title:=Note").GetROProperty("message")
'					'Click on 'OK' button
'					OracleNotification("title:=Note").Approve
'					Call gfReportExecutionStatus(micPass,"View Output",strMessage)
'				Else
'					If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'						Wait gSYNCWAIT
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Saves the output file
'						Call SaveViewOutputFile(intRequestNo, strViewOutput)
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Close the 'View Out' browser window
'						Browser("title:=.*temp_id.*").CloseAllTabs
'						Call gfReportExecutionStatus(micPass,"View Output","View Output has been displayed successfully.")
'					Else
'						'------------------------------------------------------ravikanth 13-Jul-2015
'						Call gfReportExecutionStatus(micPass,"View Output","Failed to display View Output for this request. File type may be of 'Excel' or 'Word'. Need to manually save Output.")
'						'------------------------------------------------------ravikanth 13-Jul-2015
'					End If
'				End If
'			End If
'		
'			If UCase(strViewLog) = "VIEWLOG" Then
'				'Click on 'View Log' button
'				OracleFormWindow("short title:=Requests").OracleButton("description:=View Log...").click
'				If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'					strMessage = OracleNotification("title:=Note").GetROProperty("message")
'					'Click on 'OK' button
'					OracleNotification("title:=Note").Approve
'					Call gfReportExecutionStatus(micPass,"View Output",strMessage)
'				Else
'					If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'						Wait gSYNCWAIT
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Saves the output file
'						Call SaveViewOutputFile(intRequestNo, strViewLog)
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Close the 'View Out' browser window
'						Browser("title:=.*temp_id.*").CloseAllTabs
'						Call gfReportExecutionStatus(micPass,"View Log","View Log has been displayed successfully.")
'					Else
'						Call gfReportExecutionStatus(micFail,"View Log","Failed to display View Log for this request.")
'					End If
'				End If
'			End If
'		End If
'	'Close Requests Form
'	OracleFormWindow("short title:=Requests").CloseWindow
'	End If 
'    pstrStatus="PASSED"   
'End Function 'bfuncRunRequest
'
'
''########################################################################################################################
''
''           PROGRAM NAME        	=         RUN REQUEST NO TIMEOUT
''
''########################################################################################################################
''
''           PURPOSE:
''                                   The Purpose of this function is to submit a request via Oracle Applications with the flexiblity of:
''		                            - Any type of navigation whether it be Menu or Navigator
''		                            - Ability to handle various windows for which Requests are sent 
''		                            - Ability to enter any no. of parameters
''
''           INPUT PARAMETERS        = StepID, BrowserName, FormName, TabName, strRequestName, intParamCount, strParameterName, strParameterValue, 
''																		strViewOutput, strViewLog
''           OUTPUT PARAMETERS       = intRequestNo
''           MODULES CALLED          = 
''           OWNER                   =          DHO
''			Resource					 Date					Remarks
''########################################################################################################################
'
'Function bfuncRunRequestNoTimeout(StepID, BrowserName, FormName, TabName, strRequestName, intParamCount, strParameterName, strParameterValue, strViewOutput, strViewLog)
'
'		'Declaration
'		Dim intRequestNo, strPhase, strStatus, strMessage, pstrStatus
'		Const FUNC_NAME="Run Request"
'		
'		On Error resume next
'		pstrStatus="FAILED"
'        	
'        If Ucase(FormName)="NAVIGATOR" Then
'            'Navigate To 'View->Requests"
'			OracleNavigator("short title:=Navigator").SelectMenu "View->Requests"
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'			'Click on 'Submit a New Request...
'			OracleFormWindow("short title:=Find Requests").OracleButton("label:=Submit a New Request...").Click
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'		End If
'		'Click on 'OK' button.
'		OracleFormWindow("short title:=Submit a New Request").OracleButton("label:=OK").Click
'		If Err.Number<>0 Then
'		   Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		'Submit Request Window
'		If OracleFormWindow("short title:=Submit Request").Exist(gSYNCWAIT) Then
'        	Call gfReportExecutionStatus(micPass,"Submit Request window","Submit Request window is displayed")
'		End If
'	
'		'Enter Request Name
'		OracleFormWindow("short title:=Submit Request").OracleTextField("description:=Name").Enter strRequestName
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'		'Request Name
'		Call gfReportExecutionStatus(micPass,"Enter Request Name","Request Name : '"&strRequestName&"'")	
'        If (intParamCount>0 ) Then
'				
'			' Parse parrParameterID if it contain "." 
'				If Instr(strParameterName,";") > 0 Then
'					arrParamName = Split(strParameterName,";")
'					arrParamValue = Split(strParameterValue,";")
'				Else
'					ReDim arrParamName(iPIndex), arrParamValue(iPIndex)
'					arrParamName(iPIndex) = strParameterName
'					arrParamValue(iPIndex) = strParameterValue
'				End If
'
'			' Enter Parameters
'			For iPIndex=0 To intParamCount-1
'                'Enter 'Parameter
'				OracleFlexWindow("title:=Parameters").OracleTextField("prompt:="&arrParamName(iPIndex)).Enter arrParamValue(iPIndex)
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				If OracleListOfValues("title:="&arrParamName(iPIndex)).Exist(1) Then
'					OracleListOfValues("title:="&arrParamName(iPIndex)).Select 1
'				End If
'				'Parameter Name
'				Call gfReportExecutionStatus(micPass,"Enter Parameter "&arrParamName(iPIndex),arrParamName(iPIndex)&" : "&arrParamValue(iPIndex))	
'			 Next ' End For
'			 'Click on 'OK'
'			OracleFlexWindow("title:=Parameters").OracleButton("label:=OK").Click
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'		Else
'			If OracleFlexWindow("title:=Parameters").Exist(gSYNCWAIT) Then
'        		'Click on 'OK'
'				OracleFlexWindow("title:=Parameters").OracleButton("label:=OK").Click
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'			End If
'		End If 
'
'        'Click on 'Submit' button
'		OracleFormWindow("short title:=Submit Request").OracleButton("label:=Submit").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'		'Check for Caution notification
'		If OracleNotification("title:=Caution").Exist(gSYNCWAIT) Then
'			'Click on 'OK' button
'			OracleNotification("title:=Caution").Approve
'		End If
'
'		If OracleFormWindow("short title:=Requests").Exist(0) Then
'			'Get Request Id from 'Requests' window
'			intRequestNo= OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS").GetFieldValue(1,"Request ID")   
'			If intRequestNo<>"" Then
'				'Request No
'				Call gfReportExecutionStatus(micPass,"Submit Request","'"&strRequestName&"' is submitted. Request ID  : "&intRequestNo)
'				'Store the value in Global dict
'				dicGlobalOutput.Add StepID,intRequestNo
'			Else
'				Call gfReportExecutionStatus(micFail,"Submit Request","'"&strRequestName&" is not submitted. Request ID  : "&intRequestNo)
'				Exit Function
'			End If
'		End If
'
'		'Click on 'Find Requests' button
'		OracleFormWindow("short title:=Requests").OracleButton("label:=Find Requests").Click
'		If Err.Number<>0 Then
'		   Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'			Exit Function
'		End If
'
'		'Selet Specific Requests
'		OracleFormWindow("short title:=Find Requests").OracleRadioGroup("selected item:=All My Requests").Select 4
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        'Enter Request Number
'		OracleFormWindow("short title:=Find Requests").OracleTextField("description:=Request ID").Enter intRequestNo
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'			Exit Function
'		End If
'
'		'Click on 'Find' button
'		OracleFormWindow("short title:=Find Requests").OracleButton("label:=Find").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'			Exit Function
'		End If
'
'	'Check Phase and Status
'	Set objRequest = OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS")
'	If objRequest.Exist(gLONGWAIT) Then
'		'Get Phase
'		strPhase = objRequest.GetFieldValue(1,"Phase")
'		'Get Status
'		strStatus = objRequest.GetFieldValue(1,"Status")
'		intRequestTimeOut = 1
'        Do While intRequestTimeOut>0 
'			If strPhase="Completed" And (strStatus="Normal" or strStatus="Warning") Then
'				Call gfReportExecutionStatus(micPass,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'				Exit Do
'			ElseIf strStatus="Error" or strStatus="No Manager" Then
'				Call gfReportExecutionStatus(micFail,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'                Exit Function
'			End If
'			Wait 3
'			'Click on Refresh button
'			OracleFormWindow("short title:=Requests").OracleButton("description:=Refresh Data").Click
'			strPhase = objRequest.GetFieldValue(1,"Phase")
'			strStatus = objRequest.GetFieldValue(1,"Status")
'			intRequestTimeOut = intRequestTimeOut + 1
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Run Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'				Exit Function
'			End If
'		Loop 'Do 
''		'Check if request is timedout
''		If intRequestTimeOut>=600 Then
''			Call gfReportExecutionStatus(micFail,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
''			Call gfReportExecutionStatus(micFail,"Request Timed Out","Request has been timed out. Timeout value : "&(intRequestTimeOut*3)& " secs")
''			Exit Function
''		End If
'
'		If strPhase="Completed" And strStatus="Normal" Then
'		
'			'Check View Output
'			If UCase(strViewOutput) = "VIEWOUTPUT" Then
'				'Click on 'View Output' button
'				OracleFormWindow("short title:=Requests").OracleButton("description:=View Output").click
'				If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'					strMessage = OracleNotification("title:=Note").GetROProperty("message")
'					'Click on 'OK' button
'					OracleNotification("title:=Note").Approve
'					Call gfReportExecutionStatus(micPass,"View Output",strMessage)
'				Else
'					If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'						Wait gSYNCWAIT
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Saves the output file
'						Call SaveViewOutputFile(intRequestNo, strViewOutput)
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Close the 'View Out' browser window
'						Browser("title:=.*temp_id.*").CloseAllTabs
'						Call gfReportExecutionStatus(micPass,"View Output","View Output has been displayed successfully.")
'					Else
'						'------------------------------------------------------ravikanth 13-Jul-2015
'						Call gfReportExecutionStatus(micPass,"View Output","Failed to display View Output for this request. File type may be of 'Excel' or 'Word'. Need to manually save Output.")
'						'------------------------------------------------------ravikanth 13-Jul-2015
'					End If
'				End If
'			End If
'		
'			If UCase(strViewLog) = "VIEWLOG" Then
'				'Click on 'View Log' button
'				OracleFormWindow("short title:=Requests").OracleButton("description:=View Log...").click
'				If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'					strMessage = OracleNotification("title:=Note").GetROProperty("message")
'					'Click on 'OK' button
'					OracleNotification("title:=Note").Approve
'					Call gfReportExecutionStatus(micPass,"View Output",strMessage)
'				Else
'					If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'						Wait gSYNCWAIT
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Saves the output file
'						Call SaveViewOutputFile(intRequestNo, strViewLog)
'						'----------------------------------------------------ravikanth 08-Jul-2015
'						'Close the 'View Out' browser window
'						Browser("title:=.*temp_id.*").CloseAllTabs
'						Call gfReportExecutionStatus(micPass,"View Log","View Log has been displayed successfully.")
'					Else
'						Call gfReportExecutionStatus(micFail,"View Log","Failed to display View Log for this request.")
'					End If
'				End If
'			End If
'		End If
'	'Close Requests Form
'	OracleFormWindow("short title:=Requests").CloseWindow
'	End If 
'    pstrStatus="PASSED"   
'End Function 'bfuncRunRequestNoTimeout
'
''########################################################################################################################
''
''           PROGRAM NAME        	=         VIEW REQUEST
''
''########################################################################################################################
''
''           PURPOSE:
''                                   Navigate to "Find Request" window from "View->Request" menu option. Enter the 
''									values to find the request. Wait for the request to complete. If "View Output" 
''									parameter is not given than it won't check the output, if "View Output" parameter is given 
''									then it will check  the expeted string in the out put . Similar for "View Log Pages.
''
''           INPUT PARAMETERS        = StepID, BrowserName, FormName, TabName, strType, strRequestNo, strViewOutput, strOutputSearchString, 
''																		strViewLog, strLogSearchString
''           OUTPUT PARAMETERS       = 
''           MODULES CALLED          = 
''           OWNER                   =          DHO
''			Resource					 Date					Remarks
''
''########################################################################################################################
'
'Function bfuncViewRequest(StepID, BrowserName, FormName, TabName, strType, strRequestNo, strViewOutput, strOutputSearchString, strViewLog, strLogSearchString)
'
'		'Declaration
'		Dim intRequestNo, strPhase, strStatus, strMessage, pstrStatus, strBodyText
'		
'		Const FUNC_NAME="View Request"
'		
'		On Error resume next
'		pstrStatus="FAILED"
'        	
'        If Ucase(FormName)="NAVIGATOR" Then
'            'Navigate To 'View->Requests"
'			OracleNavigator("short title:=Navigator").SelectMenu "View->Requests"
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'
'			'Submit Request Window
'			If OracleFormWindow("short title:=Find Requests").Exist(gSYNCWAIT) Then
'				Call gfReportExecutionStatus(micPass,"Find Requests window","Find Requests window is displayed")
'			End If
'
'			'Selet Specific Requests
'			OracleFormWindow("short title:=Find Requests").OracleRadioGroup("selected item:=All My Requests").Select 4
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'            If UCase(strType) = "REQUESTNAME" Then
'				'Enter Request Name
'				OracleFormWindow("short title:=Find Requests").OracleTextField("description:=Name").Enter strRequestNo
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,"Enter Request Name","Request Name is : "&strRequestNo)
'			Else
'				'Enter 'Request Number 
'				OracleFormWindow("short title:=Find Requests").OracleTextField("description:=Request ID").Enter strRequestNo
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,"Enter Request Number","Request Number is : "&strRequestNo)
'			End If
'            		
'			'Click on 'Find' button
'			OracleFormWindow("short title:=Find Requests").OracleButton("label:=Find").Click
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'		End If
'
'		Wait 5
'		'Handle Cancel Query popup window
'		While JavaWindow("title:=Oracle Applications.*").JavaInternalFrame("title:=Cancel Query").Exist 
'			Wait gSYNCWAIT
'		Wend
'            
'		If OracleFormWindow("short title:=Requests").Exist(0) Then
'			'Get Request Id from 'Requests' window
'			intRequestNo= OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS").GetFieldValue(1,"Request ID")   
'			If intRequestNo<>"" Then
'			
'				'Check Phase and Status
'				Set objRequest = OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS")
'				If objRequest.Exist(gLONGWAIT) Then
'					'Get Phase
'					strPhase = objRequest.GetFieldValue(1,"Phase")
'					'Get Status
'					strStatus = objRequest.GetFieldValue(1,"Status")
'					intRequestTimeOut = 1
'					Do While intRequestTimeOut<600 
'						If strPhase="Completed" And (strStatus="Normal" or strStatus="Warning") Then
'							Call gfReportExecutionStatus(micPass,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'							Exit Do
'						ElseIf strStatus="Error" or strStatus="No Manager" Then
'							Call gfReportExecutionStatus(micFail,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'							Exit Do
'						End If
'						Wait 3
'						'Click on Refresh button
'						OracleFormWindow("short title:=Requests").OracleButton("description:=Refresh Data").Click
'						strPhase = objRequest.GetFieldValue(1,"Phase")
'						strStatus = objRequest.GetFieldValue(1,"Status")
'						intRequestTimeOut = intRequestTimeOut + 1
'					Loop 'Do 
'					'Check if request is timedout
'					If intRequestTimeOut>=600 Then
'						Call gfReportExecutionStatus(micFail,"Request Timed Out","Request has been timed out. Timeout value : "&(intRequestTimeOut*3)& " secs")
'						Exit Function
'					End If
'			
'					If strPhase="Completed" Then
'					
'						'Check View Output
'						If UCase(strViewOutput) = "VIEWOUTPUT" Then
'							'Click on 'View Output' button
'							OracleFormWindow("short title:=Requests").OracleButton("description:=View Output").click
'							If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'								strMessage = OracleNotification("title:=Note").GetROProperty("message")
'								'Click on 'OK' button
'								OracleNotification("title:=Note").Approve
'								Call gfReportExecutionStatus(micPass,"View Output",strMessage)
'							Else
'								If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'									Wait gSYNCWAIT
'									Call gfReportExecutionStatus(micPass,"View Output","View Output has been displayed successfully.")
'									If strOutputSearchString<> "" Then
'										'Body Text
'										strBodyText = Browser("title:=.*temp_id.*").Page("name:=.*").Object.body.innerText
'                                        If Instr(strBodyText,strOutputSearchString) > 0 Then
'                                            Call gfReportExecutionStatus(micPass,"Verify Request Output","Request Output contains '"&strOutputSearchString&"' text.")
'										Else
'											Call gfReportExecutionStatus(micFail,"Verify Request Output","Request Output does not contains '"&strOutputSearchString&"' text.")
'										End If
'									End If
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Saves the output file
'									Call SaveViewOutputFile(intRequestNo, strViewOutput)
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Close the 'View Out' browser window
'									Browser("title:=.*temp_id.*").CloseAllTabs
'								Else
'									'------------------------------------------------------ravikanth 13-Jul-2015
'									Call gfReportExecutionStatus(micPass,"View Output","Failed to display View Output for this request. File type may be of 'Excel' or 'Word'. Need to manually save Output.")
'									'------------------------------------------------------ravikanth 13-Jul-2015
'								End If
'							End If
'						End If
'					
'						If UCase(strViewLog) = "VIEWLOG" Then
'							'Click on 'View Log' button
'							OracleFormWindow("short title:=Requests").OracleButton("description:=View Log...").click
'							If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'								strMessage = OracleNotification("title:=Note").GetROProperty("message")
'								'Click on 'OK' button
'								OracleNotification("title:=Note").Approve
'								Call gfReportExecutionStatus(micPass,"View Log",strMessage)
'							Else
'								If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'									Wait gSYNCWAIT
'									Call gfReportExecutionStatus(micPass,"View Log","View Log has been displayed successfully.")
'									If strLogSearchString<> "" Then
'										'Body Text
'										strBodyText = Browser("title:=.*temp_id.*").Page("name:=.*").Object.body.innerText
'                                        If Instr(strBodyText,strLogSearchString) > 0 Then
'                                            Call gfReportExecutionStatus(micPass,"Verify Request Log","Request Log contains '"&strLogSearchString&"' text.")
'										Else
'											Call gfReportExecutionStatus(micFail,"Verify Request Log","Request Log does not contains '"&strLogSearchString&"' text.")
'										End If
'									End If
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Saves the log file
'									Call SaveViewOutputFile(intRequestNo, strViewLog)
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Close the 'View Out' browser window
'									Browser("title:=.*temp_id.*").CloseAllTabs
'								Else
'									Call gfReportExecutionStatus(micFail,"View Log","Failed to display View Log for this request.")
'								End If
'							End If
'						End If
'					End If
'				End If
'			Else
'				Call gfReportExecutionStatus(micFail,"Request Number","'"&strRequestNo&"' is not available")
'				Exit Function
'			End If
'        	'Close Requests Form
'			OracleFormWindow("short title:=Requests").CloseWindow
'		End If
'        pstrStatus="PASSED"   
'End Function 'bfuncViewRequest
'
''########################################################################################################################
''
''           PROGRAM NAME        	=         VIEW REQUEST NO TIMEOUT
''
''########################################################################################################################
''
''           PURPOSE:
''                                   Navigate to "Find Request" window from "View->Request" menu option. Enter the 
''									values to find the request. Wait for the request to complete. If "View Output" 
''									parameter is not given than it won't check the output, if "View Output" parameter is given 
''									then it will check  the expeted string in the out put . Similar for "View Log Pages.
''
''           INPUT PARAMETERS        = StepID, BrowserName, FormName, TabName, strType, strRequestNo, strViewOutput, strOutputSearchString, 
''																		strViewLog, strLogSearchString
''           OUTPUT PARAMETERS       = 
''           MODULES CALLED          = 
''           OWNER                   =          DHO
''			Resource					 Date					Remarks
'
''########################################################################################################################
'
'Function bfuncViewRequestNoTimeout(StepID, BrowserName, FormName, TabName, strType, strRequestNo, strViewOutput, strOutputSearchString, strViewLog, strLogSearchString)
'
'		'Declaration
'		Dim intRequestNo, strPhase, strStatus, strMessage, pstrStatus, strBodyText
'		
'		Const FUNC_NAME="View Request"
'		
'		On Error resume next
'		pstrStatus="FAILED"
'        	
'        If Ucase(FormName)="NAVIGATOR" Then
'            'Navigate To 'View->Requests"
'			OracleNavigator("short title:=Navigator").SelectMenu "View->Requests"
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'
'			'Submit Request Window
'			If OracleFormWindow("short title:=Find Requests").Exist(gSYNCWAIT) Then
'				Call gfReportExecutionStatus(micPass,"Find Requests window","Find Requests window is displayed")
'			End If
'
'			'Selet Specific Requests
'			OracleFormWindow("short title:=Find Requests").OracleRadioGroup("selected item:=All My Requests").Select 4
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'            If UCase(strType) = "REQUESTNAME" Then
'				'Enter Request Name
'				OracleFormWindow("short title:=Find Requests").OracleTextField("description:=Name").Enter strRequestNo
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,"Enter Request Name","Request Name is : "&strRequestNo)
'			Else
'				'Enter 'Request Number 
'				OracleFormWindow("short title:=Find Requests").OracleTextField("description:=Request ID").Enter strRequestNo
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,"Enter Request Number","Request Number is : "&strRequestNo)
'			End If
'            		
'			'Click on 'Find' button
'			OracleFormWindow("short title:=Find Requests").OracleButton("label:=Find").Click
'			If Err.Number<>0 Then
'               Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                Exit Function
'			End If
'			
'			Wait 60
'			
'		End If
'            
'		If OracleFormWindow("short title:=Requests").Exist(0) Then
'			'Get Request Id from 'Requests' window
'			intRequestNo= OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS").GetFieldValue(1,"Request ID")   
'			If intRequestNo<>"" Then
'			
'				'Check Phase and Status
'				Set objRequest = OracleFormWindow("short title:=Requests").OracleTable("block name:=JOBS")
'				If objRequest.Exist(gLONGWAIT) Then
'					'Get Phase
'					strPhase = objRequest.GetFieldValue(1,"Phase")
'					'Get Status
'					strStatus = objRequest.GetFieldValue(1,"Status")
'					intRequestTimeOut = 1
'					Do While intRequestTimeOut>0 
'						If strPhase="Completed" And (strStatus="Normal" or strStatus="Warning") Then
'							Call gfReportExecutionStatus(micPass,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'							Exit Do
'						ElseIf strStatus="Error" or strStatus="No Manager" Then
'							Call gfReportExecutionStatus(micFail,"Verification for Request Phase and Status","Request Phase is : "&strPhase&" and Status is : "&strStatus)
'							Exit Do
'						End If
'						Wait 3
'						'Click on Refresh button
'						OracleFormWindow("short title:=Requests").OracleButton("description:=Refresh Data").Click
'						strPhase = objRequest.GetFieldValue(1,"Phase")
'						strStatus = objRequest.GetFieldValue(1,"Status")
'						intRequestTimeOut = intRequestTimeOut + 1
'						If Err.Number<>0 Then
'							Call gfReportExecutionStatus(micFail,"View Request ",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'							Exit Function
'						End If
'					Loop 'Do 
''					'Check if request is timedout
''					If intRequestTimeOut>=600 Then
''						Call gfReportExecutionStatus(micFail,"Request Timed Out","Request has been timed out. Timeout value : "&(intRequestTimeOut*3)& " secs")
''						Exit Function
''					End If
'			
'					If strPhase="Completed" Then
'					
'						'Check View Output
'						If UCase(strViewOutput) = "VIEWOUTPUT" Then
'							'Click on 'View Output' button
'							OracleFormWindow("short title:=Requests").OracleButton("description:=View Output").click
'							If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'								strMessage = OracleNotification("title:=Note").GetROProperty("message")
'								'Click on 'OK' button
'								OracleNotification("title:=Note").Approve
'								Call gfReportExecutionStatus(micPass,"View Output",strMessage)
'							Else
'								If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'									Wait gSYNCWAIT
'									Call gfReportExecutionStatus(micPass,"View Output","View Output has been displayed successfully.")
'									If strOutputSearchString<> "" Then
'										'Body Text
'										strBodyText = Browser("title:=.*temp_id.*").Page("name:=.*").Object.body.innerText
'                                        If Instr(strBodyText,strOutputSearchString) > 0 Then
'                                            Call gfReportExecutionStatus(micPass,"Verify Request Output","Request Output contains '"&strOutputSearchString&"' text.")
'										Else
'											Call gfReportExecutionStatus(micFail,"Verify Request Output","Request Output does not contains '"&strOutputSearchString&"' text.")
'										End If
'									End If
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Saves the output file
'									Call SaveViewOutputFile(intRequestNo, strViewOutput)
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Close the 'View Out' browser window
'									Browser("title:=.*temp_id.*").CloseAllTabs
'								Else
'									'------------------------------------------------------ravikanth 13-Jul-2015
'									Call gfReportExecutionStatus(micPass,"View Output","Failed to display View Output for this request. File type may be of 'Excel' or 'Word'. Need to manually save Output.")
'									'------------------------------------------------------ravikanth 13-Jul-2015
'								End If
'							End If
'						End If
'					
'						If UCase(strViewLog) = "VIEWLOG" Then
'							'Click on 'View Log' button
'							OracleFormWindow("short title:=Requests").OracleButton("description:=View Log...").click
'							If OracleNotification("title:=Note").Exist(gSHORTWAIT) Then
'								strMessage = OracleNotification("title:=Note").GetROProperty("message")
'								'Click on 'OK' button
'								OracleNotification("title:=Note").Approve
'								Call gfReportExecutionStatus(micPass,"View Log",strMessage)
'							Else
'								If Browser("title:=.*temp_id.*").Exist(gSHORTWAIT) Then
'									Wait gSYNCWAIT
'									Call gfReportExecutionStatus(micPass,"View Log","View Log has been displayed successfully.")
'									If strLogSearchString<> "" Then
'										'Body Text
'										strBodyText = Browser("title:=.*temp_id.*").Page("name:=.*").Object.body.innerText
'                                        If Instr(strBodyText,strLogSearchString) > 0 Then
'                                            Call gfReportExecutionStatus(micPass,"Verify Request Log","Request Log contains '"&strLogSearchString&"' text.")
'										Else
'											Call gfReportExecutionStatus(micFail,"Verify Request Log","Request Log does not contains '"&strLogSearchString&"' text.")
'										End If
'									End If
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Saves the output file
'									Call SaveViewOutputFile(intRequestNo, strViewOutput)
'									'----------------------------------------------------ravikanth 08-Jul-2015
'									'Close the 'View Out' browser window
'									Browser("title:=.*temp_id.*").CloseAllTabs
'								Else
'									Call gfReportExecutionStatus(micFail,"View Log","Failed to display View Log for this request.")
'								End If
'							End If
'						End If
'					End If
'				End If
'			Else
'				Call gfReportExecutionStatus(micFail,"Request Number","'"&strRequestNo&"' is not available")
'				Exit Function
'			End If
'        	'Close Requests Form
'			OracleFormWindow("short title:=Requests").CloseWindow
'		End If
'        pstrStatus="PASSED"   
'End Function 'bfuncViewRequestNoTimeout
'
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_ICX_Setups()
''# Function is used to create/add setups in the ICX Forms Launcher module.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_ICX_Setups()
'
'	Dim bSuccess: bSuccess = True
'	Dim strTemp
'
'	'Reading the excel data for MBS AP Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_ICX_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of ICX Forms Launcher Setup **********","********** ICX Forms Launcher Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Responsibility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		    If NOT OracleFormWindow("micclass:=OracleFormWindow").Exist(gMEDIUMWAIT) Then
'			OracleNavigator("short title:=Navigator").SelectFunction "Home"
'			Wait(gSHORTWAIT)
'			Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Home")
'		    End If
'		End If
'
'		If NOT OracleFormWindow("micclass:=OracleFormWindow").Exist(gSHORTWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0)
'			Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Home")
'		End If
'	Else
'		'strTemp = funcLaunchBrowser("Oracle", 0)
'		Call Login(rsTestCaseData("EBSUserName").value, rsTestCaseData("Responsibility").value, "","", "Grants","")
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Home")
'	End If
'
''	If NOT Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
''		Call Login(rsTestCaseData("EBSUserName").value, rsTestCaseData("Responsibility").value, "", "", "Grants","")
''	End If
'
'	blnStatus = funcICXFormsLauncherSetup()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of ICX Forms Launcher  Setup **********","********** ICX Forms Launcher Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of ICX Forms Launcher  Setup **********","********** ICX Forms Launcher Setup is Failed **********")
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_AP_Setups()
''# Function is used to create/add setups in the AP module.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'Function func_AP_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS AP Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_AP_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Accounts Payables Setup **********","********** Accounts Payables Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Respnbility1").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		
'			If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'				OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility1").value
'			End If
'	
'			If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'				If NOT OracleFormWindow("short title:=Invoice Hold and Release Names").Exist(gMEDIUMWAIT) Then
'					OracleNavigator("short title:=Navigator").SelectFunction "Setup:Invoice:Hold and Release Names"
'					Wait(gSHORTWAIT)
'					Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Respnbility1").value & " > Setup > Invoice > Hold and Release Names")
'				End If
'			End If
'		End If
'
'		If NOT OracleFormWindow("short title:=Invoice Hold and Release Names").Exist(gLONGWAIT) Then
'			Set oDesc = Description.Create
'			oDesc("name").value=rsTestCaseData("Respnbility1").value
'			If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Link(oDesc).Exist(gSHORTTIME) Then
'				Call func_ClickingLinks(rsTestCaseData("Respnbility1").value, rsTestCaseData("Link0").value, 0)
'				Wait(30)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Respnbility1").value & " > Setup > Invoice > Hold and Release Names")
'			Else
'				funcAddResponsibility(rsTestCaseData("Respnbility1").value)
'			End If
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName1").value, rsTestCaseData("Respnbility1").value, rsTestCaseData("Link0").value, 0, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Respnbility1").value & " > Setup > Invoice > Hold and Release Names")
'	End If
'
'	blnStatus = funcAddBPMHoldRelease()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddResponsibilities()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddSystemProfileValues()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddSystemProfileValuesatUserLevel()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Accounts Payables Setup **********","********** Accounts Payables Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Accounts Payables Setup **********","********** Accounts Payables Setup is Failed **********")
'	End If
' 
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_AR_Setups()
''# Function is used to create/add setups in the AR module.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_AR_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS AR Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_AR_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Accounts Recievables Setup **********","********** Accounts Recievables Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Users").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'			End If
'		End If
'	
'		If NOT OracleFormWindow("short title:=Users").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Respnbility").value, rsTestCaseData("Link").value, 3)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName1").value, rsTestCaseData("Respnbility").value, rsTestCaseData("Link").value, 3, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'	End If
'
'	blnStatus = funcAddCustomers()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddResponsibilities()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddPaymentTerms()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddApprovalLimits()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcAddReceivableActivity()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Accounts Recievables Setup **********","********** Accounts Recievables Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Accounts Recievables Setup **********","********** Accounts Recievables Setup is Failed **********")
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_FA_Setups()
''# Function is used to create/add setups in the FA module.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_FA_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS FA Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_FA_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Fixed Assets Setup **********","********** Fixed Assets Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Responsibility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Find Key Flexfield Segment").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Setup:Financials:Flexfields:Key:Values"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Financials > Flexfields > Key > Values")
'			End If
'		End If
'
'		If NOT OracleFormWindow("short title:=Find Key Flexfield Segment").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Financials > Flexfields > Key > Values")
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName").value, rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Financials > Flexfields > Key > Values")
'	End If
'
'	blnStatus = funcRemoveExpiryDates4SegmentValues()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcRemoveExpiryDates4GLAccount()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'	
'	blnStatus = funcAddResponsibilities()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Fixed Assets Setup **********","********** Fixed Assets Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Fixed Assets Setup **********","********** Fixed Assets Setup is Failed **********")
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_iExpen_Setups()
''# Function is used to create/add setups in the iExpenses module.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_iExpen_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS iExpen Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_iExpen_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of iExpenses Setup **********","********** iExpenses Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Responsibility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Users").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Responsibility").value & " > Security > User > Define")
'			End If
'		End If
'	
'		If NOT OracleFormWindow("short title:=Users").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 3)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Responsibility").value & " > Security > User > Define")
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName0").value, rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 3, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Responsibility").value & " > Security > User > Define")
'	End If
'
'	blnStatus = funcAddPersons()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of iExpenses Setup **********","********** iExpenses Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of iExpenses Setup **********","********** iExpenses Setup is Failed **********")
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_iProc_Setups()
''# Function is used to create/add setups in the iProcurement module.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_iProc_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS iProc Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_iProc_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of iProcurement Setup **********","********** iProcurement Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Find System Profile Values").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Profile:System"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Profile > System")
'			End If
'		End If
'
'		If NOT OracleFormWindow("short title:=Find System Profile Values").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Respnbility").value, rsTestCaseData("Link").value, 0)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Profile > System")
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName1").value, rsTestCaseData("Respnbility").value, rsTestCaseData("Link").value, 0, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Profile > System")
'	End If
'
'	blnStatus = funcAddSystemProfileValuesChangePassword()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of iProcurement Setup **********","********** iProcurement Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of iProcurement Setup **********","********** iProcurement Setup is Failed **********")
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_Other_Setups()
''# Function is used to setup other setups present in the ERP application.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_Other_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS Report Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_Other_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Other Setups **********","********** Other Setups has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Responsibility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Define Financial Report").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Reports:Define:Report"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Responsibility").value &" > Reports > Define > Report")
'			End If
'		End If
'	
'		If NOT OracleFormWindow("short title:=Define Financial Report").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Responsibility").value &" > Reports > Define > Report")
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName").value, rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to "& rsTestCaseData("Responsibility").value &" > Reports > Define > Report")
'	End If
'
'	blnStatus = funcRowOrderRemoval()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcCreateAccountingSetup()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'	
'	blnStatus = funcAddResponsibilities()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	Call funcLogout()
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Other Setups **********","********** Other Setups is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Other Setups **********","********** Other Setups is Failed **********")
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcICXFormsLauncherSetup()
''# Function is used to add User IDs and their Values as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcICXFormsLauncherSetup()
'
'	Dim bSuccess: bSuccess = True
'	'Dim objPage, intNoOfUsers, intCnt, oDesc, oLink, intRowNo, objParent, tblObject, blnPageNavigation, objWebTableParent, intCount, oNextLink, oDescWebList, strMsg, strUser, strSiteValue, strURL
'
'	On Error Resume Next
'	Err.Clear
'	Wait(5)
'	Set objPage = Browser("name:=Oracle Applications Home Page","index:=0").Page("title:=Oracle Applications Home Page","index:=0")
'	If objPage.Exist(gMEDIUMWAIT) Then
'		objPage.Link("name:=Functional Administrator","index:=0").Click
'		Wait(5)
'	End If
'
'	Set objPage=Browser("name:=Grants","index:=0").Page("title:=Grants","index:=0")
'	If objPage.Exist(gSHORTWAIT) Then
'		objPage.Link("name:=Core Services","index:=0").Click
'		Wait(2)
'		Browser("name:=Lookup Types","index:=0").Page("title:=Lookup Types","index:=0").Link("name:=Profiles","index:=0").Click
'	End If
'	
'	Set objPage=Browser("name:=Profiles","index:=0").Page("title:=Profiles","index:=0")
'	If objPage.Exist(gSHORTWAIT) Then
'		objPage.WebEdit("name:=FndProfileName","index:=0").Set rsTestCaseData("Name").value
'    	objPage.WebButton("name:=Go","index:=0").Click
'		Wait(5)
'
'    	If objPage.Image("file name:=updateicon_enabled.gif","index:=0").Exist(gMEDIUMWAIT) Then
'			objPage.Image("file name:=updateicon_enabled.gif","index:=0").Click
'			Wait(5)
'		End If
'	
'		Set objPage=Browser("name:=Define Profile Values:ICX: Forms Launcher","index:=0").Page("title:=Define Profile Values:ICX: Forms Launcher","index:=0")
'		strSiteValue = objPage.WebEdit("name:=Site","index:=0").GetROProperty("default value")
'		objPage.Link("name:=User","index:=0").Click
'		Wait(5)
'	End If
'
'	'Logic for counting total no of responsibilities to be added
'	Set objPage = Browser("name:=Define Profile Values:ICX: Forms Launcher","index:=0").Page("title:=Define Profile Values:ICX: Forms Launcher","index:=0")
'	intNoOfUsers = 0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"eUserID") > 0 Then
'			intNoOfUsers =intNoOfUsers+1
'		End If
'	Next
'
'	Set oDesc = Description.Create
'	Set oLink = Description.Create
'
'	For intCnt=0 to intNoOfUsers-1
'		strUser = rsTestCaseData("eUserID"&intCnt).value
'		intRowNo=-1
'		blnPageNavigation = False
'
'		' Navigate to other pages in the same table.
'		Do Until intRowNo <>-1
'			Set tblObject=objPage.WebTable("column names:=User;Value;Remove","index:=0")
'
'			'To find the WebTable parent to get the navigation controls.
'			Set objParent = tblObject.Object.parentNode
'			
'			While objParent.tagName <> "TABLE"
'				Set objParent = objParent.parentNode
'			Wend
'			
'			'Get the web table parent
'			If objParent Is Nothing Then
'				Set objParent = Nothing
'				Exit Do
'			Else
'				Set objWebTableParent = objPage.WebTable("source_Index:=" & objParent.sourceIndex)
'			End If
'			
'			'Find the row with text strText
'			For intCount = 1 to tblObject.RowCount
'				If StrComp (Trim(tblObject.GetCellData(intCount,1)), Trim(strUser),1) =  0 Then
'					intRowNo = intCount
'					Call gfReportExecutionStatus(micPass,"Verification for eUser ID", "eUser ID : " & strUser & " is already present")
'					Exit For
'				End If
'			Next
'			
'			If intRowNo = -1 Then
'				oDesc("MicClass").Value = "WebTable"
'				oDesc("column names").Value = ";;Previous.*"
'				Set objChild = objWebTableParent.ChildObjects(oDesc)
'				If objChild.Count  > 1 Then
'					oLink("MicClass").Value = "Link"
'					oLink("name").Value = "Next.*"
'					Set oNextLink = objChild(0).ChildObjects(oLink)
'					
'					If oNextLink.count >0 Then
'						oNextLink(0).Click										' Click on Next link
'						Wait gMEDIUMWAIT
'						blnPageNavigation = True
'					Else
'						Exit Do
'					End If
'				Else
'					Exit Do
'				End If
'			Else
'				Exit Do
'			End If
'		Loop
'		
'		If blnPageNavigation Then						' Navigate to first Page
'			Set oDescWebList = Description.Create
'			oDescWebList("micClass").Value = "WebList"
'			Set objWebList = objWebTableParent.ChildObjects(oDescWebList)
'			objWebList(0).Select "#0"
'			Wait gSHORTWAIT
'		End If
'
'		If intRowNo = -1 Then
'			If objPage.WebButton("name:=Add Another Row","index:=0").Exist(gShortWait) Then
'				objPage.WebButton("name:=Add Another Row","index:=0").Click
'			End If
'
'			If objPage.WebEdit("name:=FndProfileValueUserRN:User:.*","index:=0").Exist(gSHORTWAIT) Then
'				objPage.WebEdit("name:=FndProfileValueUserRN:User:.*","index:=0").Set strUser
'			End If
'			Wait(2)
'			If rsTestCaseData("URL").value = "?play=&record=names" Then
'            	strURL = strSiteValue+rsTestCaseData("URL").value
'			Else
'				strURL = rsTestCaseData("URL").value
'			End If
'            Wait(2)
'			'objPage.WebEdit("name:=FndProfileValueUserRN:ProfileValueUser.*","class:=x4","default value:=","index:=0").Set strURL
'			If objPage.WebEdit("name:=FndProfileValueUserRN:ProfileValueUser.*","html id:=FndProfileValueUserRN:ProfileValueUser.*","default value:=","index:=0").Exist(gSHORTWAIT) Then
'				objPage.WebEdit("name:=FndProfileValueUserRN:ProfileValueUser.*","html id:=FndProfileValueUserRN:ProfileValueUser.*","default value:=","index:=0").Set strURL
'			End If
'			Wait(2)
'			If objPage.WebButton("name:=Update","index:=0").Exist(gSHORTWAIT) Then
'				objPage.WebButton("name:=Update","index:=0").Click
'			End If
'			Wait(2)
'			If Dialog("regexpwndtitle:=Message from webpage").Exist(gSHORTWAIT) Then
'				strText = Dialog("regexpwndtitle:=Message from webpage").Static("regexpwndclass:=Static","window id:=65535").GetROProperty("text")
'				Dialog("regexpwndtitle:=Message from webpage").WinButton("regexpwndclass:=Button","regexpwndtitle:=OK").Click
'				If Instr(strText,"value must be entered for ""User""") > 0 AND Instr(strText,"value must be entered for ""Value""") > 0 Then
'					objPage.WebEdit("name:=FndProfileValueUserRN:User:.*","index:=0").Set strUser
'					Wait(2)
'					objPage.WebEdit("name:=FndProfileValueUserRN:ProfileValueUser.*","html id:=FndProfileValueUserRN:ProfileValueUser.*","default value:=","index:=0").Set strURL
'				ElseIf Instr(strText,"value must be entered for ""User""") > 0 Then
'					objPage.WebEdit("name:=FndProfileValueUserRN:User:.*","index:=0").Set strUser
'				ElseIf Instr(strText,"value must be entered for ""Value""") > 0 Then
'					objPage.WebEdit("name:=FndProfileValueUserRN:ProfileValueUser.*","html id:=FndProfileValueUserRN:ProfileValueUser.*","default value:=","index:=0").Set strURL
'				End If
'				If objPage.WebButton("name:=Update","index:=0").Exist(gSHORTWAIT) Then
'					objPage.WebButton("name:=Update","index:=0").Click
'				End If
'			End If
'			Wait(2)
'			If objPage.WebElement("outertext:=Save.*","html tag:=DIV","html id:=").Exist(gSHORTWAIT) Then
'				'strMsg = objPage.WebElement("class:=x77","html tag:=TD").GetROProperty("innertext")
'				strMsg = objPage.WebElement("outertext:=Save.*","html tag:=DIV","html id:=").GetROProperty("innertext")
'			End If
'			If Instr(strMsg,"Save completed") > 0 Then
'				Call gfReportExecutionStatus(micPass,"Verification for save", "eUser : " & strUser & " has been added and saved")
'			Else
'				Call gfReportExecutionStatus(micFail,"Verification for save", "eUser : " & strUser & " has been failed to add")
'				bSuccess = False
'			End If	
'		End If
'	Next
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	objPage.Link("name:=Home","index:=0").Click
'    
'	funcICXFormsLauncherSetup = bSuccess
'
'	Set objPage = Nothing
'	Set oDesc = Nothing
'	Set oLink = Nothing
'	Set objParent = Nothing
'	Set tblObject = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_ClickingLinks(strResponsibility, strLink, intLinkIndex)
''# Function is used 
''#
''# Input Parameters: strResponsibility, strLink
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_ClickingLinks(strResponsibility, strLink, intLinkIndex)
'
'	Dim bSuccess: bSuccess = True
'	'Dim strTitle, strWndTitle
'
'	On Error Resume Next
'	Err.Clear
'	Wait(5)
'	Set objPage = Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page")
'	If objPage.Exist(gSHORTWAIT) Then
'		If objPage.Link("name:="& strResponsibility,"index:=0").Exist(gSHORTWAIT) Then
'			'objPage.Link("name:="& strResponsibility,"index:=0").Highlight
'			objPage.Link("name:="& strResponsibility,"index:=0").Click
'			Wait(5)
'			If objPage.Link("name:="& strLink,"index:="& intLinkIndex).Exist(gSHORTWAIT) Then
'				'objPage.Link("name:="& strLink,"index:="& intLinkIndex).Highlight
'				objPage.Link("name:="& strLink,"index:="& intLinkIndex).Click
'				Wait(5)
'			End If
'		End If
'	Else
'		If objPage.Link("name:=Home","index:=0").Exist(gSHORTWAIT) Then
'			objPage.Link("name:=Home","index:=0").Click
'			Wait(5)
'			If objPage.Link("name:="& strResponsibility,"index:=0").Exist(gSHORTWAIT) Then
'				'objPage.Link("name:="& strResponsibility,"index:=0").Highlight
'				objPage.Link("name:="& strResponsibility,"index:=0").Click
'				Wait(5)
'				If objPage.Link("name:="& strLink,"index:="& intLinkIndex).Exist(gSHORTWAIT) Then
'					'objPage.Link("name:="& strLink,"index:="& intLinkIndex).Highlight
'					objPage.Link("name:="& strLink,"index:="& intLinkIndex).Click
'					Wait(5)
'				End If
'			End If
'		End If
'	End If
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddBPMHoldRelease()
''# Function is used to add BPM Hold & Release for particular User ID as a part of the setup..
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'Function funcAddBPMHoldRelease()
'
'	Dim bSuccess: bSuccess = True
'	'Dim strTitle, strWndTitle
'
'	On Error Resume Next
'	Err.Clear
'
'	Set objParent = OracleFormWindow("title:=Invoice Hold and Release Names")
'
'	If objParent.Exist(Environment("timeOut")) Then
'		Call gfReportExecutionStatus(micPass,"Verify 'Invoice Hold and Release Names' is opened","'Invoice Hold and Release Names' form is opened")
'
'		'1. BPM Hold
'		objParent.SelectMenu "View->Query By Example->Enter"
'		Wait 0,500
'		objParent.OracleTable("block name:=HOLD_CODES").EnterField 1,"Name",rsTestCaseData("BPMName0").value
'		Wait(1)
'		objParent.SelectMenu "View->Query By Example->Run"
'		Wait(1)
'		If LCase(objParent.OracleTable("block name:=HOLD_CODES").GetFieldValue(1,"Accounting Allowed")) <> "true" Then
'			objParent.OracleTable("block name:=HOLD_CODES").EnterField 1,"Accounting Allowed",True
'			If Err.Number = 0  Then
'				Call gfReportExecutionStatus(micPass,"Select the 'Accounting Allowed' check box for 'BPM Hold'","'Accounting Allowed' checkbox  for 'BPM Hold' is checked")
'			Else
'				Call gfReportExecutionStatus(micFail,"Select the 'Accounting Allowed' check box for 'BPM Hold'","Failed to  check 'Accounting Allowed' checkbox  for 'BPM Hold'")					
'				bSuccess = False
'			End If
'		Else
'			Call gfReportExecutionStatus(micPass,"Select the 'Accounting Allowed' check box for 'BPM Hold'","'Accounting Allowed' checkbox  is already checked for 'BPM Hold'")
'		End If
'		
'		If LCase(objParent.OracleTable("block name:=HOLD_CODES").GetFieldValue(1,"Manual Release Allowed")) <> "true" Then
'			objParent.OracleTable("block name:=HOLD_CODES").EnterField 1,"Manual Release Allowed",True
'			If Err.Number = 0  Then
'				Call gfReportExecutionStatus(micPass,"Select the 'Manual Release Allowed' check box for 'BPM Hold'","'Manual Release Allowed' checkbox  for 'BPM Hold' is checked")
'			Else
'				Call gfReportExecutionStatus(micFail,"Select the 'Manual Release Allowed' check box for 'BPM Hold'","Failed to  check 'Manual Release Allowed' checkbox  for 'BPM Hold'")					
'				bSuccess = False
'			End If
'		Else
'			Call gfReportExecutionStatus(micPass,"Select the 'Manual Release Allowed' check box for 'BPM Hold'","'Manual Release Allowed' checkbox  is already checked for 'BPM Hold'")
'		End If
'		
'		objParent.SelectMenu "File->Save"
'		
'		'2. BPM Release
'		objParent.SelectMenu "View->Query By Example->Enter"
'		Wait 0,500
'		objParent.OracleTable("block name:=HOLD_CODES").EnterField 1,"Name",rsTestCaseData("BPMName1").value
'		Wait(1)
'		objParent.SelectMenu "View->Query By Example->Run"
'		Wait(1)
'		If LCase(objParent.OracleTable("block name:=HOLD_CODES").GetFieldValue(1,"Accounting Allowed")) <> "true" Then
'			objParent.OracleTable("block name:=HOLD_CODES").EnterField 1,"Accounting Allowed",True
'			If Err.Number = 0  Then
'				Call gfReportExecutionStatus(micPass,"Select the 'Accounting Allowed' check box for 'BPM Release'","'Accounting Allowed' checkbox  for 'BPM Release' is checked")
'			Else
'				Call gfReportExecutionStatus(micFail,"Select the 'Accounting Allowed' check box for 'BPM Release'","Failed to  check 'Accounting Allowed' checkbox  for 'BPM Release'")
'				bSuccess = False
'			End If
'		Else
'			Call gfReportExecutionStatus(micPass,"Select the 'Accounting Allowed' check box for 'BPM Release'","'Accounting Allowed' checkbox  is already checked for 'BPM Release'")
'		End If
'		
'		If LCase(objParent.OracleTable("block name:=HOLD_CODES").GetFieldValue(1,"Manual Release Allowed")) <> "true" Then
'			objParent.OracleTable("block name:=HOLD_CODES").EnterField 1,"Manual Release Allowed",True
'			If Err.Number = 0  Then
'				Call gfReportExecutionStatus(micPass,"Select the 'Manual Release Allowed' check box for 'BPM Release'","'Manual Release Allowed' checkbox  for 'BPM Release' is checked")
'			Else
'				Call gfReportExecutionStatus(micFail,"Select the 'Manual Release Allowed' check box for 'BPM Release'","Failed to  check 'Manual Release Allowed' checkbox  for 'BPM Release'")
'				bSuccess = False
'			End If
'		Else
'			Call gfReportExecutionStatus(micPass,"Select the 'Manual Release Allowed' check box for 'BPM Release'","'Manual Release Allowed' checkbox  is already checked for 'BPM Release'")
'		End If
'		objParent.SelectMenu "File->Save"
'		objParent.CloseWindow
'	Else
'		Call gfReportExecutionStatus(micFail,"Verify 'Invoice Hold and Release Names' is opened","Failed to open 'Invoice Hold and Release Names' form")
'		bSuccess = False
'	End If
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddBPMHoldRelease = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddResponsibilities()
''# Function is used to add Responsibility for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'Function funcAddResponsibilities()
'
'	Dim bSuccess: bSuccess = True
'	'Dim strTitle, intIncrmnt, intCnt, objParent, strValue, strMessage, strDate
'
'	On Error Resume Next
'	Err.Clear
'
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation 4", "Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Security > User > Define")
'	End If
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"Responsibility") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Users")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		wait(3)
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("EBSUserName").value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Call gfReportExecutionStatus(micPass,"Adding Responsibilities","Adding the responsibilities to " & rsTestCaseData("EBSUserName").value)
'
'			For intCnt=0 to intIncrmnt-1
'			Wait(1)
'			If objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").Exist(gSHORTWAIT) Then
'				objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").SetFocus 1,"Responsibility"
'				objParent.SelectMenu "View->Query By Example->Enter"
'				objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Responsibility",rsTestCaseData("Responsibility"&intCnt).value
'				objParent.SelectMenu "View->Query By Example->Run"
'				Wait(1)
'				strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"query caused no records") Then
'					objParent.SelectMenu "View->Query By Example->Cancel"
'					strValue=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Responsibility")										'strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Effective Dates: To")
'					strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"To")
'					If strValue = "" Then
'						objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Responsibility",rsTestCaseData("Responsibility"&intCnt).value
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for adding Responsibility", "Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value & " has been added to User ID : " &  rsTestCaseData("EBSUserName").value)
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'							bSuccess = False
'						End If
'					End If
'				ElseIf strMessage = "" Then
'					strValue=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Responsibility")
'					'strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Effective Dates: To")
'					strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"To")
'					If (strValue <> "" AND strDate <> "")Then
'						'objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Effective Dates: To",""
'						objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"To",""
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for removing Effective Date To", "End date for Effective Date To field removed for Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value)
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'							bSuccess = False
'						End If
'					End If
'					Call gfReportExecutionStatus(micPass,"Verification for adding Responsibility", "Responsibility " & rsTestCaseData("Responsibility"&intCnt).value & " is already present for User ID : " & rsTestCaseData("EBSUserName").value)
'				Else
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'	If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddResponsibilities = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddSystemProfileValues()
''# Function is used to add System Profile Values for particular User ID as a part of Setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'Function funcAddSystemProfileValues()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strSiteValue, strRspnsblityValue, strMessage
'
'	On Error Resume Next
'	Err.Clear
'
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Profile:System"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to "&  rsTestCaseData("Respnbility").value & " > Profile > System")
'	End If
'
'	'Logic for counting total no of System Profile values  to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"SystemProfileRspnsblty") > 0Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'    If objParent.Exist(gMEDIUMWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'			objParent.Activate
'			objParent.OracleCheckBox("description:=Responsibility","index:=0").Select
'			objParent.OracleTextField("description:=Responsibility Name","index:=0").Enter rsTestCaseData("SystemProfileRspnsblty"&intCnt).value
'			objParent.OracleTextField("description:=Profile","index:=0").Enter rsTestCaseData("SystemProfileOption"&intCnt).value
'			objParent.OracleButton("description:=Find","index:=0").Click
'			Wait(1)
'			Set objParent=OracleFormWindow("short title:=System Profile Values")
'			strSiteValue=objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"Site")
'			strRspnsblityValue=objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"Responsibility")
'			If rsTestCaseData("SystemProfileRspnsblty"&intCnt).value = "MCD US AP Payments" Then
'				If ((strSiteValue = "") AND (strRspnsblityValue = "")) Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",""
'					objParent.SelectMenu "File->Save"
'				ElseIf ((strSiteValue = "") AND (strRspnsblityValue <> "")) Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",""
'					objParent.SelectMenu "File->Save"
'				ElseIf ((strSiteValue <> rsTestCaseData("SystemProfileValue"&intCnt).value) AND (strRspnsblityValue = "")) Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					objParent.SelectMenu "File->Save"
'				ElseIf ((strSiteValue <> "") AND (strRspnsblityValue <> "")) Then
'					If strSiteValue <> rsTestCaseData("SystemProfileValue"&intCnt).value Then
'						objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					End If
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",""
'					objParent.SelectMenu "File->Save"
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for System Profile value at Site level", "System Profile value : " & rsTestCaseData("SystemProfileValue"&intCnt).value & " at Site level is already present for Responsibility " & rsTestCaseData("SystemProfileRspnsblty"&intCnt).value)
'				End If
'
'				strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'				If strMessage <> "" Then
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at Site level","System Profile value : " &  rsTestCaseData("SystemProfileValue"&intCnt).value  & " at Site level has been added for Responsibility " & rsTestCaseData("SystemProfileRspnsblty"&intCnt).value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'						bSuccess = False
'					End If
'				End If
'			ElseIf rsTestCaseData("SystemProfileRspnsblty"&intCnt).value = "MCD US AP Business Analyst" Then
'				If ((strSiteValue = "") AND (strRspnsblityValue = "")) Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",rsTestCaseData("SystemProfileValue"&intCnt).value
'					objParent.SelectMenu "File->Save"
'				ElseIf ((strSiteValue = "") AND (strRspnsblityValue <> "")) Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					If (strRspnsblityValue <> rsTestCaseData("SystemProfileValue"&intCnt).value) Then
'						objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",rsTestCaseData("SystemProfileValue"&intCnt).value
'					End If
'					objParent.SelectMenu "File->Save"
'				ElseIf ((strSiteValue <> "") AND (strRspnsblityValue = "")) Then
'					If (strSiteValue <> rsTestCaseData("SystemProfileValue"&intCnt).value) Then
'							objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'					End If
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",rsTestCaseData("SystemProfileValue"&intCnt).value
'					objParent.SelectMenu "File->Save"
'				ElseIf ((strSiteValue <> "") AND (strRspnsblityValue <> "")) Then
'					If (strSiteValue <> rsTestCaseData("SystemProfileValue"&intCnt).value) Then
'							objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue"&intCnt).value
'							objParent.SelectMenu "File->Save"
'					End If
'					If (strRspnsblityValue <> rsTestCaseData("SystemProfileValue"&intCnt).value) Then
'						objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Responsibility",rsTestCaseData("SystemProfileValue"&intCnt).value
'						objParent.SelectMenu "File->Save"
'					End If
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for System Profile value at Site & Responsibility level", "System Profile value : " & rsTestCaseData("SystemProfileValue"&intCnt).value & " at Site & Responsibility level is already present for Responsibility " & rsTestCaseData("SystemProfileRspnsblty"&intCnt).value)
'				End If
'
'				strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'				If strMessage <> "" Then
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at Site & Responsibility level","System Profile value : " &  rsTestCaseData("SystemProfileValue"&intCnt).value  & " at Site & Responsibility level has been added for Responsibility " & rsTestCaseData("SystemProfileRspnsblty"&intCnt).value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'						bSuccess = False
'					End If
'				End If
'			End If
'		Next
'	Else
'		Exit Function
'	End If
'	
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddSystemProfileValues = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddSystemProfileValuesatUserLevel()
''# Function is used to add System Profile Values at User level for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddSystemProfileValuesatUserLevel()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strSiteValue, blnValue,strMessage
'
'	On Error Resume Next
'	Err.Clear
'
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Profile:System"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to "& rsTestCaseData("Respnbility").value & " > Profile > System")
'	End If
'
'	'Logic for counting total no of values to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"SysProfileOption") > 0Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			If rsTestCaseData("SysProfileOption"&intCnt).value = "Sequential Numbering" Then
'				Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'				objParent.Activate
'				objParent.OracleCheckBox("description:=User","index:=0").Select
'				objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("SysProfileUser").value
'				objParent.OracleTextField("description:=Profile","index:=0").Enter rsTestCaseData("SysProfileOption"&intCnt).value
'				objParent.OracleButton("description:=Find","index:=0").Click
'				Wait(1)
'				Set objParent=OracleFormWindow("short title:=System Profile Values")
'				If rsTestCaseData("SysProfileUser").value <> "E1222140" Then
'					strUserValue = objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"User")
'					If strUserValue <> rsTestCaseData("SysProfileValue"&intCnt).value Then
'						blnValue=objParent.OracleTable("block name:=PROFILE_VALUES").IsFieldEditable(1,"User")
'						If blnValue Then
'							objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"User",rsTestCaseData("SysProfileValue"&intCnt).value
'							objParent.SelectMenu "File->Save"
'							strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'							If Instr(Lcase(strMessage),"transaction complete") Then
'								Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at User level","System Profile value : " & rsTestCaseData("SysProfileValue"&intCnt).value & " at User level has been added for User ID "& rsTestCaseData("SysProfileUser").value)
'								Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'							Else
'								Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'								bSuccess = False
'							End If
'						Else
'							Call gfReportExecutionStatus(micPass,"Verification for System Profile value at User level", "System Profile value : " & rsTestCaseData("SysProfileValue"&intCnt).value & " at User level is non-editable for User ID "& rsTestCaseData("SysProfileUser").value)
'						End If
'					Else
'						Call gfReportExecutionStatus(micPass,"Verification for System Profile value at User level", "System Profile value : " & rsTestCaseData("SysProfileValue"&intCnt).value & " at User level is already present for User ID "& rsTestCaseData("SysProfileUser").value)
'					End If
'				Else
'					strSiteValue = objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"Site")
'					If strSiteValue <> rsTestCaseData("SystemProfileValue1").value Then
'						objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue1").value
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at Site level","System Profile value : " & rsTestCaseData("SystemProfileValue1").value & " at Site level has been added for User ID "& rsTestCaseData("SysProfileUser").value)
'							Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'							bSuccess = False
'						End If
'					Else
'						Call gfReportExecutionStatus(micPass,"Verification for System Profile value at Site level", "System Profile value : " & rsTestCaseData("SysProfileValue"&intCnt).value & " at Site level is already present for User ID "& rsTestCaseData("SysProfileUser").value)
'					End If
'				End If
'			ElseIf rsTestCaseData("SysProfileOption"&intCnt).value = "Concurrent:Save Output" Then
'				Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'				objParent.Activate
'                objParent.OracleCheckBox("description:=User","index:=0").Clear
'				objParent.OracleTextField("description:=User Name","index:=0").Enter ""
'				objParent.OracleTextField("description:=Profile","index:=0").Enter rsTestCaseData("SysProfileOption"&intCnt).value
'				objParent.OracleButton("description:=Find","index:=0").Click
'				Wait(1)
'				Set objParent=OracleFormWindow("short title:=System Profile Values")
'				strSiteValue = objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"Site")
'				If strSiteValue <> rsTestCaseData("SysProfileValue"&intCnt).value Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SysProfileValue"&intCnt).value
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at Site level","System Profile value : " & rsTestCaseData("SysProfileValue"&intCnt).value & " at Site level has been added for System Profile Option : "& rsTestCaseData("SysProfileOption"&intCnt).value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'						bSuccess = False
'					End If
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for System Profile value at Site level", "System Profile value : " & rsTestCaseData("SysProfileValue"&intCnt).value & " at Site level is already present for System Profile Option : "& rsTestCaseData("SysProfileOption"&intCnt).value)
'				End If
'
'				objParent.CloseWindow
'				
'				If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'					OracleNavigator("short title:=Navigator").SelectFunction "Concurrent:Program:Define"
'					Wait(gSHORTWAIT)
'					Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Concurrent > Program > Define")
'				End If
'
'				Set objParent=OracleFormWindow("short title:=Concurrent Programs")
'				objParent.SelectMenu "View->Query By Example->Enter"
'				objParent.OracleTextField("description:=Program","index:=0").Enter rsTestCaseData("ProgramName").value
'		                objParent.SelectMenu "View->Query By Example->Run"
'				Wait(1)
'				strShortName=objParent.OracleTextField("description:=Short Name","index:=0").GetROProperty("value")
'				If strShortName <> "" Then
'					blnValue = objParent.OracleCheckbox("description:=Save","index:=0").IsSelected
'					If blnValue = True Then
'						Call gfReportExecutionStatus(micPass,"Verification for Check box selection for Output Save option", "Check box is already selected for Output Save option")
'					ElseIf blnValue = False Then
'						objParent.OracleCheckbox("description:=Save","index:=0").Select
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for Check box selection for Output Save option", "Check box is selected for Output Save option")
'							Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'							bSuccess = False
'						End If
'					Else
'						Call gfReportExecutionStatus(micFail,"Verification for Check box selection for Output Save option", "Failed to select the Check box for Output Save option")
'						bSuccess = False
'					End If
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddSystemProfileValuesatUserLevel = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddCustomers()
''# Function is used to add Customers to particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddCustomers()
'
'	Dim bSuccess: bSuccess = True
'	'Dim strTitle, intIncrmnt, intCnt, objParent, strValue, strMessage
'
'	On Error Resume Next
'	Err.Clear
'
''	OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'	Wait(gSHORTWAIT)
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"Customers") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Users")
'	If objParent.Exist(gLONGWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("EBSUserName").value
'			objParent.SelectMenu "View->Query By Example->Run"
'            strPersonValue=objParent.OracleTextField("description:=Person","index:=0").GetROProperty("value")
'			strValue=objParent.OracleTextField("description:=Customer","index:=0").GetROProperty("value")
'			If (strValue <> "") Then
'				If Instr(Ucase(strValue),rsTestCaseData("Customers"&intCnt).value) > 0 Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Customer", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is already present for User ID : " &rsTestCaseData("EBSUserName").value)
'				Else
'					'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''28-Jul-2014
'					objParent.OracleTextField("description:=Person","index:=0").Enter ""	
'					''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''28-Jul-2014
'					objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'					If OracleListOfValues("title:=Customers").Exist(gSHORTWAIT)  Then
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'					
'					If OracleNotification("title:=Forms").Exist(gSHORTWAIT)  Then
'						OracleNotification("title:=Forms").OracleButton("label:=OK").Click
'					End If
'	
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for adding Customer","Customer : " & rsTestCaseData("Customers"&intCnt).value & " has been added to User ID : " & rsTestCaseData("EBSUserName").value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'						bSuccess = False
'					End If
'				End If
'			ElseIf strValue = ""Then
'				''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''28-Jul-2014
'				objParent.OracleTextField("description:=Person","index:=0").Enter ""	
'				''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''28-Jul-2014
'				objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'				If OracleListOfValues("title:=Customers").Exist(gSHORTWAIT)  Then
'					OracleListOfValues("title:=Customers").Select 1
'				End If
'				
'				If OracleNotification("title:=Forms").Exist(gSHORTWAIT)  Then
'					OracleNotification("title:=Forms").OracleButton("label:=OK").Click
'				End If
'				objParent.SelectMenu "File->Save"
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Customer","Customer : " & rsTestCaseData("Customers"&intCnt).value & " has been added to User ID : " & rsTestCaseData("EBSUserName").value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'					bSuccess = False
'				End If
'			Else
'				Call gfReportExecutionStatus(micPass,"Verification for adding Customer", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is already present for User ID : " &rsTestCaseData("EBSUserName").value)
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddCustomers = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddPaymentTerms()
''# Function is used to add Payment Terms as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddPaymentTerms()
'
'	Dim bSuccess: bSuccess = True
'	'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, strDate
'
'	On Error Resume Next
'	Err.Clear
'	Wait(5)
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("ChangeRspnsblty").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("ChangeRspnsblty").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Setup:Transactions:Payment Terms"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("ChangeRspnsblty").value & " > Setup > Transactions > Payment Terms")
'	End If
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"PymtTermName") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Payment Terms")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			objParent.OracleTextField("description:=Name","index:=0").SetFocus
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=Name","index:=0").Enter rsTestCaseData("PymtTermName" &intCnt).value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Wait(1)
'			strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'			If strMessage <> "" Then
'				objParent.SelectMenu "View->Query By Example->Cancel"
'				objParent.OracleTextField("description:=Name","index:=0").Enter rsTestCaseData("PymtTermName" &intCnt).value
'				objParent.OracleTextField("description:=Description","index:=0").Enter rsTestCaseData("PymtTermDesc" &intCnt).value
'				objParent.OracleCheckBox("description:=Allow Discount on Partial Payments","index:=0").Select
'				objParent.OracleCheckBox("description:=Prepayment","index:=0").Select
'				objParent.OracleTextField("description:=Discount Basis","index:=0").Enter rsTestCaseData("DiscountBasis").value
'				objParent.OracleTextField("description:=Installment Options","index:=0").Enter rsTestCaseData("InstlmntOptions").value
'				'objParent.OracleTable("block name:=RA_TERMS_LINES").SetFocus 1,"Payment Schedule: Due: Days"
'				objParent.OracleTable("block name:=RA_TERMS_LINES").SetFocus 1,"Days"
'				'objParent.OracleTable("block name:=RA_TERMS_LINES").EnterField 1,"Payment Schedule: Due: Days",rsTestCaseData("DueDays").value
'				objParent.OracleTable("block name:=RA_TERMS_LINES").EnterField 1,"Days",rsTestCaseData("DueDays").value
'				objParent.SelectMenu "File->Save"
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Payment Terms", "Payment Term : " & rsTestCaseData("PymtTermName"&intCnt).value & " has been added")
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'					bSuccess = False
'				End If
'			Else
'				strDate=objParent.OracleTextField("description:=High Effective Date","index:=0").GetROProperty("value")
'				If strDate <> "" Then
'					objParent.OracleTextField("description:=High Effective Date","index:=0").Enter ""
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for removing Effective Dates To", "Effective Dates To removed for Payment Term : " & rsTestCaseData("PymtTermName"&intCnt).value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'						bSuccess = False
'					End If					
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for adding Payment Terms", "Payment Term : " & rsTestCaseData("PymtTermName"&intCnt).value & " is already present")
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddPaymentTerms = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddApprovalLimits()
''# Function is used to add Approval Limits as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddApprovalLimits()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, objTable
'
'	On Error Resume Next
'	Err.Clear
'	Wait(5)
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("ChangeRspnsbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("ChangeRspnsbility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Setup:Transactions:Approval Limits"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("ChangeRspnsbility").value & " > Setup > Transactions > Approval Limits")
'	End If
'
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"DocumentType") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Approval Limits")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		For intCnt=1 to intIncrmnt
'			Set objParent=OracleFormWindow("short title:=Approval Limits")
'			objParent.SelectMenu "View->Query By Example->Enter"
'			Set objTable = objParent.OracleTabbedRegion("label:=Main").OracleTable("block name:=AR_APPROVAL_USER_LIMITS")
'			'objTable.EnterField 1,"Username",rsTestCaseData("EBSUserName").value
'			'objTable.EnterField 1,"User Name",rsTestCaseData("EBSUserName").value
'			objTable.EnterField 1,"User Name",rsTestCaseData("EBSUserName"&intCnt-1).value
'			objTable.EnterField 1,"Document Type",rsTestCaseData("DocumentType"&intCnt-1).value
'			
'			'**********************************************************************************************
'			'Added for CA Setup
'			objTable.EnterField 1,"Currency", rsTestCaseData("Currency"&intCnt-1).value
'			'**********************************************************************************************
'			
'			
'			objParent.SelectMenu "View->Query By Example->Run"
'			Wait(1)
'			strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'			If strMessage = "" Then
'				intRows  = 	objTable.GetROProperty("visible rows")
'				For intLoop= 1 to intRows
'					If Instr(Trim(objTable.GetFieldValue(intLoop,"Document Type")), rsTestCaseData("DocumentType"&intCnt-1).value) > 0 Then
'						Call gfReportExecutionStatus(micPass,"Verification for Approval Limit - " &rsTestCaseData("DocumentType"&intCnt-1).value &" ", " Approval Limit - "& rsTestCaseData("DocumentType"&intCnt-1).value & " is already present for User ID : " & rsTestCaseData("EBSUserName"&intCnt-1).value)
''					If Trim(objTable.GetFieldValue(intLoop,"Document Type")) = "Receipt Write-off" Then
''						Call gfReportExecutionStatus(micPass,"Verification for Approval Limit - Receipt Write-off", " Approval Limit - Receipt Write-off is already present for User ID : " & rsTestCaseData("EBSUserName").value)
''					ElseIf Trim(objTable.GetFieldValue(intLoop,"Document Type")) = "Adjustment" Then
''						Call gfReportExecutionStatus(micPass,"Verification for Approval Limit - Adjustment", " Approval Limit - Adjustment is already present for User ID : " & rsTestCaseData("EBSUserName").value)
'					ElseIf Trim(objTable.GetFieldValue(intLoop,"Document Type")) = "" Then
'						Exit For
'					End If
'				Next
'			ElseIf Instr(Lcase(strMessage),"query caused no records") Then
'				objParent.SelectMenu "View->Query By Example->Cancel"
'				'objTable.EnterField 1,"Username", rsTestCaseData("EBSUserName").value
'				'objTable.EnterField 1,"User Name", rsTestCaseData("EBSUserName").value
'				objTable.EnterField 1,"User Name", rsTestCaseData("EBSUserName"& intCnt-1).value
'				objTable.EnterField 1,"Document Type", rsTestCaseData("DocumentType"& intCnt-1).value
'				objTable.SetFocus 1,"Currency"
'				
'				
'				'**************************************************************************************
'				'objTable.EnterField 1,"Currency", rsTestCaseData("Currency").value
'				
'				'Above line Modified for CA Setups
'				objTable.EnterField 1,"Currency", rsTestCaseData("Currency"&intCnt-1).value
'				'**************************************************************************************
'				
'				objTable.EnterField 1,"From  Amount", rsTestCaseData("FromAmount"&intCnt-1).value					
'				objTable.EnterField 1,"To Amount",rsTestCaseData("ToAmount"&intCnt-1).value
'				objParent.SelectMenu "File->Save"
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Approval Limit - " & Trim(rsTestCaseData("DocumentType"& intCnt-1).value) & " for User ID : " & rsTestCaseData("EBSUserName"& intCnt-1).value,"Approval Limit - " & Trim(rsTestCaseData("DocumentType"& intCnt-1).value) & " has been added for User ID : " & rsTestCaseData("EBSUserName"& intCnt-1).value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'					bSuccess = False
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddApprovalLimits = bSuccess
'
'	Set objParent = Nothing
'	Set objTable = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddReceivableActivity()
''# Function is used to add Receivable Activity for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddReceivableActivity()
'
'	Dim bSuccess: bSuccess = True
'	'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, strValue
'
'	On Error Resume Next
'	Err.Clear
'	Wait(5)
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("ChangeRspnsbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("ChangeRspnsbility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Setup:Receipts:Receivable Activities"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("ChangeRspnsbility").value & " > Setup > Receipts > Receivable Activities")
'	End If
'
'	Set objParent=OracleFormWindow("short title:=Receivables Activities")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		objParent.SelectMenu "View->Query By Example->Enter"
'		objParent.OracleTextField("description:=Name","index:=0").Enter rsTestCaseData("RecvbleActivity").value
'		objParent.OracleList("description:=Type","index:=0").Select rsTestCaseData("Type").value
'		objParent.SelectMenu "View->Query By Example->Run"
'		Wait(1)
'		strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'		If strMessage = "" Then
'			strValue=objParent.OracleTextField("description:=Name","index:=0").GetROProperty("value")
'			If strValue = rsTestCaseData("RecvbleActivity").value Then
'                blnValue = objParent.OracleCheckbox("description:=Active").GetROProperty("selected")
'				If blnValue = True Then
'					Call gfReportExecutionStatus(micPass,"Verification for Receivable Activity", " Receivable Activity : " & rsTestCaseData("RecvbleActivity").value & " is already present")
'				Else
'					objParent.OracleCheckbox("description:=Active").Select
'					Call gfReportExecutionStatus(micPass,"Verification for Receivable Activity", " Receivable Activity : " & rsTestCaseData("RecvbleActivity").value & " is already present and made Active")
'				End If
'			End If
'		Else
'			objParent.SelectMenu "View->Query By Example->Cancel"
'			objParent.OracleTextField("description:=Name","index:=0").Enter rsTestCaseData("RecvbleActivity").value
'			objParent.OracleList("description:=Type","index:=0").Select rsTestCaseData("Type").value
'			objParent.OracleTextField("description:=Activity GL Account","index:=0").Enter rsTestCaseData("ActvtyGLAccnt").value
'			objParent.SelectMenu "File->Save"
'			If OracleNotification("title:=Error").Exist(10)  Then
'				strMessage = OracleNotification("title:=Error").GetROProperty("message")
'				If Instr(strMessage,"You can only define one active Electronic Refund activity") > 0 Then
'					OracleNotification("title:=Error").OracleButton("label:=OK").Click
'				End If
'				Call gfReportExecutionStatus(micPass,"Transaction status",strMessage & "Receivable Activity : " & rsTestCaseData("RecvbleActivity").value & " is already present")
'				objParent.CloseWindow
'				If OracleNotification("title:=Forms").Exist(5)  Then
'						OracleNotification("title:=Forms").OracleButton("label:=No").Click
'				End If
'				Exit Function
'			End If
'			strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'			If Instr(Lcase(strMessage),"transaction complete") Then
'				Call gfReportExecutionStatus(micPass,"Verification for adding Receivable Activity","Receivable Activity : " & rsTestCaseData("RecvbleActivity").value & " has been added")
'				Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'			Else
'				Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'				bSuccess = False
'			End If
'		End If
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddReceivableActivity = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcRemoveExpiryDates4SegmentValues()
''# Function is used to remove Expiry Dates for Segment Values for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcRemoveExpiryDates4SegmentValues()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, strValue
'
'	On Error Resume Next
'	Err.Clear
'
''	OracleNavigator("short title:=Navigator").SelectFunction "Setup:Financials:Flexfields:Key:Values"
'	Wait(gSHORTWAIT)
'
'	Set objParent=OracleFormWindow("short title:=Find Key Flexfield Segment")
'	If objParent.Exist(gLONGWAIT) Then
'		objParent.OracleTextField("description:=Title","index:=0").Enter rsTestCaseData("Title").value
'		objParent.OracleTextField("description:=Structure","index:=0").Enter rsTestCaseData("Structure").value 
'		objParent.OracleTextField("description:=Segment","index:=0").Enter rsTestCaseData("DefaultSegment").value 
'		objParent.OracleButton("description:=Find","index:=0").Click
'		Wait(1)
'		'Logic for counting total no of responsibilities to be added
'		intIncrmnt=0
'		For intCnt=0 to rsTestCaseData.Fields.Count-1
'			If Instr(rsTestCaseData.Fields(intCnt).Name,"SegmentValue") > 0 Then
'				intIncrmnt=intIncrmnt+1
'			End If
'		Next
'	
'		Set objParent=OracleFormWindow("short title:=Segment Values")
'		For intCnt=0 to intIncrmnt-1
'			If objParent.Exist(gMEDIUMWAIT) Then
'				If rsTestCaseData("SegmentValue"&intCnt).value <> "70016" Then
'					objParent.OracleTabbedRegion("label:=Values, Effective").OracleTable("block name:=VALUE").SetFocus 1,"Value"
'					objParent.SelectMenu "View->Query By Example->Enter"
'					objParent.OracleTabbedRegion("label:=Values, Effective").OracleTable("block name:=VALUE").EnterField 1,"Value",rsTestCaseData("SegmentValue"&intCnt).value
'					objParent.SelectMenu "View->Query By Example->Run"
'					Wait(1)
'				Else
'					objParent.OracleTextField("description:=Title","index:=0").SetFocus
'					objParent.SelectMenu "View->Query By Example->Enter"
'					objParent.OracleTextField("description:=Title","index:=0").Enter rsTestCaseData("Title").value
'					objParent.OracleTextField("description:=Independent Segment","index:=0").Enter rsTestCaseData( "IndependentSegment").value
'					objParent.OracleTextField("description:=Structure","index:=0").Enter rsTestCaseData( "Structure").value
'					objParent.SelectMenu "View->Query By Example->Run"
'					Wait(1)
'					objParent.OracleTabbedRegion("label:=Values, Effective").OracleTable("block name:=VALUE").SetFocus 1,"Value"
'					objParent.SelectMenu "View->Query By Example->Enter"
'					objParent.OracleTabbedRegion("label:=Values, Effective").OracleTable("block name:=VALUE").EnterField 1,"Value",rsTestCaseData("SegmentValue"&intCnt).value
'					objParent.SelectMenu "View->Query By Example->Run"
'					Wait(1)
'				End If
'			End If
'	
'			strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'			If strMessage = "" Then
'				strValue=objParent.OracleTabbedRegion("label:=Values, Effective").OracleTable("block name:=VALUE").GetFieldValue(1,"To")
'				If strValue <> "" Then
'					objParent.OracleTabbedRegion("label:=Values, Effective").OracleTable("block name:=VALUE").EnterField 1,"To",""
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for removal of Segment Value Effective Date To", " Effective Date To for Segment Value : " & rsTestCaseData("SegmentValue"&intCnt).value & " is removed")
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'						bSuccess = False
'					End If
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for removal of Segment Value Effective Date To", " Effective Date To for Segment Value : " & rsTestCaseData("SegmentValue"&intCnt).value & " is already Blank")
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'	'To close the Notification window
'	If OracleNotification("title:=Note").Exist(5)  Then
'		OracleNotification("title:=Note").OracleButton("label:=OK").Click
'	End If
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcRemoveExpiryDates4SegmentValues = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcRemoveExpiryDates4GLAccount()
''# Function is used to remove Expiry Dates for GL Accounts for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcRemoveExpiryDates4GLAccount()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, strValue
'
'	On Error Resume Next
'	Err.Clear
'
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Responsibility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Setup:Accounts:Combinations"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Accounts > Combinations")
'	End If
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"GLAccount") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=GL Accounts")
'	For intCnt=0 to intIncrmnt-1
'		If objParent.Exist(gMEDIUMWAIT) Then
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTable("block name:=COMBO").SetFocus 1,"Account"
'			objParent.OracleTable("block name:=COMBO").EnterField 1,"Account",rsTestCaseData("GLAccount"&intCnt).value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Wait(1)
'		End If
'
'		strMessage = OracleStatusLine("error code:=.*").GetROProperty("message")
'		If strMessage = "" Then
'		
'			'******************************************************************************************************
'			'Added for CA Setups will set start date to 01-JAN-1955 if Start date is not set
'			'strValue = objParent.OracleTable("block name:=COMBO").GetFieldValue(1,"Effective Dates: From")
'			strValue = objParent.OracleTable("block name:=COMBO").GetFieldValue(1,"From")
'			If strValue = "" Then
'				'objParent.OracleTable("block name:=COMBO").EnterField 1,"Effective Dates: From", rsTestCaseData("Date").value
'				objParent.OracleTable("block name:=COMBO").EnterField 1,"From", rsTestCaseData("Date").value
'			End If
'			'CA Setup Ends here
'			'******************************************************************************************************
'						
'			'strValue = objParent.OracleTable("block name:=COMBO").GetFieldValue(1,"Effective Dates: To")
'			strValue = objParent.OracleTable("block name:=COMBO").GetFieldValue(1,"To")
'			If strValue <> "" Then
'				'objParent.OracleTable("block name:=COMBO").EnterField 1,"Effective Dates: To",""
'				objParent.OracleTable("block name:=COMBO").EnterField 1,"To",""
'				objParent.SelectMenu "File->Save"
'				strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for removal of GL Accounts Effective Date To ", " Effective Date To for GL Account : " & rsTestCaseData("GLAccount"&intCnt).value & " is removed")
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'					bSuccess = False
'				End If
'			Else
'				Call gfReportExecutionStatus(micPass,"Verification for removal of GL Accounts Effective Date To", " Effective Date To for GL Account : " & rsTestCaseData("GLAccount"&intCnt).value & " is already Blank")
'			End If
'		Else
'			'To close the Notification window
'			If OracleNotification("title:=Error").Exist(5)  Then
'				OracleNotification("title:=Error").OracleButton("label:=OK").Click
'			ElseIf OracleNotification("title:=Note").Exist(5)  Then
'				OracleNotification("title:=Note").OracleButton("label:=OK").Click
'			End If
'			objParent.SelectMenu "View->Query By Example->Cancel"
'		End If
'	Next
'
'	objParent.CloseWindow
'
'	'To close the Notification window
'	If OracleNotification("title:=Note").Exist(5)  Then
'		OracleNotification("title:=Note").OracleButton("label:=OK").Click
'	End If
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcRemoveExpiryDates4GLAccount = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddPersons()
''# Function is used to add Persons for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddPersons()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, strPersonValue, strCustomerValue
'
'	On Error Resume Next
'	Err.Clear
'
''	OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'	Wait(gSHORTWAIT)
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"EBSUserName") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Users")
'	If objParent.Exist(gLONGWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("EBSUserName"&intCnt).value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Wait(1)
'			strPersonValue=objParent.OracleTextField("description:=Person","index:=0").GetROProperty("value")
'			strCustomerValue=objParent.OracleTextField("description:=Customer","index:=0").GetROProperty("value")
'			If ((strPersonValue <> "") AND (Ucase(strPersonValue) <> rsTestCaseData("Persons"&intCnt).value)) Then
'				If ((strCustomerValue <> "") AND (Ucase(strCustomerValue) <> rsTestCaseData("Customers"&intCnt).value)) Then
'					objParent.OracleTextField("description:=Person","index:=0").Enter rsTestCaseData("Persons"&intCnt).value
'					If OracleNotification("title:=Caution").Exist(3)  Then
'						OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'					End If
'					objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'					If OracleListOfValues("title:=Customers").Exist(5) Then
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'					Call gfReportExecutionStatus(micPass,"Verification for adding Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				ElseIf (strCustomerValue = "") Then
'					objParent.OracleTextField("description:=Person","index:=0").Enter rsTestCaseData("Persons"&intCnt).value
'					If OracleListOfValues("title:=Person Names").Exist(5) Then
'						OracleListOfValues("title:=Person Names").Select 1
'					End If
'					objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'					If OracleListOfValues("title:=Customers").Exist(5) Then
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'				End If
'				'To close the Notification window
'				If OracleNotification("title:=Caution").Exist(5)  Then
'					OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'				End If
'				objParent.SelectMenu "File->Save"
'				If OracleNotification("title:=Caution").Exist(5)  Then
'					OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'				End If
'				If OracleNotification("title:=Forms").Exist(5)  Then
'					OracleNotification("title:=Forms").OracleButton("label:=Yes").Click
'				End If
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				ElseIf Instr(Lcase(strMessage),"no changes to save") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding and saving Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is already added and saved to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'					bSuccess = False
'				End If
'			ElseIf ((strPersonValue = "") AND (strCustomerValue = "")) Then
'				objParent.OracleTextField("description:=Person","index:=0").Enter rsTestCaseData("Persons"&intCnt).value
'				If OracleListOfValues("title:=Person Names").Exist(5) Then
'					OracleListOfValues("title:=Person Names").Select 1
'				End If
'				'To close the Notification window
'				If OracleNotification("title:=Caution").Exist(3)  Then
'					OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'				End If
'				
'				
'				
'				'objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'				'If OracleListOfValues("title:=Customers").Exist(5) Then
'				'	OracleListOfValues("title:=Customers").Select 1
'				'End If
'				
'				'******************************************************************************************************
'				'Added for CA Setups
'				objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'				If OracleListOfValues("title:=Customers").Exist(5) Then
'					'Need to select second customer if user is E1908883 as transactions are created with 2 customer
'					If UCase(rsTestCaseData("EBSUserName"&intCnt).value) = Environment.Value("EBSFAUserName") Then
'						OracleListOfValues("title:=Customers").Select 2
'					Else
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'				End If
'				'CA Setup Ends here
'				'******************************************************************************************************
'			
'				
'				objParent.SelectMenu "File->Save"
'				If OracleNotification("title:=Caution").Exist(5)  Then
'					OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'				End If
'				If OracleNotification("title:=Forms").Exist(5)  Then
'					OracleNotification("title:=Forms").OracleButton("label:=Yes").Click
'				End If
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Verification for adding Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				ElseIf Instr(Lcase(strMessage),"no changes to save") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding and saving Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is already added and saved to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Verification for adding and saving Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is already added and saved to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'					bSuccess = False
'				End If
'			ElseIf ((strPersonValue = "") AND (strCustomerValue <> "")) Then
'				If (Ucase(strCustomerValue) <> rsTestCaseData("Customers"&intCnt).value) Then
'					objParent.OracleTextField("description:=Person","index:=0").Enter rsTestCaseData("Persons"&intCnt).value
'					If OracleListOfValues("title:=Person Names").Exist(5) Then
'						OracleListOfValues("title:=Person Names").Select 1
'					End If
'					'To close the Notification window
'					If OracleNotification("title:=Caution").Exist(3)  Then
'						OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'					End If
'					objParent.OracleTextField("description:=Customer","index:=0").Enter  rsTestCaseData("Customers"&intCnt).value
'					If OracleListOfValues("title:=Customers").Exist(5) Then
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'					Call gfReportExecutionStatus(micPass,"Verification for adding Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				Else
'					objParent.OracleTextField("description:=Person","index:=0").Enter rsTestCaseData("Persons"&intCnt).value
'					If OracleListOfValues("title:=Person Names").Exist(5) Then
'						OracleListOfValues("title:=Person Names").Select 1
'					End If
'					'To close the Notification window
'					If OracleNotification("title:=Caution").Exist(5)  Then
'						OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'					End If
'				End If	
'				objParent.SelectMenu "File->Save"
'				If OracleNotification("title:=Caution").Exist(5)  Then
'					OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'				End If
'				If OracleNotification("title:=Forms").Exist(5)  Then
'					OracleNotification("title:=Forms").OracleButton("label:=Yes").Click
'				End If
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				ElseIf Instr(Lcase(strMessage),"no changes to save") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding and saving Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is already added and saved to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'					bSuccess = False
'				End If
'			ElseIf ((strPersonValue <> "") AND (strCustomerValue =	"")) Then
'				If (Ucase(strPersonValue) <> rsTestCaseData("Persons"&intCnt).value) Then
'					objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'					If OracleListOfValues("title:=Customers").Exist(3) Then
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'					'To close the Notification window
'					If OracleNotification("title:=Caution").Exist(3)  Then
'						OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'					End If
'					objParent.OracleTextField("description:=Person","index:=0").Enter  rsTestCaseData("Persons"&intCnt).value
'					If OracleListOfValues("title:=Person Names").Exist(3) Then
'						OracleListOfValues("title:=Person Names").Select 1
'					End If
'					Call gfReportExecutionStatus(micPass,"Verification for adding Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				Else
'					objParent.OracleTextField("description:=Customer","index:=0").Enter rsTestCaseData("Customers"&intCnt).value
'					If OracleListOfValues("title:=Customers").Exist(3) Then
'						OracleListOfValues("title:=Customers").Select 1
'					End If
'					'To close the Notification window
'					If OracleNotification("title:=Caution").Exist(3)  Then
'						OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'					End If
'				End If	
'				objParent.SelectMenu "File->Save"
'				If OracleNotification("title:=Caution").Exist(3)  Then
'					OracleNotification("title:=Caution").OracleButton("label:=OK").Click
'				End If
'				If OracleNotification("title:=Forms").Exist(5)  Then
'					OracleNotification("title:=Forms").OracleButton("label:=Yes").Click
'				End If
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is added to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				ElseIf Instr(Lcase(strMessage),"no changes to save") Then
'					Call gfReportExecutionStatus(micPass,"Verification for adding and saving Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is already added and saved to User ID : " & rsTestCaseData("EBSUserName"&intCnt).value)
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'					bSuccess = False
'				End If
'			Else
'				Call gfReportExecutionStatus(micPass,"Verification for adding Person to User ID", "Person : " & rsTestCaseData("Persons"&intCnt).value & " is already present for User ID : " &rsTestCaseData("EBSUserName"&intCnt).value)
'				Call gfReportExecutionStatus(micPass,"Verification for adding Customer to User ID", "Customer : " & rsTestCaseData("Customers"&intCnt).value & " is already present for User ID : " &rsTestCaseData("EBSUserName"&intCnt).value)
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'	If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddPersons = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcAddSystemProfileValuesChangePassword()
''# Function is used to add System Profile Values at User level for particular User ID as a part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcAddSystemProfileValuesChangePassword()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strUserValue, blnValue, strMessage, strSiteValue
'
'	On Error Resume Next
'	Err.Clear
'
''	OracleNavigator("short title:=Navigator").SelectFunction "Profile:System"
'	Wait(gSHORTWAIT)
'
'	'Logic for counting total no of values to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"SystemProfileUser") > 0Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'	If objParent.Exist(gLONGWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			Set objParent=OracleFormWindow("short title:=Find System Profile Values")
'			objParent.Activate
'			objParent.OracleCheckBox("description:=User","index:=0").Select
'			objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("SystemProfileUser"&intCnt).value
'			objParent.OracleTextField("description:=Profile","index:=0").Enter rsTestCaseData("SystemProfileOption").value
'			objParent.OracleButton("description:=Find","index:=0").Click
'			Wait(1)
'			Set objParent=OracleFormWindow("short title:=System Profile Values")
'			If rsTestCaseData("SystemProfileUser"&intCnt).value <> "E1222140" Then
'				strUserValue = objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"User")
'				If strUserValue <> rsTestCaseData("SystemProfileValue").value Then
'					blnValue=objParent.OracleTable("block name:=PROFILE_VALUES").IsFieldEditable(1,"User")
'					If blnValue Then
'						objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"User",rsTestCaseData("SystemProfileValue").value
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at User level","System Profile value : " & rsTestCaseData("SystemProfileValue").value & " at User level has been added for User ID "& rsTestCaseData("SystemProfileUser"&intCnt).value)
'							Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'							bSuccess = False
'						End If
'					End If
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for System Profile value at User level", "System Profile value : " & rsTestCaseData("SystemProfileValue").value & " at User level is already present for User ID "& rsTestCaseData("SystemProfileUser"&intCnt).value)
'				End If
'			Else
'				strSiteValue = objParent.OracleTable("block name:=PROFILE_VALUES").GetFieldValue(1,"Site")
'				If strSiteValue <> rsTestCaseData("SystemProfileValue1").value Then
'					objParent.OracleTable("block name:=PROFILE_VALUES").EnterField 1,"Site",rsTestCaseData("SystemProfileValue1").value
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for System Profile Value at Site level","System Profile value : " & rsTestCaseData("SystemProfileValue1").value & " at Site level has been added for User ID "& rsTestCaseData("SystemProfileUser"&intCnt).value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status", strMessage)
'						bSuccess = False
'					End If
'				Else
'					Call gfReportExecutionStatus(micPass,"Verification for System Profile value at Site level", "System Profile value : " & rsTestCaseData("SystemProfileValue1").value & " at Site level is already present for User ID "& rsTestCaseData("SystemProfileUser"&intCnt).value)
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'	End If
'
'	Set objParent=OracleFormWindow("short title:=Users")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			If rsTestCaseData("SystemProfileUser"&intCnt).value <> "E1222140" Then
'				objParent.SelectMenu "View->Query By Example->Enter"
'				objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("SystemProfileUser"&intCnt).value
'				objParent.SelectMenu "View->Query By Example->Run"
'				Wait(1)
'				objParent.OracleTextField("description:=Password","index:=0").SetFocus
'				objParent.OracleTextField("description:=Password","index:=0").Enter rsTestCaseData("Password0").value
'				Wait(1)
'				strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"re-enter your password") Then
'					Call gfReportExecutionStatus(micPass,"Verification for entering the Password", "Password entered successfully for UserID : " & rsTestCaseData("SystemProfileUser"&intCnt).value & " ")
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'					bSuccess = False
'				End If
'				objParent.OracleTextField("description:=Password","index:=0").Enter rsTestCaseData("Password0").value
'				objParent.SelectMenu "File->Save"
'				Wait(3)
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for re-entering the Password", "Password re-entered successfully for UserID : " & rsTestCaseData("SystemProfileUser"&intCnt).value)
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'					bSuccess = False
'				End If
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'	strURL = Environment.Value("SSOURL")
'	SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
'	Wait(4)
'	For intCnt=0 to intIncrmnt-1
'		If rsTestCaseData("SystemProfileUser"&intCnt).value <> "E1222140" Then
'			Set objParentLogin = Browser("name:=Login","index:=0").Page("title:=Login","index:=0")
'			If objParentLogin.Exist(gSHORTWAIT) Then
'				objParentLogin.WebEdit("name:=usernameField","index:=0").Set rsTestCaseData("SystemProfileUser"&intCnt).value
'				Wait(1)
'				objParentLogin.WebEdit("name:=passwordField","index:=0").Set rsTestCaseData("Password0").value
'				Wait(1)
'				objParentLogin.WebButton("name:=Login","index:=0").Click
'				Set objParentPwd = Browser("name:=Change Password","index:=0").Page("title:=Change Password","index:=0")
'				If objParentPwd.Exist(gSHORTWAIT) Then
'					objParentPwd.WebEdit("name:=password","index:=0").Set rsTestCaseData("Password0").value
'					Wait(1)
'					objParentPwd.WebEdit("name:=newPassword","index:=0").Set rsTestCaseData("Password1").value
'					Wait(1)
'					objParentPwd.WebEdit("name:=newPassword2","index:=0").Set rsTestCaseData("Password1").value
'					objParentPwd.WebButton("name:=Submit","index:=0").Click
'					'Set objParentHome = Browser("name:=Oracle Applications Home Page","index:=0").Page("title:=Oracle Applications Home Page","index:=0")
'					Set objParentHome = Browser("name:=Oracle Applications Home Page","index:=1").Page("title:=Oracle Applications Home Page","index:=1")
'					If objParentHome.Exist(gSHORTWAIT) Then
'						If objParentHome.Link("name:=Logout", "index:=0").Exist(gSHORTWAIT) Then
'							objParentHome.Link("name:=Logout", "index:=0").Click
'						End If
'						Call gfReportExecutionStatus(micPass,"Verification for changing the Password", "Password changed successfully for UserID : " & rsTestCaseData("SystemProfileUser"&intCnt).value)
'					Else
'						Call gfReportExecutionStatus(micFail,"Verification for changing the Password", "Password NOT changed successfully for UserID : " & rsTestCaseData("SystemProfileUser"&intCnt).value)
'						bSuccess = False
'					End If
'				End If
'			End If
'		End If
'	Next
'
'	Browser("name:=Login","index:=0").Close
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddSystemProfileValuesChangePassword = bSuccess
'
'	Set objParent = Nothing
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcRowOrderRemoval()
''# Function is used to remove the value of Row Order field for some Reports.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcRowOrderRemoval()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strValue,objParent, intIncrmnt, intCnt
'
'	On Error Resume Next
'	Err.Clear
'
'	'Logic for counting total no of values to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"ReportName") > 0Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Define Financial Report")
'	If objParent.Exist(gLONGWAIT) Then
'		For intCnt=0 to intIncrmnt-1
'			Set objParent=OracleFormWindow("short title:=Define Financial Report")
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=Report","index:=0").Enter rsTestCaseData("ReportName"&intCnt).value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Wait(1)
'			strValue=objParent.OracleTextField("prompt:=Row Order","index:=0").GetROProperty("value")
'			If strValue <> ""Then
'				objParent.OracleTextField("prompt:=Row Order","index:=0").Enter ""
'				objParent.SelectMenu "File->Save"
'				strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"transaction complete") Then
'					Call gfReportExecutionStatus(micPass,"Verification for removing Row Order value", "Row Order value has been removed for Report Name : '" &  rsTestCaseData("ReportName"&intCnt).value & "'")
'					Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been applied and saved")
'				Else
'					Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'					bSuccess = False
'				End If
'			Else
'				Call gfReportExecutionStatus(micPass,"Verification for Row Order value", "Row Order value for Report Name : '" &  rsTestCaseData("ReportName"&intCnt).value & "' is already Blank")
'			End If
'		Next
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcRowOrderRemoval = bSuccess
'
'	Set objParent = Nothing
'End Function
'
''*******************************************************************************************************************************************************************************************
''# Function:   funcCreateAccountingSetup()
''# Function is used to setup if Create Accounting does not work.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function funcCreateAccountingSetup()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strValue,objParent, intIncrmnt, intCnt
'
'	On Error Resume Next
'	Err.Clear
'Wait(5)
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Responsibility1").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility1").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Setup:Options:Payables Options"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("Responsibility1").value & " > Setup > Options > Payables Options")
'	End If
'
''	'Logic for counting total no of values to be added
''	intIncrmnt=0
''	For intCnt=0 to rsTestCaseData.Fields.Count-1
''		If Instr(rsTestCaseData.Fields(intCnt).Name,"ReportName") > 0Then
''			intIncrmnt=intIncrmnt+1
''		End If
''	Next
'
'	Set objParent=OracleFormWindow("short title:=Payables Options")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		'For intCnt=0 to intIncrmnt-1
'		Set objParent=OracleFormWindow("short title:=Payables Options")
'		objParent.OracleTabbedRegion("label:=Accounting Option").OracleRadioGroup("developer name:=AP_SYSTEM_PARAMETERS_LIABILITY_POST_LOOKUP_CODE").Select Trim(rsTestCaseData("AutomaticOffsetMethod").value)
'        objParent.SelectMenu "File->Save"
'		Wait(5)
'		strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'		If Instr(Lcase(strMessage),"transaction complete") Then
'			Call gfReportExecutionStatus(micPass,"Verification for checking Automatic Offset Method", "Automatic Offset Method has been set to '" &  rsTestCaseData("AutomaticOffsetMethod").value & "'")
'			Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been applied and saved")
'		Elseif Instr(Lcase(strMessage),"no changes to save") Then
'			Call gfReportExecutionStatus(micPass,"Verification for checking Automatic Offset Method", "Automatic Offset Method has been already set to '" &  rsTestCaseData("AutomaticOffsetMethod").value & "'")
'		Else
'			Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'			bSuccess = False
'		End If
'	End If
'
'	objParent.CloseWindow
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcCreateAccountingSetup = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''=========================================================
'
'Function funcLogout()
'
'	Dim bSuccess: bSuccess = True
'    'Dim objParent
'
'	On Error Resume Next
'	Err.Clear
'	Wait(5)
'
'	Set objParent = Browser("name:=Oracle Applications Home Page","index:=0").Page("title:=Oracle Applications Home Page","index:=0")
'   	If objParent.Link("name:=Logout", "index:=0").Exist(gSHORTWAIT) Then
'		objParent.Link("name:=Logout", "index:=0").Click
'		Wait(5)
'		If Browser("name:=.*off.*","index:=0").Exist(gSHORTWAIT) Then
'			Browser("name:=.*off.*","index:=0").Close
'		End If
'	ElseIf objParent.Link("name:=Home", "index:=0").Exist(gSHORTWAIT) Then
'		objParent.Link("name:=Home", "index:=0").Click
'		If objParent.Link("name:=Logout", "index:=0").Exist(gSHORTWAIT) Then
'			objParent.Link("name:=Logout", "index:=0").Click
'			Wait(5)
'			If Browser("name:=.*off.*","index:=0").Exist(gSHORTWAIT) Then
'				Browser("name:=.*off.*","index:=0").Close
'			End If
'		End If
'	End If
'
'	If Browser("name:=Oracle Applications R12","index:=0").Exist(gSHORTWAIT) Then
'		Browser("name:=Oracle Applications R12","index:=0").Close
'	End If
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcLogout = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''====================================================================================================================
'
'Function funcAddResponsibility(strResponsibility)
'
'	Set objParent = Browser("name:=Oracle Applications Home Page","index:=0").Page("title:=Oracle Applications Home Page","index:=0")
'	objParent.Link("name:=System Administrator").Click
'	Wait(5)
'	objParent.Link("name:=Define","index:=3").Click
'	Wait(10	)
'
'	Set objParent = OracleFormWindow("short title:=Users")
''If NOT OracleFormWindow("short title:=Users").Exist(gMEDIUMWAIT) Then
'	If objParent.Exist(gMEDIUMWAIT) Then
''		For intCnt=0 to intIncrmnt-1
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("EBSUserName").value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Wait(1)
'			If objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").Exist(gSHORTWAIT) Then
'				objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").SetFocus 1,"Responsibility"
'                objParent.SelectMenu "View->Query By Example->Enter"
'				objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Responsibility",rsTestCaseData(strResponsibility).value
'				objParent.SelectMenu "View->Query By Example->Run"
'				Wait(1)
'				strValue=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Responsibility")
'				'strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Effective Dates: To")
'				strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"To")
'				Wait(1)
'				If strValue = "" Then
'					objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Responsibility",rsTestCaseData("Responsibility"&intCnt).value
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for adding Responsibility", "Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value & " has been added to User ID : " &  rsTestCaseData("EBSUserName").value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'						bSuccess = False
'					End If
'				ElseIf (strValue <> "" AND strDate <>"") Then
'					'objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Effective Dates: To",""
'					objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"To",""
'					objParent.SelectMenu "File->Save"
'					strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'					If Instr(Lcase(strMessage),"transaction complete") Then
'						Call gfReportExecutionStatus(micPass,"Verification for removing Effective Date To", "Effective Date To removed for Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value)
'						Call gfReportExecutionStatus(micPass,"Transaction status","Transaction complete : Record has been  saved")
'					Else
'						Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'						bSuccess = False
'					End If
'				'Else
'					'Call gfReportExecutionStatus(micPass,"Verification for adding Responsibility", "Responsibility " & rsTestCaseData("Responsibility"&intCnt).value & " is already present for User ID : " & rsTestCaseData("EBSUserName").value)
'				End If
'			End If
'		'Next
'	End If
'
'	objParent.CloseWindow
'
'	If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddResponsibility = bSuccess
'
'	Set objParent = Nothing
'
'End Function
'
''====================================================================================================================
'
'Function funcAddResponsibilitiesforMultipleUsers()
'
'	Dim bSuccess: bSuccess = True
'	
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_Resp_Multi_Users'",rsTestCaseData)
'	
'	Call gfReportExecutionStatus(micPass,"********** Start of Adding Responsibilities for Multiple Users Setup **********","********** Adding Responsibilities for Multiple Users Setup has Started **********")
'	
'	On Error Resume Next
'	Err.Clear
'
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'		End If
'	End If
'	
'	If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'		OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'	End If
'
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Security -> User -> Define")
'	End If
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'      	If Instr(rsTestCaseData.Fields(intCnt).Name,"Responsibility") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	For intUser=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intUser).Name,"SSOUser") > 0 Then
'			i=i+1
'		End If
'	Next
'    	
'	Set objParent=OracleFormWindow("short title:=Users")
'	If objParent.Exist(gMEDIUMWAIT) Then
'
'		For intUser=0 to i-1
'		wait(3)	
'			objParent.OracleTextField("description:=User Name","index:=0").SetFocus
'			objParent.SelectMenu "View->Query By Example->Enter"
'			objParent.OracleTextField("description:=User Name","index:=0").Enter rsTestCaseData("SSOUser"&intUser).value
'			objParent.SelectMenu "View->Query By Example->Run"
'			Call gfReportExecutionStatus(micPass,"Adding Responsibilities","Adding the responsibilities to " & rsTestCaseData("SSOUser"&intUser).value)
'
'			For intCnt=0 to intIncrmnt-1
'			Wait(1)
'			If objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").Exist(gSHORTWAIT) Then
'				objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").SetFocus 1,"Responsibility"
'				objParent.SelectMenu "View->Query By Example->Enter"
'				objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Responsibility",rsTestCaseData("Responsibility"&intCnt).value
'				objParent.SelectMenu "View->Query By Example->Run"
'				Wait(1)
'				strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'				If Instr(Lcase(strMessage),"query caused no records") Then
'					objParent.SelectMenu "View->Query By Example->Cancel"
'					strValue=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Responsibility")
'					'strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Effective Dates: To")
'					strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"To")
'					If strValue = "" Then
'						objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Responsibility",rsTestCaseData("Responsibility"&intCnt).value
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for adding Responsibility", "Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value & " has been added to User ID : " &  rsTestCaseData("SSOUser"&intUser).value)
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'							bSuccess = False
'						End If
'					End If
'				ElseIf strMessage = "" Then
'					strValue=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Responsibility")
'					'strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"Effective Dates: To")
'					strDate=objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").GetFieldValue(1,"To")
'					If strValue <> "" AND strDate <> ""Then
'						'objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"Effective Dates: To",""
'						objParent.OracleTabbedRegion("label:=Direct Responsibilities").OracleTable("block name:=USER_RESP").EnterField 1,"To",""
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for removing Effective Date To", "End date for Effective Date To field removed for Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value)
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'							bSuccess = False
'						End If
'					End If
'					Call gfReportExecutionStatus(micPass,"Verification for adding Responsibility", "Responsibility " & rsTestCaseData("Responsibility"&intCnt).value & " is already present for User ID : " & rsTestCaseData("SSOUser"&intUser).value)
'				Else
'				End If
'			End If
'		Next
'	Next
'   	End If
'
'	objParent.CloseWindow
'
'	If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcAddResponsibilitiesforMultipleUsers = bSuccess
'	
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Adding Responsibilities for Multiple Users Setup **********","********** Adding Responsibilities for Multiple Users Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Adding Responsibilities for Multiple Users Setup **********","********** Adding Responsibilities for Multiple Users Setup is Failed **********")
'	End If
'
'	Set objParent = Nothing
'
'End Function
'
''====================================================================================================================
'
'Function func_GL_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS GL Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_GL_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of General Ledger Setup **********","********** General Ledger Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Users").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Security:User:Define"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation 1","Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'				Wait(6)
'				'**********************************************************************
'				'Line should be included
'				Set objParent=OracleFormWindow("short title:=Users")
'				'**********************************************************************
'				If objParent.Exist(gMEDIUMWAIT) Then
'					objParent.CloseWindow
'				End If
'			End If
'		End If
'
'    	If NOT OracleFormWindow("short title:=Users").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Respnbility").value, rsTestCaseData("Link").value, 3)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation 2","Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'			'**********************************************************************
'			'below 4 lines should be included
'			Set objParent=OracleFormWindow("short title:=Users")
'			If objParent.Exist(gMEDIUMWAIT) Then
'				objParent.CloseWindow
'			End If
'			'**********************************************************************
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName").value, rsTestCaseData("Respnbility").value, rsTestCaseData("Link").value, 3, "Oracle Applications Home Page","")
'		Wait(30)
'		Set objParent=OracleFormWindow("short title:=Users")
'		If objParent.Exist(gMEDIUMWAIT) Then
'			objParent.CloseWindow
'		End If
'		Call gfReportExecutionStatus(micPass,"Navigation 3","Navigated successfully to " & rsTestCaseData("Respnbility").value &" > Security > User > Define")
'	End If
'		
'	blnStatus = funcAddResponsibilities()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'	
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of General Ledger Setup **********","********** General Ledger Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of General Ledger Setup **********","********** General Ledger Setup is Failed **********")
'	End If
' 
'End Function
'
''====================================================================================================================
'
'Function func_Projects_Setups()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS Projects Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_Projects_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Projects Setup **********","********** Projects Setup has Started **********")
'
'	blnStatus = funcAddResponsibilities()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'	
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Projects Setup **********","********** Projects Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Projects Setup **********","********** Projects Setup is Failed **********")
'	End If
' 
'End Function
'
''====================================================================================================================
'
'Function funcRemoveEndDateForResponsibilities()
'
'	Dim bSuccess: bSuccess = True
'
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_Remove_EndDate_Resp'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Removing End Dates for Responsibilities Setup **********","********** Removing End Dates for Responsibilities Setup has Started **********")
'
'	On Error Resume Next
'	Err.Clear
'	
'	If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'		strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'		If NOT Instr(strTitle,rsTestCaseData("Respnbility").value) > 0 Then
'			OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'			Wait(3)
'				If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'				OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Respnbility").value
'				End If
'		End If
'	End If
'	
'	If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'		OracleNavigator("short title:=Navigator").SelectFunction "Security:Responsibility:Define"
'		Wait(gSHORTWAIT)
'		Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to "& rsTestCaseData("Respnbility").value &" > Security > Responsibility > Define")
'	End If
'
'	'Logic for counting total no of responsibilities to be added
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"Responsibility") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	Set objParent=OracleFormWindow("short title:=Responsibilities")
'	If objParent.Exist(gMEDIUMWAIT) Then
'		wait(3)
'			For intCnt=0 to intIncrmnt-1
'			Wait(1)
'				objParent.SelectMenu "View->Query By Example->Enter"
'				objParent.OracleTextField("description:=Responsibility Name","index:=0").SetFocus
'				objParent.OracleTextField("description:=Responsibility Name","index:=0").Enter rsTestCaseData("Responsibility"&intCnt).value
'				objParent.SelectMenu "View->Query By Example->Run"
'				Wait(1)
'					strDateFrom=objParent.OracleTextField("description:=Effective Dates: From").GetROProperty("value")
'					strDateTo=objParent.OracleTextField("description:=Effective Dates: To").GetROProperty("value")
'					If (strDateFrom <> "" AND strDateTo <> "") Then
'						objParent.OracleTextField("description:=Effective Dates: To").Enter ""
'						objParent.SelectMenu "File->Save"
'						strMessage=OracleStatusLine("error code:=FRM.*").GetROProperty("message")
'						If Instr(Lcase(strMessage),"transaction complete") Then
'							Call gfReportExecutionStatus(micPass,"Verification for End Date of Responsibility", "End Date has been removed for Responsibility  " & rsTestCaseData("Responsibility"&intCnt).value)
'						Else
'							Call gfReportExecutionStatus(micFail,"Transaction status",strMessage)
'							bSuccess = False
'						End If
'					ElseIf (strDateFrom <> "" AND strDateTo = "") Then
'					Call gfReportExecutionStatus(micPass,"Verification for End Date of Responsibility", "Thers is no End Date for Responsibility " & rsTestCaseData("Responsibility"&intCnt).value)
'					End If
'			Next
'	End If
'
'	objParent.CloseWindow
'
'	If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		Err.Clear
'		'On Error Goto 0
'		bSuccess = False
'	End If
'
'	funcRemoveEndDateForResponsibilities = bSuccess
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Removing End Dates for Responsibilities Setup **********","********** Removing End Dates for Responsibilities Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Removing End Dates for Responsibilities Setup **********","********** Removing End Dates for Responsibilities Setup is Failed **********")
'	End If
'
'	Set objParent = Nothing
'
'End Function
'
'
''*******************************************************************************************************************************************************************************************
''# Function:   func_AR_TransTypes_Setups()
''# Function is used to Query Transaction Type record (Regular Invoice or Credit Memo type etc) based on Name and Description fields then removing End Date 
''#and enter valid Receivable, Revenue and Tax Accounts to theTransaction Type quered as part of the setup.
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_AR_TransTypes_Setups()
'
'	Dim bSuccess: bSuccess = True
'    'Dim strTitle, intIncrmnt, intCnt, objParent, strMessage, objTable
'
'	On Error Resume Next
'    Err.Clear
'
'	Wait(5)
'
'	'Reading the excel data for MBS AR Setups
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_AR_TransTypes_Setups'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Accounts Recievables Transaction Types Setup **********","********** Accounts Recievables Transaction Types Setup has Started **********")
'
'	intIncrmnt=0
'	For intCnt=0 to rsTestCaseData.Fields.Count-1
'		If Instr(rsTestCaseData.Fields(intCnt).Name,"ChangeResponsibility") > 0 Then
'			intIncrmnt=intIncrmnt+1
'		End If
'	Next
'
'	For intCnt=1 to intIncrmnt
'
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("ChangeResponsibility"&intCnt-1).value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("ChangeResponsibility"&intCnt-1).value
'		End If
'	
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			OracleNavigator("short title:=Navigator").SelectFunction "Setup:Transactions:Transaction Types"
'			Wait(gSHORTWAIT)
''			Call gfReportExecutionStatus(micPass,"Navigation", "Navigated successfully to " & rsTestCaseData("ChangeResponsibility"&intCnt-1).value & " > Setup > Transactions > Transaction Types")
'		End If
'
'		Set objParent=OracleFormWindow("short title:=Transaction Types")
'
'		objParent.SelectMenu "View->Query By Example->Enter"
'		objParent.OracleTextField("description:=Name","index:=0").Enter rsTestCaseData("Name"&intCnt-1).value
'		objParent.OracleTextField("description:=Description","index:=0").Enter rsTestCaseData("Description"&intCnt-1).value
'		objParent.SelectMenu "View->Query By Example->Run"
'		Wait(2)
'		strMessage=OracleStatusLine("error code:=.*").GetROProperty("message")
'		If strMessage = "" Then
'			objParent.OracleTextField("description:=End Date","index:=0").Enter rsTestCaseData("EndDate"&intCnt-1).value
'			objParent.OracleTabbedRegion("label:=Accounts", "index:=0").OracleTextField("description:=Receivable Account","index:=0").Enter rsTestCaseData("ReceivableAccount"&intCnt-1).value
'			objParent.OracleTabbedRegion("label:=Accounts", "index:=0").OracleTextField("description:=Revenue Account","index:=0").Enter rsTestCaseData("RevenueAccount"&intCnt-1).value
'			objParent.OracleTabbedRegion("label:=Accounts", "index:=0").OracleTextField("description:=Tax Account","index:=0").Enter rsTestCaseData("TaxAccount"&intCnt-1).value
'			 If Err.Number = 0 Then
'				Call gfReportExecutionStatus(micPass,"Setup Transaction Types", "Successfully added accounts to Transaction Type: " & rsTestCaseData("Name"&intCnt-1).value & " for region: " & rsTestCaseData("ChangeResponsibility"&intCnt-1).value)
'			End If
'		ElseIf Instr(Lcase(strMessage),"query caused no records") Then
'			objParent.SelectMenu "View->Query By Example->Cancel"
'			Call gfReportExecutionStatus(micFail,"Failed to set accounts for " & rsTestCaseData("Name"&intCnt-1).value & " Transaction Type in responsibility " & rsTestCaseData("ChangeResponsibility"&intCnt-1).value, "Failed to set accounts for " & rsTestCaseData("Name"&intCnt-1).value & " Transaction Type in responsibility " & rsTestCaseData("ChangeResponsibility"&intCnt-1).value)
'		End If
'
'		'Save details
'		objParent.SelectMenu "File->Save"	
'
'		'Close the Transaction Types form
'		objParent.CloseWindow
'
'	Next
'
'    If Err.Number <> 0 Then
'		Call gfReportExecutionStatus(micFail,"Error Description",Err.Description)
'		On Error Goto 0
'		bSuccess = False
'	End If
'
'	func_AR_TransTypes_Setups = bSuccess
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Accounts Receivables Transaction Types Setup **********","********** Accounts Receivables Transaction Types Setup is successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Accounts Receivables Transaction Types Setup **********","********** Accounts Receivables Transaction Types Setup has Failed **********")
'	End If
'
'	Set objParent = Nothing
'
'End Function
'
''********************************************************************************************************************************************************************************************
''# Function:   func_FA_Setups_CA()
''# Function is used to remove end dates for CA region GBL accounts and segments
''#
''# Input Parameters: None
''#
''# OutPut Parameters: boolean
''#  
''# Usage: Function needs to be executed from KeyActions keyword.
''*******************************************************************************************************************************************************************************************
'
'Function func_FA_Setups_CA()
'
'	Dim bSuccess: bSuccess = True
'
'	'Reading the excel data for MBS FA Setups_CA
'	Call  gFuncReadExcel(Environment("TestDataPath")&"\"&Split(DataTableBook,".xls")(0)&"_TestData.xls",DataTableSheet,"ScenarioName='MBS_FA_Setups_CA'",rsTestCaseData)
'
'	Call gfReportExecutionStatus(micPass,"********** Start of Fixed Assets CA Setup **********","********** Fixed Assets CA Setup has Started **********")
'
'	If Browser("name:=Oracle Applications Home Page").Page("title:=Oracle Applications Home Page").Exist(gLONGWAIT) Then
'		If OracleNavigator("short title:=Navigator").Exist(gLONGWAIT) Then
'			strTitle = OracleNavigator("short title:=Navigator").GetROProperty("title")
'			If NOT Instr(strTitle,rsTestCaseData("Responsibility").value) > 0 Then
'				OracleNavigator("short title:=Navigator").SelectMenu "File->Switch Responsibility..."
'				Wait(3)
'			End If
'		End If
'		
'		If OracleListOfValues("title:=Responsibilities").Exist(gSHORTWAIT) Then
'			OracleListOfValues("title:=Responsibilities").Select rsTestCaseData("Responsibility").value
'		End If
'
'		If OracleNavigator("short title:=Navigator").Exist(gMEDIUMWAIT) Then
'			If NOT OracleFormWindow("short title:=Find Key Flexfield Segment").Exist(gMEDIUMWAIT) Then
'				OracleNavigator("short title:=Navigator").SelectFunction "Setup:Financials:Flexfields:Key:Values"
'				Wait(gSHORTWAIT)
'				Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Financials > Flexfields > Key > Values")
'			End If
'		End If
'
'		If NOT OracleFormWindow("short title:=Find Key Flexfield Segment").Exist(gLONGWAIT) Then
'			Call func_ClickingLinks(rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0)
'			Wait(30)
'			Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Financials > Flexfields > Key > Values")
'		End If
'	Else
'		Call Login(rsTestCaseData("EBSUserName").value, rsTestCaseData("Responsibility").value, rsTestCaseData("Link").value, 0, "Oracle Applications Home Page","")
'		Wait(30)
'		Call gfReportExecutionStatus(micPass,"Navigation","Navigated successfully to " & rsTestCaseData("Responsibility").value & " > Setup > Financials > Flexfields > Key > Values")
'	End If
'
'	blnStatus = funcRemoveExpiryDates4SegmentValues()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	blnStatus = funcRemoveExpiryDates4GLAccount()
'	If blnStatus = False Then
'		bSuccess = False
'	End If
'
'	If bSuccess = True Then
'		Call gfReportExecutionStatus(micPass,"********** End of Fixed Assets CA Setup **********","********** Fixed Assets CA Setup is Successful **********")
'	Else
'		Call gfReportExecutionStatus(micFail,"********** End of Fixed Assets CA Setup **********","********** Fixed Assets CA Setup is Failed **********")
'	End If
'
'End Function
'
''=============================================ravikanth 24-nov-2014
'
''########################################################################################################################
''
''           PROGRAM NAME        	=          MDMLOGIN       
''
''########################################################################################################################
''
''           PURPOSE: Login to MDM Application by directly launching the oracle forms based on the parameter. 
''           Initial State          = Desktop
''           Final State            = 
''           INPUT PARAMETERS       = sstrUserName,strPassword, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow
''           OUTPUT PARAMETERS      = 
''            OWNER                 = DHO
''########################################################################################################################
'
'Function MDMLogin(strTabName, strResponsibility, strLink, strIndex, strBrowserWindow, strFormWindow)
'   'Declaration Part
'   Dim pstrStatus, strURL, bcontinue, intElapsedTime
'
'    Const FUNC_NAME="MDMLogin"
'
'	On Error Resume Next
'	pstrStatus="FAILED"
'	strURL = Environment.Value("MDMURL")
'
'    'Get the UserName and Password
'	Select Case UCase(strTabName)
'			Case "MCDEBSMDMUSER"
'					strUserName = Environment("EBSMDMUserName")
'					strPassword = Environment("EBSMDMPassword")
'			Case Else
'					strUserName = Environment("EBSUserName")
'					strPassword = Environment("EBSPassword")
'		End Select
'
'		'To get IE browser version
'        Const HKEY_LOCAL_MACHINE = &H80000002
'		strComputer = "."
'		Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
'		strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
'		strValueName = "Version"
'		oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
'		If cInt(Left(strValue,1)) >=8 Then
'			SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
'		Else
'			SystemUtil.Run "iexplore.exe",strURL,"","","3"' for IE7 and below
'		End If
'        
'		If Err.Number<>0 Then
'			On Error GoTo 0
'		End If
'
'    Call gfReportExecutionStatus(micPass,"Launch Browser","Browser Launched with URL	: "&strURL)	
'
'    If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(30) Then
'	
'		'Enter UserName
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Username.*").Set strUserName
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)	
'		'Enter  Password
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Password.*").Set strPassword
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		'Click on 'Login Button
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebButton("name:=Login").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Click on Login Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		Wait(25)
'        'Checking Login failed
'		If Browser("name:=Portal Home").Page("title:=Portal Home").Exist(15) Then
'			strText = Browser("name:=Portal Home").Page("title:=Portal Home").Object.body.innerText
'			If Instr(strText, "Invalid user name or password.") > 0 Then
'				pstrStatus="FAILED"
'				Exit Function
'			End If
'		End If
'        
'        'Sync
'		Browser("name:=Portal Home").Page("title:=Portal Home").Sync
'		Wait 5
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Activate Browser",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        If strResponsibility<>"" Then
'			'Click on Responsibility Link
'			Browser("name:=Portal Home").Page("title:=Portal Home").Link("text:="&strResponsibility, "html tag:=A").Click
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Select Responsibility","Responsibility '"&strResponsibility&"' is not available for this user")
'                Exit Function
'			End If
'			Call gfReportExecutionStatus(micPass,"Select Responsibility","Selected Responsibility : "&strResponsibility)	
'			Wait 5
'			If strLink <> "" Then
'				Browser("name:=Portal Home").Page("title:=Portal Home").Sync
'				'Click on Link
'				If Trim(strIndex) = "" Then
'					Browser("name:=Portal Home").Page("title:=Portal Home").Link("text:="&strLink,"index:=0").Click
'				Else
'					Browser("name:=Portal Home").Page("title:=Portal Home").Link("text:="&strLink,"index:="&strIndex).Click
'				End If
'
'				Call gfReportExecutionStatus(micPass,"Click Link","Clicked on Link : "&strLink)
'
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Click on Link", FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'			End If
'
'		Else
'				'Sync
'				Browser("name:="& strResponsibility).Page("title:="& strResponsibility).Sync
'				Wait 5
'				If Err.Number<>0 Then
'					Call gfReportExecutionStatus(micFail,"Activate Browser "& strResponsibility,FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'                    Exit Function
'				End If
'				Call gfReportExecutionStatus(micPass,strResponsibility &" window",strResponsibility & " window is displayed.")
'			'End If
'		End If
'	Else
'		pstrStatus="FAILED"
'	End If
'    pstrStatus="PASSED"
'	MDMLogin = pstrStatus
'End Function ' Login
'
''=============================================ravikanth 24-nov-2014
'
''########################################################################################################################
''
''           PROGRAM NAME        	=          DRMLOGIN    
''
''########################################################################################################################
''
''           PURPOSE: Login to DRM Application 
''           Initial State          = Desktop
''           Final State            = 
''           INPUT PARAMETERS       = sstrUserName,strPassword
''           OUTPUT PARAMETERS      = 
''            OWNER                 = DHO
''########################################################################################################################
'
'Function DRMLogin(strTabName)
'
'   'Declaration Part
'   Dim pstrStatus, strURL, bcontinue, intElapsedTime, intCount, iCount
'
'    Const FUNC_NAME="DRMLogin"
'
'	On Error Resume Next
'	pstrStatus="FAILED"
'	strURL = Environment.Value("DRMURL")
'
'    'Get the UserName and Password
'	Select Case UCase(strTabName)
'			Case "DRMCOAUSER1"
'					strUserName = Environment("DRMCOAUserName1")
'					strPassword = Environment("DRMCOAPassword1")
'			Case "DRMCCGUSER1"
'					strUserName = Environment("DRMCCGUserName1")
'					strPassword = Environment("DRMCCGPassword1")
'			Case "DRMMLOUSER1"
'					strUserName = Environment("DRMMLOUserName1")
'					strPassword = Environment("DRMMLOPassword1")
'			Case "DRMMLOUSER2"
'					strUserName = Environment("DRMMLOUserName2")
'					strPassword = Environment("DRMMLOPassword2")
'		End Select
'
'		'To get IE browser version
'        Const HKEY_LOCAL_MACHINE = &H80000002
'		strComputer = "."
'		Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
'		strKeyPath = "SOFTWARE\Microsoft\Internet Explorer"
'		strValueName = "Version"
'		oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
'		If cInt(Left(strValue,1)) >=8 Then
'			SystemUtil.Run "iexplore.exe", "-noframemerging "&strURL,"","","3" ' for IE 8 and above
'		Else
'			SystemUtil.Run "iexplore.exe",strURL,"","","3"' for IE7 and below
'		End If
'
'        Wait(5)
'
'		If Err.Number<>0 Then
'			On Error GoTo 0
'		End If
'
'    Call gfReportExecutionStatus(micPass,"Launch Browser","Browser Launched with URL	: "&strURL)	
'
''-------------------------------------------------ravikanth 14-Dec-2014
'    If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(20) Then
'	
'		'Enter UserName
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Username.*").Set strUserName
'		If Err.Number<>0 Then
'            Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)	
'		'Enter  Password
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebEdit("name:=.*Password.*").Set strPassword
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'		
'		'Click on 'Login Button
'		Browser("name:=MCD Login").Page("title:=MCD Login").WebButton("name:=Login").Click
'		If Err.Number<>0 Then
'			Call gfReportExecutionStatus(micFail,"Click on Login Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'            Exit Function
'		End If
'
'        'Checking Login failed
'		If Browser("name:=MCD Login").Page("title:=MCD Login").Exist(5) Then
'			strText = Browser("name:=MCD Login").Page("title:=MCD Login").Object.body.innerText
'			If Instr(strText, "Invalid user name or password.") > 0 Then
'				pstrStatus="FAILED"
'				Exit Function
'			End If
'		End If
'	Else
''-------------------------------------------------ravikanth 14-Dec-2014
'		Set objDesc = Description.Create()
'		objDesc("nativeClass").Value = "#32770"
'		Set objDialogs = Desktop.ChildObjects(objDesc)
'	
'		' Close all the dialogs
'		For iCount = 0 To objDialogs.Count - 1
'			If objDialogs(iCount).GetROProperty("text") = "Windows Security" Then
'				intCount = iCount
'				Exit For
'			End If
'		Next
'	
'		If objDialogs(intCount).WinEdit("nativeclass:=Edit","index:=0").Exist(20) Then
'	
'			'Enter UserName
'			objDialogs(intCount).WinEdit("nativeclass:=Edit","index:=0").Set "Corp\" & strUserName
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Enter User Name",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'				Exit Function
'			End If
'			Call gfReportExecutionStatus(micPass,"Enter User Name","Logged in User Name : "&strUserName)	
'	
'			'Enter  Password
'			objDialogs(intCount).WinEdit("nativeclass:=Edit","index:=1").Set strPassword
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Enter Password",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'				Exit Function
'			End If
'			
'			'Click on 'Login Button
'			objDialogs(intCount).WinButton("text:=OK").Click
'			If Err.Number<>0 Then
'				Call gfReportExecutionStatus(micFail,"Click on OK Button",FUNC_NAME & "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
'				Exit Function
'			End If
'	
'			Wait(5)
'	
'			'Checking Login failed
'			If objDialogs(intCount).WinEdit("nativeclass:=Edit","index:=0").Exist(5) Then
'				pstrStatus="FAILED"
'				Exit Function			
'			End If
'	
'		End If
'	End If
'    pstrStatus="PASSED"
'
'	DRMLogin = pstrStatus
'
'End Function
''########################################################################################################################
''
''           PROGRAM NAME        	=         UserActionOnItemReq      
''
''########################################################################################################################
'''           PURPOSE: To perform Approval/Claim/Mark Complete actions on the Items assigned to users
''            INPUT PARAMETERS       = Item Request number(NPRRequestID/CO ID, UserAction) While ITEm creation, CO number for Change oreder, User action: approve/Calim/Mark complte/Reject and send user(approver) name and comment seperated by $
''										Eg:UserActionOnItemReq(NPR123XX NotificationMsg, Approve) or 
''											UserActionOnItemReq(NPR123XX, Notification,Mark Complete;UserName$Comment)--if user ants to add task with approver name and comment
''           OUTPUT PARAMETERS      = 
''            OWNER                 = DOH 
''			Resource:Triveni P					 Date:08/01/2020					Remarks
''########################################################################################################################
Function UserActionOnItemReq(RequestID,Notification,UserAction )	

	err.clear
	On error resume next
	
	UActions = Split(UserAction, ";")
	Set wsh = CreateObject("Wscript.Shell")
	
	If Ubound(UActions)>0 Then
		
		Action = UActions(0)
		Task = UActions(1)
		Taskaction = Split(Task, "$")
		UserName = Taskaction(0)
		Comment = Taskaction(1)
	else	
	Action = UserAction
	Task = ""
	
	End If
	
	
	Set Pgobj = Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*")
		
'	.Link("name:=Product Information Management").Click
	Wait(2)
	Pgobj.Link("name:=^Notifications.*", "visible:=True", "class:=svg-glob xko p_AFIconOnly").Click	
		Wait(2)	
	Pgobj.WebEdit("name:=pt1:_UISatr:0:it1").Set RequestID
	Pgobj.Image("html tag:=IMG","title:=Search","visible:=True", "class:=x11a").Click	
		Wait(2)
	If instr(1, RequestID,"NPR")>0 Then
	''Check the notification message if not exists refresh and check aroundd 100 sec 
		For	timeitr = 1 to 10
		if Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*").Link("name:=^"&Notification&".*","visible:=True").Exist(10) then
		NotifnChk = "True"
		Wait 5		
		Exit for
		ElseIf Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*").Link("name:=^"&Notification&".*","visible:=True", "index:=0").Exist(10) then
		NotifnChk = "True" 
		Wait 5
		Exit for
		else
		wsh.SendKeys "{F5}"
		Wait(5)
		Pgobj.Link("name:=^Notifications.*", "visible:=True", "class:=svg-glob xko p_AFIconOnly").Click
		Wait(2)	
		Pgobj.WebEdit("name:=pt1:_UISatr:0:it1").Set RequestID
		Pgobj.Image("html tag:=IMG","title:=Search","visible:=True", "class:=x11a").Click
		Wait(2)		
		end if
		timeitr = timeitr+1
		Next
		
		'# Notification verification and Approving/Rejecting th items
		If NotifnChk = "True" Then
			
			'			.Link("name:=^Action Required: New Item Request .*Requires .*", "visible:=True").Click
			if Pgobj.Link("name:=^"&Notification&".*", "visible:=True", "index:=0").Exist(3) then
			Pgobj.Link("name:=^"&Notification&".*", "visible:=True", "index:=0").Click
			Wait 5			
			elseif Pgobj.Link("name:=^"&Notification&".*", "visible:=True").Exist(10) then
			Pgobj.Link("name:=^"&Notification&".*", "visible:=True").Click
			Wait(gSHORTWAIT)
			end if
	
			'##User Action--Approve/Calim/mark complte/Reject
				if Browser("name:=New Item Request.*").page("title:=New Item Request.*").Exist(gLONGWAIT) then
					
					If Task = "" Then
					Browser("name:=New Item Request.*").page("title:=New Item Request.*").WebButton("name:="&UserAction).Click	
					Wait 1
					UserActionOnItemReq = True
					else
					 Success  = AddTask(UserName,Comment)
						If Success = "True" Then
							Call gfReportExecutionStatus(micPass, "Task Added", "Task Added: with approved user: "& UserName )
							UserActionOnItemReq = "True"
						else
						Call gfReportExecutionStatus(micFail, "Task not Added", "Task Added: with approved user: "& UserName )
						UserActionOnItemReq = "False"
						Exit Function
						End If
					End If		
												
				
				else
				
				Call gfReportExecutionStatus(micFail, "Notification Status", "Notification Status"& UserAction&" for Request:  "& RequestID & "deosn't Exists")
				UserActionOnItemReq = False
				
				end if
		
		else
	
		Call gfReportExecutionStatus(micFail, "Notification Verification", "Action Item Notification for Request:  "& RequestID & " doesn't exist")
		UserActionOnItemReq = False	
		End if
	
	ElseIf instr(1,RequestID, "DOH")>0 Then
	
		 if Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*").Link("name:=^Action Required: Change Order "&RequestID&" Requires Approval.*","visible:=True").Exist(gSYNCWAIT) then
		 
			Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*").Link("name:="&UserAction, "visible:=True").Click
						Wait(2)
			Call gfReportExecutionStatus(micPass, "CO Notification", "CO Notification for :  "& RequestID & "exist's and action performed")
			UserActionOnItemReq = True	
		else
		
		Call gfReportExecutionStatus(micFail, "CO Notification", "CO Notification for:  "& RequestID & "deosn't exist")
			UserActionOnItemReq = False	
		
		End if 
		
			If err.Number = "0" Then
				UserActionOnItemReq = True	
			else
			UserActionOnItemReq = "False"	
			Call gfReportExecutionStatus(micFail, "CO Notification", "Notification for:  "& RequestID & "doesn't exist"&" Error is"&Err.Description)		
			End If
			
	 End if	

	If Browser("name:=^Product Information Management.*", "index:=1").Exist(gSHORTWAIT) Then
		Browser("name:=^Product Information Management.*", "index:=1").Close
	End If
	
	Err.Clear
End Function

'###################################################
''To add task  while Approving/Marking as complete....Internal function called in UserActionOnItem.
Function AddTask(UserName, Comment)
	err.clear
	On error resume next
Set PgObj=	Browser("name:=^New Item Request.*").page("title:=^New Item Request.*")
PgObj.Image("alt:=Go to Task", "class:=xo1", "index:=0","visible:=True").Click

	Set wsh = CreateObject("Wscript.Shell")
	
	Set PgObj=	Browser("name:=^Items of New Item Request.*").page("title:=^Items of New Item Request.*")

	if PgObj.Image("alt:=Add Row", "class:=x1qe", "visible:=True").Exist(gLONGWAIT) then
	PgObj.Image("alt:=Add Row", "class:=x1qe", "visible:=True").Click
	Wait(1)
	PgObj.WebEdit("name:=.*rowIdentifier$", "visible:=True").Set "1"
	PgObj.WebElement("html id:=.*approv.*Label0$", "class:=x1dy", "visible:=True").Click
	PgObj.WebEdit("name:=.*comments$", "visible:=True").Set Comment
'	PgObj.WebEdit("name:=.*ATt1:0:approvedBy$", "visible:=True").Set "CAPA"
	PgObj.WebEdit("name:=.*approve.*", "visible:=True", "class:=x25").Set UserName
	
	If PgObj.WebEdit("name:=.*capaDecision$", "visible:=True", "class:=x112").Exist(5) Then
		PgObj.WebEdit("name:=.*capaDecision$", "visible:=True", "class:=x112").Click
		wsh.SendKeys "{DOWN}"
		wait(1)
		PgObj.WebElement("innertext:=Approved", "class:=x2s3", "visible:=True","index:=0").Click
		
	End If
'	If TaskStatus = "Completed"  Then
				
	PgObj.WebList("name:=.*AP1:soc1$", "visible:=True").Select "Completed"
	PgObj.WebButton("name:=Save", "visible:=True").Click
	PgObj.Sync
	wait(3)
	PgObj.WebButton("name:=Mark Complete",  "visible:=True").Click
	PgObj.SynC
	
	If PgObj.WebButton("name:=Yes","visible:=True").Exist(gLONGWAIT) Then
	    PgObj.WebButton("name:=Yes","visible:=True").Click
	End If
	
	 Browser("name:=^Product Information Management.*", "index:=2").Close
	 Browser("name:=^New Item Request.*").Close
		 If err.Number <>0 Then
		 	AddTask = "False"		 	
		 	else
			AddTask = "True"
		 End If
	else
	AddTask = "False"
	End If
	
End Function
'########################################################################################################################
''
''           PROGRAM NAME        	=         bfuncCOCreationandApproval(Product/Item Status change to carte Change Order)      
''
''########################################################################################################################
'''  PURPOSE: To change the Product/Item Status  to create Change Order and make it approved by using responsible assigned users.
''  Function Name: bfuncCOCreationandApproval         
'''INPUT PARAMETERS       = bfuncCOCreationandApproval(ProductID/COid,StatusTobeChanged, UseridtoCheckCOstatus, StepId) 
'' OUTPUT PARAMETERS      =  True /False
''  OWNER                 = DOH 
''Resource:Triveni P					 Date:14/01/2020					Remarks:Assigned users credentials should be defined in Automation Environmental varaibles.
''########################################################################################################################
Function bfuncCOCreationandApproval(ProductID,StatustoBeChanged,SSOUsertoCheckCOWF, StepId)
	err.clear
On error resume next
If not instr(1,ProductID, "DOH")>0 Then
COId = PrdStatusChangeAndSavetoCO(ProductID,StatustoBeChanged)
else
COId = ProductID
End If
		
	If COId <> "False" Then
		
		   Do 
				ApproverName = ProcessCOAndGetWFApproverName(COId)	
				
				If ApproverName = "True" Then
				Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").WebElement("html id:=.*rmAbv$", "visible:=True", "class:=x1mx").Click
				Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").WebElement("html id:=.*rmAbv$", "visible:=True", "class:=x1mx").Click
				ElseIf instr(1,ApproverName,"test")>0  Then
				funcCloseBrowser ".*Oracle Applications.*", ""
				Success = CheckCOApprovarandApprove(ApproverName,COId)
					If  Success = "True" then					
						call gfReportExecutionStatus(micDone,"CO WF Approved"," CO id: "&COId& " Approved by user "&ApproverName)
						OracleSSOLogin SSOUsertoCheckCOWF, "You have a new home page!"
						
			if Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").WebElement("innertext:=Product Management", "class:=app-nav-label top-nav-label.*", "visible:=True").Exist(4) then
				Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").WebElement("innertext:=Product Management", "class:=app-nav-label top-nav-label.*", "visible:=True").Click	
			End if					
						Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").Link("name:=Product Information Management", "visible:=True").Click
					else
					call gfReportExecutionStatus(micFail,"CO WF Approval Failed"," CO id: "&COId& " not Approved by user "&ApproverName&" Check the Notification exist or not")
						bfuncCOCreationandApproval = "False"
					end if
	 			else
	 			call gfReportExecutionStatus(micFail,"CO not created for Product "&ProductID,"Check Product and Status "&StatustoBeChanged, "")
					bfuncCOCreationandApproval = "False"
				Exit Function
				End if
				
			Loop Until (instr(1, ApproverName, "True")>0)
			
			
	else
		call gfReportExecutionStatus(micFail,"CO not created for Product "&ProductID,"Check Product and Status "&StatustoBeChanged, "")
		bfuncCOCreationandApproval = "False"
		Exit Function
	End if
		
		If Err.Number<>0 Then
			Call gfReportExecutionStatus(micFail,"CO creation and approval", "->" & "Error Number=" & CStr(Err.Number) & ", Description=" & Err.Description)
			bfuncCOCreationandApproval = "False"
		Exit Function
		
		else
		Call gfReportExecutionStatus(micPass,"COCreationandApproval", "CO ID: "&COId&"Created and Approved for Product:"& ProductID)
		bfuncCOCreationandApproval = "True"
		dicGlobalOutput.Add StepID, COId
		End If
		
End function 

 ''##########
Function AccessCOWF(COId)
err.clear
On error resume next'
 Set PgObj = Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
	PgObj.Image("alt:=Tasks", "visible:=True").Click
	PgObj.Sync
	PgObj.Link("name:=Manage Change Orders", "visible:=True").Click
	PgObj.Sync
wait(2)	
If PgObj.WebButton("title:=Expand Advanced Search", "visible:=True").Exist(gLONGWAIT) Then
	PgObj.WebButton("title:=Expand Advanced Search", "visible:=True").Click
End If	
	PgObj.WebList("name:=^pt1:.*q1:value00$","visible:=True").Select "DOH Product Change Request"
	Wait(2)
	PgObj.WebEdit("name:=^pt1:.*AP1:r1:0:q1:value10$").Set COId
	Wait(2)
	PgObj.WebList("name:=^pt1:.*AP1:r1:0:q1:value30$").Select "#0"
	Wait(2)
	PgObj.Sync
	PgObj.WebEdit("name:=^pt1:.*:q1:value60$").Set empty
	PgObj.WebButton("name:=Search", "visible:=True").Click
	PgObj.Sync
	  Wait(1)
		  if PgObj.WebTable("cols:=3","column names:=^;DOH.*", "visible:=True").Exist(gLONGWAIT) then
		  PgObj.WebTable("cols:=3","column names:=^;DOH.*", "visible:=True").Link("name:="&COId,"visible:=True").Click
				IF Browser("name:=.*Change Order.*").page("title:=.*Change Order.*").Exist(gSHORTWAIT) THEN
				PgObj =  Browser("name:=.*Change Order.*").page("title:=.*Change Order.*")
				PgObj.Image("alt:=Workflow").Click
				PgObj.Sync
				Else
				AccessCOWF = "False"
				Call gfReportExecutionStatus(micFail, "Get CO", "CO id "& COId & " Not listed in Search Results")
				Exit Function
				end if
			  
			  AccessCOWF = "True"
			   Call gfReportExecutionStatus(micPass, "Access CO WorkFlow", "CO id"& COId & "Workflow accessed")
		  Else
		  AccessCOWF = "False"
		  Call gfReportExecutionStatus(micFail, "Get CO", "CO id "& COId & " deosn't exist: Error is"&Err.description)
		  Exit Function
		  end if
 
  
  End  Function
  
''########## 
Function ProcessCOAndGetWFApproverName(COId)
err.clear
  	On error resume next
  
  Success = AccessCOWF(COId)
  If Success = "True" Then 

	''To open the CO
		With Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")	
		Colnames =  .WebTable("html id:=.*.dc_pgl5.*").GetROProperty("column names")
			If instr(1,Colnames, "Draft")>0 Then
			.Link("innertext:=Change Status", "visible:=True", "name:=Change Status").Click
			.WebElement("innertext:=Open", "visible:=True", "class:=xnw").Click
			Wait(gSHORTWAIT)		
			End If
		End with
  
  	CORefresh()
	Colnames =  Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").WebTable("html id:=.*.dc_pgl5.*","cols:=8").GetROProperty("column names")
	AllColms = Split(Colnames, ";")
	
	For Flowno = 1 To Ubound(AllColms)+1
	
		Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebTable("html id:=.*.dc_pgl5.*","cols:=8").ChildItem(1,Flowno,"WebTable",1).Click
		wait(gSHORTWAIT)
		
		'To handle CAPA And CTM Approvals
		CORefresh()
		
		
		Flowname = GetWorkflowstatus(Flowno)
		
		If  not instr(1, Flowname,"Completed")>0 Then 
			If not instr(1, Flowname,"DM Review")> 0 and  not instr(1, Flowname,"6 Approval")> 0 Then
				
		For iter = 1 To 3
			CORefresh()
			wait(3)
		Next			
				Username = GetApprovalName()
				
			 Select case trim(Username)
				
				 Case "NA"					
					Flowname = GetWorkflowstatus(Flowno)	
				countr = 0					
					Do until instr(1, Flowname, "Completed")>0 or Username <> "NA" or countr > 20
					CORefresh()
					countr= countr+1
					Flowname = GetWorkflowstatus(Flowno)
					Username = GetApprovalName()					
					Loop				
		
				 Case ""
				
					Call gfReportExecutionStatus(micFail,"Automation Approvers not Avilable","for CO "&COId& " Approval : "&Flowname)
					ProcessCOAndGetWFApproverName = "False"
					Exit Function
			 	
				 Case else
				
				   ProcessCOAndGetWFApproverName = Username
				   Call gfReportExecutionStatus(micPass,"WF Approver name fetched","For CO "&COId& " Approvar is : "&Username &" for Flow: "&Flowname)
					
					Exit Function
							
		  	End select
		  
		elseif instr(1, Flowname,"DM Review")> 0 then
			CORefresh()
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").Link("name:=Change Status","innertext:=Change Status").Click
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebElement("innertext:=CTM Approval", "visible:=True", "class:=xnw").Click
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebEdit("name:=.*0:AP2:r4:0:it2.*", "visible:=True").Set "Test"
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebButton("name:=Submit", "visible:=True").Click
			Wait(gSYNCWAIT)
			CORefresh()
			Flowname = GetWorkflowstatus(Flowno)	
				Do until Instr(1, Flowname, "Completed")>0 
				CORefresh()
				Flowname = GetWorkflowstatus(Flowno)
				Loop	
			
		elseif instr(1, Flowname,"6 Approval")> 0 then	''fOR 6TH Step Approval
			
			do while (Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebButton("name:=Approve", "visible:=True").Exist(gLONGWAIT) = False)
			Refresh()
			Loop 
			
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebButton("name:=Approve", "visible:=True").Click
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").Sync
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebEdit("name:=.*AP2:r3:0:it1.*","visible:=True").Set "Test"
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").Sync
			Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*").WebButton("name:=Approve","class:=.*AFTextOnly","html id:=.*:cb1$", "visible:=True").Click
			Wait(gSYNCWAIT)
		
			
				Flowname = GetWorkflowstatus(Flowno)
		
			Do until instr(1, Flowname, "Completed")>0 
			wait(1)
			CORefresh()
			Flowname = GetWorkflowstatus(Flowno)			
			Loop 
			
		 end if
		
	  End if	

  Next 
	
else
	Call gfReportExecutionStatus(micFail,"CO ID not listed"," CO "&COId& " Doesn't exist")
	ProcessCOAndGetWFApproverName = "False"
	Exit Function

End if	 'if CO  exists
	err.clear
	
	If Username <> "" and Flowno = "9" Then
		Call gfReportExecutionStatus(micPass,"CO Approved"," CO "&COId& " Approved")
	ProcessCOAndGetWFApproverName = "True"
	Exit Function
	End If
 
End Function
	
''##########	
Function PrdStatusChangeAndSavetoCO(ProductID,StatustoBeChanged)
	err.clear

	On error resume next
	Success = bfuncEditProduct(ProductID)
	
	If Success = "True" Then
		With Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
	 			 .WebList("name:=.*0:pt1:ap1:r10:0:isst").Select StatustoBeChanged
'				Wait(gMEDIUMWAIT)
				if Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").WebButton("name:=OK","visible:=True").Exist(gLONGWAIT) then
				 .WebButton("name:=OK","visible:=True").Click
				else
			
				Call gfReportExecutionStatus(micFail, "Product Status Update", "Product is already with Status :"&StatustoBeChanged)
				PrdStatusChangeAndSavetoCO = "False"
				end if
			
			
'			if .WebButton("name:=OK","visible:=True").WaitProperty("disabled","0",gLONGWAIT) = true then
'			.WebButton("name:=OK","visible:=True").Click
'			End if
'		 .Sync
'		 .WebElement("html id:=.*0:pt1:ap1:csavebtn::popEl","visible:=True").Click
'		 .WebElement("innertext:=Save to Change Order", "class:=xnw","visible:=True").Click	
			.WebButton("name:=Save","visible:=True").Click
			wait(gSYNCWAIT)
		 .WebEdit("name:=.*0:pt1:ap1:SelCh:0:r3:0:typeNameId").Set "DOH Product Change Request"
		 .WebButton("name:=Next","visible:=True").Click
		 .WebEdit("name:=.*0:pt1:ap1:SelCh:0:r1:0:it5").Set "AUTO CO"&ProductID
		.WebEdit("name:=.*0:pt1:ap1:SelCh:0:r1:0:it6").Set "CO Desc "&ProductID
		 .WebButton("name:=Save and Edit", "visible:=True").Click
		 .Sync
		 Wait(gSHORTWAIT)
		 Set PgObj = Browser("name:=Change Order.*").page("title:=Change Order.*")
		 
		 COReqNum = PgObj.WebElement("html id:=.*0:AP2:it3::content", "visible:=True").GetROProperty("innertext")
		
		 End With
		 
		PrdStatusChangeAndSavetoCO = COReqNum  
		
		'Select Workflow and Make the CO as open
		With Browser("name:=.*Change Order.*").page("title:=.*Change Order.*")
			.Image("alt:=Workflow").Click
			.Sync
			Wait(gSHORTWAIT)
			.Link("innertext:=Change Status", "visible:=True", "name:=Change Status").Click
			.WebElement("innertext:=Open", "visible:=True", "class:=xnw").Click
			Wait(gSHORTWAIT)			
				With Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*")
				.WebElement("html id:=.*rmAbv$", "class:=x1mx", "visible:=True").Click
				Wait(2)
				.WebElement("html id:=.*rmAbv$", "class:=x1mx","visible:=True").Click
				end with
		
		End With
		
		If Err.Number<>0 Then
			Call gfReportExecutionStatus(micFail,"CO Creation", "for Product :"&ProductID&" Failed "  & CStr(Err.Number) & ", Description=" & Err.Description)
			PrdStatusChangeAndSavetoCO = "False"
		Exit Function
		
		else
		Call gfReportExecutionStatus(micPass,"CO Created", "CO ID: "&COReqNum&"Created for Product:"& ProductID)
		PrdStatusChangeAndSavetoCO = COReqNum
		dicGlobalOutput.add TestStepID , COReqNum
		 end if 
	else
		Call gfReportExecutionStatus(micFail,"CO Creation", "for Product :"&ProductID&" Failed "  & CStr(Err.Number) & ", Description=" & Err.Description)
			PrdStatusChangeAndSavetoCO = "False"
		Exit Function
	end if

  End  Function
''########################################################################################################################
'''  PURPOSE: To access the Product by searching in manage items
''  Function Name: bfunEditProduct         
'''INPUT PARAMETERS       = bfunEditProduct(ProductID) 
'' OUTPUT PARAMETERS      =  True /False
''  OWNER                 = DOH 
''Resource:Triveni P					 Date:14/01/2020					Remarks:Assigned users credentials should be defined in Automation Environmental varaibles.
''########################################################################################################################
	
	Function  bfuncEditProduct(ProductID)
	err.clear
	On error resume next
		With Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
		.Image("alt:=Tasks", "visible:=True").Click
		.Sync
		.Link("name:=Manage Items", "visible:=True").Click
		Wait(gSHORTWAIT)
		'		With Browser("name:=Manage Items.*").page("title:=Manage Items.*")
		.WebList("name:=.*0:pt1:ItemC1:0:simplePanel1:region2:0:efqrp:operator0.*").Select ("Equals")
		.Sync
		.WebEdit("name:=.*0:pt1:ItemC1:0:simplePanel1:region2:0:efqrp:value00").DoubleClick
		.WebEdit("name:=.*0:pt1:ItemC1:0:simplePanel1:region2:0:efqrp:value00").Set ProductID
		.Sync
		wait(gSHORTWAIT)
		.WebButton("name:=Search", "visible:=True").Click
		.Sync
		Wait(gSHORTWAIT)
		if .WebTable("column names:=.*"&ProductID&".*", "cols:=10").Exist(gLONGWAIT) then
		
		.Link("name:="&ProductID, "visible:=True").Click
		.Sync
		bfuncEditProduct = "True"
'		.WebElement("html id:=.*rmAbv$", "class:=x1mx", "visible:=True").Click
'		Wait(2)
'		.WebElement("html id:=.*rmAbv$", "class:=x1mx","visible:=True").Click
		else
		
		Call gfReportExecutionStatus(micFail, "Product Status Update", "Product number "& ProductID & "deosn't exist")
		bfuncEditProduct = "False"
		Exit Function
		
		end if
	End with
End function
			
			
''##########	
Function GetWorkflowstatus(Flowno)
'	
err.clear
On error resume next
with Browser("name:=.*Oracle Applications*").Page("title:=.*Oracle Applications.*")
Colnames = .WebTable("html id:=.*.dc_pgl5.*").GetROProperty("column names")
AllColms = Split(Colnames, ";")
GetWorkflowstatus = AllColms(Flowno-1)
End with
End Function
''##########	
Sub CORefresh()

Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*").Image("alt:=Refresh","html id:=.*:AP2:ctb1::icon").Click	
Wait(2)
End Sub	
''##########
Function CheckCOApprovarandApprove(Username,COId)
err.clear
On error resume next
Select Case trim(Username)

Case "test automation1", "test.automation1@nhssc.com"


	bSuccess =  OracleSSOLogin("SSOTESTUSER1", "You have a new home page!")
		If bSuccess = "PASSED" Then
		Success = UserActionOnItemReq(COId, "^Action Required: Change Order","Approve")	
		CheckCOApprovarandApprove = Success
		End If
		funcCloseBrowser ".Oracle Applications.*", "0"

Case "test automation2", "test.automation2@nhssc.net"
	 bSuccess =  OracleSSOLogin("SSOTESTUSER2", "You have a new home page!")
		If bSuccess = "PASSED" Then
		Success = UserActionOnItemReq(COId,"^Action Required: Change Order","Approve")	
		CheckCOApprovarandApprove = Success
		brclose = funcCloseBrowser (".*Oracle Applications.*", "")
		End If
		
	Case "test automation3", "test.automation3@nhssc.net"
		bSuccess =  OracleSSOLogin("SSOTESTUSER3", "You have a new home page!")
			If bSuccess = "PASSED" Then
			Success = UserActionOnItemReq(COId, "^Action Required: Change Order","Approve")	
			CheckCOApprovarandApprove = Success
			brclose = funcCloseBrowser (".*Oracle Applications.*", "")
			End If
			
			
		Case "test automation6", "test.automation6@nhssc.net"
		bSuccess =  OracleSSOLogin("SSOTESTUSER6", "You have a new home page!")
			If bSuccess = "PASSED" Then
			Success = UserActionOnItemReq(COId, "^Action Required: Change Order", "Approve")
			CheckCOApprovarandApprove = Success
			brclose = funcCloseBrowser (".*Oracle Applications.*", "")
			End If
			
			
		Case "test.user6@nhssc.net"
			bSuccess =  OracleSSOLogin("SSOUSER6", "You have a new home page!")
				If bSuccess = "PASSED" Then
				Success = UserActionOnItemReq(COId, "^Action Required: Change Order", "Approve")					
				CheckCOApprovarandApprove = Success
				brclose = funcCloseBrowser (".*Oracle Applications.*", "")
			End If	
			
		
		Case "test.user8@nhssc.net"	
			bSuccess =  OracleSSOLogin("SSOUSER8", "You have a new home page!")
			If bSuccess = "PASSED" Then
			Success = UserActionOnItemReq(COId, "^Action Required: Change Order", "Approve")				
			CheckCOApprovarandApprove = Success
			brclose = funcCloseBrowser (".*Oracle Applications.*", "")
			end if
		Case "test.user2@nhssc.net"	
			bSuccess =  OracleSSOLogin("SSOUSER2", "You have a new home page!")
			If bSuccess = "PASSED" Then
			Success = UserActionOnItemReq(COId, "^Action Required: Change Order", "Approve")				
			CheckCOApprovarandApprove = Success
			brclose = funcCloseBrowser (".*Oracle Applications.*", "")
			End If	
			
	
End Select

End  Function 

'#############################
Function GetApprovalName()	
err.clear
On error resume next
Set Usernames = Description.Create()
Usernames("micclass").value = "WebTable"
Usernames("cols").value = "5"
Usernames("innertext").value= ".*Awaiting Approval.*"
Browser("Welcome").Page("DOH Product Change Request:").WebTable("column names:=^General Information.*", "cols:=2").Highlight
'Browser("Welcome").Page("DOH Product Change Request:").WebTable("column names:=^General Information.*", "cols:=2").WebTable("cols:=5", "innertext:=.*dxc.com.*").Highlight
Set userscollection =Browser("Welcome").Page("DOH Product Change Request:").ChildObjects(Usernames)
cnt =  userscollection.Count

If cnt = "0" Then
	GetApprovalName = "NA"
	Exit Function
End If
For j =0 to cnt-1
'userscollection(j).Highlight

	rowcount = userscollection(j).GetRoProperty("rows")
	
	For i = 1 To rowcount 
	username=	userscollection(j).GetCellData(i, 1)	
	If instr(1,username,"automation")>0 Then
	success = "True"
	GetApprovalName = username
	Exit for
	
	ElseIf instr(1,username,"test.user6")>0 or instr(1,username,"test.user8")>0 Then
	success = "True"
		GetApprovalName = username
		Exit for
	ElseIf username = "" Then
	success = "True"
		GetApprovalName = "NA"
		Exit for
	End If
	
	Next
	
	If success = "True" Then
		Exit For
	End If
	
Next

End Function


''########################################################################################################################
'''  PURPOSE: To access the Product by searching in manage items
''  Function Name: gfunFetchProductIDfromNPR         
'''INPUT PARAMETERS       = NPRID-New Product Request number 
'' OUTPUT PARAMETERS      =  True /False
''  OWNER                 = DOH 
''Resource:Triveni P					 Date:14/01/2020					Remarks:Assigned users credentials should be defined in Automation Environmental varaibles.
''########################################################################################################################

Function gfunFetchProductIDfromNPR (ByVal NPRId, ByVal StepID)
	
err.clear
On error resume next
	With Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
		.Image("alt:=Tasks", "visible:=True").Click
		.Sync
		.Link("name:=Manage New Item Requests", "visible:=True").Click
		Wait(gSHORTWAIT)
		.WebList("name:=.*operator0.*").Select ("Equals")
		.Sync
		.WebEdit("name:=.*value00$").DoubleClick
		.WebEdit("name:=.*value00$").Set NPRId
		.Sync
		.WebList("name:=.*value20$").Select "#0"
		.Sync
		.WebList("name:=.*value30$").Select "#0"
		Wait(gSHORTWAIT)
		.WebEdit("name:=.*value50$").Set empty
		wait(gSHORTWAIT)
		.WebButton("name:=Search", "visible:=True").Click
		.Sync
		Wait(gSHORTWAIT)
	if .WebTable("column names:=^;"&NPRId&";.*", "cols:=3").Exist(gLONGWAIT) then
		
		.Link("name:="&NPRId, "visible:=True").Click
		.Sync
		Wait(gMEDIUMWAIT)
		Prdid = .WebTable("cols:=7","rows:=1", "column names:=^Category Tower.*").Link("html id:=.*nicommandLink1$").getRoproperty("innertext")
		.WebElement("html id:=.*rmAbv$", "class:=x1mx", "visible:=True").Click
		Wait(2)
		.WebElement("html id:=.*rmAbv$", "class:=x1mx","visible:=True").Click
		gfunFetchProductIDfromNPR = "True"
		Call gfReportExecutionStatus(micPass, "Product id Fetched from NPR", "Product number for NPR: "&NPRId &" is: "& Prdid )
		gfunFetchProductIDfromNPR = "True"
		dicGlobalOutput.Add StepID, Prdid
	
	Else
		Call gfReportExecutionStatus(micFail, "Get Product id from NPR", "Product number for NPR: "& NPRId & "deosn't exist")
		gfunFetchProductIDfromNPR = "False"
		Exit Function
		 
	End if
 End with	
		
End Function
'''########################################################################################################################
'''  PURPOSE: To access the Product by searching in manage items
''  Function Name: gfunCreate Item         
'''INPUT PARAMETERS       = 6 parameters , each param should contain values of eachpage to be filled(param1-Oveviewpage details;param2-Product Attributes page, Param3-Brand Information page, Param4:Storage Handling information page, Param5:Reglatory page details; Param6:Approvals details
'' OUTPUT PARAMETERS      =  True /False
''  OWNER                 = DOH 
''Resource:Triveni P					 Date:14/01/2020					Remarks:Assigned users credentials should be defined in Automation Environmental varaibles.
''########################################################################################################################
Function bfuncCreateItem(ByVal OverviewpageDetails, ByVal ProductAttributesDetails,ByVal BrandInformationDetails, ByVal StorageHandlinginformationDetails, ByVal RegulatoryInformationDetails, ByVal ApprovalsDetails, ByVal strTestStepID)
'Overview page(7)
'Organization
'NoOfItems
'ItemClass
'ItemDescription
'ItemStatus
'LifeStylePhase
'PackType
'PrimaryUnitofMeasure


'Product Attributes page(7)
'Channel
'VltDays
'NPCIdentifier
'NPCAlphaCode
'Supplier
'ManufactureProductCode
'ContractTitle

'Brand Information page	
'Eclass
'CatalogueSpeciality
'CatalogueGroup
'CatalogueSection
'BaseDescription

'Storage Handling information page
'CoshhProduct
'IsCoshhAttached
'MinimumStorageTemperatureC
'MaximumStorageTemperatureC
'MinimumHumidityLevel
'MaximumHumidityLevel

'Regulatory Information page
'IsSubjectToMDR
'IsSubjectToHumanMedicine
'IsLicensedMedicalDetailsReq
'LicensedMedicalPrdDetails
'MDRDeclaritionConfirmity
'MedicalDeviseClassification
	
''Approvals Page
'CTSPApprovalRequired
'CTMApprovalRequired
'CAPAApprovalRequired
'ItemName
err.clear
On error resume next

	OverviewDetails =  Split(OverviewpageDetails, ";")
	Organization = OverviewDetails(0)
	NoOfItems = OverviewDetails(1)
	ItemClass = OverviewDetails(2)
	ItemDescription =OverviewDetails(3)
	ItemStatus = OverviewDetails(4)
	LifeStylePhase = OverviewDetails(5)
	PackType = OverviewDetails(6)
	PrimaryUnitofMeasure = OverviewDetails(7)
	
	ProductAtbDetails =  Split(ProductAttributesDetails, ";")
	Channel = ProductAtbDetails(0)
	VltDays = ProductAtbDetails(1)
	NPCIdentifier = ProductAtbDetails(2)
	NPCAlphaCode =ProductAtbDetails(3)
	Supplier = ProductAtbDetails(4)
	ManufactureProductCode = ProductAtbDetails(5)
	ContractTitle = ProductAtbDetails(6)
	

	BrandInfrmnDetails =  Split(BrandInformationDetails, ";")
	Eclass = BrandInfrmnDetails(0)
	CatalogueSpeciality = BrandInfrmnDetails(1)
	CatalogueGroup = BrandInfrmnDetails(2)
	CatalogueSection =BrandInfrmnDetails(3)
	BaseDescription = BrandInfrmnDetails(4)
	
	StorageHandlgDetails =  Split(StorageHandlinginformationDetails, ";")
	CoshhProduct = StorageHandlgDetails(0)
	IsCoshhAttached = StorageHandlgDetails(1)
	MinimumStorageTemperatureC = StorageHandlgDetails(2)
	MaximumStorageTemperatureC =StorageHandlgDetails(3)
	MinimumHumidityLevel = StorageHandlgDetails(4)
	MaximumHumidityLevel = StorageHandlgDetails(5)
	

	RegulatoryDetails =  Split(RegulatoryInformationDetails, ";")
	IsSubjectToMDR = RegulatoryDetails(0)
	IsSubjectToHumanMedicine = RegulatoryDetails(1)
	IsLicensedMedicalDetailsReq = RegulatoryDetails(2)
	LicensedMedicalPrdDetails =RegulatoryDetails(3)
	MDRDeclaritionConfirmity = RegulatoryDetails(4)
	MedicalDeviseClassification = RegulatoryDetails(5)

	ApprovalsPageDetails =  Split(ApprovalsDetails, ";")
	CTSPApprovalRequired = ApprovalsPageDetails(0)
	CTMApprovalRequired = ApprovalsPageDetails(1)
	CAPAApprovalRequired = ApprovalsPageDetails(2)
	ItemName = ApprovalsPageDetails(3)
	
	
	Set wsh = CreateObject("Wscript.Shell")

'Overview page
'Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").
Set PgObj = Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
		PgObj.Image("alt:=Tasks", "visible:=True").Click
		PgObj.Sync
		PgObj.Link("name:=Create Item", "visible:=True").Click
		if PgObj.WebEdit("name:=.*organizationDispId.*").Exist(gLONGWAIT) then
			PgObj.WebEdit("name:=.*organizationDispId.*").Set Organization
			PgObj.WebEdit("name:=.*nitxt.*").Set NoOfItems
			PgObj.WebEdit("name:=.*itemClassId.*").Set ItemClass
			PgObj.Sync
			PgObj.WebButton("name:=OK", "visible:=True").Click
			PgObj.Sync
		else
		Call gfReportExecutionStatus(micFail, "Item Creation:Overview Page", "Got Error "& Err.Description)
				bfuncCreateItem = "False"		
				Exit function				
		end if	
		
	if PgObj.WebEdit("name:=.*pt1:ap1:r10:0:inputText2$", "visible:=True").Exist(gLONGWAIT)  then
		PgObj.WebEdit("name:=.*pt1:ap1:r10:0:inputText2$", "visible:=True").Set ItemDescription
		PgObj.WebList("name:=.*isst.*").Select ItemStatus
		PgObj.WebList("name:=.*selectOneChoice2.*").Select LifeStylePhase
		PgObj.WebList("name:=.*socti1$").Select PackType
		PgObj.WebEdit("name:=.*dynamicFormLeft_PrimaryUomCodeDisp$").Set PrimaryUnitofMeasure
		PgObj.Sync
		PgObj.Link("name:=Specifications", "visible:=True").Click
		PgObj.Sync
		
	else	
			Call gfReportExecutionStatus(micFail, "Item Creation Summary page:", "Got Error "& Err.Description)
			bfuncCreateItem = "False"		
			Exit function
	end if	
	
	
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncCreateItem = "False"
		Exit function
		
	End If
	
	
	
		'Product Attributes Page
		Wait(1)
		PgObj.Link("name:=Product Attributes", "visible:=True").Click
		
	If PgObj.WebEdit("name:=.*channel.*").Exist(gLONGWAIT) Then			
			
		PgObj.WebEdit("name:=.*channel.*").Highlight
		PgObj.WebEdit("name:=.*channel.*").Set Channel
		PgObj.Sync
		PgObj.WebEdit("name:=.*vltDays.*").Set VltDays
		PgObj.Image("alt:=Add Row", "visible:=True", "class:=x1qe", "index:=1").Highlight
		PgObj.Image("alt:=Add Row", "visible:=True", "class:=x1qe", "index:=1").Click
		wait(2)
		PgObj.WebEdit("name:=.*npcIdentifier.*").Highlight
		PgObj.WebEdit("name:=.*npcIdentifier.*").Set NPCIdentifier
		PgObj.WebEdit("name:=.*npcAlphaCode.*").Set NPCAlphaCode
		Wait(2)
		PgObj.WebEdit("name:=.*supplier.*").set Supplier
		Wait(2)	
		PgObj.WebEdit("name:=.*manufacturerProductCode.*").Set ManufactureProductCode
		PgObj.WebEdit("name:=.*contractTitle.*").Set ContractTitle
		PgObj.Sync
		PgObj.Link("name:=Brand Information and Product Classification", "visible:=True").Click
	else	
			Call gfReportExecutionStatus(micFail, "Item Creation Product Attrobuts page:", "Got Error "& Err.Description)
			bfuncCreateItem = "False"		
			Exit function
	end if
	
		
		If Err.Number <>0 Then		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncCreateItem = "False"
		Exit function
		End If
		
			
		'Brand Information page		
		PgObj.Sync
		Wait(1)
		If PgObj.WebEdit("name:=.*eclass.*").Exist(gLONGWAIT) Then
		
			PgObj.WebEdit("name:=.*eclass.*").Click
			wait(1)
			wsh.SendKeys "{DOWN}"
			wait(2)
			PgObj.WebElement("innertext:="&Eclass, "class:=x2s3").Click
			PgObj.Sync
			Wait(2)
			
			PgObj.WebEdit("name:=.*catalogueSpeciality.*").Highlight
			PgObj.WebEdit("name:=.*catalogueSpeciality.*").Click
			Wait(1)
			wsh.SendKeys "{DOWN}"
			PgObj.Sync
			Wait(2)
			PgObj.WebElement("innertext:="&CatalogueSpeciality, "class:=x2s3", "index:=0").Click
			PgObj.Sync
			Wait(2)
			PgObj.WebEdit("name:=.*catalogueGroup.*").Highlight
			PgObj.WebEdit("name:=.*catalogueGroup.*").Click
			Wait(1)
			wsh.SendKeys "{DOWN}"
			PgObj.Sync
			Wait(2)
			PgObj.WebElement("innertext:="&CatalogueGroup, "class:=x2s3", "index:=0").Click
			PgObj.Sync
			Wait(2)			
			PgObj.WebEdit("name:=.*catalogueSection.*").Click
			wsh.SendKeys "{DOWN}"
			Wait(1)
			PgObj.Sync
			Wait(2)
			PgObj.WebElement("innertext:="&CatalogueSection, "class:=x2s3", "index:=0").Click
			PgObj.Sync
			Wait(2)			
			PgObj.WebEdit("name:=.*baseDescription.*").Click
			wsh.SendKeys "{DOWN}"
			Wait(1)
			PgObj.Sync
			Wait(2)
			PgObj.WebElement("innertext:="&BaseDescription, "class:=x2s3", "index:=0").Click
			PgObj.Sync
			Wait(2)
			PgObj.Link("name:=Storage and Handling Information", "visible:=True").Click
			PgObj.Sync
			Wait(1)
			
		else	
			Call gfReportExecutionStatus(micFail, "Item Creation Brand Information page:", "Got Error "& Err.Description)
			bfuncCreateItem = "False"		
			Exit function		
		End if

		If Err.Number <>0 Then		
		Call gfReportExecutionStatus(micFail, "Item Creation Brand Information page:", "Got Error "& Err.Description)
		bfuncCreateItem = "False"		
		Exit function		
		End If
		
	
'		Storage and Handling Information page
		If PgObj.WebEdit("name:=.*coshhProduct.*").Exist(gLONGWAIT) then
			PgObj.WebEdit("name:=.*coshhProduct.*").Click
			wsh.SendKeys "{DOWN}"
			PgObj.Sync
			Wait(2)
			PgObj.WebElement("innertext:="&CoshhProduct, "class:=x2s3", "index:=0").Click
			PgObj.Sync
			Wait(2)
			PgObj.WebEdit("name:=.*hasCoshhDataSheetBeenAttached.*").Click
			wsh.SendKeys "{DOWN}"
			PgObj.Sync
			Wait(2)
			PgObj.WebElement("innertext:="&IsCoshhAttached, "class:=x2s3", "index:=0").Click
			PgObj.Sync
			Wait(2)		
	
			If IsSubjectToMDR = "Yes" Then
				PgObj.WebElement("html id:=.*temperatureLimitations::Label1$").Click
				PgObj.WebEdit("name:=.*MinimumStorageTemperatureC$").Set MinimumStorageTemperatureC
				PgObj.WebEdit("name:=.*MaximumStorageTemperatureC$").Set MaximumStorageTemperatureC
			
	
				PgObj.WebElement("html id:=.*humidityLimitationMet::Label1$").Click
				PgObj.WebEdit("name:=.*minimumHumidityLevel$").Set MinimumHumidityLevel
				PgObj.WebEdit("name:=.*maximumHumidityLevel$").Set MaximumHumidityLevel
			End If
			
		else	
		Call gfReportExecutionStatus(micFail, "Item Creation Storage and Handling Information page:", "Got Error "& Err.Description)
		bfuncCreateItem = "False"		
		Exit function
		End If
	
		
	  		If Err.Number <>0 Then		
			Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
			bfuncCreateItem = "False"
			Exit function		
			End If
	 
	 PgObj.Link("name:=Regulatory Information").Click
		PgObj.Sync
		Wait(1)
	If PgObj.WebEdit("name:=.*subjectToTheEuMdrIvddregulatio.*").Exist(gLONGWAIT) then	
		''Regulatory Information page
		PgObj.WebEdit("name:=.*subjectToTheEuMdrIvddregulatio.*").Set IsSubjectToMDR
		PgObj.Sync
		Wait(2)
		PgObj.WebEdit("name:=.*subjectToTheHumanMedicinesRegu.*").Set IsSubjectToHumanMedicine
		PgObj.Sync
		Wait(2)
		PgObj.WebEdit("name:=.*mhraDetailRequired.*").Set IsLicensedMedicalDetailsReq
		PgObj.Sync
		Wait(2)
		PgObj.WebEdit("name:=.*mhraDetail$").Set LicensedMedicalPrdDetails
		PgObj.Sync
		Wait(2)
	
		If IsSubjectToMDR = "Yes" Then
				PgObj.WebEdit("name:=.*declarationOfConformityRequire$").Set MDRDeclaritionConfirmity
				PgObj.Sync
				Wait(1)
				PgObj.WebEdit("name:=.*euMedicalDeviceClassification$").Set MedicalDeviseClassification
		end if
	
	else	
		Call gfReportExecutionStatus(micFail, "Item Creation Regulatory Information:", "Got Error "& Err.Description)
		bfuncCreateItem = "False"		
		Exit function
	End If
	
		If Err.Number <>0 Then		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description)
		bfuncCreateItem = "False"		
		Exit function		
		End If
	
			
	''Approvals Page
	PgObj.Link("name:=Approvals", "visible:=True").Click
	PgObj.Sync
	Wait(1)
	If PgObj.WebEdit("name:=.*ctspApprovalRequired$").Exist(gLONGWAIT) Then
			
		PgObj.WebEdit("name:=.*ctspApprovalRequired$").Set CTSPApprovalRequired
		PgObj.Sync
		PgObj.WebEdit("name:=.*ctmApproval$").Set CTMApprovalRequired
		PgObj.Sync
		PgObj.WebEdit("name:=.*capaApproval$").Set CAPAApprovalRequired
		PgObj.Sync	
		PgObj.WebButton ("name:=Submit", "visible:=True").Click
		PgObj.Sync	
		
		if PgObj.WebButton ("name:=Next", "visible:=True").Exist(gLONGWAIT) then
		PgObj.WebButton ("name:=Next", "visible:=True").Click
		PgObj.Sync
		end if
		
		if PgObj.WebEdit("name:=.*:it5$", "visible:=True").Exist(gLONGWAIT) then
		PgObj.WebEdit("name:=.*:it5$").Set ItemName
		PgObj.WebButton ("name:=Save and Edit", "visible:=True").Click
		PgObj.Sync	
		end if
		
		If PgObj.WebTable("clos:=7", "column names:=^Category.*").Exist(20) Then
		 ItemNum = PgObj.WebTable("clos:=7", "column names:=^Category.*").GetCellData(1,2)
		 NPRID = PgObj.WebTable("column names:=^Type;New Item Request.*").GetCellData(3,2)
		 PgObj.WebButton ("name:=Submit", "visible:=True").Click
		 PgObj.Sync
		End If
	else	
		Call gfReportExecutionStatus(micFail, "Item Creation Approvals Page:", "Got Error "& Err.Description)
		bfuncCreateItem = "False"		
		Exit function
	End If

	
	If Err.Number <> 0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncCreateItem = "False"
		''Store the value in Global dict
		
		
	else
		Call gfReportExecutionStatus(micPass, "Item Creation is Success:", "NPR ID: "& NPRID &", Item Number is: "&ItemNum)
		bfuncCreateItem = "True"
		dicGlobalOutput.Add strTestStepID,NPRID
		
	End If
  
End Function

Public Function bfuncSupCreateItem()

err.clear
On error resume next	
	
	Set wsh = CreateObject("Wscript.Shell")
	
	ProductID = RandomNumber.Value(100000,999999)

	'Overview page
	Category = "CT01 - Ward Based Consumables"   '"CT10 - Food"
	PrimaryUnitOfMeasure = "CC"
	PackType = "Case"
	
	'Compliance details
	IsSubjectToMDR = "Yes"
	IsSubjectToHumanMedicine = "Yes"
	IsLicensedMedicalDetailsReq = "Yes"
	LicensedMedicalPrdDetails = "Yes"
	MDRDeclaritionConfirmity = "Yes"
	MedicalDeviseClassification  = "Auto Medicine"
	
	
	''Eclass info
	EClass = "AAB"
	
	'Product Attributes info
	Channel = "Blue Diamond"
	VLTDays = "5"
	
	'COSHH Information
	IsCOSHHPoduct = "No"
	IsCOSHHSheetAttached  = "No"
	
	'Catalogue description info
	CatalogueSpeciality = "Medical"
	CatalogueGroup = "Cardiology"
	CatalogueSection ="Biopsy"
	BaseDesc = "Needle"
	gLONGWAIT = "10"
	
	'Overview page
	'Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*").
	 Set BrObj= Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
	'		.Image("alt:=Tasks", "visible:=True").Click
		BrObj.Sync
		BrObj.Link("name:=Manage Products", "visible:=True").Click
		BrObj.Sync
		
		if BrObj.Image("alt:=Create", "class:=x1qe", "visible:=True").Exist(gLONGWAIT) then
		BrObj.Image("alt:=Create", "class:=x1qe", "visible:=True").Click
		else
		Call gfReportExecutionStatus(micFail, "Item Creation:Overview Page", "Got Error "& Err.Description)
				bfuncSupCreateItem = "False"		
				Exit function				
		end if
		
		
		if BrObj.WebEdit("name:=.*itemImportCategoryNameId$").Exist(gLONGWAIT) then
			BrObj.WebEdit("name:=.*itemImportCategoryNameId$").Click
			wsh.SendKeys "{DOWN}"
			wait(1)
			BrObj.WebElement("innertext:="&Category, "class:=x2s3", "index:=0").Click
			BrObj.Sync
			wait(2)
'			BrObj.WebEdit("name:=.*itemImportCategoryNameId$").Set Category 
			BrObj.WebEdit("name:=.*itemImportCategoryNameId$").Set Category 
			BrObj.WebEdit("name:=.*it1$").Click
			BrObj.WebEdit("name:=.*it1$").Set ProductID
			BrObj.Sync
			Wait(2)
			BrObj.WebEdit("name:=.*it2$").Click
			BrObj.WebEdit("name:=.*it2$").Set "Desc" & ProductID
			BrObj.Sync
			Wait(2)
			BrObj.WebEdit("name:=.*primaryUomCodeDispId$").Click 
			wsh.SendKeys "{DOWN}"
			wait(3)
			BrObj.WebElement("innertext:="&PrimaryUnitOfMeasure, "class:=x2s3", "index:=0").Click
			BrObj.Sync			
			wait(3)
			BrObj.WebEdit("name:=.*tradeItemDescriptorDispId$").Click
			wsh.SendKeys "{DOWN}"
			wait(1)
			BrObj.WebElement("innertext:="&PackType, "class:=x2s3", "index:=0").Click
			wait(3)
			BrObj.Sync
		else
			Call gfReportExecutionStatus(micFail, "Item Creation:Overview Page", "Got Error "& Err.Description)
			bfuncSupCreateItem = "False"		
			Exit function				
		end if
		
''		COSHH INFO
			if BrObj.WebButton("title:=Collapse COSHH Information", "html id:=.*sdh5::_afrDscl$", "visible:=True").Exist(gLONGWAIT) then
			BrObj.WebButton("title:=Collapse COSHH Information", "html id:=.*sdh5::_afrDscl$", "visible:=True").Highlight
			
			else
			BrObj.WebButton("title:=Expand COSHH Information", "html id:=.*sdh5::_afrDscl$", "visible:=True").Highlight
			BrObj.WebButton("title:=Expand COSHH Information", "html id:=.*sdh5::_afrDscl$", "visible:=True").Click
			end if

			If Err.Number <> 0 Then	
			
			Call gfReportExecutionStatus(micFail, "Item Creation:Overview Page", "Got Error "& Err.Description)
			bfuncSupCreateItem = "False"		
			Exit function				
			end if

		
			if BrObj.WebEdit("name:=.*coshhProduct_ATTRIBUTE_CHAR1$", "visible:=True").Exist(gLONGWAIT)  then
			BrObj.WebEdit("name:=.*coshhProduct_ATTRIBUTE_CHAR1$", "visible:=True").Click
			wsh.SendKeys "{DOWN}"
			wait(1)
			BrObj.WebElement("innertext:="&IsCOSHHPoduct, "class:=x2s3", "index:=0").Click
			BrObj.Sync	
			wait(2)			
			BrObj.WebEdit("name:=.*hasCoshhDataSheetBeenAttached_ATTRIBUTE_CHAR12$").Click
			wsh.SendKeys "{DOWN}"
			wait(1)
			BrObj.WebElement("innertext:="&IsCOSHHSheetAttached, "class:=x2s3", "index:=0").Click
			BrObj.Sync
			wait(2)
			
			else	
				Call gfReportExecutionStatus(micFail, "Item Creation COSHH Information:", "Got Error "& Err.Description)
				bfuncSupCreateItem = "False"		
				Exit function
			end if
			
			If Err.Number <>0 Then
			
			Call gfReportExecutionStatus(micFail, "Item Creation COSHH Information:", "Got Error "& Err.Description) 
			bfuncSupCreateItem = "False"
			Exit function
			
			End If
		
		'Catalogue description details
	if	BrObj.WebButton("title:=Expand Catalogue Description", "html id:=.*sdh7::_afrDscl$", "visible:=True").Exist(gLONGWAIT) then
		BrObj.WebButton("title:=Expand Catalogue Description", "html id:=.*sdh7::_afrDscl$", "visible:=True").Highlight
		BrObj.WebButton("title:=Expand Catalogue Description", "html id:=.*sdh7::_afrDscl$", "visible:=True").Click
		
	else
	BrObj.WebButton("title:=Collapse Catalogue Description", "html id:=.*sdh7::_afrDscl$", "visible:=True").Highlight
	end if	
				
				if  BrObj.WebEdit("name:=.*catalogueSpeciality_ATTRIBUTE_CHAR1$").Exist(gLONGWAIT) then
					BrObj.WebEdit("name:=.*catalogueSpeciality_ATTRIBUTE_CHAR1$").Highlight
					BrObj.WebEdit("name:=.*catalogueSpeciality_ATTRIBUTE_CHAR1$").Click
					wsh.SendKeys "{DOWN}"
					wait(1)
					BrObj.WebElement("innertext:="&CatalogueSpeciality, "class:=x2s3", "index:=0").Click
					BrObj.Sync
					Wait(2)
					
					BrObj.WebEdit("name:=.*catalogueGroup_ATTRIBUTE_CHAR2$").Highlight
					BrObj.WebEdit("name:=.*catalogueGroup_ATTRIBUTE_CHAR2$").Click
					wsh.SendKeys "{DOWN}"
					wait(1)
					BrObj.WebElement("innertext:="&CatalogueGroup, "class:=x2s3", "index:=0").Click
					BrObj.Sync
					wait(2)
					
					BrObj.WebEdit("name:=.*catalogueSection_ATTRIBUTE_CHAR3$").Highlight
					BrObj.WebEdit("name:=.*catalogueSection_ATTRIBUTE_CHAR3$").Click
					wsh.SendKeys "{DOWN}"
					wait(1)
					BrObj.WebElement("innertext:="&CatalogueSection, "class:=x2s3", "index:=0").Click
					BrObj.Sync
					wait(2)	
					
					BrObj.WebEdit("name:=.*baseDescription_ATTRIBUTE_CHAR4$").Highlight
					BrObj.WebEdit("name:=.*baseDescription_ATTRIBUTE_CHAR4$").Click
					wsh.SendKeys "{DOWN}"
					wait(1)
					BrObj.WebElement("innertext:="&BaseDesc, "class:=x2s3", "index:=0").Click
					BrObj.Sync
					wait(2)				
			else	
					Call gfReportExecutionStatus(micFail, "Item Creation Catalogue info:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"		
					Exit function
			end if		
				
				If Err.Number <>0 Then
					
					Call gfReportExecutionStatus(micFail, "Item Creation Catalogue info:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"
					Exit function
					
				End If


		'Compliance details
		if BrObj.WebButton("title:=Collapse Compliance", "html id:=.*sdh11::_afrDscl$", "visible:=True").Exist(gLONGWAIT) then
		BrObj.WebButton("title:=Collapse Compliance", "html id:=.*sdh11::_afrDscl$", "visible:=True").Highlight
		else
		BrObj.WebButton("title:=Expand Compliance", "html id:=.*sdh11::_afrDscl$", "visible:=True").Highlight
		BrObj.WebButton("title:=Expand Compliance", "html id:=.*sdh11::_afrDscl$", "visible:=True").Click
		BrObj.Sync	
		end if 
		 
			if BrObj.WebEdit("name:=.*subjectToTheEuMdrIvddregulatio.*").Exist(gLONGWAIT) then	
				BrObj.WebEdit("name:=.*subjectToTheEuMdrIvddregulatio.*").Highlight
				BrObj.WebEdit("name:=.*subjectToTheEuMdrIvddregulatio.*").Click
				wsh.SendKeys "{DOWN}"
				wait(1)
				BrObj.WebElement("innertext:="&IsSubjectToMDR, "class:=x2s3").Click
				BrObj.Sync
				Wait(2)
				BrObj.WebEdit("name:=.*subjectToTheHumanMedicinesRegu.*").Click
				wsh.SendKeys "{DOWN}"
				wait(1)
				BrObj.WebElement("innertext:="&IsSubjectToHumanMedicine, "class:=x2s3").Click
				BrObj.Sync
				Wait(2)
						
				If IsSubjectToMDR = "Yes" Then
						BrObj.WebEdit("name:=.*declarationOfConformityRequire_ATTRIBUTE_CHAR4$").Set MDRDeclaritionConfirmity
						BrObj.Sync
						Wait(1)
						BrObj.WebEdit("name:=.*euMedicalDeviceClassification_ATTRIBUTE_CHAR9$").Set MedicalDeviseClassification
				end if
	
			else	
				Call gfReportExecutionStatus(micFail, "Item Creation Compliance Information:", "Got Error "& Err.Description)
				bfuncSupCreateItem = "False"		
				Exit function
			End If
		
			If Err.Number <>0 Then
					
					Call gfReportExecutionStatus(micFail, "Item Creation Compliance info:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"
					Exit function
			end if				
	
	'Eclass details
		if	BrObj.WebButton("title:=Expand EClass Information", "html id:=.*sdh15::_afrDscl$", "visible:=True").Exist(gLONGWAIT) then
		BrObj.WebButton("title:=Expand EClass Information", "html id:=.*sdh15::_afrDscl$", "visible:=True").Highlight
			BrObj.WebButton("title:=Expand EClass Information", "html id:=.*sdh15::_afrDscl$", "visible:=True").Click
			BrObj.Sync	
		else			
		BrObj.WebButton("title:=Collapse EClass Information", "html id:=.*sdh15::_afrDscl$", "visible:=True").Highlight
		end if
			
				if BrObj.WebEdit("name:=.*eclass_ATTRIBUTE_CHAR1$").Exist(gLONGWAIT) then	
					BrObj.WebEdit("name:=.*eclass_ATTRIBUTE_CHAR1$").Highlight
					BrObj.WebEdit("name:=.*eclass_ATTRIBUTE_CHAR1$").Click
					wsh.SendKeys "{DOWN}"
					wait(1)
					BrObj.WebElement("innertext:="&EClass, "class:=x2s3").Click
					BrObj.Sync
					wait(2)
				else	
					Call gfReportExecutionStatus(micFail, "Item Creation Eclass Information:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"		
					Exit function
				End If
		
			If Err.Number <>0 Then
					
					Call gfReportExecutionStatus(micFail, "Item Creation EClass info:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"
					Exit function
			end if
			
		'Product Attributes details
		if BrObj.WebButton("title:=Expand Product Attributes", "html id:=.*sdh21::_afrDscl$", "visible:=True").Exists(gLONGWAIT) then
			BrObj.WebButton("title:=Expand Product Attributes", "html id:=.*sdh21::_afrDscl$", "visible:=True").Highlight
			BrObj.WebButton("title:=Expand Product Attributes", "html id:=.*sdh21::_afrDscl$", "visible:=True").Click
			BrObj.Sync	
		else
		BrObj.WebButton("title:=Collapse Product Attributes", "html id:=.*sdh21::_afrDscl$", "visible:=True").Highlight
		end if
				if BrObj.WebEdit("name:=.*channel_ATTRIBUTE_CHAR1$").Exist(gLONGWAIT) then	
					BrObj.WebEdit("name:=.*channel_ATTRIBUTE_CHAR1$").Highlight
					BrObj.WebEdit("name:=.*channel_ATTRIBUTE_CHAR1$").Set Channel
					BrObj.Sync
					BrObj.WebEdit("name:=.*vltDays_ATTRIBUTE_NUMBER2$").Set VLTDays
				else	
					Call gfReportExecutionStatus(micFail, "Item Creation Product Attributes Information:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"		
					Exit function
				End If
		
			If Err.Number <>0 Then
					
					Call gfReportExecutionStatus(micFail, "Item Creation Product Attributes info:", "Got Error "& Err.Description)
					bfuncSupCreateItem = "False"
					Exit function
			end if		
		
				
				
	
'			If IsSubjectToMDR = "Yes" Then
'				.WebElement("html id:=.*temperatureLimitations::Label1$").Click
'				.WebEdit("name:=.*MinimumStorageTemperatureC$").Set MinimumStorageTemperatureC
'				.WebEdit("name:=.*MaximumStorageTemperatureC$").Set MaximumStorageTemperatureC
'			
'	
'				.WebElement("html id:=.*humidityLimitationMet::Label1$").Click
'				.WebEdit("name:=.*minimumHumidityLevel$").Set MinimumHumidityLevel
'				.WebEdit("name:=.*maximumHumidityLevel$").Set MaximumHumidityLevel
'			End If
'			
		BrObj.WebButton ("name:=Submit", "visible:=True", "class:=xx3").Click
		BrObj.Sync
	if BrObj.WebTable("class:x1no x1oc", "column names:=;"&ProductID&";.*" , "cols:=6", "name:=Submitted", "visible:=True").Exist(gLONGWAIT)	then
	
		bfuncSupCreateItem = "True"
		
	end if 	
	

	
	If Err.Number <> 0 Then
		
		Call gfReportExecutionStatus(micFail, "Supplier: Item Creation:", "Got Error "& Err.Description) 
		bfuncCreateItem = "False"
		''Store the value in Global dict
		
		
	else
		Call gfReportExecutionStatus(micPass, "Supplier:Item Creation is Success:", "NPR ID: "& NPRID &", Item Number is: "&ItemNum)
		bfuncSupCreateItem = "True"
'		dicGlobalOutput.Add strTestStepID, ProductID
		
	End If
  
End Function

''''###################################################################################
'''  PURPOSE: To Reassign the New Item request by accessing Notification Message.
''  Function Name: gfunReassignItemRequest          
'''INPUT PARAMETERS       = 2 parameters :RequestID, User name to whome the Item should be assigned for approval
'' OUTPUT PARAMETERS      =  True /False
''  OWNER                 = DOH 
''########################################################################################################################
Function gfunReassignItemRequest(RequestID, ReassignedUser)
err.clear
On error resume next

Set PgObj = Browser("name:=.*Oracle Applications.*").page("title:=.*Oracle Applications.*")
 		
'	.Link("name:=Product Information Management").Click
'	Wait(gSHORTWAIT)
	PgObj.Link("name:=^Notifications.*", "visible:=True", "class:=svg-glob xko p_AFIconOnly").Click
	
		Wait(2)	
	PgObj.WebEdit("name:=pt1:_UISatr:0:it1").Set RequestID
	PgObj.Image("html tag:=IMG","title:=Search","visible:=True", "class:=x11a").Click	
		Wait(2)

'NotifnChk = PgObj.Link("name:=^Action Required: New Item Request .*Requires Approval$","visible:=True").Exist(gLONGWAIT)

	For itr = 1 to 10

		If PgObj.Link("name:=^Action Required: New Item Request .*Requires Approval$","visible:=True").Exist(gLONGWAIT) Then
			NotifnChk = "True"
			Exit For
		else
			Set wsh = CreateObject("Wscript.Shell")
			wsh.SendKeys "{F5}"
			Wait(5)
			Pgobj.Link("name:=^Notifications.*", "visible:=True", "class:=svg-glob xko p_AFIconOnly").Click
			Wait(2)	
			Pgobj.WebEdit("name:=pt1:_UISatr:0:it1").Set RequestID
			Pgobj.Image("html tag:=IMG","title:=Search","visible:=True", "class:=x11a").Click
			Wait(2)		
		end if
	timeitr = timeitr+1
	Next

		
		'# Notification verification and Approving/Rejecting th items
		If NotifnChk = "True" Then
		
			PgObj.Link("name:=^Action Required: New Item Request .*Requires Approval$","visible:=True").Click
'			Wait(gSHORTWAIT)
			
			Set  PgObj = Browser("name:=New Item Request.*").page("title:=New Item Request.*")
				if PgObj.Exist(gLONGWAIT) then
						PgObj.WebElement("class:=xmi", "visible:=True", "index:=0").Click
						PgObj.WebElement("innertext:=Reassign.*", "class:=xnw").Click
						If PgObj.WebEdit("name:=reAsIdB:idSearchStringField").Exist(gLONGWAIT) Then
							PgObj.WebEdit("name:=reAsIdB:idSearchStringField").Set ReassignedUser					
							PgObj.WebButton("name:=Search", "visible:=True").Click
								if PgObj.WebElement("html id:=reAsIdB:dc_pc1:idSTable:0:selIdCB::Label0", "class:=x1dy").Exist(10) then
									PgObj.WebElement("html id:=reAsIdB:dc_pc1:idSTable:0:selIdCB::Label0", "class:=x1dy").Click
									PgObj.Sync
									PgObj.WebButton("name:=OK", "visible:=True").Click
									gfunReassignItemRequest = "True"
								else
									Call gfReportExecutionStatus(micFail, "Task Reassignment", "User name:"& UserName&" Not found" )
									gfunReassignItemRequest = "False"
									Exit Function
								end if	
						end if
				end if	
		else
			Call gfReportExecutionStatus(micFail, "Task Reassignment", "Notification message for NPRID:"& RequestID&" Not found" )
			gfunReassignItemRequest = "False"
			Exit Function
		End if 
End function 

''########################################################################################################################
''
''           PURPOSE: To Logout from the DOH Product Hub Application
''           Initial State          = 
''           Final State            = 
''           INPUT PARAMETERS       = LoggedIn User mailid
''           OUTPUT PARAMETERS      = 
''            OWNER                 =  DOH
''			Resource:Triveni				 Date:07/Feb/2020					Remarks
''########################################################################################################################
'
Function bfuncDOHLogOut(UserName)
   
	err.clear
    On Error Resume Next
  
    strUserName = Environment.Value(UserName)
     
		UName =  Split(strUserName, "@")
		User =  Replace(UName(0), ".", " ")
    	    
		Set PgObj =  Browser("name:=.*Oracle Applications.*").Page("title:=.*Oracle Applications.*")
		PgObj.Image("class:=xi8", "alt:="&User, "visible:=True").Click
		PgObj.Link("innertext:=Sign Out", "name:=Sign Out", "visible:=True").Click
		Set PgObj =  Browser("name:=.*Single Sign-Off consent.*").Page("title:=.*Single Sign-Off consent.*")
		PgObj.WebButton("name:= Confirm", "visible:=True").Click
		Set PgObj =  Browser("name:=.*Sign out.*").Page("title:=.*Sign out.*")
		PgObj.WaitProperty "visible", "True", "30000"
		PgObj.WebElement("innertext:="&User,"visible:=True").Click 
		Browser("name:=.*Sign out.*").Close 
      	
    	    If Err.Number<>0 Then
            Call gfReportExecutionStatus(micFail,"DOH Logout", "Error Number=" & CStr(Err.Number)&", Description=" & Err.Description)
            bfuncDOHLogOut = "False"
            Exit Function
            Else
            Call gfReportExecutionStatus(micPass,"DOH Logout", "User:"&User&" Logged out Successfully")
            bfuncDOHLogOut = "True"            
         	End if
       
    End Function ' Lo
    
''########################################################################################################################
''
''           PURPOSE: To Create Bulkupload using Import Map
''           Initial State          = 
''           Final State            = 
''           INPUT PARAMETERS       = 6 Various screen details like CreateBatchDeatils,EditBatchDeatils,ChangeOrderDeatils,ImportMapName,FilePath
''           OUTPUT PARAMETERS      = 
''           OWNER                 =  DOH
''			Resource:Thirupathi				 Date:12/Feb/2020					Remarks
''########################################################################################################################
    
    Function bfuncBulkuploadImportMap(ByVal CreateBatchDeatils,ByVal EditBatchDeatils,ByVal ChangeOrderDeatils,ByVal ImportMapName,ByVal FilePath,ByVal ActionType, ByVal StepID)
	
	Err.clear
	On error resume next
	
	'Variable Initilization
	vName = "BulkUpload"&Year(Now)&Month(Now)&Day(Now)&Hour(Now)&Minute(Now)&Second(Now)
	BatchDeatils = Split(CreateBatchDeatils,";")
	vSpokeSystem = BatchDeatils(0)
	vDefaultOrg = BatchDeatils(1)
	
	EditBatchOption =Split(EditBatchDeatils,";")
	vSchedule = EditBatchOption(0)	
	vUpdate = EditBatchOption(1)
	vProcItems = EditBatchOption(2)
	vItemRequest = EditBatchOption(3)

	ChOrderDetails = Split(ChangeOrderDeatils,";")
	vChangeOrder = ChOrderDetails(0)
	vType = ChOrderDetails(1)
	vChOdName = ChOrderDetails(2)
	
	vImportMap = ImportMapName
	vFilePath = FilePath
	
'Click on 'Tasks'
	Set ObjPage = Browser("name:=.*Oracle Applications$").Page("title:=.*Oracle Applications$")
	ObjPage.Image("alt:=Tasks", "visible:=True").Click
	ObjPage.Sync
'Click on 'New Item Batches'
	ObjPage.Link("name:=Manage Item Batches", "text:=Manage Item Batches").Click
	Wait(gLONGWAIT)
'Check 'Manage Item Batches' Screen loads	 
	If ObjPage.Exist(gLONGWAIT) Then
	Else
		Call gfReportExecutionStatus(micFail, "Manage Item Batches Page", "Got Error "& Err.Description)
		bfuncBulkuploadImportMap = "False"		
		Exit function		
	End If
	
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncBulkuploadImportMap = "False"
		Exit function
		
	End If
	
'Clcik on 'Create Item'	
	Set ObjManageBatchPage = Browser("name:=Manage Item Batches.*").Page("title:=Manage Item Batches.*")
	ObjManageBatchPage.Image("title:=Create","visible:=True").Click
	Wait(gLONGWAIT)
'Enter'Create Item Batch' values
	Set ObjCreateItemPage = Browser("name:=^Create Item Batch.*").Page("title:=^Create Item Batch.*")
	If ObjCreateItemPage.Exist(gLONGWAIT) Then
	Else
		Call gfReportExecutionStatus(micFail, "Create Item Batch Screen Page", "Got Error "& Err.Description)
		bfuncBulkuploadImportMap = "False"		
		Exit function
	End If
	ObjCreateItemPage.WebEdit("name:=.*:it2$","visible:=True").Set vName
	ObjCreateItemPage.WebElement("title:=Spoke System","class:=x1u4").Click
	Wait 3
	ObjCreateItemPage.WebElement("innertext:="&vSpokeSystem,"class:=x2s3","visible:=True").Click
	Wait 3
	ObjCreateItemPage.WebElement("title:=Default Organization","class:=x1u4").Click
	Wait 1
	ObjCreateItemPage.WebElement("innertext:="&vDefaultOrg,"index:=0","visible:=True").Click
	Wait 3
		
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncBulkuploadImportMap = "False"
		Exit function
		
	End If
	
	ObjCreateItemPage.WebElement("title:=Save and Close","class:=x1qd","html id:=.*ctb1::popEl$").Click
	ObjCreateItemPage.WebElement("innerhtml:=Save and Edit Item Batch Options","innertext:=Save and Edit Item Batch Options").Click
	Wait(gShortWait)

'Enter Batch item options
	Set ObjBatchOptionsPage = Browser("name:=^Edit Item Batch Options.*").Page("title:=^Edit Item Batch Options.*")
	If ObjBatchOptionsPage.Exist(gShortWait) Then
	Else
		Call gfReportExecutionStatus(micFail, "Edit Item Batch Options Page", "Got Error "& Err.Description)
		bfuncBulkuploadImportMap = "False"		
		Exit function
	End If
	'ObjBatchOptionsPage.WebList("innertext:=ManualOn data loadSpecify date and time","class:=x2h").Select vSchedule
	ObjBatchOptionsPage.WebList("name:=.*:soc6$","class:=x2h").Select vUpdate
	Wait 1
	ObjBatchOptionsPage.WebList("name:=.*:soc8$","class:=x2h").Select vProcItems
	Wait 1
	ObjBatchOptionsPage.WebList("name:=.*:NirOption$","class:=x2h").Select vItemRequest 
'	ObjBatchOptionsPage.WebList("name:=.*:ChangeOrderOption$","class:=x2h").Select vChangeOrder
'	ObjBatchOptionsPage.WebElement("innertext:=Create new","outertext:=Create new","class:=x2l","visible:=True").Click
'	ObjBatchOptionsPage.WebList("name:=.*:changeType","visible:=True").Select vType
'	Wait 2
'	ObjBatchOptionsPage.WebEdit("name:=.*:it4$","class:=x25").Set vChOdName	
	Wait 2
	
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncBulkuploadImportMap = "False"
		Exit function
		
	End If
	ObjBatchOptionsPage.WebElement("class:=x1qd", "html id:=.*ctb1::popEl$").Click
	ObjBatchOptionsPage.WebElement("class:=xnw", "innertext:=Save and Add Items").Click
						
'Enter Add Items to batch values
	Set ObjAdditemsBatchPage = Browser("name:=^Add Items to Batch.*").Page("title:=^Add Items to Batch.*")	
	ObjAdditemsBatchPage.Sync
	If ObjAdditemsBatchPage.Exist(gSHORTWAIT) Then
	Else
		Call gfReportExecutionStatus(micFail, "Add Items to Batch Page", "Got Error "& Err.Description)
		bfuncBulkuploadImportMap = "False"		
		Exit function
	End If
	ObjAdditemsBatchPage.WebElement("title:=Import Map","class:=x1u4","visible:=True").Click
	Wait 3	
	ObjAdditemsBatchPage.WebElement("innertext:=DOH_IMPORT_INTERNAL","visible:=True","class:=x2s3").Click
	ObjAdditemsBatchPage.WebFile("name:=.*:if1$").WaitProperty "Visible",True,4000
	ObjAdditemsBatchPage.WebFile("name:=.*:if1$").Click	
'Browse Bulck upload file
	Wait(gSYNCWAIT)	
	Set ObjBrowsePane = Browser("name:=Add Items to Batch.*").Dialog("regexpwndtitle:=Choose File to Upload","text:=Choose File to Upload")
	ObjBrowsePane.Activate
	ObjBrowsePane.WinEdit("regexpwndclass:=Edit").Click
	ObjBrowsePane.WinEdit("regexpwndclass:=Edit").Set vFilePath
	ObjBrowsePane.WinButton("regexpwndtitle:=&Open","text:=&Open").Click
	Wait 5
	ObjAdditemsBatchPage.WebButton("name:=Upload File","visible:=-1").WaitProperty "visible",True,4000
	ObjAdditemsBatchPage.WebButton("name:=Upload File","visible:=-1").Click
	ObjAdditemsBatchPage.WebElement("innerhtml:=^File upload complete.*","innertext:=^File upload complete.*").WaitProperty "Visible",True,5000
	ProcessText=ObjAdditemsBatchPage.WebElement("innerhtml:=^File upload complete.*","innertext:=^File upload complete.*").GetROProperty("innertext")
	
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncBulkuploadImportMap = "False"
		Exit function
		
	End If
	
	Set RegEx = New RegExp
	RegEx.pattern = "\d+"
	RegEx.Ignorecase = False
	RegEx.Global = True
	Set Nums = RegEx.execute(ProcessText)
	ProcessNum = Nums(1)
	ObjAdditemsBatchPage.WebButton("name:=OK", "visible:=True").Click
	Wait(gSHORTWAIT)
	
	If Cint(ProcessNum)<>0 Then		
		Call gfReportExecutionStatus(micPass, "Bulk file upload:", "File upload successfull and "& "Process Id is:-"&ProcessNum) 
	End If
	
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "Item Creation:", "Got Error "& Err.Description) 
		bfuncBulkuploadImportMap = "False"
		Exit function
		
	End If
	
	'Just Bulk Update
	If Instr(ActionType,"Update") > 0 Then
		Call gfReportExecutionStatus(micPass, "Bulk Upload Update records", "Bulk Upload Update records is successfull") 
		bfuncBulkuploadImportMap = "True"
		Exit function
	End If
	
	NPRnum = FetchNPR(ProcessNum)	

	If Instr(NPRnum,"NPR")> 0 Then
		Call gfReportExecutionStatus(micPass, "Batch Item Creation using mapImport", "Batch Item is Created using mapImport")
		bfuncBulkuploadImportMap = "True"	
		dicGlobalOutput.Add StepID,NPRnum
	Else
		Call gfReportExecutionStatus(micFail, "Batch Item Creation using mapImport:", "Got Error "& Err.Description) 
		bfuncBulkuploadImportMap = "False"	
	End If

End  Function

''########################################################################################################################
''
''           PURPOSE: To Fetch NPR number from Batch Grid
''           Initial State          = 
''           Final State            = 
''           INPUT PARAMETERS       = 1 , Process Num
''           OUTPUT PARAMETERS      = 
''           OWNER                 =  DOH
''			Resource:Thirupathi				 Date:12/Feb/2020					Remarks
''########################################################################################################################


Function FetchNPR(ProcessNum)

	Err.Clear
	On error resume next
	
	'Editing Created Batch process item
	Set ObjManageBatchPage = Browser("name:=Manage Item Batches.*").Page("title:=Manage Item Batches.*")
	ObjManageBatchPage.WaitProperty "visible","True",4000
	ObjManageBatchPage.WebList("class:=x2h","name:=.*:value00$").Select 0
	Wait 1
	ObjManageBatchPage.WebEdit("class:=x112","name:=.*:value20$").Set ""
	Wait 1
	ObjManageBatchPage.WebEdit("class:=x25","name:=.*:value30$").Set ProcessNum
	ObjManageBatchPage.WebButton("name:=Search","Visible:=True").Click
	Wait(gSHORTWAIT)

	Do While ObjManageBatchPage.WebTable("html tag:=TABLE","cols:=15","innertext:="&ProcessNum&".*").GetCellData(1,7)= "Pending"
		ObjManageBatchPage.Image("alt:=Refresh","title:=Refresh").Click
		Wait(gSHORTWAIT)		
	Loop
	
	ObjManageBatchPage.WebTable("html tag:=TABLE","cols:=15","innertext:="&ProcessNum&".*").Highlight
	pNum = ObjManageBatchPage.WebTable("html tag:=TABLE","cols:=15","innertext:="&ProcessNum&".*").GetCellData(1,1)
	ActRecords = ObjManageBatchPage.WebTable("html tag:=TABLE","cols:=15","innertext:="&ProcessNum&".*").GetCellData(1,10)
	ProRecords = ObjManageBatchPage.WebTable("html tag:=TABLE","cols:=15","innertext:="&ProcessNum&".*").GetCellData(1,13)
	
	If cInt(ProcessNum) = cInt(pNum) and Cint(ActRecords) = Cint(ProRecords) Then
		print "New batch item present in the batch grid"
		Call gfReportExecutionStatus(micPass, "Manage Item Batches", "Batch records are processed")
	Else
		print "New batch item does not present in the batch grid"
		Call gfReportExecutionStatus(micFail, "Manage Item Batches", "Got Error "& Err.Description)
		bfuncCreateItem = "False"		
		Exit function
	End If
	
	ObjManageBatchPage.WebTable("html tag:=TABLE","cols:=15","innertext:="&ProcessNum&".*").Click
	Wait 2
	ObjManageBatchPage.Image("alt:=Edit","title:=edit").Click		
	Wait(gSHORTWAIT)	
	
	Set ObjEditBatch = Browser("name:=^Edit Item Batch: \d.*").Page("title:=Edit Item Batch: \d.*")
	If ObjEditBatch.Exist(gLONGWAIT) Then 
		print "Edit Item Batch screen is loaded"
	Else
		print "Edit Item Batch screen is not loaded "
		Call gfReportExecutionStatus(micFail, "Edit Item Batch screen", "Got Error "& Err.Description)
		bfuncBulkuploadImportMap = "False"		
		Exit function
	End If	
	
	ObjEditBatch.WebElement("innertext:=Edit Item Batch: \d.*","class:=xnq").WaitProperty "Visible",True,2000
	vNPR= ObjEditBatch.Link("html tag:=A","text:=NPR.*").GetROProperty("name")	
	
	
	If Err.Number <> 0 Then		
		Call gfReportExecutionStatus(micFail, "BulkUpdate Batch Item Creation:", "Got Error "& Err.Description) 
		FetchNPR = "False"		
		''Store the value in Global dict		
	else
		Call gfReportExecutionStatus(micPass, "BulkUpdate Batch Item Creation:", "NPR ID: "&vNPR)
		FetchNPR = vNPR	
		
	End If	
	Err.clear
	
'	Environment("NPRnum")=vNPR 
'	print Environment("NPRnum")
'	ObjEditBatch.Link("html tag:=A","text:=NPR.*").Click
'	ObjEditBatch.WebElement("innertext:=View New Item Request.*","outertext:=View New Item Request.*").WaitProperty "visible",True,2000
'	ObjEditBatch.Link("name:=Details","innertext:=Details","outertext:=Details","visible:=True").Click
'	ObjEditBatch.WebTable("rows:=5","cols:=9").WaitProperty "Visible",True,2000
	
	
End Function

''########################################################################################################################
''
''           PURPOSE: To check NPR number status in the application
''           Initial State          = 
''           Final State            = 
''           INPUT PARAMETERS       = 1 , NPR number
''           OUTPUT PARAMETERS      = 
''           OWNER                 =  DOH
''			Resource:Thirupathi				 Date:12/Feb/2020					Remarks
''########################################################################################################################

Function bfuncCheckNPRStatus(NPRnum)
	
	Err.Clear
	On Error Resume Next
	
	'Click on 'Tasks' ->Manage New Item Requests
	Set ObjPage = Browser("name:=.*Oracle Applications$").Page("title:=.*Oracle Applications$")
	ObjPage.Image("alt:=Tasks", "visible:=True").Click
	ObjPage.Sync	
	ObjPage.Link("name:=Manage New Item Requests","visible:=True").Click
	ObjPage.Sync
	
	'Add Filter conditions
	ObjPage.WebEdit("name:=.*:value00$","visible:=True").Set NPRnum
	ObjPage.WebList("name:=.*:value20","visible:=True").Select 0
	ObjPage.WebEdit("name:=.*:value50$","visible:=True").Set ""
	ObjPage.WebButton("name:=Search","visible:=True").Click
	
	If ObjPage.Link("name:="&NPRnum,"visible:=True").Exist(5) Then
		Call gfReportExecutionStatus(micPass, "NPR Check Filter", "NPR Search is successfull")
	Else
		Call gfReportExecutionStatus(micFail, "NPR Check Filter", "NPR Search is failed")
		bfuncCheckNPRStatus = "False"
		Exit function
	End  If
	

	'NPR Status Validation
	ObjPage.WebTable("class:=x1no x1oc","text:=NPR\d.*").Highlight
	status = ObjPage.WebTable("class:=x1no x1oc","text:=NPR\d.*").GetCellData(1,3)
	
	If Instr(status,"Completed") > 0 Then
		Call gfReportExecutionStatus(micPass, "Bulk upload NPR request", "NPR request is completed") 
	Else
		Call gfReportExecutionStatus(micFail, "Bulk upload NPR request", "NPR request is not completed") 
	End If
	
'	ObjPage.Link("title:=Expand","class:=x1g2").Click
'	Wait 1
'	ObjPage.Link("class:=.*xmr$","html id:=.*:tt1:2:cl3$","index:=0").Click
	
	If Err.Number <>0 Then
		
		Call gfReportExecutionStatus(micFail, "NPR Status Check:", "Got Error "& Err.Description) 
		bfuncCheckNPRStatus = "False"
		Exit function
	Else
		Call gfReportExecutionStatus(micPass, "NPR Status Check", "NPR Status Check is successfull") 
		bfuncCheckNPRStatus = "True"
		
	End If
	
End Function


Function bFuncVerifyBatchUpdate(NPRnum,UpdatedText)

	Err.Clear
	On Error Resume Next
	
	'Click on 'Tasks' ->Manage New Item Requests
	Set ObjPage = Browser("name:=.*Oracle Applications$").Page("title:=.*Oracle Applications$")
	ObjPage.Image("alt:=Tasks", "visible:=True").Click
	ObjPage.Sync	
	ObjPage.Link("name:=Manage New Item Requests","visible:=True").Click
	ObjPage.Sync
	
	'Add Filter conditions
	ObjPage.WebEdit("name:=.*:value00$","visible:=True").Set NPRnum
	ObjPage.WebList("name:=.*:value20","visible:=True").Select 0
	ObjPage.WebEdit("name:=.*:value50$","visible:=True").Set ""
	ObjPage.WebButton("name:=Search","visible:=True").Click
	
	If ObjPage.Link("name:="&NPRnum,"visible:=True").Exist(5) Then
		ObjPage.Link("title:=Expand","class:=x1g2").Click
		Call gfReportExecutionStatus(micPass, "NPR Check Filter", "NPR Search is successfull")
	Else
		Call gfReportExecutionStatus(micFail, "NPR Check Filter", "NPR Search is failed")
		bFuncVerifyBatchUpdate = "False"
		Exit function
	End  If
	

	'NPR records updates validation
	ObjPage.WebTable("class:=x1no x1oc","cols:=3","name:=t").WaitProperty "visible","True",5000	
	tRows = ObjPage.WebTable("class:=x1no x1oc","cols:=3","name:=t").RowCount()	
	Set RegEx = New RegExp
	RegEx.pattern = "\d+"
	RegEx.Ignorecase = False
	RegEx.Global = True
		
	For row = 1 To tRows
		
		vDesription = ObjPage.WebTable("class:=x1no x1oc","cols:=3","name:=t").GetCellData(row,3)
		If Instr(vDesription,UpdatedText) > 0 Then			
			Set vMatch = RegEx.execute(vDesription)
			ItemNum = vMatch.Item(0)
			print "Item: "&ItemNum&" is updated"
			Call gfReportExecutionStatus(micPass, "Bulk upload records updation Check:", "Item: "&ItemNum&" is updated") 
			bFuncVerifyBatchUpdate = "True"
		Else
			Call gfReportExecutionStatus(micFail, "Bulk upload records updation Check:", "Got Error "& Err.Description) 
			bFuncVerifyBatchUpdate = "False"
			Exit function
		End If
	Next

	Set RegEx = Nothing

	
	If Err.Number <> 0 Then
		
		Call gfReportExecutionStatus(micFail, "Bulk upload records updation Check:", "Got Error "& Err.Description) 
		bFuncVerifyBatchUpdate = "False"
		Exit function
	Else
		Call gfReportExecutionStatus(micPass, "Bulk upload records updation Check", "Bulk upload records updation Check is successfull") 
		bFuncVerifyBatchUpdate = "True"
		
	End If
	
End Function
