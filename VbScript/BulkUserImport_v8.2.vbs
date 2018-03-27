'=================================================================================================================
' BulkUserLoad version 8.2
'=================================================================================================================
Dim strSearchVal
Dim sConn
Dim oConn
Dim LogWriter
Dim DBWriter

Dim SetGroupPermission
Dim costCodeFromAD
Dim strLogFolder
Dim strLogFilePath

strLogFilePath = Replace(Wscript.ScriptFullName, Wscript.ScriptName, "")
strLogFolder = "Logs"



'=================================================================================================================
' EDITABLE CONFIGURATION SETTINGS
'=================================================================================================================

LogWriter = True:        FileName = strLogFilePath & strLogFolder &"\bulkUserimportLoadLogs"&Year(Date())&Month(Date())&Day(Date())&".txt"
DBWriter = True: sConn = "<ConectionDetails>"

SetGroupPermission = False  'Set true to import AD Group Permissions (Group Mapping)
costCodeFromAD = 0  'Cost code from AD 0 is false, 1 is true

regExFilter = ".*"  'Only AD account names which match this regular expression will be imported into Condeco
regExIgnoreCase = False

'=================================================================================================================
' DO NOT EDIT BELOW THIS LINE
'=================================================================================================================


SET RS1 = CreateObject("ADODB.recordset")
SqlQ1 = "SELECT * from tbldomains WHERE pkDomainID > 1 and active=1"
RS1.open SqlQ1,sConn,3,3
arr_domains =  RS1.getRows()

dString = ""
dDomainId = ""

for ii = 0 to uBound(arr_domains,2)

	if len(trim(dString)) > 0 then
		dString= dString&"~"&arr_domains(2,ii)
		dDomainId = dDomainId&"~"&arr_domains(0,ii)
	else
		dString= arr_domains(2,ii)
		dDomainId = arr_domains(0,ii)
	end if


next
LDAP_Connection_string = split(dString,"~")
LDAP_dom = split(dDomainId,"~")



'=================================================================================================================

Const adCmdStoredProc = &H0004
Const adParamInput = &H0001
Const adParamOutput = &H0002
Const adParamInputOutput = &H0003
Const adParamReturnValue = &H0004

Const adEmpty = 0
Const adTinyInt = 16
Const adSmallInt = 2
Const adInteger = 3
Const adBigInt = 20
Const adUnsignedTinyInt = 17
Const adUnsignedSmallInt = 18
Const adUnsignedInt = 19
Const adUnsignedBigInt = 21
Const adSingle = 4
Const adDouble = 5
Const adCurrency = 6
Const adDecimal = 14
Const adNumeric = 131
Const adBoolean = 11
Const adError = 10
Const adUserDefined = 132
Const adVariant = 12
Const adIDispatch = 9
Const adIUnknown = 13
Const adGUID = 72
Const adDate = 7
Const adDBDate = 133
Const adDBTime = 134
Const adDBTimeStamp = 135
Const adBSTR = 8
Const adChar = 129
Const adVarChar = 200
Const adLongVarChar = 201
Const adWChar = 130
Const adVarWChar = 202
Const adLongVarWChar = 203
Const adBinary = 128
Const adVarBinary = 204
Const adLongVarBinary = 205
Const adChapter = 136
Const adFileTime = 64
Const adPropVariant = 138
Const adVarNumeric = 139
Const adArray = &H2000



IF DBWriter = TRUE OR SetGroupPermission = True Then

            Set oConn = CreateObject("ADODB.Connection")
            oConn.Open sConn

End IF


IF LogWriter = TRUE Then

            Set fs = CreateObject("Scripting.FileSystemObject")
            If Not fs.FolderExists(strLogFolder) Then
                        fs.CreateFolder strLogFolder
            End If
            Set a = fs.CreateTextFile(FileName, True)

End IF

LdapCons = 0

a.WriteLine("***  BULK USER IMPORT START***")

do while LdapCons <= uBound(LDAP_Connection_string)
            on error resume next
            if LDAP_Connection_string(LdapCons) <> "" Then
                        
                        If LogWriter = True Then
                                    a.WriteLine("*** Start of logging. Domain=" & LDAP_Connection_string(LdapCons) & "***")
                        END IF
                        
                       call QueryLDAP(LDAP_Connection_string(LdapCons),LDAP_dom(LdapCons))
                        
                        If LogWriter = True Then
                                    a.WriteLine("*** End of logging. Domain=" & LDAP_Connection_string(LdapCons) & "***")
                        END IF
            End if


            If Err.Number <> 0   and LogWriter = TRUE  Then
              'WScript.Echo "Error in connection: " & Err.Description
              a.writeline("Error in connection: " & Err.Description)

                        Err.Clear
            End If


            LdapCons = LdapCons +1
Loop
If DBWriter = True Then
	set objCmd_addNewUser = CreateObject("ADODB.command")
	set objCmd_addNewUser.activeconnection = oConn
	objCmd_addNewUser.CommandText = "dbo.usp_LDAP_addNewUser_v1"
	objCmd_addNewUser.CommandType = adCmdStoredProc
	objCmd_addNewUser.CommandTimeout = 0
	objCmd_addNewUser.execute
	Set objCmd_addNewUser = Nothing
End if
a.WriteLine("***  BULK USER IMPORT END***")
' THIS PART TAKES CARE OF THE GROUP PERMISSIONS
IF SetGroupPermission = TRUE THEN

    GetGroups()
            ImportUserBusinessUnitPermissions()

End If


IF DBWriter = TRUE OR SetGroupPermission = True Then

            oConn.close
            Set oConn = nothing

End IF


IF DBWriter = TRUE Then
            Set fs = nothing
End IF

IF LogWriter = TRUE Then

            Set fs = Nothing

End IF


Function QueryLDAP(LDAP_Connection_string, domain)

            IF LDAP_Connection_string <> "" Then

                        dim x   

                        dim strDepartmentNubmerFieldValue
            
                        set x = ADUserSearch(LDAP_Connection_string)

                        Set re = New RegExp
                      With re
                          .Pattern    = regExFilter
                          .IgnoreCase = regExIgnoreCase
                          .Global     = False
                      End With
        
                        IF isObject(x) THEN
                                    IF x.recordCount > 0 THEN
                                                Do while x.EOF = false 
                    
                                                    
                                                        on error resume next                           
                                                            strDepartmentNubmerFieldValue = ""
                                                            'Uncomment block, change value and use if cost code value is stored in a multi value field
                                                            If Not IsNull(x("departmentNumber").Value) Then
                                                                        For Each StrdepartmentNumber in x("departmentNumber").Value
                                                            'Wscript.Echo "CostCode: " & StrdepartmentNumber
                                                                                    strDepartmentNubmerFieldValue = StrdepartmentNumber
                                                                        NEXT
                                                            ELSE
                                                                        strDepartmentNubmerFieldValue = ""
                                                            END IF
                                                            'Wscript.Echo "**CostCode: " & strDepartmentNubmerFieldValue

                                                            If re.Test(x("sAMAccountName")) Then                                                          
                                                                'ADDED BY PANKAJ FOR TASK-6609
                                                                If DBWriter = True Then
                                                                            set objCmd_addNewUser = CreateObject("ADODB.command")
                                                                            set objCmd_addNewUser.activeconnection = oConn
                                                                            objCmd_addNewUser.CommandText = "dbo.usp_LDAP_importToStaging"
                                                                            objCmd_addNewUser.CommandType = adCmdStoredProc
                                                                            
                                                                            objCmd_addNewUser.NamedParameters = true

                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@userID", adInteger, adParamInputOutput, 0)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@username", adVarchar, adParamInput, 100, LeftB(x("sAMAccountName"), 100))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@title", adVarchar, adParamInput, 100, "")
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@firstName", adVarchar, adParamInput, 100, LeftB(x("givenname"), 100))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@lastName", adVarchar, adParamInput, 100, LeftB(x("sn"), 100))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@telephone", adVarchar, adParamInput, 100, LeftB(x("telephoneNumber"), 100))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@mobile", adVarchar, adParamInput, 100, LeftB(x("mobile"), 100))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@extension", adVarchar, adParamInput, 150, "")
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@fax", adVarchar, adParamInput, 150, "")
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@email", adVarchar, adParamInput, 200, LeftB(x("mail"), 200))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@accessLevel", adInteger, adParamInput, , 4)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@languageID", adInteger, adParamInput, , 1)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@countryID", adInteger, adParamInput, ,1)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@businessUnitID", adInteger, adParamInput, , 0)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@locationID", adInteger, adParamInput, , 3)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@floor", adInteger, adParamInput, , -100)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@parkingSchemeID", adInteger, adParamInput, , 0)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@parkingAdmin", adInteger, adParamInput, ,0)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@department", adInteger, adParamInput, ,0)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@employeeID", adVarchar, adParamInput, 255,0)
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@ADUserGUID", adGUID, adParamInput, , ConvertHexStrGuidToStrGuid(OctetToHexStr(x("objectGUID"))))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@costCodeFromAD", adInteger, adParamInput, , costCodeFromAD)
                                                                            'Uncomment and add cost code value if it is in a multi value field if required - see above
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@costCode", adVarchar, adParamInput, 255, strDepartmentNubmerFieldValue)

                                                                            'Uncomment and add the CSN field value if required
                                                                            'objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@CSN", adVarchar, adParamInput, 20, x("Pager"))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@domainID", adInteger, adParamInput, 100, cint(domain))
                                                                            objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("@domainString", adVarchar, adParamInput, 100, LDAP_Connection_string)
                                                                            objCmd_addNewUser.execute
                                                                            set objCmd_addNewUser = nothing
                                                                End IF

                                                                If LogWriter = True Then
    																a.WriteLine(LDAP_Connection_string & "-" & x("sAMAccountName") & "-" & x("givenname") & "-" & x("sn") & "-" & x("company"))
                                                                END IF

                                                            End If
                                                
                                                            x.Movenext
                                                            
                                                            If Err.Number <> 0   and LogWriter = TRUE  Then
                                                                        'WScript.Echo "Error in connection: " & Err.Description
                                                                        a.writeline("Error inside ldap lookup: " & Err.Description)
            
                                                                        Err.Clear
                                                            End if
                                                       
                                                Loop
                                    End if

                                    'close recordset
                                    x.close

                        End if   

                        set x = nothing
                        set re = nothing

            End If

End Function

Function ADUserSearch(szConn)

    Dim adoConnection, objCommand
    Dim strQuery, adoRecordset

    Const adOpenStatic = 3
    Const adLockOptimistic = 3
    Const adUseClient = 3
    Const ADS_SCOPE_SUBTREE = 1

    ' Use ADO to search Active Directory.
    Set adoConnection = CreateObject("ADODB.Connection")
    Set objCommand = CreateObject("ADODB.Command")

    adoConnection.Provider = "ADsDSOObject"
    adoConnection.Open "Active Directory Provider"

    Set objCommand.ActiveConnection = adoConnection
    objCommand.Properties("Page Size") = 1000
    'objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 

    Set adoRecordset = CreateObject("ADODB.Recordset")
    
    strQuery = "select sAMAccountName, givenname, sn, mail, telephoneNumber, mobile, department, company, objectGUID, departmentNumber " & _
    "from '" & szConn & "' " & _
    "WHERE objectCategory='Person' " & _
    "AND objectClass='user' "  & _
    "AND userAccountControl <> 514 " & _
    "AND givenname = '*' " & _
    "AND sn = '*' "         

    strQuery = strQuery & " ORDER BY sn"
    
    ' Run the query.
    objCommand.CommandText = strQuery

    adoRecordset.CursorLocation = adUseClient
    adoRecordset.CursorType = adOpenStatic
    adoRecordset.LockType = adLockOptimistic
    adoRecordset.Open objCommand

    ' Disconnect the recordset.
    Set adoRecordset.ActiveConnection = Nothing
    adoConnection.Close

    ' Clean up.
    'adoRecordset.Close
    Set objCommand = Nothing

    Set ADUserSearch = adoRecordset           
    
End Function

Function OctetToHexStr(arrbytOctet)
' Function to convert OctetString (byte array) to Hex string.

Dim k
OctetToHexStr = ""
For k = 1 To Lenb(arrbytOctet)
OctetToHexStr = OctetToHexStr _
& Right("0" & Hex(Ascb(Midb(arrbytOctet, k, 1))), 2)
Next
End Function

Function ConvertHexStrGuidToStrGuid(strOctet)
Dim tempGuid, GuidStr
GuidStr = Mid(strOctet, 7, 2)
GuidStr = GuidStr & Mid(strOctet, 5, 2)
GuidStr = GuidStr & Mid(strOctet, 3, 2)
GuidStr = GuidStr & Mid(strOctet, 1, 2)
GuidStr = GuidStr & Mid(strOctet, 11, 2)
GuidStr = GuidStr & Mid(strOctet, 9, 2)
GuidStr = GuidStr & Mid(strOctet, 15, 2)
GuidStr = GuidStr & Mid(strOctet, 13, 2)
GuidStr = GuidStr & Mid(strOctet, 17)

TempGuid = "{" & Mid(GuidStr, 1, 8) & "-" & Mid(GuidStr, 9, 4) _
& "-" & Mid(GuidStr, 13, 4) & "-" & Mid(GuidStr, 17, 4) _
& "-" & Mid(GuidStr, 21, 15) & "}"

ConvertHexStrGuidToStrGuid = tempGuid
End Function

Sub GetGroups()

    set oRS_ldapGroups = CreateObject("ADODB.Recordset")
    oRS_ldapGroups.CursorLocation = 3
    oRS_ldapGroups.Open "dbo.usp_getLDAPGroups", sConn

    if oRS_ldapGroups.recordcount <> 0 then arr_ldapGroups = oRS_ldapGroups.getRows() end if
    oRS_ldapGroups.Close


    Dim i
    For i = 0 to Ubound(LDAP_Connection_string)

		If LDAP_Connection_string(i) <> "" Then        

			If IsArray(arr_ldapGroups) Then 
        
				For r = 0 to uBound(arr_ldapGroups,2) 
					GetUsersForGroup arr_ldapGroups(0,r), LDAP_Connection_string(i)
                Next
            End if
        End If

    Next             

End Sub

Function GetUsersForGroup(strGroup, strLDAPDomain)

    Dim strDNSDomain, adoConnection
    Dim strBase, strFilter, strAttributes, strQuery, adoRecordset
    Dim objList

    Const adOpenStatic = 3
    Const adLockOptimistic = 3
    Const adUseClient = 3

    ' Use ADO to search Active Directory.
    Set objCommand = CreateObject("ADODB.Command")
    Set adoConnection = CreateObject("ADODB.Connection")
    adoConnection.Provider = "ADsDSOObject"
    adoConnection.Open "Active Directory Provider"

    Set objCommand.ActiveConnection = adoConnection
    objCommand.Properties("Page Size") = 1000

    Set adoRecordset = CreateObject("ADODB.Recordset")

    ' Construct the LDAP query.
    strQuery = "select sAMAccountName, givenname, sn, mail, telephoneNumber, mobile, department, company, objectGUID, departmentNumber " & _
    "from '" & strLDAPDomain & "' " & _
    " WHERE MemberOf='" & strGroup &"' "		

    ' Run the query.
    objCommand.CommandText = strQuery

    adoRecordset.CursorLocation = adUseClient
    adoRecordset.CursorType = adOpenStatic
    adoRecordset.LockType = adLockOptimistic

    On Error Resume Next

    adoRecordset.Open objCommand

	If Err.Number <> 0 Then
		If LogWriter = True Then
			a.WriteLine("")
            a.writeline("Error: " &strLDAPDomain &" - " & Err.Description)
			Err.Clear
        End If
    End If

	If adoRecordset.RecordCount = 0 Then
		If LogWriter = True Then
			a.WriteLine("")
			a.writeline("Error: Could not find any users for " &strGroup &" in domain "&strLDAPDomain)
		End If
	End If

    ' Disconnect the recordset.
    Set adoRecordset.ActiveConnection = Nothing
    adoConnection.Close


    If LogWriter = True Then
		a.WriteLine("")
        a.WriteLine("*** Start of permission logging for domain " &strLDAPDomain)
    End If

    ' Enumerate members of the group.
    Call EnumMembers(adoRecordset, strGroup)

    If LogWriter = True Then
		a.WriteLine("*** End of permission logging for domain " &strLDAPDomain)
    End If

    ' Clean up.
    adoRecordset.Close
    Set objCommand = Nothing

End Function

Sub EnumMembers(adoDiscRS, strGroupDN)

	If adoDiscRS.RecordCount > 0 Then

		Dim strsAMAccountName, strGivenName, strSN, strObjectGUID

    	adoDiscRS.MoveFirst
		'Start Fix Changes done by Mark
		On Error Resume Next
		'End Fix Changes done by Mark
    	Do Until adoDiscRS.EOF
			strsAMAccountName = adoDiscRS("sAMAccountName")
			strGivenName = adoDiscRS("givenname")
			strSN = adoDiscRS("sn")
			strObjectGUID = ConvertHexStrGuidToStrGuid(OctetToHexStr(adoDiscRS("objectGUID")))

        	If LogWriter = True Then
				a.WriteLine(strsAMAccountName & "-" & strGivenName & "-" & strSN & "-" &strObjectGUID &"-" &strGroupDN)
        	End If

			Call storeADGroupUsers(strGroupDN, strObjectGUID)
        	'Wscript.Echo strObjectGUID

			adoDiscRS.MoveNext
    	Loop
        
	End If
End Sub


Function storeADGroupUsers(strGroup, strObjectGUID)

    Set objCmd_addNewUser = CreateObject("ADODB.command")
    Set objCmd_addNewUser.activeconnection = oConn
    objCmd_addNewUser.CommandText = "dbo.usp_storeADGroupUsers"
    objCmd_addNewUser.CommandType = adCmdStoredProc
    objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("ADGroupName", adVarchar, adParamInput, 200, strGroup)
    objCmd_addNewUser.Parameters.Append objCmd_addNewUser.CreateParameter("ADUserGUID", adGUID, adParamInput, , strObjectGUID)
	objCmd_addNewUser.execute
    Set objCmd_addNewUser = Nothing

End Function

Sub ImportUserBusinessUnitPermissions()
	'execute usp_ImportUserBusinessUnitPermissions to permission the users
    Set objCmd_addNewUser = CreateObject("ADODB.command")
    Set objCmd_addNewUser.activeconnection = oConn
    objCmd_addNewUser.CommandText = "dbo.usp_ImportUserBusinessUnitPermissions"
    objCmd_addNewUser.CommandType = adCmdStoredProc
	objCmd_addNewUser.execute
    Set objCmd_addNewUser = Nothing
End Sub
