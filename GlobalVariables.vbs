'*******************************************************************************************************************************************************************************************
'Function Lib Name			  			 	- GlobalVariables.vbs
'Author		            		  			- DXC	 	
'Created On                      			- 
'Target Application            				- 
'Purpose / Description      				- This library intended for storing all global variables 
'# which are being used across all the Tests.
'*******************************************************************************************************************************************************************************************
Option Explicit

'Store synchronization value
Public gBrowserType
Public gSYNCWAIT
Public gSHORTWAIT
Public gMEDIUMWAIT
Public gLONGWAIT
Public gTIMEOUT
Public DataTableSheet
Public DataTableBook 
Public gMultipleEntries
Public gstrFail
Public ObjFSOReport
Public rsTestCaseData
Public rsTestData
Set ObjFSOReport = CreateObject("Scripting.FileSystemObject") 					'		Create FileSystem Object

