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

IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=117 AND UserID=2)
INSERT INTO dbo.AccessControlledResource ([Adhoc], [Administrate], [Copy], [Cut], [Delete], [Export], [Modify], [Read], [Report], [Rights], [Write],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)VALUES ('1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1','117','3261','2021-06-04 07:04:02.267','3261','2021-06-04 07:04:02.267','1'); 


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

SET XACT_ABORT ON;
BEGIN TRAN;
IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=127 AND UserID=<USERID>) INSERT INTO dbo.AccessControlledResource ([Adhoc], [Administrate], [Copy], [Cut], [Delete], [Export], [Modify], [Read], [Report], [Rights], [Write],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)VALUES ('1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1','127','3261','2021-06-04 07:42:02.047','3261','2021-06-04 07:42:02.047','1')