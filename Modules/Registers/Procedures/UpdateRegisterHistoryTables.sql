
/****** Object:  StoredProcedure [dbo].[UpdateregisterHistoryTables]    Script Date: 06/06/2021 11:01:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************************************
OBJECT NAME:        dbo.UpdateRegisterHistoryTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		INSERT HISTORICAL DATA IN Registers_history,RegisterProperties_history,RegisterPropertiesXref_history
USAGE:        		EXEC dbo.UpdateregisterHistoryTables @RegisterID =1,@versionNum = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

Create OR ALTER PROCEDURE [dbo].[UpdateRegisterHistoryTables]
@RegisterID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON; 
		
		DECLARE @PeriodIdentifierID INT = 1

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
				   ,FullSchemaJSON
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
				   ,@VersionNum
				   ,@PeriodIdentifierID
				   ,NULL
				   ,NULL
				   ,[RegisterID]
				   ,FullSchemaJSON
				   ,[Name]
				   ,[FrameworkID]
				   ,[UniverseID]
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties]
		FROM dbo.Registers R
		WHERE RegisterID = @RegisterID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[Registers_history] WHERE [RegisterID]=R.[RegisterID] AND Name=R.NAME AND VersionNum = @VersionNum)

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
           ,[PropertyName]
		   ,[APIKEYName],
		   [JSONType])
		SELECT  [UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,@VersionNum
           ,@PeriodIdentifierID
           ,NULL
           ,NULL
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName]
		   ,[APIKEYName],
		   [JSONType]
		FROM dbo.RegisterProperties R
		WHERE RegisterID = @RegisterID
			  AND NOT EXISTS(SELECT 1 FROM [dbo].[RegisterProperties_history] WHERE [RegisterID]=R.[RegisterID] AND RegisterPropertyID=R.RegisterPropertyID AND VersionNum = @VersionNum)

    	INSERT INTO [dbo].[RegisterPropertiesXref_history]
					([UserCreated]
					,[DateCreated]
					,[UserModified]
					,[DateModified]
					,[VersionNum]
					,[PeriodIdentifierID]
					,[OperationType]
					,[UserActionID]
					,[RegisterPropertiesXrefID]
					,[RegisterID]
					,[RegisterPropertyID]
					,[PropertyName]
					,[APIKEYName]
					,[IsRequired]
					,[IsActive])
		SELECT [UserCreated]
			,[DateCreated]
			,[UserModified]
			,[DateModified]
			,@VersionNum
			,@PeriodIdentifierID
			,NULL
			,NULL
			,[RegisterPropertiesXrefID]
			,[RegisterID]
			,[RegisterPropertyID]
			,[PropertyName]
			,[APIKEYName]
			,[IsRequired]
			,[IsActive]
		FROM dbo.RegisterPropertiesXref R
		WHERE RegisterID = @RegisterID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[RegisterPropertiesXref_history] WHERE [RegisterID]=R.[RegisterID] AND RegisterPropertyID=R.RegisterPropertyID AND VersionNum = @VersionNum)


		UPDATE dbo.Registers_history SET PeriodIdentifierID = 0 WHERE RegisterID = @RegisterID AND VersionNum < @VersionNum		
		UPDATE dbo.RegisterProperties_history SET PeriodIdentifierID = 0 WHERE RegisterID = @RegisterID AND VersionNum < @VersionNum
		UPDATE dbo.RegisterPropertiesXref_history SET PeriodIdentifierID = 0 WHERE RegisterID = @RegisterID AND VersionNum < @VersionNum

END
GO


