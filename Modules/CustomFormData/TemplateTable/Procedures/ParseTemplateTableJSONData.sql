USE AGSQA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseTemplateTableJSONData
CREATION DATE:      2021-09-21
AUTHOR:             Rishi Nayar
DESCRIPTION:		
					
USAGE:
CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ParseTemplateTableJSONData
@Name VARCHAR(100),
@Entityid INT,
@InputJSON VARCHAR(MAX),
@FullSchemaJSON VARCHAR(MAX),
@UserLoginID INT,
@TableID INT,
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
			 @ObjectName VARCHAR(100)

 
 
DROP TABLE IF EXISTS #TMP_ALLSTEPS 

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)
 WHERE ValueType !='array'
	   
 SET @Name = REPLACE(@NAME,' ','')

 DECLARE @FrameWorkTblName VARCHAR(500) = CONCAT('[TemplateTable_', @Name,'_data]')
 DECLARE @FrameWorkHistTblName VARCHAR(500) = CONCAT('[TemplateTable_', @Name,'_data_history]')
 DECLARE @FrameWorkTblName_WhereClause VARCHAR(500)
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =2
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =20

 --SELECT * FROM #TMP_ALLSTEPS
 --RETURN

 DROP TABLE IF EXISTS #TMP_Objects

 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS
	   --AND Element_ID<=12 --FILTERING OUT USERCREATED,DATECREATED,SUBMIT ETC.
	   AND Name NOT IN ('userCreated','dateCreated','userModified','dateModified','submit')
	  -- AND NAME IN ('Name','riskCategory1')
	    
 
 --SELECT * FROM #TMP_Objects
 --RETURN
	 	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500), --='XYZ',
			@StepItemType VARCHAR(500),		 
			@StepItemName VARCHAR(500),
			@LookupValues VARCHAR(1000),
			@StepItemID INT,			
			@VersionNum INT,
			@StepItemKey VARCHAR(100),
			--@Name VARCHAR(100) = 'TAB',
			@SQL NVARCHAR(MAX),
			@IsAvailable BIT,
			@TemplateTableName SYSNAME,
			@Counter INT = 1,
			@AttributeID INT, @LookupID INT
	
	--GET VERSION NO.--------------------------------------------------------
	SELECT @VersionNum = MAX(VersionNum) + 1 FROM dbo.TemplateTableColumnMaster

	IF @VersionNum IS NULL
		SET @VersionNum = 1
	---------------------------------------------------------------------------	

	--BUILD SCHEMA FOR _DATA TABLE============================================================================================	 
	 
	 DECLARE @SQL_ID VARCHAR(MAX)='ID INT'
	 DECLARE @SQL_HistoryID VARCHAR(MAX)='HistoryID INT IDENTITY(1,1)'
	 DECLARE @StaticCols VARCHAR(MAX) =	 
	 'UserCreated INT NOT NULL, 
	 DateCreated DATETIME2(0) NOT NULL DEFAULT GETDATE(), 
	 UserModified INT,
	 DateModified DATETIME2(0),
	 VersionNum INT NOT NULL,	 
	 TableInstanceID INT'
	 
	 DROP TABLE IF EXISTS #TMP_DATA

	 SELECT TOB.Element_ID, TOB.NAME,TA.StringValue, CAST(NULL AS VARCHAR(50)) AS DataType,
			CAST(NULL AS VARCHAR(50)) AS DataTypeLength,
			CAST(NULL AS VARCHAR(500)) AS StepName
		INTO #TMP_DATA
	 FROM #TMP_Objects TOB
		 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TOB.Element_ID
	 WHERE TA.Name = 'type'
	
	 UPDATE #TMP_DATA
		SET DataType = CASE WHEN StringValue IN ('textfield','selectboxes','select','textarea','email','URL','phoneNumber','tags','signature','password','button','colorPicker','colored','entityLinkGrid','datagrid','checkbox','radio') THEN 'NVARCHAR' 
							WHEN StringValue = 'number' THEN 'INT'
							WHEN StringValue = 'datetime' THEN 'DATETIME' 							
							WHEN StringValue = 'currency' THEN 'FLOAT'
							WHEN StringValue = 'time' THEN 'TIME'
					   END
	
	UPDATE #TMP_DATA
		SET DataTypeLength = CASE WHEN DataType = 'NVARCHAR' THEN '(MAX)'
							 END

		--EXTRACT STEP ITEM(AFTER LAST DOT) & STEP NAME(BEFORE FIRST DOT)-----------------
		SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos,MIN(TAB.pos) AS MinPos
			INTO #TMP_POS
		 FROM #TMP_DATA T
			  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB		
		GROUP BY T.Element_ID,T.Name

		UPDATE TD
		SET Name = SUBSTRING(TDD.Name,TDD.Pos+1,len(TDD.Name))
		FROM #TMP_DATA TD
			 INNER JOIN #TMP_POS TDD ON TD.Element_ID=TDD.Element_ID
	 
	-----------------------------------------------------------------------------------
	 
	
	 DECLARE @DataCols VARCHAR(MAX), @HistDataCols VARCHAR(MAX), @MainDataCols VARCHAR(MAX), @NewDataCols VARCHAR(MAX) 
	 SET @DataCols = --STUFF(
					 (SELECT CONCAT(', [',[Name],'] [', DataType,'] ', DataTypeLength)
					 FROM #TMP_DATA
					 FOR XML PATH('')
					 )
					 --,1,1,'')

	--SET @DataCols = CONCAT(',FrameworkID INT',@DataCols)
	PRINT @DataCols
	
	--CHECK IF TABLE IS ALREADY AVAILABLE, THEN GET ANY NEW COLUMNS THAT ARE PART OF THE SCHEMA
	SET @SQL = CONCAT(N'SELECT @NewDataCols = STUFF(
						(SELECT CONCAT('', ['',[Name],''] ['', DataType,''] '', DataTypeLength)
						FROM #TMP_DATA TA								  
						WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.Name AND C.object_id =OBJECT_ID(',CHAR(39),@FrameWorkTblName,CHAR(39),'))
						FOR XML PATH('''')
						)
						,1,1,'''')'
						)
	PRINT @SQL
	EXEC sp_executesql @SQL,N'@NewDataCols VARCHAR(MAX) OUTPUT',@NewDataCols OUTPUT
	--SELECT @FrameWorkTblName,@NewDataCols,* from #TMP_DATA
	--RETURN
 

	SET @MainDataCols = CONCAT(@SQL_ID,' IDENTITY(1,1),',CHAR(10),@StaticCols,CHAR(10),@DataCols)
	SET @StaticCols = CONCAT(@StaticCols,',PeriodIdentifier INT')
	SET @HistDataCols = CONCAT(@SQL_HistoryID,',',CHAR(10),@SQL_ID,',', CHAR(10),@StaticCols,CHAR(10),',OperationType VARCHAR(50)',CHAR(10),@DataCols)
	
	--PRINT @HistDataCols
	SET @FrameWorkTblName_WhereClause = CONCAT('TemplateTable_',@Name,'_data')
	SET @SQL = ''
	SET @SQL = CONCAT(N'IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME=',CHAR(39),@FrameWorkTblName_WhereClause,CHAR(39),')', CHAR(10))
	SET @SQL = CONCAT(@SQL,N' BEGIN ',CHAR(10))
	SET @SQL = CONCAT(@SQL,N' CREATE TABLE dbo.', @FrameWorkTblName,CHAR(10), '(', @MainDataCols, ') ;',CHAR(10))
	SET @SQL = CONCAT(@SQL,N' CREATE TABLE dbo.', @FrameWorkHistTblName, CHAR(10), '(', @HistDataCols, ') ;',CHAR(10))	
	SET @SQL = CONCAT(@SQL,N' END ',CHAR(10))
	IF @NewDataCols IS NOT NULL	--_DATA TABLE ALREADY EXISTS
	BEGIN
		SET @SQL = CONCAT(@SQL,N' ELSE ',CHAR(10)) 
		SET @SQL = CONCAT(@SQL,N' BEGIN ',CHAR(10))	
		SET @SQL = CONCAT(@SQL,N' ALTER TABLE dbo.', @FrameWorkTblName ,' ADD ', CHAR(10), @NewDataCols, CHAR(10),';')
		SET @SQL = CONCAT(@SQL,N' ALTER TABLE dbo.', @FrameWorkHistTblName ,' ADD ', CHAR(10), @NewDataCols, CHAR(10),';')
		SET @SQL = CONCAT(@SQL,N' END ',CHAR(10))
	END
	PRINT @SQL
	
	EXEC sp_executesql @SQL		

	--INSERT COLUMN LIST IN TemplateTableColumnMaster------------
	DECLARE @TableColID INT, @PeriodIdentifierID INT
	DECLARE @TBL_HISTORY TABLE(ID INT NOT NULL,
								UserCreated INT NOT NULL, 
								DateCreated DATETIME2(0) NOT NULL, 
								UserModified INT,
								DateModified DATETIME2(0),
								ColumnName VARCHAR(500),
								IsActive BIT,
								VersionNum INT NOT NULL,
								CustomFormsInstanceID INT NOT NULL) 
							 
	INSERT INTO dbo.TemplateTableColumnMaster (ColumnName,UserCreated,DateCreated,UserModified,DateModified,IsActive,VersionNum,CustomFormsInstanceID)
		OUTPUT INSERTED.ID,INSERTED.ColumnName,INSERTED.UserCreated,INSERTED.DateCreated,INSERTED.UserModified,INSERTED.DateModified,INSERTED.IsActive,INSERTED.VersionNum,INSERTED.CustomFormsInstanceID
			INTO @TBL_HISTORY (ID,ColumnName,UserCreated,DateCreated,UserModified,DateModified,IsActive,VersionNum,CustomFormsInstanceID)
		SELECT Name,@UserID,GETUTCDATE(),@UserID,GETUTCDATE(),1,@VersionNum,@TableID
		FROM #TMP_DATA
	
	--CHECKING FOR ISACTIVE
	INSERT INTO dbo.TemplateTableColumnMaster (ColumnName,UserCreated,DateCreated,UserModified,DateModified,IsActive,VersionNum,CustomFormsInstanceID)
		OUTPUT INSERTED.ID,INSERTED.ColumnName,INSERTED.UserCreated,INSERTED.DateCreated,INSERTED.UserModified,INSERTED.DateModified,INSERTED.IsActive,INSERTED.VersionNum,INSERTED.CustomFormsInstanceID
			INTO @TBL_HISTORY (ID,ColumnName,UserCreated,DateCreated,UserModified,DateModified,IsActive,VersionNum,CustomFormsInstanceID)
		SELECT ColumnName,@UserID,GETUTCDATE(),@UserID,GETUTCDATE(),0,@VersionNum,CustomFormsInstanceID
		FROM dbo.TemplateTableColumnMaster TCM
		WHERE VersionNum = @VersionNum - 1
		      AND NOT EXISTS(SELECT 1 FROM #TMP_DATA WHERE Name = TCM.ColumnName)
			  			  

	INSERT INTO dbo.TemplateTableColumnMaster_history (ID, ColumnName,UserCreated,DateCreated,UserModified,DateModified,IsActive,VersionNum,CustomFormsInstanceID)
		SELECT ID, ColumnName,UserCreated,DateCreated,UserModified,DateModified,IsActive,VersionNum,CustomFormsInstanceID
		FROM @TBL_HISTORY
	

	UPDATE dbo.TemplateTableColumnMaster_history
		SET PeriodIdentifierID = 0
	WHERE VersionNum < @VersionNum

	UPDATE dbo.TemplateTableColumnMaster_history
		SET PeriodIdentifierID = 1
	WHERE VersionNum = @VersionNum
	---------------------------------------------------
					--CREATE TRIGGER------------------------------------------------------------------------------------------------------------------------------------------
					DECLARE @cols VARCHAR(MAX) = ''

					SELECT @cols = CONCAT(@cols,N', [',name,'] ')
					FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM ',@FrameWorkTblName), NULL, 1)
					
					SET @cols = STUFF(@cols, 1, 1, N'');

					DECLARE @TriggerTblName VARCHAR(500)= REPLACE(REPLACE(@FrameWorkTblName,']','') ,'[','')			
					SET @TriggerTblName = CONCAT(@TriggerTblName,'_Insert')

					SET @SQL = CONCAT(N'IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME=',CHAR(39),@TriggerTblName,CHAR(39),') SET @IsAvailable = 1;' )
					PRINT @SQL
					EXEC sp_executesql @SQL,N'@IsAvailable BIT OUTPUT',@IsAvailable OUTPUT
					 
					IF @IsAvailable = 1						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '			
					

					SET @SQL = CONCAT(@SQL,N' <TriggerTblName>
									   ON  <TableName>
									   AFTER INSERT, UPDATE
									AS 
									BEGIN
										SET NOCOUNT ON;
																				
										IF EXISTS(SELECT 1 FROM INSERTED) AND  NOT EXISTS(SELECT 1 FROM DELETED) --INSERT
											INSERT INTO <HISTTABLENAME>(<ColumnList>)
												SELECT <columnList>
												FROM INSERTED
										ELSE IF EXISTS(SELECT 1 FROM INSERTED) AND  EXISTS(SELECT 1 FROM DELETED) --UPDATE
											INSERT INTO <HISTTABLENAME>(<ColumnList>)
												SELECT <columnList>
												FROM DELETED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
					SET @SQL = REPLACE(@SQL,'<TableName>',@FrameWorkTblName)
					SET @SQL = REPLACE(@SQL,'<TriggerTblName>',@TriggerTblName)
					SET @SQL = REPLACE(@SQL,'<HISTTABLENAME>',@FrameWorkHistTblName)
					
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				---TRIGGER ENDS HERE-------------------------------------------------------------------------------------------------------------------------------
	 

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@Name=', CHAR(39),@Name, CHAR(39),',@Entityid=',@Entityid,',@TableID=',@TableID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
			SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39))
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

			SET @Params = CONCAT('@Name=', CHAR(39),@Name, CHAR(39),',@Entityid=',@Entityid,',@TableID=',@TableID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
			SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39))
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