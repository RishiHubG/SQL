 USE JUNK
 GO 

 DROP TRIGGER IF EXISTS dbo.Trg_RegistersPropertiesXref_Insert
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
CREATE TRIGGER dbo.Trg_RegistersPropertiesXref_Insert
   ON  dbo.RegistersPropertiesXref
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
		INSERT INTO [dbo].[RegistersPropertiesXref_history]
						   ([UserCreated]
						   ,[DateCreated]
						   ,[UserModified]
						   ,[DateModified]
						   ,[VersionNum]
						   ,[PeriodIdentifierID]
						   ,[OperationType]
						   ,[UserActionID]
						   ,[RegistersPropertiesXrefID]
						   ,[RegisterID]
						   ,[RegisterPropertyID]
						   ,[PropertyName]
						   ,[IsRequired]
						   ,[IsActive])
		SELECT [UserCreated]
			,[DateCreated]
			,[UserModified]
			,[DateModified]
			,[VersionNum]
			,1
			,NULL
			,NULL
			,[RegistersPropertiesXrefID]
			,[RegisterID]
			,[RegisterPropertyID]
			,[PropertyName]
			,[IsRequired]
			,[IsActive]
		FROM INSERTED
END
GO
