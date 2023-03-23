USE [ClientDemo_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SaveUserGroupDetails]    Script Date: 3/23/2023 1:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[SaveUserGroupDetails]
(
	@UserLoginID INT,
	@UserGroupID INT,
	@MethodName VARCHAR(255),
	@InputJson NVARCHAR(MAX)
)
AS
BEGIN 

	SET NOCOUNT ON   

	DECLARE @UserID int,
			@Error varchar(255),
			@ModifiedDate datetime,
			@NamespaceID int,
			@Rights int,
			@PSAuthEntityID INT,
			@IsError int,
			@Name nvarchar(255),
			@Description NVARCHAR(MAX)
	
	DROP TABLE IF EXISTS  #Deleted_Users
	DROP TABLE IF EXISTS  #Users
	DROP TABLE IF EXISTS  #Administrate
	DROP TABLE IF EXISTS  #PermissionScheme
	DROP TABLE IF EXISTS  #Rights
	DROP TABLE IF EXISTS  #UserRights

	CREATE TABLE #Deleted_Users(UserID int)
	CREATE TABLE #Users( UserID int )
	CREATE TABLE #Administrate(UserId INT)
	CREATE TABLE #PermissionScheme( PermissionSchemeID int )
	CREATE TABLE #Rights( Code varchar(20) )
	
	CREATE TABLE #UserRights( 
	[Userid]		[int] ,
	[Read]			[bit] ,
	[Modify]		[bit] ,
	[Write]			[bit] ,
	[Administrate]	[bit] ,
	[Cut]			[bit] ,
	[Copy]			[bit] ,
	[Export]		[bit] ,
	[Delete]		[bit] ,
	[report]		[bit] ,
	[Adhoc]			[bit] ,

	)

	--EXEC CheckUserAuthorisation_NG @ParentEntityTypeID = null, @ParentEntityID = null, @EntityTypeID = 24 ,@EntityID = @UserGroupID, @userloginID = @UserLoginId, @MethodName = 'Check User Authorisation', @IsError = @IsError OUTPUT

	IF(@IsError != 0)
	BEGIN
		SELECT 'Unauthorised Access, Session terminated' AS ErrorMessage
		RETURN
	END	


	--BEGIN TRANSACTION;

	IF (@UserLoginID IS NULL) 
	BEGIN
		SET @Error ='Invalid User Login.'
		GOTO ENDING
	END

		IF (@UserLoginID IS NOT NULL)
		BEGIN
			CREATE TABLE #USER(USERID INT)

			INSERT INTO #USER 
			EXEC LogRequest @UserLogInId , @MethodName
			
			SELECT @UserId = UserID
			FROM   #USER

			UPDATE UserLogin 
			SET	   LastRequestTime = GETUTCDATE(),
				   RequestCount = RequestCount  + 1
			WHERE  UserLoginID = @UserLoginID;
		END


	IF(@UserGroupID IS NULL OR (@UserGroupID <> -1 AND @UserGroupID NOT IN (SELECT userid FROM [AUser] WHERE AuthType =2)))
		BEGIN
			SET @Error ='Please provide a proper value for UserGroupID.'
			GOTO ENDING 
		END

	SELECT @ModifiedDate = GETUTCDATE();

	DECLARE @userjson NVARCHAR(MAX),@PermissionJson NVARCHAR(MAX),@administratejson NVARCHAR(MAX),@schemeJson NVARCHAR(MAX)

	
		SELECT @userjson = dataGrid FROM OpenJson(@InputJson)
		WITH(dataGrid NVARCHAR(MAX) AS JSON) 
	
		SELECT @PermissionJson = permissions FROM OpenJson(@InputJson)
		WITH(permissions NVARCHAR(MAX) AS JSON) 		

		SELECT @administratejson = administrateby FROM OpenJson(@InputJson)
		WITH(administrateby NVARCHAR(MAX) AS JSON) 	

		SELECT @schemeJson = permissionsSchemeGrid FROM OpenJson(@InputJson)
		WITH(permissionsSchemeGrid NVARCHAR(MAX) AS JSON) 	

		 SELECT a.[KEY] as Id,b.* INTO #usergrp
		FROM openjson(@userjson) AS a
		CROSS APPLY openjson(a.value) 
		as b
	 
		SELECT *  INTO #Permission
		FROM openjson(@PermissionJson) AS a
		--CROSS APPLY openjson(a.value) 
		--as b

		SELECT a.[KEY] as Id,b.* INTO #admin
		FROM openjson(@administratejson) AS a
		CROSS APPLY openjson(a.value) 
		as b

		SELECT a.[KEY] as Id,b.* INTO #scheme
		FROM openjson(@schemeJson) AS a
		CROSS APPLY openjson(a.value) 
		as b


		DECLARE @ii INT = 0
		DECLARE @jj  INT ,@Schemename INT ,@permissionschemeinGroup BIT

		SELECT @Jj = MAX(id) FROM #scheme

		WHILE (@ii<=@jj)
		BEGIN
			SELECT @Schemename = value from #scheme where id = @ii and [key] ='permissionschemeid'
			SELECT @permissionschemeinGroup = value from #scheme where id = @ii and [key] ='IsSelected'
			
			IF @permissionschemeinGroup = 'true' OR @permissionschemeinGroup='1'
				Insert into #PermissionScheme(PermissionSchemeID)
				SELECT @Schemename

			SELECT @ii= @ii+1
		END

	 
		DECLARE @ia INT = 0
		DECLARE @ja  INT ,@administratename NVARCHAR(2000),@administrateinGroup BIT

		SELECT @ja = MAX(id) FROM #admin

 
		WHILE (@ia<=@ja)
		BEGIN
			SELECT @administratename = value from #admin where id = @ia and [key] ='userid'
			SELECT @administrateinGroup = value from #admin where id = @ia and [key] ='ingroup'
			
			 
			IF @administrateinGroup = 'true' OR @administrateinGroup ='1'
				Insert into #Administrate(UserId)
				SELECT @administratename

			SELECT @ia= @ia+1
		END

		 
		DECLARE @i INT = 0
		DECLARE @j  INT ,@groupname NVARCHAR(2000),@ingroup BIT,@ingroupvalue NVARCHAR(200)

		SELECT @J = MAX(id) FROM  #usergrp

		WHILE(@i<=@j)
		BEGIN
		
			SELECT @groupname = value from #usergrp where id = @i and [key] ='userName'
			SELECT @ingroupvalue = value from #usergrp where id = @i and [key] ='inGroup'
			
			 
			IF @ingroupvalue = 'true' OR @ingroupvalue = '1'
				Insert into #Users(UserId)
				SELECT UserId FROM Auser where name =  @groupname

			SELECT @i= @i+1
		END

	
	SELECT @Name = name ,@Description = description
	FROM OpenJson(@InputJson)
	WITH (
		name nvarchar(255) ,
		description NVARCHAR(2000))
	
	INSERT INTO #Rights 
	SELECT pr.code FROM #Permission p
	INNER JOIN PermissionRights pr
		ON p.[Key] Collate Database_default = pr.RightName Collate Database_default
	WHERE [value] = 'true'

	IF(SELECT COUNT(*) FROM #Permission) > 0
	BEGIN
		INSERT INTO #UserRights
		 SELECT -1,* 
		FROM
		(
			SELECT [Key],[value]
			FROM #Permission
		) AS SourceTable PIVOT(MAX([Value]) FOR [Key] IN([read], [modify],[write],[administrate],[cut],[copy],[export]	,[delete],[report],[adhoc]))AS PivotTable
	END
	 

	--SELECT @Rights = ISNULL(SUM (CASE Code WHEN 'Read' THEN 1 WHEN 'Modify' THEN 2 WHEN 'Write' THEN 4 WHEN 'Administrate' THEN 8 WHEN 'Report' THEN 16 WHEN 'Export' THEN 32 END),0)
	--FROM #Rights
	DECLARE @right NVARCHAR(MAX)
	DECLARE @rights_tbl TABLE(Rights INT)

	IF(SELECT count(*) FROM #Rights) > 0
	BEGIN
		SELECT @right =  STUFF( (SELECT CONCAT('|','Power(2*1,',Code,')') FROM #Rights FOR XML PATH('')
					   ) 
				    ,1,1,''
				    )
		
		INSERT INTO @rights_tbl
		EXEC ('SELECT ' +   @right)

		SELECT @Rights = isnull((SELECT Rights FROM @rights_tbl),0)
	END
	ELSE
		SELECT @Rights =0		 
	 

		
	IF(@UserID IS NOT NULL)
	BEGIN
	--	BEGIN  TRY
			SET @Error = ''

			IF(@UserGroupID = -1)
				BEGIN
					IF EXISTS(SELECT 1 FROM AUser WHERE Name = @Name and AuthType= 2)
					BEGIN
						SELECT @Error = 'User Group with Name :' + @Name + ' already exists'
						GOTO ENDING
					END
					
					INSERT INTO AUser( Name, AuthType, Rights, Description, Usercreated, datecreated,UserModified,DateModified,UserTypeID,Password,Active,ContactID,ForcePasswordExpired)
					VALUES( @Name,2, @Rights, @Description, @UserID, @ModifiedDate,@UserID,@ModifiedDate,-1,'',1,-1,0)

					 SELECT @UserGroupID = SCOPE_IDENTITY()

					UPDATE #UserRights
					SET Userid = @UserGroupID

					INSERT INTO UserGroup(GroupID, UserID, Usercreated, datecreated,UserModified,DateModified)
					SELECT @UserGroupID, UserID, @UserID, @ModifiedDate,@UserID,@ModifiedDate FROM #Users

					INSERT INTO UserRights(Userid,[Read],[Modify],Write,Administrate,Cut,[Copy],Export,[Delete],report,Adhoc)
					Select Userid, ISNULL([Read],0), ISNULL([modify],0),ISNULL([write],0),ISNULL([administrate],0),ISNULL([cut],0),ISNULL([copy],0),ISNULL([export],0)	,ISNULL([delete],0),ISNULL([report],0),ISNULL([adhoc],0) from #UserRights

					INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights, usercreated,datecreated, UserModified, DateModified)
					SELECT b.AccessControlID, a.UserId, a.rights --(a.Rights & ~b.NewRights) AS Rights
					 
					--CASE  WHEN (a.Rights & ~b.NewRights) <> a.Rights THEN 1 ELSE 0 END  AS Customised
				 
					, @UserID,@ModifiedDate,@UserID,@ModifiedDate
					FROM AUser AS a
					CROSS JOIN AccessControl AS b
					WHERE UserId = @UserGroupID

					UPDATE ac
					SET  [Read]= ISNULL(u.[Read],0),
					[modify] = ISNULL(u.[modify],0),
					[write] = ISNULL(u.[write],0),
					[administrate] = ISNULL(u.[administrate],0),
					[cut] = ISNULL(u.[cut],0),
					[copy] = ISNULL(u.[copy],0),
					[export] = ISNULL(u.[export],0)	,
					[delete] = ISNULL(u.[delete],0),
					[report] = ISNULL(u.[report],0),
					[adhoc] = ISNULL(u.[adhoc],0)
					FROM AccessControlledResource ac
					INNER JOIN #UserRights u
						ON ac.UserId = ac.UserId
					WHERE ac.UserId = @UserGroupID

					IF(SELECT COUNT(*) FROM #PermissionScheme) >0
					BEGIN						
						INSERT INTO PermissionScheme_User( PermissionSchemeID,UserID,UserCreated,DateCreated, UserModified, DateModified)
						SELECT PermissionSchemeID,@UserGroupID,@UserID,@ModifiedDate ,@UserID,@ModifiedDate 
						  FROM #PermissionScheme
					END
					IF(SELECT COUNT(*) FROM #Administrate) >0
					BEGIN
						INSERT INTO EntityUserPermission(EntityID, EntityTypeID, UserId, Rights,UserCreated,DateCreated,UserModified,DateModified)
						SELECT @UserGroupID, 4, userId, 3,@UserID,@ModifiedDate ,@UserID,@ModifiedDate 
						FROM #Administrate
					END

				END
			ELSE IF(@UserGroupID > 0)
				BEGIN
					UPDATE AUser
					SET Name = @Name, [Description] = @Description, DateModified = @ModifiedDate,Rights = @Rights
					,UserModified = @UserID
					WHERE UserId = @UserGroupID

					UPDATE AccessControlledResource
					SET Rights = @Rights
					WHERE UserId = @UserGroupID --AND Customised = 0 

					UPDATE ac
					SET  [Read]= ISNULL(u.[Read],0),
					[modify] = ISNULL(u.[modify],0),
					[write] = ISNULL(u.[write],0),
					[administrate] = ISNULL(u.[administrate],0),
					[cut] = ISNULL(u.[cut],0),
					[copy] = ISNULL(u.[copy],0),
					[export] = ISNULL(u.[export],0)	,
					[delete] = ISNULL(u.[delete],0),
					[report] = ISNULL(u.[report],0),
					[adhoc] = ISNULL(u.[adhoc],0)
					FROM AccessControlledResource ac
					INNER JOIN #UserRights u
						ON ac.UserId = ac.UserId
					WHERE ac.UserId = @UserGroupID --AND Customised = 0 

					UPDATE #UserRights
					SET Userid = @UserGroupID

					DELETE FROM UserRights where Userid = @UserGroupID

					INSERT INTO UserRights(Userid,[Read],[Modify],Write,Administrate,Cut,[Copy],Export,[Delete],report,Adhoc)
					Select Userid, ISNULL([Read],0), ISNULL([modify],0),ISNULL([write],0),ISNULL([administrate],0),ISNULL([cut],0),ISNULL([copy],0),ISNULL([export],0)	,ISNULL([delete],0),ISNULL([report],0),ISNULL([adhoc],0) from #UserRights

				 
					INSERT INTO UserGroup(GroupID, UserID, UserModified,DateModified,UserCreated,DateCreated)
					SELECT @UserGroupID, UserID, @UserID, @ModifiedDate,@UserID,@ModifiedDate 
					  FROM #Users WHERE UserID NOT IN (SELECT UserID FROM UserGroup WHERE GroupID = @UserGroupID)

					INSERT INTO #Deleted_Users
					SELECT UserID FROM UserGroup
					WHERE GroupID = @UserGroupID AND UserID NOT IN ( SELECT UserID FROM #Users)

					DELETE FROM UserGroup
					WHERE GroupID = @UserGroupID AND UserID NOT IN ( SELECT UserID FROM #Users)
				
					INSERT INTO PermissionScheme_User( PermissionSchemeID,UserID,UserCreated,DateCreated, UserModified, DateModified)
					SELECT PermissionSchemeID,@UserGroupID,@UserID,@ModifiedDate ,@UserID,@ModifiedDate  FROM #PermissionScheme
					WHERE PermissionSchemeID NOT IN (SELECT PermissionSchemeID FROM PermissionScheme_User WHERE PermissionScheme_User.UserID = @UserGroupID)

					DELETE FROM PermissionScheme_User WHERE PermissionSchemeID NOT IN (SELECT PermissionSchemeID FROM #PermissionScheme)
					AND UserID = @UserGroupID

					INSERT INTO EntityUserPermission(EntityID, EntityTypeID, UserId, Rights,UserCreated,DateCreated,UserModified,DateModified)
					SELECT @UserGroupID, 4, userId, 3,@UserID,@ModifiedDate ,@UserID,@ModifiedDate 
					FROM #Administrate
					WHERE UserId NOT IN (SELECT UserId FROM EntityUserPermission WHERE EntityID = @UserGroupID AND EntityTypeID = 4)

					DELETE FROM EntityUserPermission
					WHERE EntityID = @UserGroupID AND EntityTypeID = 4 AND UserId NOT IN (SELECT UserId FROM #Administrate)


				END

				--GET ALL GROUPS-USERS UNDER AN ACCESSCONTROL PROVIDED THE USER HAS CUSTOMIZED=0
				SELECT DISTINCT ug.GroupID,ug.UserID, AC.Rights AS GroupRights,AC.AccessControlID,
						CAST(NULL AS INT) AS UserRights
					INTO #TMP
				FROM dbo.AccessControlledResource AC WITH (NOLOCK) 
					INNER JOIN dbo.AUser u WITH (NOLOCK) ON u.UserId = AC.UserId
					INNER JOIN dbo.UserGroup ug WITH (NOLOCK) ON ug.GroupID = u.UserId 
					INNER JOIN dbo.AccessControlledResource AC_User ON AC_User.UserId = ug.UserID
					 --INNER JOIN dbo.AControlledResource AC ON AC.AuthEntityID = AGroup.GroupID
				WHERE u.AuthType = 2 AND ug.GroupID = @UserGroupID
					-- AND AC_User.Customised = 0
	
				--CONCATENTATE ALL RIGHTS BY USER,AccessControlID
				SELECT T.*,STUFF(TAB.Col,1,1,'') AS NewUserRights 
					INTO #TMP_UserRights
				FROM #TMP T
					 CROSS APPLY (SELECT CONCAT('|',GroupRights) FROM #TMP WHERE T.UserID = UserID AND T.AccessControlID=AccessControlID FOR XML PATH(''))TAB(Col)
	
				;WITH CTE AS
				(
					SELECT *,ROW_NUMBER()OVER(PARTITION BY UserID,AccessControlID ORDER BY UserID,AccessControlID) AS ROWNUM
					FROM #TMP_UserRights
				)
				DELETE FROM CTE WHERE ROWNUM > 1

				--SELECT * FROM #TMP_UserRights

				DECLARE @SQL VARCHAR(MAX)

				SET @SQL = STUFF( (SELECT CONCAT(' UPDATE #TMP_UserRights SET UserRights = (SELECT ' , NewUserRights,') WHERE UserID=',UserID,';',CHAR(10)) FROM #TMP_UserRights 
									FOR XML PATH('')
								   ) 
								,1,1,''
								)
				--SELECT @SQL
				PRINT @SQL
				EXEC(@SQL)

				CREATE NONCLUSTERED INDEX NCI_TMP_UserRights ON #TMP_UserRights(UserID)INCLUDE(AccessControlID)

				--UPDATE USER RIGHTS
				UPDATE AC
					SET Rights = TMP.UserRights,
						DateModified = @ModifiedDate,
						UserModified = @UserID
				FROM #TMP_UserRights TMP
					 INNER JOIN dbo.AccessControlledResource AC ON AC.UserId=TMP.UserID AND AC.AccessControlID=TMP.AccessControlID
	
				--NEW ENTRIES FOR USERS NOT ALREADY AVAILABLE IN AControlledResource
				INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights,UserCreated,DateCreated, UserModified, DateModified) 
					SELECT DISTINCT ac.AccessControlID, AA.UserId, 0, @UserID,@ModifiedDate, @UserID,@ModifiedDate
					FROM AUser AA WITH (NOLOCK)
					INNER JOIN dbo.UserGroup ug WITH (NOLOCK) ON ug.GroupID = AA.UserId AND ug.GroupID= @UserGroupID
					INNER JOIN AccessControlledResource ac ON ug.GroupID = ac.UserId
					WHERE AA.AuthType = 1
			 AND NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE UserId = AA.UserId)
		
			Exec dbo.SaveUserAccessControlledResource @EntityId=@UserID,
											@UserType='UserGroup',
											@InputJson=@InputJson,
											@MethodName=@MethodName,
											@UserLoginID=@userloginID
		
		--END TRY
		--BEGIN CATCH  
		--		SET @Error = ERROR_MESSAGE();  
  
		--	IF @@TRANCOUNT > 0  
		--		ROLLBACK TRANSACTION 
		--END CATCH;  
	END
  
	--IF @@TRANCOUNT > 0  
	--	COMMIT TRANSACTION

	ENDING:
	--IF @Error !=''
	--	ROLLBACK TRANSACTION

	SELECT @Error AS ErrorMessage
	SELECT @UserGroupID as Id

END


