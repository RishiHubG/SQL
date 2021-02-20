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