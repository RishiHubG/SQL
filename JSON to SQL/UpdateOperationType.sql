USE JUNK
GO


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

	SELECT * FROM #TMP_StepItems

SELECT KeyName,
	   MAX(CASE WHEN VersionNum =1 THEN KeyValue END) AS OldValue,
	   MAX(CASE WHEN VersionNum =2 THEN KeyValue END) AS NewValue,
	   CAST(NULL AS VARCHAR(50)) AS OperationType
	INTO #TMP_StepItemsChanges 
FROM #TMP_StepItems
GROUP BY KeyName

SELECT * FROM #TMP_StepItemsChanges

UPDATE #TMP_StepItemsChanges
	SET OperationType = 'UPDATE'
WHERE OldValue <> NewValue
	  AND OldValue IS NOT NULL

UPDATE #TMP_StepItemsChanges
	SET OperationType = 'DELETE'
WHERE NewValue IS NULL
	  AND OldValue IS NOT NULL

UPDATE #TMP_StepItemsChanges
	SET OperationType = 'INSERT'
WHERE NewValue IS NOT NULL
	  AND OldValue IS NULL

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

	SELECT * FROM #TMP_Attributes

SELECT KeyName,
	   MAX(CASE WHEN VersionNum =1 THEN KeyValue END) AS OldValue,
	   MAX(CASE WHEN VersionNum =2 THEN KeyValue END) AS NewValue,
	   CAST(NULL AS VARCHAR(50)) AS OperationType
	INTO #TMP_AttributesChanges 
FROM #TMP_Attributes
GROUP BY KeyName

SELECT * FROM #TMP_AttributesChanges

UPDATE #TMP_AttributesChanges
	SET OperationType = 'UPDATE'
WHERE OldValue <> NewValue
	  AND OldValue IS NOT NULL

UPDATE #TMP_AttributesChanges
	SET OperationType = 'DELETE'
WHERE NewValue IS NULL
	  AND OldValue IS NOT NULL

UPDATE #TMP_AttributesChanges
	SET OperationType = 'INSERT'
WHERE NewValue IS NOT NULL
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

	  SELECT * FROM #TMP_Lookups

SELECT KeyName,
	   MAX(CASE WHEN VersionNum =1 THEN KeyValue END) AS OldValue,
	   MAX(CASE WHEN VersionNum =2 THEN KeyValue END) AS NewValue,
	   CAST(NULL AS VARCHAR(50)) AS OperationType
	INTO #TMP_LookupChanges
FROM #TMP_Lookups
GROUP BY KeyName
--==================================================================================================================================