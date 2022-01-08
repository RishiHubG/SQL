USE AGSQA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveTemplateTableData
CREATION DATE:      2021-10-24
AUTHOR:             Rishi Nayar
DESCRIPTION:		
					
USAGE:
CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.SaveTemplateTableData
@EntityID INT,
@InputJSON VARCHAR(MAX),
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

	 SELECT @TableName = CONCAT('[TemplateTable_', [Name],'_data]')		   
	 FROM CustomFormsInstance WHERE CustomFormsInstanceID = @Entityid
	
	 IF @TableName IS NULL
	 BEGIN
		PRINT 'TEMPLATE TABLE NOT FOUND!!'
		RETURN
	 END

	--GET VERSION NO.--------------------------------------------------------
		SET @SQL = CONCAT('SELECT @VersionNum = MAX(VersionNum) + 1 FROM ',@TableName)		
		EXEC sp_executesql @SQL,N'@VersionNum INT OUTPUT',@VersionNum OUTPUT

		IF @VersionNum IS NULL	
			SET @VersionNum = 1
	---------------------------------------------------------------------------	
	--GET OPERATION TYPE--------------------------------------------------------
		SET @SQL = CONCAT('SELECT @OperationType = ''1'' FROM ',@TableName, ' WHERE TableInstanceID = ',@EntityID)		
		EXEC sp_executesql @SQL,N'@OperationType VARCHAR(50) OUTPUT',@OperationType OUTPUT

		IF @OperationType = '1'
			SET @OperationType = 'UPDATE'
	-----------------------------------------------------------------------------	
	

	DROP TABLE IF EXISTS #TMP_ALLSTEPS 

	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON)
 	   	
 --SELECT * FROM #TMP_ALLSTEPS
 --RETURN

	;WITH CTE_TemplateData
	AS
	(		
		SELECT T.Element_ID,
			   T.Name AS ColumnName, 
			   T.Parent_ID,	   
			   T.StringValue,
			   T.ValueType
		 FROM #TMP_ALLSTEPS T			  
		 WHERE Name IN ('audit','dataGrid')

		 UNION ALL

		 SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,			   
			   T.StringValue,
			   T.ValueType
		 FROM CTE_TemplateData C
			  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
		
	)

	SELECT * 
		INTO #TMP_INSERT
	FROM CTE_TemplateData WHERE ValueType ='string' --ColumnName IS NOT NULL AND ColumnName <> 'audit'
	
	SELECT Parent_ID, STRING_AGG(ColumnName,',') AS ColumnName
		INTO #TMP_AllCols
	FROM #TMP_INSERT 
	GROUP BY Parent_ID
	
	SELECT Parent_ID, STRING_AGG(CONCAT(CHAR(39),StringValue,CHAR(39)),',') AS StringValue
		INTO #TMP_AllColValues
	FROM #TMP_INSERT 
	GROUP BY Parent_ID

	 SET @StaticColValues = CONCAT(@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@VersionNum,',',@EntityID)
	 PRINT @StaticColValues
	
	  IF @OperationType = 'INSERT'
	  BEGIN
			 SELECT CONCAT('INSERT INTO dbo.<TABLENAME>(',@StaticCols,',',A1.ColumnName,') VALUES (',@StaticColValues,',',A2.StringValue,')') AS InsertString
				INTO #TMP_InsertString
			 FROM #TMP_AllCols A1
				  INNER JOIN #TMP_AllColValues A2 ON A1.Parent_ID = A2.Parent_ID
				  SELECT * FROM #TMP_InsertString
				  SELECT * FROM #TMP_AllCols
				  SELECT * FROM #TMP_AllColValues
			SET @SQL = (SELECT STRING_AGG(InsertString,CONCAT(';',CHAR(10))) FROM #TMP_InsertString);
			SET @SQL = REPLACE(@SQL,'<TABLENAME>',@TableName)
			PRINT @SQL
			EXEC sp_executesql @SQL

		END
  
		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@Entityid=',@Entityid,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)			
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

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

			SET @Params = CONCAT('@Entityid=',@Entityid,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)			
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