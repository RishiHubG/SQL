USE junk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveFrameworkJSONData
CREATION DATE:      2021-02-13
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveFrameworkJSONData   @UserLoginID=100,
													 @inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.SaveFrameworkJSONData
@InputJSON VARCHAR(MAX),
@UserLoginID INT,
@EntityID INT,
@EntityTypeID INT=NULL,
@ParentEntityID INT=NULL,
@ParentEntityTypeID INT=NULL, 
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @FrameworkID INT,
			@PeriodIdentifierID INT = 1,
			@OperationType VARCHAR(50),
			@VersionNum INT

	DECLARE @TableName VARCHAR(500) = 'TAB_DATA' --(SELECT CONCAT(Name,'_DATA') FROM dbo.Frameworks WHERE FrameworkID = @EntityID)

	IF @TableName IS NULL
		RETURN
	
	IF @EntityID = -1
	BEGIN
		SELECT @FrameworkID = 1, @OperationType ='INSERT', @VersionNum = 1
	END
	ELSE
	BEGIN
		SELECT @FrameworkID = @EntityID,
			   @VersionNum = MAX(VersionNum) + 1
		FROM dbo.TAB_Data
		WHERE FrameworkID = @EntityID
	
		SET @OperationType ='UPDATE'
	END
		
	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 

		;WITH CTE
		AS
		(
		SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.OBJECT_ID AS ObjectID,
			   TAB.pos,
			   T.StringValue,	
			   CAST(NULL AS VARCHAR(500)) AS KeyName,			   
				ROW_NUMBER()OVER(PARTITION BY T.Element_ID,T.Name ORDER BY TAB.pos DESC) AS RowNum
		 FROM #TMP_ALLSTEPS T
			  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB	 
		 WHERE Parent_ID = 0
		)
		
		SELECT *
			INTO #TMP_DATA_KEYNAME
		FROM CTE
		WHERE RowNum = 1

		UPDATE #TMP_DATA_KEYNAME
			SET KeyName = SUBSTRING(Name,Pos+1,len(Name))
		WHERE Pos > 0

		--UPDATE T
		--	SET StringValue = TA.StringValue
		--FROM #TMP_DATA_KEYNAME T
		--	 INNER JOIN #TMP_ALLSTEPS TA ON T.Element_ID = TA.Element_ID
		--WHERE TA.Pos > 0

		--SELECT * FROM #TMP_DATA_KEYNAME
		--RETURN
		--SELECT * FROM #TMP_ALLSTEPS

		 --GET THE SELECTBOXES (THESE WILL HAVE A PARENT OF TYPE "Object")
		 -------------------------------------------------------------------------------------------------------
		DECLARE @TBL TABLE(Name VARCHAR(100))
		INSERT INTO @TBL (Name) VALUES ('Name')--,('Value'),('Description'),('Color')

		 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType,TAB.MultiKeyName 
			INTO #TMP_Objects
		 FROM #TMP_ALLSTEPS
			  CROSS APPLY (SELECT NAME FROM @TBL) TAB(MultiKeyName)
		 WHERE ValueType='Object'
			   AND Parent_ID = 0 --ONLY ROOT ELEMENTS			   
			   AND Name NOT IN ('userCreated','dateCreated','userModified','dateModified','submit')
			  
			
		SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos,CAST(NULL AS VARCHAR(100)) AS KeyName	    
			INTO #TMP_DATA_MultiKeyName
		 FROM #TMP_Objects T
			  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB			  
		GROUP BY T.Element_ID,T.Name		

		UPDATE TD
			SET KeyName = SUBSTRING(TD.Name,Pos+1,len(TD.Name))
		FROM #TMP_DATA_MultiKeyName TD 
			 INNER JOIN #TMP_Objects T ON T.Element_ID = TD.Element_ID
		WHERE Pos > 0	

			SELECT DISTINCT TDM.Element_ID,
				   CONCAT(TDM.KeyName,'_',TAB.MultiKeyName) AS ColumnName,
				   STUFF(
							(SELECT CONCAT(', ',TA.[Name])
							FROM #TMP_ALLSTEPS TA
							WHERE TA.Parent_ID =TDM.Element_ID
								  AND TA.StringValue = 'True'
							FOR XML PATH(''))	
						,1,1,''	
						)  AS StringValue
				INTO #TMP_MULTI
			FROM #TMP_DATA_MultiKeyName TDM
				 INNER JOIN #TMP_Objects TAB ON TAB.Element_ID =TDM.Element_ID
				 INNER JOIN #TMP_ALLSTEPS TAS ON TAS.Parent_ID =TDM.Element_ID
			WHERE TAS.StringValue = 'True'
				
		--SELECT * FROM #TMP_DATA_MultiKeyName
		--SELECT * FROM #TMP_Objects
		 -------------------------------------------------------------------------------------------------------
		
		 --BUILD THE COLUMN LIST
		 -------------------------------------------------------------------------------------------------------

		 --FOR SELECTBOXES
		SELECT Element_ID,
		        ColumnName,
			    StringValue			 
			INTO #TMP_INSERT
		FROM #TMP_MULTI

		UNION
				
		SELECT Element_ID,
			   KeyName,
			   StringValue
		FROM #TMP_DATA_KEYNAME
		WHERE Parent_ID = 0
			  AND OBJECTID IS NULL
			  AND StringValue <> ''
		 
		--INSERT ANY OTHER AD-HOC/FIXED COLUMNS
		INSERT INTO #TMP_INSERT(ColumnName,StringValue)
			SELECT 'VersionNum',@VersionNum
			UNION
			SELECT 'UserCreated',@UserLoginID

 	 	DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX)

		IF @EntityID = -1
		BEGIN
	 		SET @ColumnNames = STUFF
									((SELECT CONCAT(', ',QUOTENAME(ColumnName))
									FROM #TMP_INSERT 								
									ORDER BY Element_ID
									FOR XML PATH ('')								
									),1,1,'')
		
			SET @ColumnNames = CONCAT('FrameworkID',',',@ColumnNames)

			SET @ColumnValues = STUFF
									((SELECT CONCAT(', ',CHAR(39),StringValue,CHAR(39))
									FROM #TMP_INSERT 								
									ORDER BY Element_ID
									FOR XML PATH ('')								
									),1,1,'')

			SET @ColumnValues = CONCAT(CHAR(39),@FrameworkID,CHAR(39),',',@ColumnValues)
		END
		ELSE
		BEGIN
			DECLARE @UpdStr VARCHAR(MAX)

			SET  @UpdStr = STUFF(
								(
								SELECT CONCAT(', ',QUOTENAME(COLUMNNAME),'=',CHAR(39),StringValue,CHAR(39), CHAR(10))
								FROM #TMP_INSERT
								FOR XML PATH('')
								),
								1,1,'')
				
		END

	BEGIN TRAN
		
		IF @EntityID = -1
		BEGIN
			SET @SQL = CONCAT('INSERT INTO dbo.',@TableName,'(',@ColumnNames,') VALUES(',@ColumnValues,')')
			PRINT @SQL		 
		END
		ELSE	--UPDATE
		BEGIN
			SET @SQL = CONCAT('UPDATE dbo.',@TableName,CHAR(10),' SET ',@UpdStr)
			SET @SQL = CONCAT(@SQL, ' WHERE FrameworkID=', @FrameworkID)
			PRINT @SQL
		END		
		
		EXEC sp_executesql @SQL	
		
		--UPDATE _HISTORY TABLE-----------------------------------------
		
		DECLARE @HistoryID INT 
		
		SET @SQL = CONCAT(N'SELECT @HistoryID = MAX(HistoryID) FROM dbo.',@TableName,'_history WHERE FrameworkID = ',@FrameworkID)
		EXEC sp_executesql @SQL,N'@HistoryID INT OUTPUT',@HistoryID OUTPUT

		--UPDATE VERSION NO.
		SET @SQL = CONCAT(N'UPDATE dbo.', @TableName,'_history
			SET VersionNum = ',@VersionNum,'
		WHERE HistoryID = ',@HistoryID,';', CHAR(10), CHAR(10))			 

		--RESET PERIODIDENTIFIER FOR EARLIER VERSIONS
		SET @SQL = CONCAT(@SQL, 'UPDATE dbo.', @TableName,'_history
			SET PeriodIdentifier = 0,
				UserModified = ',@UserLoginID,',
				DateModified = GETUTCDATE()
		WHERE FrameworkID = ',@FrameworkID,'
			  AND VersionNum < ',@VersionNum,';', CHAR(10), CHAR(10))
		
		--UPDATE OTHER COLUMNS FOR CURRENT VERSION
		SET @SQL = CONCAT(@SQL,' UPDATE dbo.', @TableName,'_history
			SET PeriodIdentifier = ',@PeriodIdentifierID,',
				UserModified = ',@UserLoginID,',
				DateModified = GETUTCDATE(),
				OperationType = ''',@OperationType,'''
		WHERE FrameworkID = ',@FrameworkID,'
			  AND VersionNum = ',@VersionNum,';', CHAR(10), CHAR(10))
		
		EXEC LongPrint @SQL
		EXEC sp_executesql @SQL
		-----------------------------------------------------------------

		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				SET @Params = CONCAT('@EntityID=',@EntityID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,'@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@LogRequest=',@LogRequest)

			--PRINT @PARAMS
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		COMMIT

		SELECT NULL AS ErrorMessage

END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				SET @Params = CONCAT('@EntityID=',@EntityID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,'@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH

		--DROP TEMP TABLES--------------------------------------	
		 DROP TABLE IF EXISTS #TMP_INSERT
		 DROP TABLE IF EXISTS #TMP_DATA_KEYNAME
		 DROP TABLE IF EXISTS  #TMP_INSERT
		 DROP TABLE IF EXISTS #TMP_DATA_MultiKeyName
		 DROP TABLE IF EXISTS #TMP_MULTI
		 --------------------------------------------------------
END