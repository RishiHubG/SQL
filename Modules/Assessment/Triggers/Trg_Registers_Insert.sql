 USE JUNK
 GO 

  DROP TRIGGER IF EXISTS dbo.Trg_Registers_Insert
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
CREATE TRIGGER dbo.Trg_Registers_Insert
   ON  dbo.Registers
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
		INSERT INTO [dbo].[Registers_history]
				   ([UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum]
				   ,[PeriodIdentifierID]
				   ,[OperationType]
				   ,[UserActionID]
				   ,[RegisterID]
				   ,[Name]
				   ,[FrameworkID]
				   ,[UniverseID]
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties])
		SELECT [UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum]
				   ,1
				   ,NULL
				   ,NULL
				   ,[RegisterID]
				   ,[Name]
				   ,[FrameworkID]
				   ,[UniverseID]
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties]
		FROM INSERTED
END
GO
