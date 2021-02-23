USE JUNK
GO	
--COMMIT
----ROLLBACK
--BEGIN TRAN;
 EXEC dbo.SaveUniverseJSONData 
 @EntityID=-1,
 @UserLoginID=100,
 @MethodName ='SaveUniverseDetail',
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
SELECT * FROM dbo.Universe
SELECT * FROM dbo.UniverseProperties
SELECT * FROM dbo.UniversePropertiesXref
SELECT * FROM UniversePropertyXerf_Data

SELECT * FROM dbo.Universe_history
SELECT * FROM dbo.UniverseProperties_history
SELECT * FROM dbo.UniversePropertiesXref_history
SELECT * FROM UniversePropertyXerf_Data_history

SELECT * FROM UniversePropertyXerf_Data
SELECT * FROM UniversePropertyXerf_Data_history

TRUNCATE TABLE UniversePropertyXerf_Data_history
TRUNCATE TABLE UniversePropertyXerf_Data

*/