USE VKB_NEW
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ImportDataForEntity
CREATION DATE:      2022-12-07
AUTHOR:             Rishi Nayar
DESCRIPTION:							
USAGE:          	Exec dbo.ImportDataForEntity 
						@dataJSON=N'{"data":[{"entityType":"4","columnToCompare":"Name","dataToMap":[{"FirstName":"ABC","MiddleName":"DEF","Name":"ABCDEF","JobTitle":"CTO","E_Mail":"ABCDEF@gmail.com"},{"FirstName":"XYZ","MiddleName":"MNO","Name":"ZYZMNO","JobTitle":"DPO","E_Mail":"ZYXMNO@gmail.com"}]},{"entityType":"","columnToCompare":"","dataToMap":[{},{}]}],"fileName":"Contact.xlsx","sheetsDependency":[{"leftSheetIndex":0,"leftColumnName":"","rightSheetIndex":1,"rightColumnName":""}]}',
						@MethodName=NULL,
						@UserLoginID=2913

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ImportDataForEntity]
@DataJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL, 
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

	 
	 DECLARE @Params VARCHAR(MAX),
			 @ObjectName VARCHAR(100),
			 @IsExistingTable BIT = 0,
			 @UTCDATE DATETIME2(3) = GETUTCDATE(),
			 @SQL NVARCHAR(MAX)
	DECLARE @StaticColValues VARCHAR(MAX)
	DECLARE @StaticCols VARCHAR(MAX) =	 'UserCreated, 
										 DateCreated, 
										 UserModified,
										 DateModified'
	
	SET @StaticColValues = CONCAT(@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@UserID,',',CHAR(39),@UTCDATE,CHAR(39))
	PRINT @StaticColValues

DROP TABLE IF EXISTS #TMP_ALLSTEPS 

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@DataJSON); 
		
		SELECT * FROM #TMP_ALLSTEPS;

		SELECT T2.Parent_ID, T1.StringValue AS ColumnToCompare, T2.StringValue 
			INTO #TMP_Name
		FROM #TMP_ALLSTEPS T1
			INNER JOIN #TMP_ALLSTEPS T2 ON T2.Name = T1.StringValue
		WHERE T1.Name = 'columnToCompare' 
			--AND T1.StringValue = 'Name'

			SELECT * FROM #TMP_Name
			
			SELECT Child.Element_ID, Child.Parent_ID,Child.Name AS ColumnName, Child.StringValue
				INTO #TMP_Child
			FROM #TMP_Name Parent
				 INNER JOIN #TMP_ALLSTEPS Child ON Parent.Parent_ID = Child.Parent_ID
			WHERE Child.Name <> 'Name'

			CREATE TABLE #TBL_Contact(ContactID INT)

			--FETCH DISPLAYNAME
			INSERT INTO #TMP_Child(Parent_ID,ColumnName,StringValue)
				SELECT DISTINCT Parent_ID,'DisplayName',TAB.DisplayName 
				FROM #TMP_Child TMP
					 CROSS APPLY (
									SELECT CONCAT((SELECT StringValue FROM #TMP_Child WHERE ColumnName = 'FirstName' AND Parent_ID = TMP.Parent_ID ),' ',
												  (SELECT StringValue FROM #TMP_Child WHERE ColumnName = 'LastName' AND Parent_ID = TMP.Parent_ID)
												) AS DisplayName
									
								  )TAB
				WHERE ColumnName <> 'DisplayName';

				--SELECT * FROM #TMP_Child;

				--RETURN			

			SELECT DISTINCT Parent_ID, TAB.*
				INTO #TMP_InsertString
			FROM #TMP_Child TMP
				  CROSS APPLY ( SELECT STRING_AGG(ColumnName,',') AS strColumns,
									   STRING_AGG(CONCAT(CHAR(39),StringValue,char(39)),',') AS strValues,
									   CONCAT('INSERT INTO dbo.Contact (',@StaticCols,',',STRING_AGG(ColumnName,','),') OUTPUT INSERTED.ContactID INTO #TBL_Contact(ContactID) 
									   VALUES (',@StaticColValues,',',STRING_AGG(CONCAT(CHAR(39),StringValue,CHAR(39)),','),')') AS InsertString
								FROM #TMP_Child
								WHERE Parent_ID = TMP.Parent_ID				  
								)TAB;

				SET @SQL = (SELECT STRING_AGG(InsertString,CONCAT(';',CHAR(10))) FROM #TMP_InsertString);			
				PRINT @SQL				
				EXEC sp_executesql @SQL	
				
				SELECT * FROM #TBL_Contact

		RETURN
		INSERT INTO [dbo].[AUser]
				   ([UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[Name]
				   ,[AuthType]
				   ,[Rights]
				   ,[Description]
				   ,[Password]
				   ,[Active]
				   ,[ContactID]
				   ,[PasswordExpires]
				   ,[IsLocked]
				   ,[ForcePasswordExpired]
				   ,[UserTypeID]
				   ,[DormentUser]
				   ,[validupto])
		SELECT @UserID,
			   @UTCDATE,
			   @UserID,
			   @UTCDATE,
			 (SELECT T2.StringValue 
			 FROM #TMP_ALLSTEPS T1
				  INNER JOIN #TMP_ALLSTEPS T2 ON T2.Name = T1.StringValue
			 WHERE T1.Name = 'columnToCompare' 
				 AND T1.StringValue = 'Name'),
			   1,
			   0,NULL,0x,1,NULL,0,0,0,1,0,validUpto

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			DECLARE @Error INT = ERROR_line()

			IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@DataJSON=',CHAR(39),@DataJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage,@Error AS Errorline
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
