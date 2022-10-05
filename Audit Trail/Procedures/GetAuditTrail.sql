SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetAuditTrail
CREATION DATE:      2022-08-30
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.GetAuditTrail  @EntityID=1442,
											@EntityTypeID=0,
											@ParentEntityID=1,
											@ParentEntityTypeID=0,
											@StartDate = '2022-08-15',
											@EndDate = '2022-08-31',
											@UserLoginID = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/
 
CREATE OR ALTER PROCEDURE [dbo].[GetAuditTrail]
@EntityID INT,
@EntityTypeID INT,
@ParentEntityID INT,
@ParentEntityTypeID INT,
@StartDate DATETIME2(6),
@EndDate DATETIME2(6),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL,
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	
	IF @EntityID IS NULL 
		RAISERROR ('Invalid Paramters, Please re-try!!',16,1)

	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN
			
			DECLARE @FrameworkID INT = (SELECT frameworkid FROM Registers WHERE registerid = @ParentEntityID)	
			DECLARE @TableName VARCHAR(500) 

			SELECT @TableName = Name
			FROM dbo.Frameworks 
			WHERE FrameworkID = @FrameworkID

			IF @TableName IS NULL
			BEGIN
				PRINT '_DATA TABLE NOT AVAILABLE!!'
				RETURN
			END

			 IF NOT EXISTS (SELECT 1 FROM dbo.AuditTrailColumns WHERE TableName = CONCAT(@TableName,'_data_history') AND TableType=1 AND ToInclude=2)
			 BEGIN
				RAISERROR('No Columns Available to Audit!!',16,1);
				PRINT 'No Columns Available to Audit!!'
				RETURN
			 END

			CREATE TABLE #AuditTrailData(ID INT, Column_Name VARCHAR(500),StepItemName VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))
			
			INSERT INTO #AuditTrailData (ID,Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)
			EXEC [dbo].[GetAuditTrailData]  @EntityID = @EntityID,
											@FrameworkID= @FrameworkID,
											@TableID = 1,	--DYNAMIC
											@TableName = @TableName,											
											@StartDate = @StartDate,
											@EndDate = @EndDate,
											@UserLoginID = @UserLoginID,
											@MethodName = @MethodName
			
			
			--FOR AUDITING STATIC TABLES
			SELECT DISTINCT TableName
				INTO #TMP_StaticTablesAudit
			FROM dbo.AuditTrailColumns WHERE TableType=2 AND ToInclude=1;

			 
			WHILE EXISTS(SELECT 1 FROM #TMP_StaticTablesAudit)
			BEGIN
				
				SELECT TOP 1 @TableName = TableName FROM #TMP_StaticTablesAudit;

				INSERT INTO #AuditTrailData (ID,Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)
				EXEC [dbo].[GetAuditTrailData]  @EntityID = @EntityID,
												@FrameworkID= @FrameworkID,
												@TableID = 0,	--STATIC
												@TableName = @TableName,											
												@StartDate = @StartDate,
												@EndDate = @EndDate,
												@UserLoginID = @UserLoginID,
												@MethodName = @MethodName
				
				DELETE FROM #TMP_StaticTablesAudit WHERE TableName = @TableName;

			END

			--FOR AUDITING EntityChildLinkFramework_history-------------------------------------------------			
				DECLARE @OldValue NVARCHAR(MAX),@NewValue NVARCHAR(MAX), @OperationType VARCHAR(50),@DateModified datetime2(6),@DatecCreated datetime2(6)
				
				SELECT @OldValue = FR.Name,
					   @NewValue = CONCAT(FR.NAME,'_data'),
					   @OperationType = hist.OperationType,
					   @DatecCreated = hist.DateCreated,
					   @DateModified = hist.DateModified
				FROM dbo.EntityChildLinkFramework_history hist
					 INNER JOIN dbo.Frameworks FR ON FR.FrameworkID = hist.ToFrameWorkId
				WHERE FromFrameworkId = @FrameworkID
					  AND FromEntityId = @EntityID

				IF @OldValue IS NULL
					SELECT @OldValue = FR.Name,
						   @NewValue = CONCAT(FR.NAME,'_data'),
						   @OperationType = hist.OperationType,
						   @DatecCreated = hist.DateCreated,
						   @DateModified = hist.DateModified
					FROM dbo.EntityChildLinkFramework_history hist
						 INNER JOIN dbo.Frameworks FR ON FR.FrameworkID = hist.FromFrameworkId
					WHERE ToFrameWorkId = @FrameworkID
						  AND ToEntityid = @EntityID

				IF @OperationType = 'INSERT' 
					SET @DateModified = @DatecCreated	 
								
					INSERT INTO #AuditTrailData (Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)
						SELECT 'EntityChildLinkFramework_history',
								@OperationType,NULL,NULL,@DateModified,NULL,
								@OldValue, @NewValue
				-------------------------------------------------------------------------------------------------

			SELECT ID,Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue
			FROM #AuditTrailData;
	 
		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

				DECLARE @vEntityID VARCHAR(10) = @EntityID
				 

				IF @EntityID IS NULL				
					SET @vEntityID = 'NULL'
				 
				 
				SET @Params = CONCAT(',@UserLoginID=',@UserLoginID,',@EntityID=',@EntityID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,',@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID)
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			--PRINT @PARAMS

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		 

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH		 

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

				DECLARE @v1EntityID VARCHAR(10) = @EntityID
				 

				IF @EntityID IS NULL				
					SET @v1EntityID = 'NULL'
 
				SET @Params = CONCAT(',@UserLoginID=',@UserLoginID,',@EntityID=',@EntityID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,',@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID)
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage

			SELECT @ErrorMessage AS ErrorMessage
END CATCH

		--DROP TEMP TABLES--------------------------------------	
		 DROP TABLE IF EXISTS #TMP_INSERT
		 DROP TABLE IF EXISTS #TMP_DATA_KEYNAME
		 DROP TABLE IF EXISTS  #TMP_INSERT
		 DROP TABLE IF EXISTS #TMP_DATA_MultiKeyName
		 DROP TABLE IF EXISTS #TMP_MULTI
		 DROP TABLE IF EXISTS #TMP_Frameworks_ExtendedValues
		 --------------------------------------------------------
END

