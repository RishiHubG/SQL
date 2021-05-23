
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveAssessmentJSONData
CREATION DATE:      2021-02-20
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveAssessmentJSONData   @UserLoginID=100,
													@inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.SaveAssessmentJSONData
@InputJSON VARCHAR(MAX),
@UserLoginID INT,
@EntityID INT,
@EntityTypeID INT=NULL,
@ParentEntityID INT=NULL,
@ParentEntityTypeID INT=NULL,
@MethodName NVARCHAR(2000) = NULL,
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON; 

	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @RegisterID INT,
			@PeriodIdentifierID INT = 1,
			@OperationType VARCHAR(50),
			@VersionNum INT,
			@RegisterName VARCHAR(250) ='ABC' -- TO BE MADE A PARAM

	IF @EntityID = -1
	BEGIN
		SELECT @RegisterID = 1, @OperationType ='INSERT', @VersionNum = 1

			INSERT INTO dbo.Registers(Name,UserCreated)
				SELECT @RegisterName, @UserLoginID
	END
	ELSE
	BEGIN
		SET @RegisterID = @EntityID
	
		SET @OperationType ='UPDATE'
	END
	
	--SELECT @RegisterID, @OperationType,@VersionNum
 --	RETURN
	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 

	 --SELECT * FROM #TMP_ALLSTEPS
	 --RETURN
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

		
		 --BUILD THE COLUMN LIST
		 -------------------------------------------------------------------------------------------------------
		SELECT Element_ID,
			   KeyName AS ColumnName,
			   StringValue
			INTO #TMP_INSERT
		FROM #TMP_DATA_KEYNAME
		WHERE Parent_ID = 0
			  AND OBJECTID IS NULL
			  AND StringValue <> ''
		 
		--INSERT ANY OTHER AD-HOC/FIXED COLUMNS
		INSERT INTO #TMP_INSERT(ColumnName,StringValue)
			SELECT 'VersionNum',@VersionNum
			UNION
			SELECT 'UserCreated',@UserLoginID
			
		---GENERATE ACCESSCONTROL ID---------------------------------------------------------------------------------
		 IF @EntityID = -1
		 BEGIN
			DECLARE @AccessControlId INT
			EXEC dbo.[GetNewAccessControllId] @UserLoginid, @MethodName, @AccessControlId OUTPUT			

			--INSERT ANY OTHER AD-HOC/FIXED COLUMNS
			INSERT INTO #TMP_INSERT(ColumnName,StringValue)
				SELECT 'AccessControlId',@AccessControlId
		 END
		-------------------------------------------------------------------------------------------------------------

 	 	DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX)

		IF @EntityID = -1
		BEGIN
	 		SET @ColumnNames = STUFF
									((SELECT CONCAT(', ',QUOTENAME(ColumnName))
									FROM #TMP_INSERT 								
									ORDER BY Element_ID
									FOR XML PATH ('')								
									),1,1,'')
		
			SET @ColumnNames = CONCAT('RegisterID',',',@ColumnNames)

			SET @ColumnValues = STUFF
									((SELECT CONCAT(', ',CHAR(39),StringValue,CHAR(39))
									FROM #TMP_INSERT 								
									ORDER BY Element_ID
									FOR XML PATH ('')								
									),1,1,'')

			SET @ColumnValues = CONCAT(CHAR(39),@RegisterID,CHAR(39),',',@ColumnValues)
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
			SET @SQL = CONCAT('INSERT INTO dbo.RegisterPropertyXerf_Data','(',@ColumnNames,') VALUES(',@ColumnValues,')')
			PRINT @SQL
		END
		ELSE	--UPDATE
		BEGIN
			SET @SQL = CONCAT('UPDATE dbo.RegisterPropertyXerf_Data',CHAR(10),' SET ',@UpdStr)
			SET @SQL = CONCAT(@SQL, ' WHERE RegisterID=', @RegisterID)
			PRINT @SQL
		END
		 
		EXEC sp_executesql @SQL	
		

		--UPDATE _HISTORY TABLE-----------------------------------------
		
		DECLARE @HistoryID INT = (SELECT MAX(HistoryID) FROM dbo.RegisterPropertyXerf_Data_history WHERE RegisterID = @RegisterID)

		--UPDATE VERSION NO.
		UPDATE dbo.RegisterPropertyXerf_Data_history
			SET VersionNum = @VersionNum
		WHERE HistoryID = @HistoryID			 

		--RESET PERIODIDENTIFIER FOR EARLIER VERSIONS
		UPDATE dbo.RegisterPropertyXerf_Data_history
			SET PeriodIdentifierID = 0,
				UserModified = @UserLoginID,
				DateModified = GETUTCDATE()
		WHERE RegisterID = @RegisterID
			  AND VersionNum < @VersionNum
		
		--UPDATE OTHER COLUMNS FOR CURRENT VERSION
		UPDATE dbo.RegisterPropertyXerf_Data_history
			SET PeriodIdentifierID = @PeriodIdentifierID,
				UserModified = @UserLoginID,
				DateModified = GETUTCDATE(),
				OperationType = @OperationType
		WHERE RegisterID = @RegisterID
			  AND VersionNum = @VersionNum
		-----------------------------------------------------------------

		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				SET @Params = CONCAT('@EntityID=',@RegisterID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityTypeID=',@EntityTypeID)
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
	
		 END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				SET @Params = CONCAT('@EntityID=',@RegisterID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,'@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH

		--DROP TEMP TABLES--------------------------------------			
		 DROP TABLE IF EXISTS #TMP_DATA_KEYNAME
		 DROP TABLE IF EXISTS  #TMP_INSERT		  
		 --------------------------------------------------------
END