USE JUNK
GO	
--COMMIT
----ROLLBACK
--BEGIN TRAN;
 EXEC dbo.SaveAssessmentJSONData 
 @EntityID=1,
 @UserLoginID=100,
 @inputJSON =
'{
  "general.Assessment Contact": "abc3",
  "general.Level of Operation": "xyz3",
  "general.Currency": "$1002",
  "riskDetail.Description": "this is a test",
  "riskDetail.Name": "hello my name is",
  "riskDetail.test": "1",
  "riskDetail.test1": "2",
  "riskDetail.test2": "3",
  "riskDetail.test4": "4",
  "riskDetail.test5": "5",
  "riskDetail.test6": "6" 
}'
  

/*
SELECT * FROM dbo.Registers
SELECT * FROM dbo.RegisterProperties
SELECT * FROM dbo.RegisterPropertiesXref
SELECT * FROM RegisterPropertyXerf_Data

SELECT * FROM dbo.Registers_history
SELECT * FROM dbo.RegisterProperties_history
SELECT * FROM dbo.RegisterPropertiesXref_history
SELECT * FROM RegisterPropertyXerf_Data_history

SELECT * FROM RegisterPropertyXerf_Data
SELECT * FROM RegisterPropertyXerf_Data_history

TRUNCATE TABLE RegisterPropertyXerf_Data
TRUNCATE TABLE RegisterPropertyXerf_Data_history

*/
--UNION OF PERMISSIONS: TO DO FOR UG USERS
--DELETE: DONE
--NEW TABLE UserAccessControlledResource: DONE

SELECT * FROM dbo.AccessControlledResource
SELECT * FROM Registers

--ROLLBACK COMMIT
SET XACT_ABORT ON;
BEGIN TRAN;
DELETE FROM Registers --WHERE registerid=1
exec SaveAssessmentJSONData 
@EntityId=-1,
@EntitytypeId=3,
@ParentEntityID=16,
@ParentEntityTypeID=2,
@RegisterName=N'Domain3',
@Description=N'Domain1 description',
@InputJSON=N'{"attributes":{"currency":"usd","exchangeRate":1.1},"domainpermissiona":[{"userUserGroup":"testname","userid":2, "read":false,"modify":true,"write":true,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false},{"userUserGroup":"test8","userid":3,"modify":true,"write":true,"cut":true,"copy":true,"delete":false,"administrate":false,"adhoc":false}],"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"test8","userid":3,"read":false,"modify":true,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"control1","stepstepItem":"step","stepname":"controlDetail","view":true},{"userUserGroup":"test9","userid":3,"workflowname":"control1","stepstepItem":"stepItem","stepname":"controlDetail","view":true,"modify":true}],"WFinheritpermissions":false,"frameworklist":{"control":true,"control2":true}}',
@MethodName=NULL,@UserLoginID=3261

  



  	
	--PROVIDE ALL PERMISSIONS FOR ADMIN/ADMIN UG
	--IF @UserID IN (1,2)
 -- 		INSERT INTO dbo.AccessControlledResource(
	--											[AccessControlID], [UserCreated], [DateCreated], [UserModified], [DateModified], [UserId], 
	--											[Rights], [Customised], [Read], [Modify], [Write], [Administrate], [Cut], [Copy], [Export], [Delete], [Report], [Adhoc]
	--											)
	--	SELECT @AccessControlID,@UserID,@UTCDATE,@UserID,@UTCDATE,@UserID,
	--		   1,1,1,1,1,1,1,1,1,1,1,1

USE [agsqa]
GO

/****** Object:  Table [dbo].[AccessControlledResource]    Script Date: 04/06/2021 16:45:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @TBL TABLE(
	[AccessControlID] [int] NULL,
	[UserCreated] [int] NULL,
	[DateCreated] [datetime] NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime] NULL,
	[UserId] [int] NULL,
	[Rights] [int] NULL,
	[Customised] [bit] NULL,
	[Read] [int] NULL,
	[Modify] [int] NULL,
	[Write] [int] NULL,
	[Administrate] [int] NULL,
	[Cut] [int] NULL,
	[Copy] [int] NULL,
	[Export] [int] NULL,
	[Delete] [int] NULL,
	[Report] [int] NULL,
	[Adhoc] [int] NULL 
	)

	INSERT INTO @TBL (USERID,[Read]) VALUES(1,1)
	INSERT INTO @TBL (USERID,[Read],Write,[Modify]) VALUES(1,1,1,1)
	INSERT INTO @TBL (USERID,[Modify]) VALUES(1,1)
	INSERT INTO @TBL (USERID,Write) VALUES(2,1)
	INSERT INTO @TBL (USERID,[Modify]) VALUES(2,1)

	SELECT userid,SUM([Read]),SUM([Modify]),SUM(Write)
	FROM @TBL
	GROUP BY userid

IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=153 AND UserID=2)
INSERT INTO dbo.AccessControlledResource ([Adhoc], [Administrate], [Copy], [Cut], [Delete], [Export], [Modify], [Read], [Report], [Rights], [UserID], [Write],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)VALUES ('1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '2', '1','153','3261','2021-06-05 04:28:22.520','3261','2021-06-05 04:28:22.520','1'); 
 IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=153 AND UserID=1)
INSERT INTO dbo.AccessControlledResource ([Adhoc], [Administrate], [Copy], [Cut], [Delete], [Export], [Modify], [Read], [Report], [Rights], [UserID], [Write],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)VALUES ('1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1','153','3261','2021-06-05 04:28:22.520','3261','2021-06-05 04:28:22.520','1'); 
 IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=153 AND UserID=2)
INSERT INTO dbo.AccessControlledResource ([userid], [read], [modify], [write], [cut], [copy], [delete], [administrate], [adhoc],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)VALUES ('2', 'false', 'true', 'true', 'false', 'false', 'false', 'false', 'false','153','3261','2021-06-05 04:28:22.520','3261','2021-06-05 04:28:22.520','1'); 
 IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=153 AND UserID=3)
INSERT INTO dbo.AccessControlledResource ([userid], [modify], [write], [cut], [copy], [delete], [administrate], [adhoc],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)VALUES ('3', 'true', 'true', 'true', 'true', 'false', 'false', 'false','153','3261','2021-06-05 04:28:22.520','3261','2021-06-05 04:28:22.520','1'); 

 SELECT * FROM Registers

 --ROLLBACK COMMIT
SET XACT_ABORT ON;
BEGIN TRAN;
DELETE FROM Registers --WHERE registerid=1
exec SaveRegisterJSONData 
@EntityId=-1,
@EntitytypeId=3,
@ParentEntityID=16,
@ParentEntityTypeID=2,
@Name=N'Domain3',
@Description=N'Domain1 description',
@InputJSON=N'{"attributes":{"currency":"usd","exchangeRate":1.1},"domainpermissiona":[{"userUserGroup":"testname","userid":2, "read":false,"modify":true,"write":true,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false},{"userUserGroup":"test8","userid":3,"modify":true,"write":true,"cut":true,"copy":true,"delete":false,"administrate":false,"adhoc":false}],"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"test8","userid":3,"read":false,"modify":true,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"control1","stepstepItem":"step","stepname":"controlDetail","view":true},{"userUserGroup":"test9","userid":3,"workflowname":"control1","stepstepItem":"stepItem","stepname":"controlDetail","view":true,"modify":true}],"WFinheritpermissions":false,"frameworklist":{"control":true,"control2":true}}',
@FrameworkID = 1,
@MethodName=NULL,@UserLoginID=3261


SELECT * FROM Registers
 

 --ROLLBACK COMMIT
SET XACT_ABORT ON;
BEGIN TRAN;
EXEC dbo.SaveregisterJSONData 
@EntityID=-1,
@InputJSON='{"attributes":{"currency":""},"domainpermissiona":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"username":"","export":false,"report":false}],"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"","stepstepItem":"","stepname":"","stepItemName":{},"view":false}],"WFinheritpermissions":false}',
@UserLoginID=3355,@LogRequest=1,
@EntityTypeID=3,@ParentEntityID=4,
@ParentEntityTypeID=2,
@FrameworkID=11,
@name='Test wtih Rishi132',
@MethodName=NULL

SELECT * FROM RegisterPropertiesXref_Data
SELECT * FROM REGISTERS  ORDER BY REGISTERID DESC
SELECT * FROM REGISTERS WHERE REGISTERID=39
INSERT INTO dbo.RegisterPropertiesXref_Data(RegisterID, [UserCreated], [Currency],ExchangeRate) VALUES('40', '3355', '','')
RegisterPropertiesXref_Data_History

 --ROLLBACK COMMIT
SET XACT_ABORT ON;
BEGIN TRAN;
EXEC dbo.SaveregisterJSONData @EntityID=-1,@InputJSON='{"attributes":{"currency":""},"domainpermissiona":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"username":"","export":false,"report":false}],"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"","stepstepItem":"","stepname":"","stepItemName":{},"view":false}],"WFinheritpermissions":false}',
@UserLoginID=3355,@LogRequest=1,@EntityTypeID=3,@ParentEntityID=4,@ParentEntityTypeID=2,@FrameworkID=11,
@name='Test wtih Rishi11',@MethodName=NULL


--EXEC dbo.RegisterCleanupByFrameworkID @Frameworkid =11111
CREATE OR ALTER  PROC dbo.RegisterCleanupByFrameworkID
@Frameworkid INT
AS
BEGIN

DECLARE @RegisterID INT
SELECT @RegisterID = RegisterID FROM dbo.Registers WHERE frameworkid=@frameworkid

DELETE FROM RegisterPropertiesXref_Data WHERE RegisterID=@RegisterID
DELETE FROM RegisterPropertiesXref WHERE RegisterID=@RegisterID
DELETE FROM RegisterProperties WHERE RegisterID=@RegisterID
DELETE FROM Registers WHERE RegisterID=@RegisterID

END