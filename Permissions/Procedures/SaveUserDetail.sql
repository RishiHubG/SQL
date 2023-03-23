USE [ClientDemo_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SaveUserDetail]    Script Date: 3/23/2023 1:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[SaveUserDetail]
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
			@Format    NVARCHAR(MAX),
			@fileas    NVARCHAR(2000) ,
			@validupto	DATE

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
		SELECT @groupname = value from #TMP12 where id = @i and [key] ='groupname'
		SELECT @ingroup = value from #TMP12 where id = @i and [key] ='ingroup'

		 
		INSERT INTO #group
		SELECT UserId,CASE WHEN @ingroup = 'true' THEN 1 ELSE @ingroup END FROM Auser where name =  @groupname and AuthType =2

		SELECT @i= @i+1
	END
 
 
	DECLARE @ii INT = 0
	DECLARE @jj  INT ,@PermissionName NVARCHAR(2000),@IsSelected BIT

	SELECT @Jj = MAX(id) FROM #permission
 

	WHILE(@ii<=@jj)
	BEGIN
		SELECT @PermissionName = value from #permission where id = @ii and [key] ='name'
		SELECT @IsSelected = value from #permission where id = @ii and [key] ='isselected'
 
		 IF @IsSelected = 1 OR @IsSelected = 'true'
			INSERT INTO #PermissionScheme
			SELECT PermissionSchemeID,@IsSelected,0 FROM PermissionScheme where name =  @PermissionName  

		SELECT @ii= @ii+1
	END
  
  


	SELECT @ModifiedDate = GETUTCDATE()

	SELECT @Title = title,@FirstName = firstname,@MiddleName = middlename,@fileas = fileas, @LoginName = loginname,@Password = password,@JobTitle = jobtitle,
	@Company = company,@E_Mail = email,@Telephone = phonenumberbusiness,@Cellphone =phonenumberhome,@Active = active,@ForcePasswordExpired = forcepasswordchangeonnextlogin  
	,@IsLocked = locked,@Description = description,@Surname = lastname,@UserType = usertype,@validupto = validupto
	FROM OpenJson(@InputJson)
	WITH (
		title nvarchar(255) ,
		firstname NVARCHAR(2000),
		middlename NVARCHAR(2000),
		fileas NVARCHAR(2000),
		loginname NVARCHAR(2000),
		password NVARCHAR(2000),
		jobtitle  NVARCHAR(2000),
		company NVARCHAR(2000),
		email  NVARCHAR(2000),
		phonenumberbusiness  NVARCHAR(2000),
		phonenumberhome  NVARCHAR(2000),
		active BIT,
		forcepasswordchangeonnextlogin BIT,
		locked BIT,
		resetPassword BIT,
		description NVARCHAR(MAX),
		lastname NVARCHAR(2000),
		usertype INT,
		validupto DATE
	)

	 
	--SELECT  @UserType = 1

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
		
		select @ContactID = -1

		SELECT @DisplayName = CONCAT(@FirstName,' ',@MiddleName,' ',@Surname)

		IF(@ContactID =-1)
		BEGIN
			IF EXISTS(SELECT 1 FROM Contact WHERE Fileas = @fileas)
			BEGIN
				SELECT @Validation = 'Contact with Name :' + @fileas + ' already exists'
				GOTO ENDING
			END

			 INSERT INTO Contact
			(DisplayName,Reference,ContactType,Telephone,Cellphone,E_Mail,Web,PhotoID,Fax,Notes,JobTitle,Company,Department,ManagerName,AssistantName,SpouseName,Birthday,HourlyRate,Anniversary,FirstName,MiddleName,
			Surname,Title,Suffix,HomePhone,HomeCity,HomePOCode,HomeProvince,HomeRegion,BusCity,HomeStreet,BusPOCode,BusProvince,BusRegion,BusStreet,Office,NickName,Profession,OutOfOfficeContactID,OutOfOfficeMessage,OutOfOfficeExpiryDate
			,UserModified,DateModified,UserCreated,DateCreated,fileas)
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
			@ModifiedDate,
			@fileas

			SELECT @ContactID = SCOPE_IDENTITY()

			 
		END
	
			

			INSERT INTO AUser
			( Name, AuthType, Description, Rights,ContactID, Password, Active, PasswordExpires, IsLocked, ForcePasswordExpired, UserTypeID, UserCreated,DateCreated,UserModified,DateModified,validupto)
			SELECT @LoginName ,@AuthType,@Description,0,@ContactId,@Password,@Active,1,@IsLocked,@ForcePasswordExpired,@UserType,@AUserID,@ModifiedDate,@AUserID,@ModifiedDate,@validupto

			SELECT @UserId = SCOPE_IDENTITY()
			
			INSERT INTO AccessControlledResource(AccessControlID, UserId, Rights,  UserCreated,DateCreated,UserModified,DateModified)
			SELECT b.AccessControlID, a.UserId, 
			0 AS Rights ,@AUserID,@ModifiedDate,@AUserID,@ModifiedDate
			FROM AUser AS a
			CROSS JOIN AccessControl AS b
			WHERE UserId = @UserId


			IF(SELECT COUNT(*) FROM #group  where InGroup = 1) >0
			BEGIN
				INSERT INTO UserGroup
				(UserID, GroupID,UserCreated,DateCreated, UserModified, DateModified)
				SELECT @UserId ,GroupId, @AUserID,@ModifiedDate, @AUserID,@ModifiedDate FROM #group where InGroup = 1
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
			SELECT @ContactID = contactId FROM AUser where UserId = @UserId

			IF EXISTS(SELECT 1 FROM AUser WHERE Name = @LoginName AND UserId != @UserId)
			BEGIN
				SELECT @Validation = 'User with Name :' + @LoginName + ' already exists'
				GOTO ENDING
			END

			IF EXISTS(SELECT 1 FROM Contact WHERE DisplayName = @DisplayName AND ContactID != @ContactID)
			BEGIN
				SELECT @Validation = 'Contact with Name :' + @DisplayName + ' already exists'
				GOTO ENDING
			END
 
			SELECT @DisplayName = CONCAT(@FirstName,' ',@MiddleName,' ',@Surname)

			UPDATE Contact
			SET DisplayName = @DisplayName, 
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
			DateModified = @ModifiedDate,
			Fileas = @fileas
				WHERE ContactID = @ContactID
 

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
				UserModified = @AUserID,
				validupto = @validupto
				WHERE UserId = @UserId
			END
			ELSE
			BEGIN
				UPDATE AUser
				SET Name = @LoginName, 
				Description = @Description, 
			--	password = @password,
				ContactId = @ContactId,
				Active = @Active ,
				ForcePasswordExpired = @ForcePasswordExpired,
				IsLocked = @IsLocked ,
				UserTypeID = @UserType,
				DateModified = @ModifiedDate,
				UserModified = @AUserID,
				validupto = @validupto
				WHERE UserId = @UserId
			END
			DELETE FROM UserGroup WHERE UserID = @UserId
			AND (
			GroupID IN (
			SELECT GroupID From #group where InGroup =0
			))

		--	SELECT COUNT(*) FROM #group where InGroup = 1

			IF(SELECT COUNT(*) FROM #group where InGroup = 1) >0
			BEGIN
				INSERT INTO UserGroup
				(UserID, GroupID,UserCreated,DateCreated, UserModified, DateModified)
				SELECT @UserId ,GroupId, @AUserID,@ModifiedDate, @AUserID,@ModifiedDate FROM #group where InGroup = 1
				and groupid not in (select groupid from UserGroup where UserID = @UserId)

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
					SELECT DISTINCT ac.AccessControlID, AA.UserId, 0, @AUserID,@ModifiedDate, @AUserID,@ModifiedDate
					FROM AUser AA WITH (NOLOCK)
					INNER JOIN dbo.UserGroup ug WITH (NOLOCK) ON ug.GroupID = AA.UserId AND ug.UserID = @UserId
					INNER JOIN AccessControlledResource ac ON ug.GroupID = ac.UserId
					WHERE AA.AuthType = 1
			 AND NOT EXISTS(SELECT 1 FROM dbo.AccessControlledResource WHERE UserId = AA.UserId)

			 Exec dbo.SaveUserAccessControlledResource @EntityId=@UserID,
													   @UserType='User',
													   @InputJson=@InputJson,
													   @MethodName=@MethodName,
													   @UserLoginID=@userloginID

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
	SELECT @UserId AS Id
END






