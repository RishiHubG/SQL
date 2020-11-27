 USE JUNK
 GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.UpdateAssessmentHistoryTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		INSERT HISTORICAL DATA IN Registers_history,RegisterProperties_history,RegistersPropertiesXref_history
USAGE:        		EXEC dbo.UpdateAssessmentHistoryTables @RegisterID =1,@versionNum = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.UpdateAssessmentHistoryTables
@RegisterID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON; 
		
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
				   ,@VersionNum
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
           ,[PropertyName])
		SELECT  [UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,@VersionNum
           ,1
           ,NULL
           ,NULL
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName]
		FROM dbo.RegisterProperties R
		WHERE RegisterID = @RegisterID
			  AND NOT EXISTS(SELECT 1 FROM [dbo].[RegisterProperties_history] WHERE [RegisterID]=R.[RegisterID] AND RegisterPropertyID=R.RegisterPropertyID AND VersionNum = @VersionNum)

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
			,@VersionNum
			,1
			,NULL
			,NULL
			,[RegistersPropertiesXrefID]
			,[RegisterID]
			,[RegisterPropertyID]
			,[PropertyName]
			,[IsRequired]
			,[IsActive]
		FROM dbo.RegistersPropertiesXref R
		WHERE RegisterID = @RegisterID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[RegistersPropertiesXref_history] WHERE [RegisterID]=R.[RegisterID] AND RegisterPropertyID=R.RegisterPropertyID AND VersionNum = @VersionNum)
END
GO
