USE VKB_NEW
GO
--USER/CONTACT: if column is name then BOTH CONTACT/USER ELSE ONLY CONTACT
SET XACT_ABORT ON
--COMMIT ROLLBACK
BEGIN TRAN
---WHILE INSERTING INTO AUSER MAKE SURE NAME COLUMN IS AVAILABLE IN JSON STRING
--IF columnToCompare":"Name" IS MAtching IN AUser then Update Contact
--IF columnToCompare":"Name" IS NOT MAtching IN AUser AND NAME IS AVAILABLE in Json then INSERT AUser/Contact
--IF columnToCompare":"Name" IS NOT MAtching IN AUser AND NAME IS NOT AVAILABLE in Json then INSERT Contact
--IF columnToCompare":"AnyOtherColumn" AND NAME IS AVAILABLE/AVAIAlable IN Contact then Insert Contact/AUser OR UPDATE Contact
--IF columnToCompare":"Email" AND Name IS NOT AVAILABLE Then Insert/Update Contact
exec importDataForEntity 
@dataJSON=N'{"data":[{"entityType":"4","columnToCompare":"Name","dataToMap":[{"FirstName":"ABC","MiddleName":"DEF","Name":"ABCDEF","JobTitle":"CTO","E_Mail":"ABCDEF@gmail.com"},{"FirstName":"XYZ","MiddleName":"MNO","Name":"ZYZMNO","JobTitle":"DPO","E_Mail":"ZYXMNO@gmail.com"}]},{"entityType":"","columnToCompare":"","dataToMap":[{},{}]}],"fileName":"Contact.xlsx","sheetsDependency":[{"leftSheetIndex":0,"leftColumnName":"","rightSheetIndex":1,"rightColumnName":""}]}',
@MethodName=NULL,
@UserLoginID=2913

--DISPLAY NAME: FNAME+LNAME DEFAULT
SELECT * FROM Contact
--validUpto:20991231 default
SELECT * FROM AUser


INSERT INTO dbo.Contact 
(FirstName,MiddleName,Name,JobTitle,E_Mail) OUTPUT INSERTED.ContactID INTO #TBL_Contact(ContactID) 
VALUES ('ABC','DEF','ABCDEF','CTO','ABCDEF@gmail.com');

USE VKB_NEW
GO
--USER/CONTACT: if column is name then BOTH CONTACT/USER ELSE ONLY CONTACT
SET XACT_ABORT ON
--COMMIT ROLLBACK
BEGIN TRAN
---WHILE INSERTING INTO AUSER MAKE SURE NAME COLUMN IS AVAILABLE IN JSON STRING
--IF columnToCompare":"Name" IS MAtching IN AUser then Update Contact
--IF columnToCompare":"Name" IS NOT MAtching IN AUser AND NAME IS AVAILABLE in Json then INSERT AUser/Contact
--IF columnToCompare":"Name" IS NOT MAtching IN AUser AND NAME IS NOT AVAILABLE in Json then INSERT Contact
--IF columnToCompare":"AnyOtherColumn" AND NAME IS AVAILABLE/AVAIAlable IN Contact then Insert Contact/AUser OR UPDATE Contact
--IF columnToCompare":"Email" AND Name IS NOT AVAILABLE Then Insert/Update Contact
exec importDataForEntity 
@dataJSON=N'{"data":[{"entityType":"4","columnToCompare":"Name","dataToMap":[{"FirstName":"ABC","MiddleName":"DEF","Name":"ABCDEF","JobTitle":"CTO","E_Mail":"ABCDEF@gmail.com"},{"FirstName":"XYZ","MiddleName":"MNO","Name":"ZYZMNO","JobTitle":"Branch Manager","E_Mail":"ZYXMNO@gmail.com"}]},{"entityType":"","columnToCompare":"","dataToMap":[{},{}]}],"fileName":"Contact.xlsx","sheetsDependency":[{"leftSheetIndex":0,"leftColumnName":"","rightSheetIndex":1,"rightColumnName":""}]}',
@MethodName=NULL,
@UserLoginID=2913;
 
 SELECT CAST(0x AS UNIQUEIDENTIFIER)
  

  exec importDataForEntity 
  @dataJSON=N'{"data":[{"entityType":"5","entityId":-1,"parentEntityId":-1,"parentEntityTypeId":-1,"columnToCompare":"E_Mail","dataToMap":[{"Name":"nitindd","FirstName":"Nitin","MiddleName":"dn","E_Mail":"nitind@gmail.com"},{"Name":"Prashanthig","FirstName":"Prashanthi","MiddleName":"g","E_Mail":"Prashanthig@gmail.com"},{"Name":"srinathk","FirstName":"Srinath","MiddleName":"k","E_Mail":"srinathk@gmail.com"}]}],"fileName":"import.xlsx","sheetsDependency":[]}',
  @MethodName=NULL,@UserLoginID=2962

  SELECT * FROM Contact WHERE E_Mail IN ('nitind@gmail.com','Prashanthig@gmail.com','srinathk@gmail.com')

    exec importDataForEntity 
  @dataJSON=N'{"data":[{"entityType":"5","entityId":-1,"parentEntityId":-1,"parentEntityTypeId":-1,"columnToCompare":"E_Mail","dataToMap":[{"Name":"nitindd","FirstName":"Nitin","MiddleName":"dn","E_Mail":"abc1@gmail.com"},{"Name":"Prashanthig","FirstName":"Prashanthi","MiddleName":"g","E_Mail":"Prashanthig1@gmail.com"},{"Name":"srinathk","FirstName":"Srinath","MiddleName":"k","E_Mail":"srinathk1@gmail.com"}]}],"fileName":"import.xlsx","sheetsDependency":[]}',
  @MethodName=NULL,@UserLoginID=2962

  
SELECT * FROM Contact ORDER BY ContactID desc

SELECT * FROM AUser ORDER BY USERID DESC

    exec importDataForEntity 
  @dataJSON=N'{"data":[{"entityType":"5","entityId":-1,"parentEntityId":-1,"parentEntityTypeId":-1,"columnToCompare":"Name","dataToMap":[{"Name":"nitindd","FirstName":"Nitin","MiddleName":"dn","E_Mail":"abc@gmail.com"},{"Name":"Prashanthig","FirstName":"Prashanthi","MiddleName":"g","E_Mail":"Prashanthig@gmail.com"},{"Name":"srinathk","FirstName":"Srinath","MiddleName":"k","E_Mail":"srinathk@gmail.com"}]}],"fileName":"import.xlsx","sheetsDependency":[]}',
  @MethodName=NULL,@UserLoginID=2962

 SELECT * FROM AUser WHERE NAME ='nitindd'

   exec importDataForEntity 
  @dataJSON=N'{"data":[{"entityType":"5","entityId":-1,"parentEntityId":-1,"parentEntityTypeId":-1,"columnToCompare":"E_Mail","dataToMap":[{"Name":"nitindd","FirstName":"Nitin","MiddleName":"dn1","E_Mail":"abc1@gmail.com"}]}],"fileName":"import.xlsx","sheetsDependency":[]}',
  @MethodName=NULL,@UserLoginID=2962
 						