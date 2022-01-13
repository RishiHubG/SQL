USE AGSQA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveSpecialInputJSON
CREATION DATE:      2022-01-13
AUTHOR:             Rishi Nayar
DESCRIPTION:		
					
USAGE:
CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.SaveSpecialInputJSON
@SpecialInputJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL, 
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	SET @UserID = 100
	IF @UserID IS NOT NULL
	BEGIN

	 
	 DECLARE @Params VARCHAR(MAX),
			 @ObjectName VARCHAR(100),
			 @UTCDATE DATETIME2(3) = GETUTCDATE(),
 	     	 @ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX),
			 @TableName SYSNAME,
			 @TableInstanceID INT,
			 @SQL NVARCHAR(MAX),
			 @VersionNum INT,
			 @OperationType VARCHAR(50) = 'INSERT'

	 DECLARE @SQL_ID VARCHAR(MAX)='ID INT'
	 DECLARE @SQL_HistoryID VARCHAR(MAX)='HistoryID INT IDENTITY(1,1)'
	 DECLARE @StaticColValues VARCHAR(MAX)
	 DECLARE @StaticCols VARCHAR(MAX) =	 
	 'UserCreated, 
	 DateCreated, 
	 UserModified,
	 DateModified,
	 VersionNum,	 
	 TableInstanceID'

	 
	DROP TABLE IF EXISTS #TMP_ALLSTEPS 

	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@SpecialInputJSON)
 	   	
 --SELECT * FROM #TMP_ALLSTEPS
 --RETURN

	--;WITH CTE_TemplateData
	--AS
	--(		
	--	SELECT T.Element_ID,
	--		   T.Name AS ColumnName, 
	--		   T.Parent_ID,	   
	--		   T.StringValue,
	--		   T.ValueType
	--	 FROM #TMP_ALLSTEPS T			  
	--	 WHERE Name IN ('Templates')

	--	 UNION ALL

	--	 SELECT T.Element_ID,
	--		   T.Name, 
	--		   T.Parent_ID,			   
	--		   T.StringValue,
	--		   T.ValueType
	--	 FROM CTE_TemplateData C
	--		  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
		
	--)

	--SELECT * 
	--	INTO #TMP_INSERT
	--FROM CTE_TemplateData WHERE ValueType ='string' --ColumnName IS NOT NULL AND ColumnName <> 'audit'
	
	--SELECT * FROM #TMP_INSERT	

	DECLARE @ENTITYID INT
	DECLARE @Count INT = (SELECT COUNT(*) FROM #TMP_ALLSTEPS WHERE [Name] ='apikey')
	DECLARE @iCounter INT = 1

	CREATE TABLE #TMP_AllCols(Parent_ID INT,ColumnName VARCHAR(500));
	CREATE TABLE #TMP_AllColValues(Parent_ID INT,StringValue VARCHAR(MAX));
	CREATE TABLE #TMP_INSERT(Element_ID INT,ColumnName VARCHAR(500),Parent_ID INT,StringValue VARCHAR(500),ValueType VARCHAR(200));
	CREATE TABLE #TMP_AllDataCols(Element_ID INT,ColumnName VARCHAR(500),Parent_ID INT,StringValue VARCHAR(500),ValueType VARCHAR(200));
	CREATE TABLE #TMP_InsertString (InsertString VARCHAR(MAX))

	WHILE @iCounter <= @Count
	BEGIN
		PRINT @iCounter
		DECLARE @ApiKey_Parent_ID INT, @ApiKey NVARCHAR(500)
		DECLARE @DataType VARCHAR(50), @TemplateKey VARCHAR(500)
		
		SELECT @ApiKey_Parent_ID = MIN(Parent_ID) 
		FROM #TMP_ALLSTEPS 
		WHERE [Name] ='apikey'
	 
		;WITH CTE_Data
		AS
		(		
			SELECT T.Element_ID,
				   T.Name AS ColumnName, 
				   T.Parent_ID,	   
				   T.StringValue,
				   T.ValueType
			 FROM #TMP_ALLSTEPS T			  
			 WHERE Parent_ID = @ApiKey_Parent_ID

			 UNION ALL

			 SELECT T.Element_ID,
				   T.Name, 
				   T.Parent_ID,			   
				   T.StringValue,
				   T.ValueType
			 FROM CTE_Data C
				  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
		
		)

		INSERT INTO #TMP_INSERT
		SELECT * 		  
	   FROM CTE_Data --WHERE ValueType NOT IN ('object','array')
	   
	   INSERT INTO #TMP_AllDataCols
	   SELECT * 
	   FROM #TMP_INSERT
	   	   
	  SELECT @DataType = StringValue 
	  FROM #TMP_AllDataCols
	  WHERE ColumnName = 'datatype'
	 
	  SELECT @TemplateKey = StringValue 
	  FROM #TMP_AllDataCols
	  WHERE ColumnName = 'TemplateKey'

	  SELECT @ApiKey =  StringValue
	  FROM #TMP_AllDataCols
	  WHERE ColumnName = 'apiKey'

	  --SELECT @DataType,@TemplateKey,@ApiKey

	  IF @DataType = 'TableTemplate'
		SET @TableName = CONCAT('[TemplateTable_', @TemplateKey,'_data]')
	  ELSE IF @DataType = 'Table'
	  	SET @TableName = CONCAT('[Table_', @TemplateKey,'_data]')
		
		 IF @TableName IS NULL
			PRINT CONCAT(@TableName, ' NOT FOUND!');

	   --REMOVE COLUMNS IN JSON NOT PART OF THAT ARE NOT SUPPOSED TO BE TABLE COLUMNS
	   DELETE FROM #TMP_INSERT
	   WHERE ValueType IN ('object','array') OR  ColumnName IN (						
						'data',
						'dataType',
						'container',
						'submit',
						'dataGrid',
						'TemplateKey'
						)

	   
		--GET VERSION NO.--------------------------------------------------------
			SET @SQL = CONCAT('SELECT @VersionNum = MAX(VersionNum) + 1 FROM ',@TableName)		
			EXEC sp_executesql @SQL,N'@VersionNum INT OUTPUT',@VersionNum OUTPUT

			IF @VersionNum IS NULL	
				SET @VersionNum = 1
		---------------------------------------------------------------------------	
		--GET OPERATION TYPE--------------------------------------------------------
			--SET @SQL = CONCAT('SELECT @OperationType = ''1'' FROM ',@TableName, ' WHERE TableInstanceID = ',@EntityID)		
			--EXEC sp_executesql @SQL,N'@OperationType VARCHAR(50) OUTPUT',@OperationType OUTPUT

			--IF @OperationType = '1'
			--	SET @OperationType = 'UPDATE'
		-----------------------------------------------------------------------------	
	
	INSERT INTO #TMP_AllCols(Parent_ID,ColumnName)
		SELECT Parent_ID, STRING_AGG(ColumnName,',') AS ColumnName
		FROM #TMP_INSERT
		WHERE ColumnName <> 'apikey'
		GROUP BY Parent_ID
	
	INSERT INTO #TMP_AllColValues(Parent_ID,StringValue)
		SELECT Parent_ID, STRING_AGG(CONCAT(CHAR(39),StringValue,CHAR(39)),',') AS StringValue			 
		FROM #TMP_INSERT T
		WHERE EXISTS (SELECT 1 FROM #TMP_AllCols WHERE Parent_ID = T.Parent_ID)
		GROUP BY Parent_ID
	  
		UPDATE #TMP_AllCols SET ColumnName = CONCAT(ColumnName,',apiKey')
		UPDATE #TMP_AllColValues SET StringValue = CONCAT(StringValue,',',CHAR(39),@ApiKey,CHAR(39))

		--SELECT * FROM #TMP_AllCols
		--SELECT * FROM #TMP_AllColValues
		--RETURN

		 --SET @StaticColValues = CONCAT(@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@VersionNum,',',@EntityID)
		 SET @StaticColValues = CONCAT(@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@VersionNum,',NULL')
		 PRINT @StaticColValues
	
		  IF @OperationType = 'INSERT'
		  BEGIN
				INSERT INTO #TMP_InsertString (InsertString)
				 SELECT CONCAT('INSERT INTO dbo.<TABLENAME>(',@StaticCols,',',A1.ColumnName,') VALUES (',@StaticColValues,',',A2.StringValue,')') AS InsertString					
				 FROM #TMP_AllCols A1
					  INNER JOIN #TMP_AllColValues A2 ON A1.Parent_ID = A2.Parent_ID
					   
				SET @SQL = (SELECT STRING_AGG(InsertString,CONCAT(';',CHAR(10))) FROM #TMP_InsertString);
				SET @SQL = REPLACE(@SQL,'<TABLENAME>',@TableName)
				PRINT @SQL
				EXEC sp_executesql @SQL

			END
					 
			SET @iCounter = @iCounter + 1

			TRUNCATE TABLE #TMP_AllColValues
			TRUNCATE TABLE #TMP_AllCols
			TRUNCATE TABLE #TMP_INSERT
			TRUNCATE TABLE #TMP_AllDataCols
			TRUNCATE TABLE #TMP_InsertString

			DELETE FROM #TMP_ALLSTEPS WHERE [Name] ='apikey' AND Parent_ID = @ApiKey_Parent_ID
			 
	  END -- END OF WHILE LOOP

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@SpecialInputJSON=',CHAR(39),@SpecialInputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)			
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

			DROP TABLE IF EXISTS #TMP_AllCols,#TMP_AllColValues,#TMP_INSERT, #TMP_AllCols, #TMP_InsertString

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH
	
		 
			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@SpecialInputJSON=',CHAR(39),@SpecialInputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)		
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH

		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS
		 DROP TABLE IF EXISTS #TMP_DATA
		 DROP TABLE IF EXISTS #TMP_DATA_DAY
		 DROP TABLE IF EXISTS #TMP_DATA_DOT 
		 DROP TABLE IF EXISTS #TMP
		 DROP TABLE IF EXISTS #TMP_Lookups
		 --------------------------------------------------------
END