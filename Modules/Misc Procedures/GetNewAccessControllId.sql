
--EXEC GetNewAccessControllId 10 ,''
CREATE OR ALTER PROCEDURE [DBO].[GetNewAccessControllId]
						@UserLoginid  INT,
						@MethodName   NVARCHAR(2000),
						@AccessControlID INT OUTPUT
AS
BEGIN

 DECLARE @UserID int ,@UTCDate DATETIME,@tempUserId INT,@Rights INT

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

	SELECT @UserID = 2

	DROP TABLE IF EXISTS #AAccessControl
 
 	CREATE TABLE #AAccessControl
		(
			AccessControlID INT,
			UserId INT,
			Rights INT
		)

	SELECT @UTCDate = GETUTCDATE()
 
	INSERT INTO AccessControl
	( NewRights, UserCreated, DateCreated,UserModified)
	SELECT 0,@UserID,@UTCDate,@UserID

	SELECT @AccessControlID =  SCOPE_IDENTITY()

		INSERT INTO #AAccessControl
		(AccessControlID, UserId, Rights)
		SELECT  @AccessControlID,UserId, Rights FROM AUser

		WHILE(SELECT COUNT(1) FROM #AAccessControl) > 0
		BEGIN
			SET @tempUserId = (SELECT TOP 1 UserId from #AAccessControl)

			IF (SELECT AuthType FROM AUser WHERE UserId = @tempUserId) = 2
				SET @Rights = (SELECT ISNULL( MAX(Rights),0) FROM AUser WHERE UserId = @tempUserId)
			ELSE
				SET @Rights = (SELECT  DISTINCT ISNULL( MAX( Rights),0)
				FROM AUser WITH (NOLOCK) 
					INNER JOIN UserGroup WITH (NOLOCK) ON 
				UserGroup.GroupID = AUser.UserId

				WHERE UserGroup.UserID = @tempUserId)

			INSERT INTO AccessControlledResource
			(AccessControlID, UserId, Rights, DateCreated, UserCreated,UserModified) 
			SELECT @AccessControlID, @tempUserId, @Rights, @UTCDate,@UserID,@UserID

			DELETE FROM #AAccessControl where UserId = @tempUserId	
		END
		
END