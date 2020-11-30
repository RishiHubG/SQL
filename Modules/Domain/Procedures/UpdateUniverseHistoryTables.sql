 USE JUNK
 GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.UpdateUniverseHistoryTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		INSERT HISTORICAL DATA IN Universe_history,UniverseProperties_history,UniversePropertiesXref_history
USAGE:        		EXEC dbo.UpdateUniverseHistoryTables @UniverseID =1,@versionNum = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.UpdateUniverseHistoryTables
@UniverseID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON; 
		
		DECLARE @PeriodIdentifierID INT = 1

		INSERT INTO [dbo].[Universe_history]
				   ([UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum]
				   ,[PeriodIdentifierID]
				   ,[OperationType]
				   ,[UserActionID]
				   ,[UniverseID]
				   ,[Name]
				   ,[FrameworkID]
				  -- ,[UniverseID]
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
				   ,[UniverseID]
				   ,[Name]
				   ,[FrameworkID]
				  -- ,[UniverseID]
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties]
		FROM dbo.Universe R
		WHERE UniverseID = @UniverseID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[Universe_history] WHERE [UniverseID]=R.[UniverseID] AND Name=R.NAME AND VersionNum = @VersionNum)

		INSERT INTO [dbo].[UniverseProperties_history]
           ([UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,[VersionNum]
           ,[PeriodIdentifierID]
           ,[OperationType]
           ,[UserActionID]
           ,[UniversePropertyID]
           ,[UniverseID]
           ,[PropertyName],
		   [JSONType])
		SELECT  [UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,@VersionNum
           ,@PeriodIdentifierID
           ,NULL
           ,NULL
           ,[UniversePropertyID]
           ,[UniverseID]
           ,[PropertyName],
		   [JSONType]
		FROM dbo.UniverseProperties R
		WHERE UniverseID = @UniverseID
			  AND NOT EXISTS(SELECT 1 FROM [dbo].[UniverseProperties_history] WHERE [UniverseID]=R.[UniverseID] AND UniversePropertyID=R.UniversePropertyID AND VersionNum = @VersionNum)

    	INSERT INTO [dbo].[UniversePropertiesXref_history]
					([UserCreated]
					,[DateCreated]
					,[UserModified]
					,[DateModified]
					,[VersionNum]
					,[PeriodIdentifierID]
					,[OperationType]
					,[UserActionID]
					,[UniversePropertiesXrefID]
					,[UniverseID]
					,[UniversePropertyID]
					,[PropertyName]
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
			,[UniversePropertiesXrefID]
			,[UniverseID]
			,[UniversePropertyID]
			,[PropertyName]
			,[IsRequired]
			,[IsActive]
		FROM dbo.UniversePropertiesXref R
		WHERE UniverseID = @UniverseID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[UniversePropertiesXref_history] WHERE [UniverseID]=R.[UniverseID] AND UniversePropertyID=R.UniversePropertyID AND VersionNum = @VersionNum)


		UPDATE dbo.Universe_history SET PeriodIdentifierID = 0 WHERE UniverseID = @UniverseID AND VersionNum < @VersionNum		
		UPDATE dbo.UniverseProperties_history SET PeriodIdentifierID = 0 WHERE UniverseID = @UniverseID AND VersionNum < @VersionNum
		UPDATE dbo.UniversePropertiesXref_history SET PeriodIdentifierID = 0 WHERE UniverseID = @UniverseID AND VersionNum < @VersionNum

END
GO
