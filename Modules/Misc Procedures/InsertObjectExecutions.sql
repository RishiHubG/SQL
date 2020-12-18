SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ObjectLog
CREATION DATE:      2020-12-18
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.ObjectLog @ObjectNameWithParam = ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.InsertObjectLog
 @PROCID INT,	
 @ObjectNameWithParam VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ObjectName SYSNAME = OBJECT_NAME(@@PROCID)

	INSERT INTO dbo.ObjectLog(ObjectNameWithParam, DateExecuted)
		SELECT @ObjectNameWithParam, GETUTCDATE()

		/*
		SELECT @@PROCID,OBJECT_NAME(@@PROCID)
	--SELECT * FROM SYS.parameters WHERE OBJECT_ID=@@PROCID
	
	SELECT CONCAT(CHAR(39),[Name],CHAR(39),[Name])FROM SYS.parameters WHERE OBJECT_ID=@@PROCID
		
		*/

END

