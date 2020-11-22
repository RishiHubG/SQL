--ASSUMPTION: SCRIPT WILL RUN ONLY IF VERSIONNUM > 1
USE JUNK
GO
	
	DROP TABLE IF EXISTS #TMP_OperationType
	CREATE TABLE #TMP_OperationType(ModuleName VARCHAR(50),KeyName VARCHAR(100),OldValue VARCHAR(MAX),NewValue VARCHAR(MAX),OperationType VARCHAR(50))


--FOR METAFIELD/STEPITEMS====================================================================================================================
DROP TABLE IF EXISTS #TMP_StepItems
DROP TABLE IF EXISTS #TMP_StepItemsChanges

SELECT *
	INTO #TMP_StepItems
FROM
(
SELECT DISTINCT Curr.HistoryID, Curr.StepItemKey AS KeyName,Curr.StepItemName AS KeyValue,Curr.VersionNum
FROM TAB_Framework_Metafield_history Curr
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr.StepID 
WHERE Curr.VersionNum = 1
	  --AND Curr.AttributeKey = 'tableView'
       
UNION

 SELECT DISTINCT Curr.HistoryID,Curr.StepItemKey,Curr.StepItemName,Curr.VersionNum
FROM TAB_Framework_Metafield_history Curr
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr.StepID	 
WHERE Curr.VersionNum = 2
	 -- AND Curr.AttributeKey = 'tableView'

)TAB

	--SELECT * FROM #TMP_StepItems

INSERT INTO #TMP_OperationType(ModuleName,KeyName,OldValue,NewValue,OperationType)
	SELECT 'StepItems' AS ModuleName,
		   KeyName,
		   MAX(CASE WHEN VersionNum =1 THEN KeyValue END) AS OldValue,
		   MAX(CASE WHEN VersionNum =2 THEN KeyValue END) AS NewValue,
		   CAST(NULL AS VARCHAR(50)) AS OperationType
	FROM #TMP_StepItems
	GROUP BY KeyName

UPDATE #TMP_OperationType
	SET OperationType = 'UPDATE'
WHERE ModuleName ='StepItems'
	  AND OldValue <> NewValue
	  AND OldValue IS NOT NULL

UPDATE #TMP_OperationType
	SET OperationType = 'DELETE'
WHERE ModuleName ='StepItems'
	  AND NewValue IS NULL
	  AND OldValue IS NOT NULL

UPDATE #TMP_OperationType
	SET OperationType = 'INSERT'
WHERE ModuleName ='StepItems'
	  AND NewValue IS NOT NULL
	  AND OldValue IS NULL

	  --SELECT * FROM #TMP_OperationType
--===============================================================================================================================


--FOR ATTRIBUTES====================================================================================================================
DROP TABLE IF EXISTS #TMP_Attributes
DROP TABLE IF EXISTS #TMP_AttributesChanges

SELECT *
	INTO #TMP_Attributes
FROM
(
SELECT DISTINCT Curr.HistoryID, Curr.AttributeKey AS KeyName,Curr.AttributeValue AS KeyValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Attributes_history Curr	
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID 
WHERE Curr.VersionNum = 1
	  --AND Curr.AttributeKey = 'tableView'
       
UNION

 SELECT DISTINCT Curr.HistoryID,Curr.AttributeKey,Curr.AttributeValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Attributes_history Curr	
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
WHERE Curr.VersionNum = 2
	 -- AND Curr.AttributeKey = 'tableView'

)TAB


INSERT INTO #TMP_OperationType(ModuleName,KeyName,OldValue,NewValue,OperationType)
	SELECT 'Attributes' AS ModuleName,
		   KeyName,
		   MAX(CASE WHEN VersionNum =1 THEN KeyValue END) AS OldValue,
		   MAX(CASE WHEN VersionNum =2 THEN KeyValue END) AS NewValue,
		   CAST(NULL AS VARCHAR(50)) AS OperationType		
	FROM #TMP_Attributes
	GROUP BY KeyName

UPDATE #TMP_OperationType
	SET OperationType = 'UPDATE'
WHERE ModuleName ='Attributes'
	  AND OldValue <> NewValue
	  AND OldValue IS NOT NULL

UPDATE #TMP_OperationType
	SET OperationType = 'DELETE'
WHERE ModuleName ='Attributes'
	  AND NewValue IS NULL
	  AND OldValue IS NOT NULL

UPDATE #TMP_OperationType
	SET OperationType = 'INSERT'
WHERE ModuleName ='Attributes'
	  AND NewValue IS NOT NULL
	  AND OldValue IS NULL

--===============================================================================================================================

---FOR LOOKUPS====================================================================================================================
DROP TABLE IF EXISTS #TMP_Lookups
DROP TABLE IF EXISTS #TMP_LookupChanges

SELECT *
	INTO #TMP_Lookups
FROM
(
SELECT DISTINCT Curr.HistoryID,Curr.LookupValue AS KeyName,Curr.LookupName AS KeyValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Lookups_history Curr	
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
WHERE Curr.VersionNum = 1
	  --AND Curr.AttributeKey = 'tableView'
       
UNION

 SELECT DISTINCT Curr.HistoryID,Curr.LookupName,Curr.LookupValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Lookups_history Curr	
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
WHERE Curr.VersionNum = 2
	 -- AND Curr.AttributeKey = 'tableView'

)TAB

	  --SELECT * FROM #TMP_Lookups

INSERT INTO #TMP_OperationType(ModuleName,KeyName,OldValue,NewValue,OperationType)
	SELECT 'Lookups' AS ModuleName,
			KeyName,
		   MAX(CASE WHEN VersionNum =1 THEN KeyValue END) AS OldValue,
		   MAX(CASE WHEN VersionNum =2 THEN KeyValue END) AS NewValue,
		   CAST(NULL AS VARCHAR(50)) AS OperationType
	FROM #TMP_Lookups
	GROUP BY KeyName
	
UPDATE #TMP_OperationType
	SET OperationType = 'UPDATE'
WHERE ModuleName ='Lookups'
	  AND OldValue <> NewValue
	  AND OldValue IS NOT NULL

UPDATE #TMP_OperationType
	SET OperationType = 'DELETE'
WHERE ModuleName ='Lookups'
	  AND NewValue IS NULL
	  AND OldValue IS NOT NULL

UPDATE #TMP_OperationType
	SET OperationType = 'INSERT'
WHERE ModuleName ='Lookups'
	  AND NewValue IS NOT NULL
	  AND OldValue IS NULL
--==================================================================================================================================

SELECT * FROM #TMP_OperationType