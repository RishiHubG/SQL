
exec SaveCustomViewJSONData 
@inputJSON=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}',
@MethodName=NULL,@UserLoginID=3840

select * from Filterconditions_Master WHERE criteria NOT like '%equals%'

ALTER TABLE Filterconditions_Master ADD OperatorType VARCHAR(50)

SELECT * FROM Filterconditions_Master
SELECT * FROM Filterconditions_Master WHERE FiltertypeId =88

UPDATE Filterconditions_Master SET OperatorType ='=' WHERE Criteria='Equals'
UPDATE Filterconditions_Master SET OperatorType ='<>' WHERE Criteria='Not Equals'
UPDATE Filterconditions_Master SET OperatorType ='LIKE ''%<COLVALUE>%''' WHERE Criteria='contains'
UPDATE Filterconditions_Master SET OperatorType ='NOT LIKE ''%<COLVALUE>%''' WHERE Criteria='Does Not Contains'
UPDATE Filterconditions_Master SET OperatorType ='LIKE ''%<COLVALUE>''' WHERE Criteria='Starts With'
UPDATE Filterconditions_Master SET OperatorType ='NOT LIKE ''%<COLVALUE>''' WHERE Criteria='Does Not Start With'
UPDATE Filterconditions_Master SET OperatorType ='LIKE ''<COLVALUE>%''' WHERE Criteria='Ends With'
UPDATE Filterconditions_Master SET OperatorType ='NOT LIKE ''<COLVALUE>%''' WHERE Criteria='Does Not End With'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') = ''''' WHERE Criteria='Is Empty'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') <> '''' ' WHERE Criteria='Is Not Empty'
UPDATE Filterconditions_Master SET OperatorType ='<' WHERE Criteria='Less Than'
UPDATE Filterconditions_Master SET OperatorType ='<=' WHERE Criteria='Less Than Or Equal to'
UPDATE Filterconditions_Master SET OperatorType ='>' WHERE Criteria='Greater Than'
UPDATE Filterconditions_Master SET OperatorType ='>=' WHERE Criteria='Greater Than or Equal to'
UPDATE Filterconditions_Master SET OperatorType ='Between' WHERE Criteria='Between'
UPDATE Filterconditions_Master SET OperatorType ='Not Between' WHERE Criteria='Not Between'
UPDATE Filterconditions_Master SET OperatorType ='=1' WHERE Criteria='True'
UPDATE Filterconditions_Master SET OperatorType ='=0' WHERE Criteria='False'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') = ''''' WHERE Criteria='Empty'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') <> '''' ' WHERE Criteria='Not Empty'
--UPDATE Filterconditions_Master SET OperatorType ='Equal to Field' WHERE Criteria='ISNULL(<COLNAME>,'''') <> '''' '