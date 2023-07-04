USE [ClientDemo]
GO

--SELECT dbo.fnGetClientID(1)

DROP FUNCTION IF EXISTS dbo.fnGetClientID 
GO

CREATE FUNCTION dbo.fnGetClientID(@UserLoginID INT)
RETURNS INT
AS
BEGIN 
   RETURN (SELECT ClientID FROM dbo.userlogin WHERE UserLoginID=@UserLoginID)
END 
GO	