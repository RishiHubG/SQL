 USE JUNK
 GO 

 DROP TRIGGER IF EXISTS dbo.RegisterPropertyXerf_Data_Insert
 GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER dbo.RegisterPropertyXerf_Data_Insert
   ON  dbo.RegisterPropertyXerf_Data
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  
END
GO
