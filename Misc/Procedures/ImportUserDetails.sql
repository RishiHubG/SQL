 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.[ImportUserDetails]
CREATION DATE:      2023-03-30
AUTHOR:             Rishi Nayar
DESCRIPTION:							
USAGE:          	Exec dbo.[ImportUserDetails] 
						@dataJSON=N'{"data":[{"entityType":"4","columnToCompare":"Name","dataToMap":[{"FirstName":"ABC","MiddleName":"DEF","Name":"ABCDEF","JobTitle":"CTO","E_Mail":"ABCDEF@gmail.com"},{"FirstName":"XYZ","MiddleName":"MNO","Name":"ZYZMNO","JobTitle":"DPO","E_Mail":"ZYXMNO@gmail.com"}]},{"entityType":"","columnToCompare":"","dataToMap":[{},{}]}],"fileName":"Contact.xlsx","sheetsDependency":[{"leftSheetIndex":0,"leftColumnName":"","rightSheetIndex":1,"rightColumnName":""}]}',
						@MethodName=NULL,
						@UserLoginID=2913

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ImportUserDetails]
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

		--SELECT * FROM #TMP_ALLSTEPS;

		--IF CONTACT ID IS NOT NULL THEN UPDATE Contact ELSE INSERT Contact/AUser
		--CHECKING FOR COLUMN TO COMPARE: IF COLUMNTOCOMPARE IS NOT "NAME" THEN CONTACTID COLUMN IS IRRELEVANT
		SELECT T2.Parent_ID, T1.StringValue AS ColumnToCompare, T2.StringValue,Usr.ContactID--, IIF(T3.Element_ID IS NULL,1,0) AS ColumnToCompareAvailableInJson
			INTO #TMP_Name
		FROM #TMP_ALLSTEPS T1
			INNER JOIN #TMP_ALLSTEPS T2 ON T2.Name = T1.StringValue
			LEFT JOIN dbo.Auser Usr ON Usr.Name = T2.StringValue			
		WHERE T1.Name = 'columnToCompare' 
			  --AND T1.StringValue = 'Name'
			
			--SELECT * FROM #TMP_Name;

			
			--GET COLUMN LIST FOR CONTACT
			SELECT Child.Element_ID, Child.Parent_ID,Child.Name AS ColumnName, Child.StringValue
				INTO #TMP_Child
			FROM #TMP_Name Parent
				 INNER JOIN #TMP_ALLSTEPS Child ON Parent.Parent_ID = Child.Parent_ID
			WHERE Child.Name <> 'Name'

			CREATE TABLE #TBL_Contact(Parent_ID INT, ContactID INT,Name NVARCHAR(4000))

			--FETCH DISPLAYNAME
			INSERT INTO #TMP_Child(Parent_ID,ColumnName,StringValue)
				SELECT DISTINCT Parent_ID,'DisplayName',TAB.DisplayName 
				FROM #TMP_Child TMP
					 CROSS APPLY (
									SELECT CONCAT((SELECT StringValue FROM #TMP_Child WHERE ColumnName = 'FirstName' AND Parent_ID = TMP.Parent_ID ),' ',
												  (SELECT StringValue FROM #TMP_Child WHERE ColumnName = 'LastName' AND Parent_ID = TMP.Parent_ID)
												) AS DisplayName
									
								  )TAB
				WHERE ColumnName NOT IN ('DisplayName','validUpto');

				--SELECT * FROM #TMP_Child;

				--RETURN			
			BEGIN TRAN
			 
			--BUILD INSERT FOR Contact: CREATE CONTACT IF ColumnToCompare Value IS NOT AVAILABLE IN CONTACT			
			SELECT DISTINCT TMP.Parent_ID,TMPName.ColumnToCompare,TMPName.StringValue, TAB.*
				INTO #TMP_InsertString
			FROM #TMP_Child TMP
				INNER JOIN #TMP_Name TMPName ON TMPName.Parent_ID =TMP.Parent_ID AND TMPName.ContactID IS NULL -- NAME NOT AVAILABLE IN AUSER
				  CROSS APPLY ( SELECT STRING_AGG((ColumnName),',') AS strColumns,
									   STRING_AGG(CONCAT(CHAR(39),StringValue,char(39)),',') AS strValues,
									   --CONCAT('INSERT INTO dbo.Contact (',@StaticCols,',',STRING_AGG(ColumnName,','),') OUTPUT INSERTED.ContactID INTO #TBL_Contact(ContactID) 
									   CONCAT('INSERT INTO dbo.Contact (',@StaticCols,',',STRING_AGG(ColumnName,','),') OUTPUT INSERTED.ContactID,',TMP.Parent_ID,',',CHAR(39),TMPName.StringValue,CHAR(39),' INTO #TBL_Contact(ContactID,Parent_ID,Name) 
									   SELECT ',@StaticColValues,',',STRING_AGG(CONCAT(CHAR(39),StringValue,CHAR(39)),',')
									   --ADD FILTER TO CHECK IF VALUE IS AVAILABLE IN CONTACT PROVIDED ColumnToCompare IS NOT "NAME"
									   --i.e. INSERT IF ColumnToCompare IS NOT AVAILABLE IN CONTACT PROVIDED ColumnToCompare IS NOT "NAME"
									   ,CASE WHEN TMPName.ColumnToCompare <> 'NAME' THEN
											CONCAT(' WHERE NOT EXISTS(SELECT 1 FROM dbo.Contact WHERE ',TMPName.ColumnToCompare,'=',CHAR(39),TMPName.StringValue,CHAR(39),')')
									   END
									   ) AS InsertString

								FROM #TMP_Child
								WHERE Parent_ID = TMP.Parent_ID				  
								)TAB
			WHERE EXISTS(SELECT 1 FROM #TMP_Name WHERE Parent_ID =TMP.Parent_ID AND ContactID IS NULL); -- NAME NOT AVAILABLE IN AUSER
				--SELECT * FROM #TMP_InsertString
			IF EXISTS(SELECT 1 FROM #TMP_InsertString)
			BEGIN
				SET @SQL = (SELECT STRING_AGG(InsertString,CONCAT(';',CHAR(10))) FROM #TMP_InsertString);			
				PRINT @SQL				
				EXEC sp_executesql @SQL				 
				
			END
			ROLLBACK
			RETURN
			
		    --BUILD UPDATE FOR Contact
			SELECT DISTINCT Parent_ID, TAB.*,  CAST(NULL AS VARCHAR(MAX)) AS strSelect
				INTO #TMP_UpdateString
			FROM #TMP_Child TMP
				  CROSS APPLY ( SELECT STRING_AGG(CONCAT(ColumnName,'=', CHAR(39),StringValue,CHAR(39)),',') AS strColumns									  
								FROM #TMP_Child
								WHERE Parent_ID = TMP.Parent_ID				  
								)TAB
			--WHERE EXISTS(SELECT 1 FROM #TMP_Name WHERE Parent_ID =TMP.Parent_ID AND ContactID IS NOT NULL); -- NAME AVAILABLE IN AUSER	;
			
			UPDATE #TMP_UpdateString
				SET strColumns = CONCAT('UPDATE	dbo.Contact SET ', CHAR(10),strColumns,  CHAR(10),
										' WHERE <ColumnToCompare>=',CHAR(39),'<StringValue>',CHAR(39)),
					--RUN UPDATE ONLY IF A SINGLE CONTACT IS BEING UPDATED ELSE RETURN ERROR MESSAGE
					strSelect = CONCAT('SELECT ',Parent_ID,' AS Parent_ID, COUNT(*) AS TotalCount FROM dbo.Contact WHERE <ColumnToCompare>=',CHAR(39),'<StringValue>',CHAR(39))
			
			UPDATE TMP
				SET strColumns = REPLACE(strColumns,'<ColumnToCompare>',
										(SELECT ColumnToCompare
												--CASE 
												--	  WHEN ContactID IS NULL THEN ColumnToCompare 
												--	  WHEN ContactID IS NOT NULL THEN CAST(ContactID AS NVARCHAR(MAX))
												--END
										  FROM #TMP_Name WHERE Parent_ID = TMP.Parent_ID AND ColumnToCompare <> 'Name')
										),
					strSelect = REPLACE(strSelect,'<ColumnToCompare>',
										(SELECT ColumnToCompare
												--CASE 
												--	  WHEN ContactID IS NULL THEN ColumnToCompare 
												--	  WHEN ContactID IS NOT NULL THEN CAST(ContactID AS NVARCHAR(MAX))
												--END
										  FROM #TMP_Name WHERE Parent_ID = TMP.Parent_ID AND ColumnToCompare <> 'Name')
										)					
			FROM #TMP_UpdateString TMP;
			 
			UPDATE TMP
				SET strColumns = REPLACE(strColumns,'<StringValue>',
										(SELECT StringValue FROM #TMP_Name WHERE Parent_ID = TMP.Parent_ID)
										),
					strSelect = REPLACE(strSelect,'<StringValue>',
										(SELECT StringValue FROM #TMP_Name WHERE Parent_ID = TMP.Parent_ID)
										)		
			FROM #TMP_UpdateString TMP;			
		

		CREATE TABLE #TBL_CHECKCOUNT(Parent_ID INT, TotalCount INT)

		SET @SQL = (SELECT STRING_AGG(strSelect,CONCAT(' UNION ',CHAR(10))) FROM #TMP_UpdateString);			
		PRINT @SQL		
		
		--GET COUNTS OF CONTACTS BEING UPDATED: UPDATE CONTACT ONLY IF A SINGLE CONTACT IS BEING UPDATED
		IF @SQL IS NOT NULL
			INSERT INTO #TBL_CHECKCOUNT(Parent_ID,TotalCount)
				EXEC sp_executesql @SQL	
			 
		--SELECT * FROM #TBL_CHECKCOUNT
		--SELECT * FROM #TBL_Contact
		 
		--UPDATE CONTACT PROVIDED ONLY ONE CONTACT IS UPDATED
		SET @SQL = (SELECT STRING_AGG(strColumns,CONCAT(' UNION ',CHAR(10)))
					FROM #TMP_UpdateString TMP
					WHERE EXISTS(SELECT 1 FROM #TBL_CHECKCOUNT WHERE TotalCount=1 AND Parent_ID = TMP.Parent_ID)
				   );
		PRINT @SQL;

		IF @SQL IS NOT NULL
			EXEC sp_executesql @SQL
			 
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
			   Name,
			   1,
			   0,NULL,
			   CAST(0x AS uniqueidentifier),
			   1,
			   ContactID,
			   0,0,0,1,0,
			   (SELECT StringValue FROM #TMP_ALLSTEPS WHERE Name = 'validUpto' AND Parent_ID = TMP.Parent_ID) 
		FROM #TBL_Contact TMP;
		
			SELECT '' AS ErrorMessage

			COMMIT
		

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
