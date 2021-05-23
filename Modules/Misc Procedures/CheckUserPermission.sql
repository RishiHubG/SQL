
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

CREATE OR ALTER PROCEDURE dbo.CheckUserPermission
@UserLoginID INT,
@MethodName NVARCHAR(2000) = NULL,
@UserID INT OUTPUT
AS
BEGIN 
		
		IF @UserLoginID IS NOT NULL
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

END