USE VKB_NEW
GO
--USER/CONTACT: if column is name then BOTH CONTACT/USER ELSE ONLY CONTACT
SET XACT_ABORT ON
--COMMIT ROLLBACK
BEGIN TRAN
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