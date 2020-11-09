
SELECT * FROM TAB_Framework_Metafield_Attributes_history
SELECT * FROM TAB_Framework_Metafield_history
SELECT * FROM TAB_Framework_Metafield_Steps_history

SELECT DISTINCT Curr.HistoryID,Curr.AttributeKey,Curr.AttributeValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Attributes_history Curr
	 INNER JOIN TAB_Framework_Metafield_Attributes_history Prev ON Prev.AttributeKey = Curr.AttributeKey
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID
	 INNER JOIN TAB_Framework_Metafield_history Prev_Met ON Prev_Met.MetaFieldID = Prev.MetaFieldID
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID
	 INNER JOIN TAB_Framework_Metafield_Steps_history Prev_Steps ON Prev_Steps.StepID = Prev_Met.StepID
WHERE Curr_Met.StepItemKey = Prev_Met.StepItemKey
      AND Curr_Steps.StepName = Prev_Steps.StepName
	  AND Curr.AttributeKey = 'tableView'	  
	  AND Curr.VersionNum =2
	  AND Prev.VersionNum =1

--FOR ATTRIBUTES====================================================================================================================
DROP TABLE IF EXISTS #TMP_Attributes
DROP TABLE IF EXISTS #TMP_AttributesChanges

SELECT *
	INTO #TMP_Attributes
FROM
(
SELECT DISTINCT Curr.HistoryID, Curr.AttributeKey,Curr.AttributeValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Attributes_history Curr	
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
WHERE Curr.VersionNum = 2
	  --AND Curr.AttributeKey = 'tableView'
       
UNION

 SELECT DISTINCT Curr.HistoryID,Curr.AttributeKey,Curr.AttributeValue,Curr.VersionNum
FROM TAB_Framework_Metafield_Attributes_history Curr	
	 INNER JOIN TAB_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
	 INNER JOIN TAB_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
WHERE Curr.VersionNum = 3
	 -- AND Curr.AttributeKey = 'tableView'

)TAB

	SELECT * FROM #TMP_Attributes

SELECT AttributeKey,
	   MAX(CASE WHEN VersionNum =2 THEN AttributeValue END) AS OldValue,
	   MAX(CASE WHEN VersionNum =3 THEN AttributeValue END) AS NewValue,
	   CAST(NULL AS VARCHAR(50)) AS OperationType
	INTO #TMP_AttributesChanges 
FROM #TMP_Attributes
GROUP BY AttributeKey

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

--====================================================================================================================	 

---FOR LOOKUPS====================================================================================================================
DROP TABLE IF EXISTS #TMP_Lookups
DROP TABLE IF EXISTS #TMP_LookupChanges

SELECT *
	INTO #TMP_Lookups
FROM
(
SELECT DISTINCT Curr.HistoryID,Curr.LookupName,Curr.LookupValue,Curr.VersionNum
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

SELECT LookupName,
	   MAX(CASE WHEN VersionNum =1 THEN LookupValue END) AS OldValue,
	   MAX(CASE WHEN VersionNum =2 THEN LookupValue END) AS NewValue,
	   CAST(NULL AS VARCHAR(50)) AS OperationType
	INTO #TMP_LookupChanges
FROM #TMP_Lookups
GROUP BY LookupName
--====================================================================================================================
