SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetAuditTrail
CREATION DATE:      2022-05-09
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.GetAuditTrail @EntityID=54,
											@StartDate='20220101',
											@EndDate='20220110',
											@UserLoginID=1,
											@MethodName= ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.GetAuditTrail
@EntityID INT,
@EntityTypeID INT,
@ParentEntityID INT,
@ParentEntityTypeID INT,
@StartDate DATETIME,
@EndDate DATETIME,
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @TableName VARCHAR(MAX)
	
	SELECT @TableName = CONCAT(Name,'_data')
	FROM dbo.Frameworks
	WHERE FrameworkID = @EntityID

	 SELECT @TableName
	 END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END