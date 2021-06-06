 USE JUNK
 GO

 DROP TRIGGER IF EXISTS dbo.Trg_RegisterProperties_Insert
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
CREATE TRIGGER dbo.Trg_RegisterProperties_Insert
   ON  dbo.RegisterProperties
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
		INSERT INTO [dbo].[RegisterProperties_history]
           ([UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,[VersionNum]
           ,[PeriodIdentifierID]
           ,[OperationType]
           ,[UserActionID]
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName])
		SELECT  [UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,[VersionNum]
           ,1
           ,NULL
           ,NULL
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName]
		FROM INSERTED
END
GO
