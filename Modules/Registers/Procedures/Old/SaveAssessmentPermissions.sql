
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveAssessmentPermissions
CREATION DATE:      2021-05-22
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveAssessmentPermissions   @UserLoginID=100,
													@inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.SaveAssessmentPermissions
@InputJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(2000) = NULL,
@AccessControlID INT,
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @UserID INT
	DECLARE @UTCDATE DATETIME2(3) = GETUTCDATE()

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT						     


	
	IF @UserID IS NOT NULL
	BEGIN
	
	DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX)

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
			  OUTER APPLY dbo.[FindPatternLocation](T.Name,'.')TAB	 
		 WHERE Parent_ID = 0
		)
		
		SELECT *
			INTO #TMP_DATA_KEYNAME
		FROM CTE
		WHERE RowNum = 1

		UPDATE #TMP_DATA_KEYNAME
			SET KeyName = SUBSTRING(Name,Pos+1,len(Name))
		WHERE Pos > 0
			
		SELECT UserID	
			INTO #TMP_ExistingUsers
		FROM dbo.AccessControlledResource
		WHERE AccessControlID = @AccessControlID
		
		 --BUILD THE COLUMN LIST
		 -------------------------------------------------------------------------------------------------------
		 
		 DROP TABLE IF EXISTS #TMP
		
		SELECT TA_Child.Element_ID,
			   TA_Child.Name AS ColumnName,
			   TA_Child.StringValue,
			   TA_Child.Parent_ID AS ParentID
			INTO #TMP
		FROM #TMP_DATA_KEYNAME TD
			 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TD.ObjectID
			 INNER JOIN #TMP_ALLSTEPS TA_Child ON TA_Child.Parent_ID = TA.Element_ID
		WHERE TD.Name ='domainpermissiona'
			  AND TA_Child.Name <> 'userUserGroup'		 
		
		SELECT ParentID,
			  TRY_PARSE(StringValue AS INT) AS UserID
			INTO #TMP_Users
		FROM #TMP
		WHERE ColumnName = 'userid'
		UNION
		SELECT -1,1  ---FOR ADMIN
		UNION
		SELECT -2,2  ---FOR ADMINUG

		--DELETE USERS NOT FOUND IN JSON BUT AVAILABLE IN AccessControlledResource
		SELECT UserID INTO #TMP_UsersToDelete 
		FROM #TMP_ExistingUsers			
		EXCEPT
		SELECT UserID FROM #TMP_Users 
		
		IF EXISTS(SELECT 1 FROM #TMP_UsersToDelete)
		BEGIN

			DECLARE @UserIDs VARCHAR(MAX)

			SET @UserIDs =
							(SELECT 
							STUFF((
							SELECT  CONCAT(', ',QUOTENAME(UserID))
							FROM #TMP_UsersToDelete 			
							FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
							,1,2,'')
							)

			DECLARE @SQL_DELETE VARCHAR(MAX)
			SELECT @SQL_DELETE = CONCAT('DELETE FROM dbo.AccessControlledResource WHERE AccessControlID = ',@AccessControlID,' AND UserID IN (',UserID,')')
			FROM #TMP_UsersToDelete

			PRINT @SQL_DELETE
			EXEC(@SQL_DELETE)

		END

		--BUILD PERMISSIONS FOR ADMIN=1 AND ADMINUG=2---------------------------------------------------------------------------------------

			--ALL PERMISSION RELATED COLUMNS IN ACCESSCONTROL
			DECLARE @MAXID INT = (SELECT MAX(Element_ID) + 1 FROM #TMP)

			DROP TABLE IF EXISTS #TMP_AllCols

			CREATE TABLE #TMP_AllCols  (Element_ID INT IDENTITY(1,1),ColumnName VARCHAR(100),StringValue BIT DEFAULT(1),ParentID INT)
			DBCC CHECKIDENT(#TMP_AllCols, RESEED,@MAXID)

			INSERT INTO #TMP_AllCols (ColumnName)
				SELECT 'UserID' 
						UNION  	
				SELECT 'Rights' 
						UNION  
				--SELECT	'Customised' 
				--		UNION  
				SELECT	'Read' 
						UNION  
				SELECT	'Modify' 
						UNION  
				SELECT	'Write'
						UNION  
				SELECT  'Administrate' 
						UNION  
				SELECT	'Cut'
						UNION  
				SELECT	'Copy'
						UNION  
				SELECT	'Export'
						UNION  
				SELECT	'Delete'
						UNION  
				SELECT	'Report'
						UNION  
				SELECT	'Adhoc'

			UPDATE #TMP_AllCols SET ParentID = -1
			UPDATE #TMP_AllCols SET StringValue = 1 WHERE ColumnName= 'UserID'

			INSERT INTO #TMP_AllCols (ColumnName,ParentID)
				SELECT ColumnName,-2 FROM #TMP_AllCols
				
			INSERT INTO #TMP (Element_ID,ColumnName,StringValue,ParentID)
				SELECT Element_ID,ColumnName,StringValue,ParentID FROM #TMP_AllCols

			UPDATE #TMP_AllCols SET StringValue = 1 WHERE ColumnName= 'UserID' AND ParentID = -2
	---------------------------------------------------------------------------------------------------------------------------
	
		
		--SELECT * FROM #TMP_Users

		--CHECK IF PERMISSIONS EXISTS
		--IF NOT EXISTS (SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=@AccessControlID AND Userid=@UserID)
		BEGIN

		--BUILD THE UPDATE STATEMENTS-------------------------------------------------------------------------------------------------------
		DECLARE @UpdStmt VARCHAR(MAX) = CONCAT('IF EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=',@AccessControlID,' AND UserID=<USERID>)',CHAR(10),
												' UPDATE dbo.AccessControlledResource SET UserModified=', @UserID,', DateModified = GETUTCDATE(),')
		DECLARE @UpdWhereClauseStmt VARCHAR(MAX) = CONCAT(' WHERE AccessControlID=',@AccessControlID, CHAR(10), ' AND userid=<USERID>')
		
		 SELECT 
			ParentID,
			STUFF((
			SELECT  CONCAT(', ', CHAR(10), QUOTENAME(ColumnName),'=''',
							CASE WHEN ColumnName ='userid' THEN '<USERID>'
							  ELSE
							  StringValue
							  END
							,'''')
			FROM #TMP 
			WHERE ParentID = TMP.ParentID
			ORDER BY Element_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,2,'') AS UpdString
			INTO #TMP_UpdateStmt	
		FROM #TMP TMP
		GROUP BY ParentID
		
		UPDATE #TMP_UpdateStmt 
			SET UpdString = CONCAT(@UpdStmt,UpdString, CHAR(10),@UpdWhereClauseStmt)

		UPDATE	TMP 
			SET UpdString = REPLACE(UpdString,'<USERID>',UserID)
		FROM #TMP_UpdateStmt TMP
			  INNER JOIN #TMP_Users Usr ON Usr.ParentID = TMP.ParentID
		--UPDATE STATEMENTS ENDS HERE--------------------------------------------------------------------------------------------------------

		 
		
		SET @SQL = STUFF
					((SELECT CONCAT(' ', UpdString,'; ', CHAR(10))
					FROM #TMP_UpdateStmt 	
					FOR XML PATH ('')								
					),1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)


		END
		--ELSE   ----INSERT
		BEGIN
		
		--BUILD THE COLUMNS
		SELECT 
			ParentID,
			STUFF((
			SELECT  CONCAT(', ',QUOTENAME(ColumnName))
			FROM #TMP 
			WHERE ParentID = TMP.ParentID
			ORDER BY Element_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,2,'') AS ColumnNames
		 INTO #TMP_Columns
		FROM #TMP TMP
		GROUP BY ParentID
		
		--BUILD THE COLUMN VALUES
		SELECT 
			ParentID,
			STUFF((
			SELECT CONCAT(', ',CHAR(39),
							  CASE WHEN ColumnName ='userid' THEN '<USERID>'
							  ELSE
							  StringValue
							  END,			
							  CHAR(39))
			FROM #TMP 
			WHERE ParentID = TMP.ParentID
			ORDER BY Element_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,2,'') AS ColumnValues
			INTO #TMP_ColumnValues
		FROM #TMP TMP
		GROUP BY ParentID
		
		DECLARE @Customized BIT = 1
		DECLARE @FixedColumns VARCHAR(1000) = 'AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised'
		DECLARE @FixedColumnValues VARCHAR(1000) =  CONCAT(CHAR(39),@AccessControlID,CHAR(39),',',
									   CHAR(39),@UserLoginID,CHAR(39),',',
									   CHAR(39),@UTCDATE,CHAR(39),',',
								  	   CHAR(39),@UserLoginID,CHAR(39),',',
									   CHAR(39),@UTCDATE,CHAR(39),',',
									   CHAR(39),@Customized,CHAR(39)
									   )		 
			
		--BUILD THE INSERT
		SELECT Cols.ParentID,
			   Usr.UserID, 
			  CONCAT('IF NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE AccessControlID=',@AccessControlID,' AND UserID=<USERID>)',CHAR(10),
					  'INSERT INTO dbo.AccessControlledResource (',ColumnNames,',',@FixedColumns, ')',
					  'VALUES (', ColumnValues,',',@FixedColumnValues,')'		
				     ) AS TableInsert
			INTO #TMP_AccessControlledResource
		FROM #TMP_Columns Cols
			 INNER JOIN #TMP_ColumnValues Val ON VAL.ParentID = Cols.ParentID
			 INNER JOIN #TMP_Users Usr ON Usr.ParentID = Cols.ParentID
	
		UPDATE #TMP_AccessControlledResource
			SET TableInsert = REPLACE(TableInsert,'<USERID>',UserID)

		SET @SQL = STUFF
					((SELECT CONCAT(' ', TableInsert,'; ', CHAR(10))
					FROM #TMP_AccessControlledResource 	
					FOR XML PATH ('')								
					),1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)

		END --END OF INSERTS
		
		--START: CHECK FOR USERGROUPS & INSERT FOR OTHER USERS***********************************************************************************

		DECLARE @TMP_SQL VARCHAR(MAX)
		CREATE TABLE #TBL(
						[AccessControlID] [int] NULL,
						[UserCreated] [int] NULL,
						[DateCreated] [datetime] NULL,
						[UserModified] [int] NULL,
						[DateModified] [datetime] NULL,
						[UserId] [int] NULL,
						[ParentID] [int] NULL,
						[Rights] [int] NULL,
						[Customised] [bit] NULL,
						[Read] [int] NULL,
						[Modify] [int] NULL,
						[Write] [int] NULL,
						[Administrate] [int] NULL,
						[Cut] [int] NULL,
						[Copy] [int] NULL,
						[Export] [int] NULL,
						[Delete] [int] NULL,
						[Report] [int] NULL,
						[Adhoc] [int] NULL 
						)		
								

		SELECT DISTINCT UG_Child.UserID,
			   TMP.ParentID,	
			   REPLACE(TableInsert,'<USERID>',UG_Child.UserID) AS TableInsert,
			   CONCAT('DELETE FROM dbo.UserAccessControlledResource WHERE AccessControlID=',@AccessControlID,' AND UserID=',UG_Child.UserID) AS TableDelete
			INTO #TMP_UG_Users
		FROM #TMP_AccessControlledResource TMP
			 INNER JOIN dbo.AUser AU ON TMP.UserID = AU.UserID
			 INNER JOIN dbo.UserGroup UG ON UG.UserID = TMP.UserID
			 INNER JOIN dbo.UserGroup UG_Child ON UG_Child.GroupID = UG.GroupID
		WHERE AU.AuthType = 2 --USERGROUP			  
		
		UPDATE #TMP_UG_Users
			SET TableInsert = REPLACE(TableInsert,'AccessControlledResource','UserAccessControlledResource')
		
		--CONCATENATE THE INSERTS
		SET @TMP_SQL = STUFF
					((SELECT CONCAT(' ', TableInsert,'; ', CHAR(10))
					FROM #TMP_UG_Users 	
					FOR XML PATH ('')								
					),1,1,'')	

		--INSERT INTO TEMP TABLE
		SET @TMP_SQL = REPLACE(@TMP_SQL,'dbo.AccessControlledResource','#TBL')
		PRINT @TMP_SQL
		EXEC (@TMP_SQL)

		--CHECK FOR USERS BELONGING TO MULTPLE GROUPS
		SELECT TBL.UserID,
			   TBL.ParentID,
			   SUM([Adhoc]) AS [Adhoc], SUM([Administrate]) AS [Administrate], SUM([Copy]) AS [Copy], SUM([Cut]) AS [Cut], SUM([Delete]) AS [Delete], 
			   SUM([Export]) AS [Export], SUM([Modify]) AS [Modify], SUM([Read]) AS [Read], SUM([Report]) AS [Report], 
			   SUM([Rights]) AS [Rights], SUM([Write]) AS [Write]
			INTO #TMP_Permissions	
		FROM #TBL TBL
			 INNER JOIN #TMP_UG_Users TUG ON TUG.ParentID = TBL.ParentID
		GROUP BY TBL.UserID,TBL.ParentID
		HAVING COUNT(*)>1

		--REMOVE DUPLICATE USERS FROM THE MAIN TEMP TABLE
		DELETE TG FROM #TMP_UG_Users TG WHERE EXISTS(SELECT 1 FROM #TMP_Permissions WHERE UserID = TG.UserID)

		--CONCATENATE THE DELETES FOR USERS BELONGING TO ONLY ONE UG
		SET @SQL = STUFF
					((SELECT CONCAT(' ', TableDelete,'; ', CHAR(10))
					FROM #TMP_UG_Users 	
					FOR XML PATH ('')								
					),1,1,'')	
		
		PRINT @SQL
		EXEC (@SQL)
		
		--CONCATENATE THE INSERTS FOR USERS BELONGING TO ONLY ONE UG
		SET @SQL = STUFF
					((SELECT CONCAT(' ', TableInsert,'; ', CHAR(10))
					FROM #TMP_UG_Users 	
					FOR XML PATH ('')								
					),1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)		

		 --START: UNION THE PERMISSIONS FOR USERS BELONGING TO MULTIPLE UG*************************************************************************************************		
				
		UPDATE #TMP_Permissions
			SET [Adhoc] = CASE WHEN [Adhoc] > 1 THEN 1 ELSE 0 END,
				[Administrate] = CASE WHEN [Administrate] > 1 THEN 1 ELSE 0 END,
				[Copy] = CASE WHEN [Copy] > 1 THEN 1 ELSE 0 END,
				[Cut] = CASE WHEN [Cut] > 1 THEN 1 ELSE 0 END,
				[Delete] = CASE WHEN [Delete] > 1 THEN 1 ELSE 0 END,
				[Export] = CASE WHEN [Read] > 1 THEN 1 ELSE 0 END,
				[Modify] = CASE WHEN [Report] > 1 THEN 1 ELSE 0 END,
				[Read] = CASE WHEN [Write] > 1 THEN 1 ELSE 0 END,
				[Report] = CASE WHEN [Adhoc] > 1 THEN 1 ELSE 0 END,
				[Rights] = CASE WHEN [Adhoc] > 1 THEN 1 ELSE 0 END,		---CHECK WITH NITIN????
				[Write] = CASE WHEN [Write] > 1 THEN 1 ELSE 0 END		

		SET @SQL = STUFF
					((SELECT CONCAT('; ', 
										'INSERT INTO dbo.UserAccessControlledResource ([Adhoc], [Administrate], [Copy], [Cut], [Delete], [Export], [Modify], [Read], [Report], [Rights], [UserID], [Write],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)',
										[Adhoc],',', [Administrate],',', [Copy],',', [Cut],',', [Delete],',', [Export],',', [Modify],',', [Read],',', [Report],',', [Rights],',', [UserID],',', [Write],',',@AccessControlID,',',@UserLoginID,',', CHAR(39),@UTCDATE,CHAR(39),',',@UserLoginID,',', CHAR(39),@UTCDATE,CHAR(39),',0',
									CHAR(10))
					FROM #TMP_Permissions 	
					FOR XML PATH ('')								
					),1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)	

		--SELECT @SQL = CONCAT('INSERT INTO dbo.AccessControlledResource ([Adhoc], [Administrate], [Copy], [Cut], [Delete], [Export], [Modify], [Read], [Report], [Rights], [UserID], [Write],AccessControlID,UserCreated,DateCreated,UserModified,DateModified,Customised)',
		--						[Adhoc],',', [Administrate],',', [Copy],',', [Cut],',', [Delete],',', [Export],',', [Modify],',', [Read],',', [Report],',', [Rights],',', [UserID],',', [Write],',',@AccessControlID,',',@UserLoginID,',', CHAR(39),@UTCDATE,CHAR(39),',',@UserLoginID,',', CHAR(39),@UTCDATE,CHAR(39),',0'		
		--				  )
		--FROM #TMP_Permissions;


		---END: UNION OF UG USERS PERMISSIONS IF USERS BELONGS TO MORE THAN ONE UG ENDS HERE*********************************************************************

		--SET Customized TO FALSE FOR OTHER USERS
		UPDATE ACR
			SET Customised = 0
		FROM dbo.UserAccessControlledResource ACR
			 INNER JOIN #TMP_UG_Users TMP ON TMP.UserID = ACR.UserID

		--END: CHECK FOR USERGROUPS & INSERT FOR OTHER USERS***********************************************************************************					   
		 
		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)
		
		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
				SET @Params = CONCAT(@Params,'@MethodName=',CHAR(39),@MethodName,CHAR(39),',@AccessControlID=',@AccessControlID,',@LogRequest=',@LogRequest)
			--PRINT @PARAMS
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		
		--DROP TEMP TABLES--------------------------------------	
		 DROP TABLE IF EXISTS #TMP
		 DROP TABLE IF EXISTS #TMP_DATA_KEYNAME		 
		 DROP TABLE IF EXISTS #TMP_Columns
		 DROP TABLE IF EXISTS #TMP_ColumnValues
		 DROP TABLE IF EXISTS #TMP_AccessControlledResource
		 DROP TABLE IF EXISTS #TMP_Users
		 DROP TABLE IF EXISTS #TMP_UG_Users
		 --------------------------------------------------------

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage

END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
				SET @Params = CONCAT(@Params,'@AccessControlID=',@AccessControlID,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH
END