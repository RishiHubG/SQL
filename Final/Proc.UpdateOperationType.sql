--ASSUMPTION: SCRIPT WILL RUN ONLY IF VERSIONNUM > 1
USE JUNK
GO

CREATE OR ALTER PROCEDURE dbo.UpdateHistoryOperationType
@TableInitial VARCHAR(100),
@VersionNum INT
AS
BEGIN

	IF @VersionNum > 1
	BEGIN
	
	DROP TABLE IF EXISTS #TMP_OperationType
	CREATE TABLE #TMP_OperationType(HistoryTableName VARCHAR(100),KeyColName VARCHAR(100),ModuleName VARCHAR(50),KeyName VARCHAR(100),OldValue VARCHAR(MAX),NewValue VARCHAR(MAX),OperationType VARCHAR(50))

	DECLARE @ID INT,@TemplateTableName VARCHAR(100),@TableType VARCHAR(100),@KeyColName VARCHAR(100)
	DECLARE @PrevVersionNum INT = @VersionNum - 1, @Query VARCHAR(MAX), @HistTableSuffix VARCHAR(50)='_history'

	SET @TableInitial = CONCAT('dbo.',@TableInitial)

WHILE EXISTS(SELECT 1 FROM #TBL_OperationTypeList)
BEGIN
		
		SELECT @ID = MIN(ID) FROM #TBL_OperationTypeList

		SELECT @TemplateTableName = TemplateTableName,
			   @KeyColName = KeyColName,
			   @TableType = TableType
		FROM #TBL_OperationTypeList 
		WHERE ID = @ID		 

		DROP TABLE IF EXISTS #TMP_Items
		CREATE TABLE #TMP_Items(KeyName VARCHAR(100),KeyValue VARCHAR(1000),VersionNum INT)
		
		IF @TableType = 'StepItems'		
			SET @Query = CONCAT('SELECT KeyName,KeyValue,VersionNum			
									FROM
									(
									SELECT DISTINCT Curr.StepItemKey AS KeyName,Curr.StepItemName AS KeyValue,Curr.VersionNum
									FROM ',@TableInitial,'_Framework_Metafield_history Curr
										 INNER JOIN ',@TableInitial,'_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr.StepID 
									WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,')		
									)TAB'
								)		
		ELSE IF @TableType = 'Attributes'
			SET @Query = CONCAT('	SELECT KeyName,KeyValue,VersionNum			
									FROM
									(
									SELECT DISTINCT Curr.AttributeKey AS KeyName,Curr.AttributeValue AS KeyValue,Curr.VersionNum
									FROM ',@TableInitial,'_Framework_Metafield_Attributes_history Curr	
										 INNER JOIN ',@TableInitial,'_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
										 INNER JOIN ',@TableInitial,'_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID 
									WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,') 
									)TAB' 
								)
			ELSE IF @TableType = 'Lookups'
			SET @Query = CONCAT('SELECT KeyName,KeyValue,VersionNum			
									FROM
									(
									SELECT DISTINCT Curr.LookupValue AS KeyName,Curr.LookupName AS KeyValue,Curr.VersionNum
									FROM ',@TableInitial,'_Framework_Metafield_Lookups_history Curr	
										 INNER JOIN ',@TableInitial,'_Framework_Metafield_history Curr_Met ON Curr_Met.MetaFieldID = Curr.MetaFieldID	
										 INNER JOIN ',@TableInitial,'_Framework_Metafield_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
									WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,') 
									)TAB' 
							  )
			
			PRINT @Query

			INSERT INTO #TMP_Items(KeyName,KeyValue,VersionNum)	
				EXEC (@Query)

		INSERT INTO #TMP_OperationType(HistoryTableName,KeyColName,ModuleName,KeyName,OldValue,NewValue,OperationType)
			SELECT CONCAT(@TableInitial,'_',@TemplateTableName,@HistTableSuffix),
				   @KeyColName,
				   @TableType AS ModuleName,
				   KeyName,
				   MAX(CASE WHEN VersionNum = @PrevVersionNum THEN KeyValue END) AS OldValue,
				   MAX(CASE WHEN VersionNum = @VersionNum THEN KeyValue END) AS NewValue,
				   CAST(NULL AS VARCHAR(50)) AS OperationType
			FROM #TMP_Items
			GROUP BY KeyName

			
		UPDATE #TMP_OperationType
			SET OperationType = 'UPDATE'
		WHERE ModuleName = @TableType
			  AND OldValue <> NewValue
			  AND OldValue IS NOT NULL

		UPDATE #TMP_OperationType
			SET OperationType = 'DELETE'
		WHERE ModuleName = @TableType
			  AND NewValue IS NULL
			  AND OldValue IS NOT NULL

		UPDATE #TMP_OperationType
			SET OperationType = 'INSERT'
		WHERE ModuleName = @TableType
			  AND NewValue IS NOT NULL
			  AND OldValue IS NULL
		
		DELETE FROM #TBL_OperationTypeList WHERE ID = @ID				
		SET @Query = NULL

	END		--END OF -> WHILE LOOP

	SELECT * FROM #TMP_OperationType

	--UPDATE THE OPERATION TYPE FLAG IN HISTORY TABLE
	SET @Query = STUFF(
						(SELECT CONCAT('; ', 'UPDATE ',HistoryTableName,' SET OperationType=''',OperationType, ''' WHERE VersionNum=',@VersionNum,' AND ',KeyColName,'=''',KeyName,''';', CHAR(10))
						FROM #TMP_OperationType
						WHERE OperationType IS NOT NULL 
						FOR XML PATH('')
						),1,1,'')
	
	PRINT @Query
	IF @Query IS NOT NULL
		EXEC (@Query)

	END	--IF @VersionNum > 1

END
 