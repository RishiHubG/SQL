
/****** Object:  Table [dbo].[AccessControl]    Script Date: 23-02-2021 12:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccessControl](
	[AccessControlID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[UserModified] [int] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[NewRights] [int] NOT NULL,
 CONSTRAINT [AccessControl_PK] PRIMARY KEY CLUSTERED 
(
	[AccessControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccessControlledResource]    Script Date: 23-02-2021 12:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccessControlledResource](
	[AccessControlID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[UserModified] [int] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[UserId] [int] NOT NULL,
	[Rights] [int] NOT NULL,
	[Customised] [bit] NOT NULL,
 CONSTRAINT [AccessControlledResource_PK] PRIMARY KEY CLUSTERED 
(
	[AccessControlID] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccessControl] ADD  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[AccessControl] ADD  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[AccessControl] ADD  DEFAULT ((0)) FOR [NewRights]
GO
ALTER TABLE [dbo].[AccessControlledResource] ADD  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[AccessControlledResource] ADD  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[AccessControlledResource] ADD  DEFAULT ((0)) FOR [Rights]
GO
ALTER TABLE [dbo].[AccessControlledResource] ADD  DEFAULT ((0)) FOR [Customised]
GO
ALTER TABLE [dbo].[AccessControlledResource]  WITH CHECK ADD  CONSTRAINT [AccessControl_AccessControlledResource_FK1] FOREIGN KEY([AccessControlID])
REFERENCES [dbo].[AccessControl] ([AccessControlID])
GO
ALTER TABLE [dbo].[AccessControlledResource] CHECK CONSTRAINT [AccessControl_AccessControlledResource_FK1]
GO
/****** Object:  StoredProcedure [dbo].[SaveEntityDetail]    Script Date: 23-02-2021 12:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveEntityDetail]
						@EntitytypeId			INT,						
						@UserLoginID			INT,
						@MethodName				VARCHAR(255),
						@InputJson              NVARCHAR(MAX),
						@EntityId				INT
AS
BEGIN 

	SET NOCOUNT ON 

	IF(@EntitytypeId = 4) -- Userlist
	BEGIN
		EXEC SaveUserDetail @entityId,@UserloginId,@MethodName,@InputJson
	END
	ELSE IF(@EntitytypeId = 5) -- Role Type List
	BEGIN
		exec SaveRoleType @roleTypeId = @entityId, @UserloginId=@UserLoginID,@MethodName=@MethodName,@InputJson = @InputJson
	END
	ELSE IF (@EntitytypeId = 7) -- Permission scheme list
	BEGIN
		exec SavePermissionSchemeDetails @PermissionSchemeID= @entityId, @UserloginId=@UserLoginID,@MethodName=@MethodName,@InputJson = @InputJson
	END
	ELSE IF (@EntitytypeId = 6) -- User Group list
	BEGIN
		exec SaveUserGroupDetails @UserloginId=@UserLoginID,@usergroupId= @entityId,@MethodName=@MethodName,@InputJson = @InputJson
	END
	
END
GO
/****** Object:  StoredProcedure [dbo].[SaveUserDetail]    Script Date: 23-02-2021 12:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SaveUserDetail]
(
	@UserId					INT =-1,	
	@userloginID			INT,
	@MethodName				NVARCHAR(255),
	@InputJson              NVARCHAR(MAX)
)						

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @AUserID		INT,
			@Error		NVARCHAR(255),
			@ModifiedDate datetime,
			@PSAuthEntityID INT,
			@Validation	NVARCHAR(MAX),
			@LoginName				NVARCHAR(255),
			@Active					INT = nUll,
			@ForcePasswordExpired	INT =NULL,
			@Password				NVARCHAR(255),
			@UserType				INT ,
			@Description			NVARCHAR(MAX)=NULL,
			@ContactId				INT,
			@AuthType				INT = 1,
			--@UserGroup 				UserGroupTVP_NG READONLY,
			--@PermissionScheme		UserPS_SelectionTVP READONLY,
			@IsLocked				INT = 0, 
			@DisplayName			NVARCHAR(255)	,
			@SourceID				INT		=null,
			@Reference				NVARCHAR(2000)	=null	,
			@ContactType			NVARCHAR(2000)	=null	,
			@Telephone				NVARCHAR(2000)	=null	,
			@Cellphone				NVARCHAR(2000)	=null	,
			@E_Mail					NVARCHAR(2000)		=null,
			@Web					NVARCHAR(2000)		=null,
			@PhotoID				INT		=null,
			@Fax					NVARCHAR(2000)	=null	,
			@Notes					NVARCHAR(MAX)	=null	,
			@JobTitle				NVARCHAR(2000)	=null	,
			@Company				NVARCHAR(2000)		=null,
			@Department				NVARCHAR(2000)	=null	,
			@ManagerName			NVARCHAR(2000)	=null	,
			@AssistantName			NVARCHAR(2000)	=null	,
			@SpouseName				NVARCHAR(2000)		=null,
			@Birthday				DATETIME		=null,
			@HourlyRate				MONEY	=null	,
			@Anniversary			DATETIME		=null,
			@FirstName				NVARCHAR(2000)		=null,
			@MiddleName				NVARCHAR(2000)		=null,
			@Surname				NVARCHAR(2000)	=null	,
			@Title					NVARCHAR(2000)		=null,
			@Suffix					NVARCHAR(2000)	=null	,
			@HomePhone				NVARCHAR(2000)	=null	,
			@HomeCity				NVARCHAR(2000)	=null	,
			@HomePOCode				NVARCHAR(2000)		=null,
			@HomeProvince			NVARCHAR(2000)		=null,
			@HomeRegion				NVARCHAR(2000)		=null,
			@BusCity				NVARCHAR(2000)	=null	,
			@HomeStreet				NVARCHAR(2000)	=null	,
			@BusPOCode				NVARCHAR(2000)		=null,
			@BusProvince			NVARCHAR(2000)	=null	,
			@BusRegion				NVARCHAR(2000)	=null	,
			@BusStreet				NVARCHAR(2000)		=null,
			@Office					NVARCHAR(2000)	=null	,
			@NickName				NVARCHAR(2000)	=null	,
			@Profession				NVARCHAR(2000)	=null	,
			@OutOfOfficeContactID	INT		=null,
			@OutOfOfficeMessage		NVARCHAR(MAX)	=null	,
			@OutOfOfficeExpiryDate	DATETIME		=null,
			@UserGroup NVARCHAR(MAX),
			@Picture    NVARCHAR(MAX),
			@Format    NVARCHAR(MAX)

	IF (@UserLoginID IS NOT NULL)
		BEGIN
			CREATE TABLE #USER(USERID INT)

			INSERT INTO #USER 
			EXEC LogRequest @UserLogInId , @MethodName
			
			SELECT @AUserID = UserID
			FROM   #USER

			UPDATE UserLogin 
			SET	   LastRequestTime = GETUTCDATE(),
				   RequestCount = RequestCount  + 1
			WHERE  UserLoginID = @UserLoginID;
	END


	DECLARE @IsUserAdmin INT = 0, @Rights INT, @NewUser INT = 0, @ActionType INT = 0

	SELECT @Rights = (SELECT MAX(Rights) FROM AUser WHERE UserId IN (SELECT GROUPID FROM UserGroup WHERE UserID = @AUserID))


	CREATE Table #group
	(
		[GroupId] [int] NULL,
		[InGroup] [int] NULL
	)

	CREATE Table #PermissionScheme
	(
		[PermissionSchemeID] [int] NULL,
		IsSelected bit NULL,
		IsInherited bit NULL
	)

	DECLARE @userjson NVARCHAR(MAX),@PermissionJson NVARCHAR(MAX)

	SELECT @userjson = userGroups FROM OpenJson(@InputJson)
	WITH(userGroups NVARCHAR(MAX) AS JSON) 
	
	SELECT @PermissionJson = permissionScheme FROM OpenJson(@InputJson)
	WITH(permissionScheme NVARCHAR(MAX) AS JSON) 

	SELECT a.[KEY] as Id,b.* INTO #TMP12
	FROM openjson(@userjson) AS a
	CROSS APPLY openjson(a.value) 
	--	WITH (GroupName NVARCHAR(2000),inGroup BIT)
	as b

	SELECT a.[KEY] as Id,b.* INTO #permission
	FROM openjson(@PermissionJson) AS a
	CROSS APPLY openjson(a.value) 
	--	WITH (GroupName NVARCHAR(2000),inGroup BIT)
	as b

		 
	DECLARE @i INT = 0
	DECLARE @j  INT ,@groupname NVARCHAR(2000),@ingroup BIT

	SELECT @J = MAX(id) FROM #TMP12

	WHILE(@i<=@j)
	BEGIN
		SELECT @groupname = value from #TMP12 where id = @i and [key] ='groupName'
		SELECT @ingroup = value from #TMP12 where id = @i and [key] ='inGroup'

		 
		INSERT INTO #group
		SELECT UserId,@ingroup FROM Auser where name =  @groupname and AuthType =2

		SELECT @i= @i+1
	END
 
 
	DECLARE @ii INT = 0
	DECLARE @jj  INT ,@PermissionName NVARCHAR(2000),@IsSelected BIT

	SELECT @Jj = MAX(id) FROM #permission

	WHILE(@ii<=@jj)
	BEGIN
		SELECT @PermissionName = value from #TMP12 where id = @i and [key] ='groupName'
		SELECT @IsSelected = value from #TMP12 where id = @i and [key] ='inGroup'

		 
		INSERT INTO #PermissionScheme
		SELECT PermissionSchemeID,@IsSelected,0 FROM PermissionScheme where name =  @PermissionName  

		SELECT @ii= @ii+1
	END
 

	SELECT @ModifiedDate = GETUTCDATE()

	SELECT @Title = title,@FirstName = firstname,@MiddleName = middlename,@DisplayName = Fileas, @LoginName = userId,@Password = Password1,@JobTitle = Jobtitle,
	@Company = company,@E_Mail = Email,@Telephone = phoneNumberBusiness,@Cellphone =phoneNumberHome,@Active = active,@ForcePasswordExpired = forcePasswordChangeOnNextLogin  
	,@IsLocked = Locked,@Description = description
	FROM OpenJson(@InputJson)
	WITH (
		title nvarchar(255) ,
		firstName NVARCHAR(2000),
		middleName NVARCHAR(2000),
		fileAs NVARCHAR(2000),
		userId NVARCHAR(2000),
		password1 NVARCHAR(2000),
		jobTitle  NVARCHAR(2000),
		company NVARCHAR(2000),
		email  NVARCHAR(2000),
		phoneNumberBusiness  NVARCHAR(2000),
		phoneNumberHome  NVARCHAR(2000),
		active BIT,
		forcePasswordChangeOnNextLogin BIT,
		locked BIT,
		resetPassword BIT,
		description NVARCHAR(MAX)
	)

	SELECT @AUserID = 2, @UserType = 1

	IF(@AUserID IS NOT NULL)
	BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		IF(@UserId =-1)
		BEGIN
			IF EXISTS(SELECT 1 FROM AUser WHERE Name = @LoginName)
			BEGIN
				SELECT @Validation = 'User with Name :' + @LoginName + ' already exists'
				GOTO ENDING
			END

	 
			IF(@PhotoID IS NULL OR @PhotoID = -1)
			BEGIN
				IF(@Picture IS NOT NULL )
				BEGIN
					 INSERT INTO Picture
					(PictureID, Format, Picture,UserCreated,DateCreated,UserModified,DateModified)
					SELECT @PhotoID,@Format,@Picture,@UserID,@ModifiedDate,@UserID,@ModifiedDate

					SELECT @PhotoID = SCOPE_IDENTITY()

				END
				ELSE
					SELECT @PhotoID = NULL

			END
			ELSE
			BEGIN
					UPDATE Picture
					SET Picture= @Picture ,
					Format = @Format,

					DateModified = @ModifiedDate,
					UserModified = @UserID
					WHERE PictureID=@PhotoID
			END
		
		SET @ContactID =-1

		IF(@ContactID =-1)
		BEGIN
			IF EXISTS(SELECT 1 FROM Contact WHERE DisplayName = @DisplayName)
			BEGIN
				SELECT @Validation = 'Contact with Name :' + @DisplayName + ' already exists'
				GOTO ENDING
			END

			 INSERT INTO Contact
			(DisplayName,Reference,ContactType,Telephone,Cellphone,E_Mail,Web,PhotoID,Fax,Notes,JobTitle,Company,Department,ManagerName,AssistantName,SpouseName,Birthday,HourlyRate,Anniversary,FirstName,MiddleName,
			Surname,Title,Suffix,HomePhone,HomeCity,HomePOCode,HomeProvince,HomeRegion,BusCity,HomeStreet,BusPOCode,BusProvince,BusRegion,BusStreet,Office,NickName,Profession,OutOfOfficeContactID,OutOfOfficeMessage,OutOfOfficeExpiryDate
			,UserModified,DateModified,UserCreated,DateCreated)
			SELECT 
			@DisplayName			,
			@Reference				,
			@ContactType			,
			@Telephone				,
			@Cellphone				,
			@E_Mail					,
			@Web					,
			@PhotoID				,
			@Fax					,
			@Notes					,
			@JobTitle				,
			@Company				,
			@Department				,
			@ManagerName			,
			@AssistantName			,
			@SpouseName				,
			@Birthday				,
			@HourlyRate				,
			@Anniversary			,
			@FirstName				,
			@MiddleName				,
			@Surname				,
			@Title					,
			@Suffix					,
			@HomePhone				,
			@HomeCity				,
			@HomePOCode				,
			@HomeProvince			,
			@HomeRegion				,
			@BusCity				,
			@HomeStreet				,
			@BusPOCode				,
			@BusProvince			,
			@BusRegion				,
			@BusStreet				,
			@Office					,
			@NickName				,
			@Profession				,
			@OutOfOfficeContactID	,
			@OutOfOfficeMessage		,
			@OutOfOfficeExpiryDate  ,
			@UserID					,
			@ModifiedDate,
			@UserID					,
			@ModifiedDate

			SELECT @ContactID = SCOPE_IDENTITY()

			 
		END
		ELSE 
		BEGIN
			IF EXISTS(SELECT 1 FROM Contact WHERE DisplayName = @DisplayName AND ContactID != @ContactID)
			BEGIN
				SELECT @Validation = 'Contact with Name :' + @DisplayName + ' already exists'
				GOTO ENDING
			END

			UPDATE Contact
			SET DisplayName =@DisplayName, 
			PhotoID =@PhotoID,
			ContactType  =@ContactType,
			Telephone = @Telephone,
			Fax = @Fax,
			CellPhone  = @Cellphone,
			E_Mail = @E_Mail,
			Web = @Web,
			Notes  = @Notes,
			JobTitle  = @JobTitle,
			Company = @Company,
			Department  = @Department,
			ManagerName = @ManagerName,
			AssistantName  = @AssistantName,
			SpouseName = @SpouseName,
			Birthday = @Birthday,
			HourlyRate = @HourlyRate,
			Anniversary = @Anniversary,
			FirstName = @FirstName,
			MiddleName = @MiddleName,
			Surname = @Surname,
			Title = @Title,
			Suffix = @Suffix,
			Homephone = @HomePhone, 
			HomeCity =@HomeCity , 
			HomePOCode =@HomePOCode , 
			HomeProvince =@HomeProvince , 
			HomeRegion = @HomeRegion , 
			HomeStreet =@HomeStreet , 
			BusCity = @BusCity, 
			BusPOCode =@BusPOCode , 
			BusProvince =@BusProvince , 
			BusRegion = @BusRegion, 
			BusStreet =@BusStreet , 
			Office =@Office , 
			NickName = @NickName, 
			Profession = @Profession, 
			DateModified = @ModifiedDate
				WHERE ContactID = @ContactID

		END

			INSERT INTO AUser
			( Name, AuthType, Description, Rights,ContactID, Password, Active, PasswordExpires, IsLocked, ForcePasswordExpired, UserTypeID, UserCreated,DateCreated,UserModified,DateModified)
			SELECT @LoginName ,@AuthType,@Description,0,@ContactId,@Password,@Active,1,@IsLocked,@ForcePasswordExpired,@UserType,@AUserID,@ModifiedDate,@AUserID,@ModifiedDate

			SELECT @UserId = SCOPE_IDENTITY()
			
			INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights, Customised, UserCreated,DateCreated,UserModified,DateModified)
			SELECT b.AccessControlID, a.UserId, 
			0 AS Rights, 
			CASE  WHEN 0 <> a.Rights THEN 1 ELSE 0 END  AS Customised,@AUserID,@ModifiedDate,@AUserID,@ModifiedDate
			FROM AUser AS a
			CROSS JOIN AccessControl AS b
			WHERE UserId = @UserId


			IF(SELECT COUNT(*) FROM #group) >0
			BEGIN
				INSERT INTO UserGroup
				(UserID, GroupID, UserCreated,DateCreated,UserModified,DateModified)
				SELECT @UserId ,GroupId ,@AUserID,@ModifiedDate,@AUserID,@ModifiedDate FROM #group
			END

			IF(SELECT COUNT(*) FROM #PermissionScheme WHERE IsSelected = 1) >0
			BEGIN
			 
				INSERT INTO PermissionScheme_User
				( PermissionSchemeID,UserID, UserCreated,DateCreated,UserModified,DateModified)
				SELECT PermissionSchemeID,@UserId,@AUserID,@ModifiedDate,@AUserID,@ModifiedDate
				FROM #PermissionScheme WHERE IsSelected = 1
			END
	

		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM AUser WHERE Name = @LoginName AND UserId != @UserId)
			BEGIN
				SELECT @Validation = 'User with Name :' + @LoginName + ' already exists'
				GOTO ENDING
			END

			

			IF(@Password IS NULL)
			BEGIN
				UPDATE AUser
				SET Name = @LoginName, 
				Description = @Description, 
				ContactId = @ContactId,
				Active = @Active ,
				ForcePasswordExpired = @ForcePasswordExpired,
				IsLocked = @IsLocked ,
				UserTypeID = @UserType,
				DateModified = @ModifiedDate,
				UserModified = @AUserID
				WHERE UserId = @UserId
			END
			ELSE
			BEGIN
				UPDATE AUser
				SET Name = @LoginName, 
				Description = @Description, 
				password = @password,
				ContactId = @ContactId,
				Active = @Active ,
				ForcePasswordExpired = @ForcePasswordExpired,
				IsLocked = @IsLocked ,
				UserTypeID = @UserType,
				DateModified = @ModifiedDate,
				UserModified = @AUserID
				WHERE UserId = @UserId
			END
			DELETE FROM UserGroup WHERE UserID = @UserId
			AND (
			GroupID IN (
			SELECT GroupID From #group where InGroup =0
			))

			SELECT COUNT(*) FROM #group where InGroup = 1

			IF(SELECT COUNT(*) FROM #group where InGroup = 1) >0
			BEGIN
				INSERT INTO UserGroup
				(UserID, GroupID,UserCreated,DateCreated, UserModified, DateModified)
				SELECT @UserId ,GroupId, @AUserID,@ModifiedDate, @AUserID,@ModifiedDate FROM #group where InGroup = 1

				--SELECT @UserId ,GroupId ,@ModifiedDate,@ModifiedDate FROM #group where InGroup = 1
			END

			
 
			IF EXISTS( SELECT 1 FROM #PermissionScheme WHERE (ISSelected = 1 AND IsInherited = 0) OR (ISSelected = 0 AND IsInherited = 1))	
			BEGIN
				INSERT INTO PermissionScheme_User
				( PermissionSchemeID,UserID, UserCreated,DateCreated,UserModified, DateModified)
				SELECT PermissionSchemeID,
				@UserId, @AUserID,@ModifiedDate, @AUserID,@ModifiedDate FROM #PermissionScheme WHERE IsSelected = 1 AND PermissionSchemeID NOT IN (SELECT PermissionSchemeID FROM PermissionScheme_User WHERE UserID = @UserId)

				DELETE FROM PermissionScheme_User
				WHERE UserID = @UserId
				AND PermissionSchemeID NOT IN (SELECT PermissionSchemeID FROM #PermissionScheme WHERE UserID = @UserId AND IsSelected = 1)
			END
			ELSE IF (SELECT COUNT(*) FROM PermissionScheme_User WHERE UserID = @UserId) > 0
			BEGIN
				DELETE FROM PermissionScheme_User
				WHERE UserID = @UserId
			END

		END
		
		--GET ALL GROUPS-USERS UNDER AN ACCESSCONTROL PROVIDED THE USER HAS CUSTOMIZED=0
				SELECT DISTINCT ug.GroupID, AC.Rights AS GroupRights,u.UserId,AC.AccessControlID,
						CAST(NULL AS INT) AS UserRights
					INTO #TMP
				FROM dbo.AccessControlledResource AC WITH (NOLOCK) 
					INNER JOIN dbo.AUser u WITH (NOLOCK) ON u.UserId = AC.UserId
					INNER JOIN dbo.UserGroup ug WITH (NOLOCK) ON ug.GroupID = u.UserId 
					INNER JOIN dbo.AccessControlledResource AC_User ON AC_User.UserId = ug.UserID
					 --INNER JOIN dbo.AControlledResource AC ON AC.AuthEntityID = AGroup.GroupID
				WHERE u.AuthType = 2 AND u.userId = @UserId
					 AND AC_User.Customised = 0
	
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
				INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights,UserCreated,DateCreated, UserModified, DateModified,Customised) 
					SELECT DISTINCT ac.AccessControlID, AA.UserId, 0, @AUserID,@ModifiedDate, @AUserID,@ModifiedDate,0
					FROM AUser AA WITH (NOLOCK)
					INNER JOIN dbo.UserGroup ug WITH (NOLOCK) ON ug.GroupID = AA.UserId AND ug.UserID = @UserId
					INNER JOIN AccessControlledResource ac ON ug.GroupID = ac.UserId
					WHERE AA.AuthType = 1
			 AND NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE UserId = AA.UserId)

		SELECT @Error =''
		ENDING:
	COMMIT TRANSACTION
	END TRY	

	BEGIN CATCH
		--SELECT ERROR_MESSAGE() As error
		SET @Error = ERROR_MESSAGE()
		IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION
	END CATCH
	END
	IF (@AUserID IS NULL)
	SET @Error = 'User Session has expired, Please re-login';

	IF (@UserLoginID IS NULL)
	SET @Error = 'Invalid User Login';

	IF NOT (@Validation = '' OR @Validation IS NULL)
	BEGIN
		SET @Error = @Validation
	END

	SELECT @Error AS 'ErrorMessage'
	SELECT @UserId AS UserId
END






GO
/****** Object:  StoredProcedure [dbo].[SaveUserGroupDetails]    Script Date: 23-02-2021 12:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SaveUserGroupDetails]
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

	CREATE TABLE #Deleted_Users(UserID int)
	CREATE TABLE #Users( UserID int )
	CREATE TABLE #Administrate(UserId INT)
	CREATE TABLE #PermissionScheme( PermissionSchemeID int )
	CREATE TABLE #Rights( Code varchar(20) )

	--EXEC CheckUserAuthorisation_NG @ParentEntityTypeID = null, @ParentEntityID = null, @EntityTypeID = 24 ,@EntityID = @UserGroupID, @userloginID = @UserLoginId, @MethodName = 'Check User Authorisation', @IsError = @IsError OUTPUT

	IF(@IsError != 0)
	BEGIN
		SELECT 'Unauthorised Access, Session terminated' AS ErrorMessage
		RETURN
	END	


	BEGIN TRANSACTION;

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
	
		SELECT @PermissionJson = permission FROM OpenJson(@InputJson)
		WITH(permission NVARCHAR(MAX) AS JSON) 		

		SELECT @administratejson = administrate FROM OpenJson(@InputJson)
		WITH(administrate NVARCHAR(MAX) AS JSON) 	

		SELECT @schemeJson = permissionsSchemeGrid FROM OpenJson(@InputJson)
		WITH(permissionsSchemeGrid NVARCHAR(MAX) AS JSON) 	

		 SELECT a.[KEY] as Id,b.* INTO #usergrp
		FROM openjson(@userjson) AS a
		CROSS APPLY openjson(a.value) 
		as b
	 
		SELECT a.[KEY] as Id,b.* INTO #Permission
		FROM openjson(@PermissionJson) AS a
		CROSS APPLY openjson(a.value) 
		as b

		SELECT a.[KEY] as Id,b.* INTO #admin
		FROM openjson(@administratejson) AS a
		CROSS APPLY openjson(a.value) 
		as b

		SELECT a.[KEY] as Id,b.* INTO #scheme
		FROM openjson(@schemeJson) AS a
		CROSS APPLY openjson(a.value) 
		as b


		DECLARE @ii INT = 0
		DECLARE @jj  INT ,@Schemename NVARCHAR(2000),@permissionschemeinGroup BIT

		SELECT @Jj = MAX(id) FROM #scheme

		WHILE (@ii<=@jj)
		BEGIN
			SELECT @Schemename = value from #scheme where id = @ii and [key] ='permissionsschemename'
			SELECT @permissionschemeinGroup = value from #scheme where id = @ii and [key] ='permissionschemeinGroup'
			
			IF @permissionschemeinGroup = 'true'
				Insert into #PermissionScheme(PermissionSchemeID)
				SELECT PermissionSchemeID FROM PermissionScheme where name =  @Schemename

			SELECT @ii= @ii+1
		END

		DECLARE @ia INT = 0
		DECLARE @ja  INT ,@administratename NVARCHAR(2000),@administrateinGroup BIT

		SELECT @ja = MAX(id) FROM #scheme

		WHILE (@ia<=@ja)
		BEGIN
			SELECT @administratename = value from #admin where id = @ia and [key] ='administratename'
			SELECT @administrateinGroup = value from #admin where id = @ia and [key] ='administrateinGroup'
			
			IF @administrateinGroup = 'true'
				Insert into #Administrate(UserId)
				SELECT UserId FROM AUser where name =  @administratename

			SELECT @ia= @ia+1
		END

	
		DECLARE @i INT = 0
		DECLARE @j  INT ,@groupname NVARCHAR(2000),@ingroup BIT,@ingroupvalue NVARCHAR(200)

		SELECT @J = MAX(id) FROM #usergrp

		WHILE(@i<=@j)
		BEGIN
		
			SELECT @groupname = value from #usergrp where id = @i and [key] ='userName'
			SELECT @ingroupvalue = value from #usergrp where id = @i and [key] ='inGroup'
			
			IF @ingroupvalue = 'true'
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

	--SELECT @Rights = ISNULL(SUM (CASE Code WHEN 'Read' THEN 1 WHEN 'Modify' THEN 2 WHEN 'Write' THEN 4 WHEN 'Administrate' THEN 8 WHEN 'Report' THEN 16 WHEN 'Export' THEN 32 END),0)
	--FROM #Rights
	DECLARE @right NVARCHAR(MAX)
	DECLARE @rights_tbl TABLE(Rights INT)

	IF(SELECT count(*) FROM @rights_tbl) > 0
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

	select @UserID = 2


	IF(@UserID IS NOT NULL)
	BEGIN
		BEGIN  TRY
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

					INSERT INTO UserGroup(GroupID, UserID, Usercreated, datecreated,UserModified,DateModified)
					SELECT @UserGroupID, UserID, @UserID, @ModifiedDate,@UserID,@ModifiedDate FROM #Users

					INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights, Customised,usercreated,datecreated, UserModified, DateModified)
					SELECT b.AccessControlID, a.UserId, (a.Rights & ~b.NewRights) AS Rights,
					CASE  WHEN (a.Rights & ~b.NewRights) <> a.Rights THEN 1 ELSE 0 END  AS Customised, @UserID,@ModifiedDate,@UserID,@ModifiedDate
					FROM AUser AS a
					CROSS JOIN AccessControl AS b
					WHERE UserId = @UserGroupID

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
					WHERE UserId = @UserGroupID AND Customised = 0 

					INSERT INTO UserGroup(GroupID, UserID, UserModified,DateModified)
					SELECT @UserGroupID, UserID, @UserID, @ModifiedDate 
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
					WHERE UserId NOT IN (SELECT UserId FROM EntityUserPermission WHERE EntityID = @UserGroupID AND EntityTypeID = 24)

					DELETE FROM EntityUserPermission
					WHERE EntityID = @UserGroupID AND EntityTypeID = 24 AND UserId NOT IN (SELECT UserId FROM #Administrate)


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
					 AND AC_User.Customised = 0
	
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
				INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights,UserCreated,DateCreated, UserModified, DateModified,Customised) 
					SELECT DISTINCT ac.AccessControlID, AA.UserId, 0, @UserID,@ModifiedDate, @UserID,@ModifiedDate,0
					FROM AUser AA WITH (NOLOCK)
					INNER JOIN dbo.UserGroup ug WITH (NOLOCK) ON ug.GroupID = AA.UserId AND ug.GroupID= @UserGroupID
					INNER JOIN AccessControlledResource ac ON ug.GroupID = ac.UserId
					WHERE AA.AuthType = 1
			 AND NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE UserId = AA.UserId)
		
	
		
		END TRY
		BEGIN CATCH  
				SET @Error = ERROR_MESSAGE();  
  
			IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION 
		END CATCH;  
	END
  
	IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION

	ENDING:
	IF @Error !=''
		ROLLBACK TRANSACTION

	SELECT @Error AS ErrorMessage
	SELECT @UserGroupID as GroupID

END


GO
