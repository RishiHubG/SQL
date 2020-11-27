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
DESCRIPTION:		
USAGE:        		EXEC dbo.UpdateAssessmentHistoryTables @RegisterID =1,@versionNum = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.UpdateAssessmentHistoryTables
@RegisterID INT,
@versionNum INT
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
				   ,@versionNum
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
		FROM dbo.Registers
		WHERE RegisterID = @RegisterID

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
           ,@versionNum
           ,1
           ,NULL
           ,NULL
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName]
		FROM dbo.RegisterProperties
		WHERE RegisterID = @RegisterID

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
			,@versionNum
			,1
			,NULL
			,NULL
			,[RegistersPropertiesXrefID]
			,[RegisterID]
			,[RegisterPropertyID]
			,[PropertyName]
			,[IsRequired]
			,[IsActive]
		FROM dbo.RegistersPropertiesXref
		WHERE RegisterID = @RegisterID
END
GO
