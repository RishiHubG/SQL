SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.InsertObjectLog
CREATION DATE:      2020-12-18
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.InsertObjectLog @ObjectNameWithParam = ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.InsertObjectLog
 @PROCID INT,	
 @Params VARCHAR(MAX),
 @UserCreated INT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ObjectName VARCHAR(MAX) = OBJECT_NAME(@PROCID)
	SET @ObjectName = CONCAT('EXEC dbo.',@ObjectName,' ',@Params)

	INSERT INTO dbo.ObjectLog(ObjectNameWithParam,UserCreated, DateExecuted)
		SELECT @ObjectName,@UserCreated, GETUTCDATE()
		

END

