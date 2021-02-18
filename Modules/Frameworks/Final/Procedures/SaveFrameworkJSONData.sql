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
@VersionNum INT = 1,
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @TableName VARCHAR(500) = (SELECT CONCAT(Name,'_DATA') FROM dbo.Frameworks WHERE FrameworkID = @EntityID)

	IF @TableName IS NULL
		RETURN
		
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

	 	SET @ColumnNames = STUFF
								((SELECT CONCAT(', ',ColumnName)
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

		SET @ColumnValues = CONCAT(CHAR(39),@EntityID,CHAR(39),',',@ColumnValues)

	BEGIN TRAN
		
		SET @SQL = CONCAT('INSERT INTO dbo.',@TableName,'(',@ColumnNames,') VALUES(',@ColumnValues,')')
		PRINT @SQL
		
		EXEC sp_executesql @SQL	
		
		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
			SET @Params = CONCAT('@FrameworkID=', CHAR(39),@EntityID, CHAR(39),',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
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
			SET @Params = CONCAT('@FrameworkID=', CHAR(39),@EntityID, CHAR(39),',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
			
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