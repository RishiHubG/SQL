
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveUniversePermissions
CREATION DATE:      2021-05-22
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveUniversePermissions   @UserLoginID=100,
													@inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.SaveUniversePermissions
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

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT						     

	IF @UserID IS NOT NULL
	BEGIN
	
	DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX)

	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 
	-- SELECT * FROM #TMP_ALLSTEPS
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

		--SELECT * FROM #TMP_DATA_KEYNAME
		
		--SELECT * FROM #TMP_ALLSTEPS

		;WITH CTE 
		AS
		(
			SELECT Element_ID, Name,Parent_ID,StringValue,OBJECT_ID AS ObjectID
			FROM #TMP_ALLSTEPS
			WHERE Name = 'permissionList'
				  AND Parent_ID = 0

			UNION ALL

			SELECT TA.Element_ID, TA.Name,TA.Parent_ID,TA.StringValue,TA.OBJECT_ID AS ObjectID
			FROM CTE C
				 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = C.Element_ID
			--WHERE TA.Name <> 'unassigned'
		),
		CTE_Assigned AS	--FETCH ALL PERMISSIONS UNDER ""ASSIGNED"" NODE
		(
			SELECT Element_ID, Name,Parent_ID,StringValue,ObjectID
			FROM CTE
			WHERE Name = 'Assigned'

			UNION ALL

			SELECT TA.Element_ID, TA.Name,TA.Parent_ID,TA.StringValue,TA.OBJECT_ID AS ObjectID
			FROM CTE_Assigned C
				 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = C.Element_ID
		
		)

		SELECT * 
			INTO #TMP_AssignedPermissions
		FROM CTE_Assigned

		DELETE FROM #TMP_AssignedPermissions WHERE Name = 'Assigned' OR Name IS NULL
		--SELECT * FROM #TMP_AssignedPermissions
		--RETURN
		 --BUILD THE COLUMN LIST
		 -------------------------------------------------------------------------------------------------------
		 
		 DROP TABLE IF EXISTS #TMP
		
		SELECT TD.Element_ID,
			   TD.Name AS ColumnName,
			   TD.StringValue,
			   TD.Parent_ID AS ParentID
			INTO #TMP
		FROM #TMP_AssignedPermissions TD
		--	 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TD.ObjectID
		--	 INNER JOIN #TMP_ALLSTEPS TA_Child ON TA_Child.Parent_ID = TA.Element_ID
		--WHERE TA_Child.Name <> 'userUserGroup'		 
		
		SELECT ParentID,
			  TRY_PARSE(StringValue AS INT) AS UserID
			INTO #TMP_Users
		FROM #TMP
		WHERE ColumnName = 'userid'

		--SELECT * FROM #TMP_AssignedPermissions
		--SELECT * FROM #TMP
		--SELECT * FROM #TMP_Users
		--RETURN
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
		DECLARE @FixedColumns VARCHAR(1000) = 'AccessControlID,UserCreated,DateCreated,UserModified,DateModified'
		DECLARE @FixedColumnValues VARCHAR(1000) =  CONCAT(CHAR(39),@AccessControlID,CHAR(39),',',
									   CHAR(39),@UserLoginID,CHAR(39),',',
									   CHAR(39),GETUTCDATE(),CHAR(39),',',
								  	   CHAR(39),@UserLoginID,CHAR(39),',',
									   CHAR(39),GETUTCDATE(),CHAR(39)
									   )		 
		
		--BUILD THE INSERT
		SELECT Cols.ParentID,
			   Usr.UserID, 
			  CONCAT('INSERT INTO dbo.AccessControlledResource (',ColumnNames,',',@FixedColumns, ')',
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

		--CHECK FOR USERGROUPS & INSERT FOR OTHER USERS
		SELECT UG_Child.UserID,
			   REPLACE(TableInsert,'<USERID>',UG_Child.UserID) AS TableInsert		
			INTO #TMP_UG_Users
		FROM #TMP_AccessControlledResource TMP
			 INNER JOIN dbo.AUser AU ON TMP.UserID = AU.UserID
			 INNER JOIN dbo.UserGroup UG ON UG.UserID = TMP.UserID
			 INNER JOIN dbo.UserGroup UG_Child ON UG_Child.GroupID = UG.GroupID
		WHERE AU.AuthType = 2 --USERGROUP

		SET @SQL = STUFF
					((SELECT CONCAT(' ', TableInsert,'; ', CHAR(10))
					FROM #TMP_UG_Users 	
					FOR XML PATH ('')								
					),1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)		

		--RETURN					   
		 
		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)
		
		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
				SET @Params = CONCAT(@Params,',@AccessControlID=',@AccessControlID,',@LogRequest=',@LogRequest)
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

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
				SET @Params = CONCAT(@Params,',@AccessControlID=',@AccessControlID,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH
END