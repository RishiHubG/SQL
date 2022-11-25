SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetAuditTrailByType
CREATION DATE:      2022-11-04
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.GetAuditTrailByType  @EntityID=1442,
											@EntityTypeID=0,
											@ParentEntityID=1,
											@ParentEntityTypeID=0,
											@StartDate = '2022-08-15',
											@EndDate = '2022-08-31',
											@UserLoginID = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/
 
CREATE OR ALTER PROCEDURE [dbo].[GetAuditTrailByType]
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
			
			DECLARE @FrameworkID INT, @RegisterName VARCHAR(500), @FrameworkName NVARCHAR(1000), @RegisterID INT
			DECLARE @SQL VARCHAR(MAX)
			DECLARE @TBL_ID TABLE(ID INT IDENTITY(1,1),EntityID INT, RegisterID INT,FrameWorkID INT)
						
			
			IF @EntityTypeID = 0	 --For Single Entity
				SELECT @RegisterID = R.registerid,
					   @FrameworkID = F.FrameworkID,
					   @FrameworkName =F.NAME,
					   @RegisterName = R.name
				FROM dbo.Registers R 
					 INNER JOIN dbo.Frameworks F ON F.FrameworkID = R.frameworkid
				WHERE registerid = @ParentEntityID;
			IF @EntityTypeID = 3	--For Register
				SELECT @RegisterID = R.registerid,
					   @FrameworkID = F.FrameworkID,
					   @FrameworkName =F.NAME,
					   @RegisterName = R.name
				FROM dbo.Registers R 
					 INNER JOIN dbo.Frameworks F ON F.FrameworkID = R.frameworkid
				WHERE registerid = @EntityID;
			ELSE IF @EntityTypeID = 2	--For UNIVERSE
				SELECT @RegisterID = R.registerid,
					   @FrameworkID = F.FrameworkID,
					   @FrameworkName = F.NAME,
					   @RegisterName = R.NAME	   
				FROM dbo.Registers R 
					 INNER JOIN dbo.Frameworks F ON F.FrameworkID = R.frameworkid
				WHERE universeid = @EntityID;

			DECLARE @TableName VARCHAR(500) 
			DECLARE @TableName_Data VARCHAR(500) 
			
			SELECT @TableName = Name
			FROM dbo.Frameworks 
			WHERE FrameworkID = @FrameworkID

			IF @TableName IS NULL
			BEGIN
				PRINT '_DATA TABLE NOT AVAILABLE!!'
				RETURN
			END

			IF @EntityTypeID = 0  --For Single Entity
			BEGIN			 
				
				INSERT INTO @TBL_ID (EntityID,RegisterID,FrameWorkID)
					VALUES(@EntityID, @RegisterID, @FrameworkID);
				 
			END
			ELSE IF @EntityTypeID = 2   --For UNIVERSE
			BEGIN
				
				DECLARE @RegisterList VARCHAR(MAX)

				--For All registers under the universe
				SELECT @RegisterList = STRING_AGG(RegisterID,',')					 
				FROM dbo.Registers 
				WHERE universeid = @EntityID;
				 
				SET @TableName_Data = CONCAT(@TableName,'_data_history'); 
				SET @SQL = CONCAT('SELECT DISTINCT ID,RegisterID,FrameworkID FROM ',@TableName_Data,' WHERE RegisterID IN (',@RegisterList,') AND DateModified BETWEEN ''',@StartDate,''' AND ''', @EndDate,'''')
				
				INSERT INTO @TBL_ID (EntityID,RegisterID,FrameworkID)
					EXEC(@SQL);

				UPDATE 	@TBL_ID SET FrameWorkID = @FrameworkID;
			END
			ELSE IF @EntityTypeID = 3 --For Register
			BEGIN
				SET @TableName_Data = CONCAT(@TableName,'_data_history'); 
				SET @SQL = CONCAT('SELECT DISTINCT ID,RegisterID,FrameworkID FROM ',@TableName_Data,' WHERE RegisterID =',@RegisterID,' AND	DateModified BETWEEN ''',@StartDate,''' AND ''', @EndDate,'''')
				
				INSERT INTO @TBL_ID (EntityID,RegisterID,FrameworkID)
					EXEC(@SQL);

				UPDATE 	@TBL_ID SET FrameWorkID = @FrameworkID;
			END

			 IF NOT EXISTS (SELECT 1 FROM dbo.AuditTrailColumns WHERE TableName = CONCAT(@TableName,'_data_history') AND TableType=1 AND ToInclude=2)
			 BEGIN
				RAISERROR('No Columns Available to Audit!!',16,1);
				PRINT 'No Columns Available to Audit!!'
				RETURN
			 END
			
			--TABLE TO STORE AUDIT TRAIL RESULTS IN THE CHILD PROCEDURE
			CREATE TABLE #AuditTrailData(RegisterID INT, FrameworkID INT, RegisterName VARCHAR(500), FrameworkName NVARCHAR(1000),ID INT, Column_Name VARCHAR(500),StepItemName VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX),Name NVARCHAR(MAX),DisplayName NVARCHAR(MAX))
			DECLARE @ID INT
			--SELECT * FROM @TBL_ID
			--RETURN
			WHILE EXISTS(SELECT 1 FROM @TBL_ID)
			BEGIN
				
				SELECT @ID = MIN(ID) FROM @TBL_ID;

				SELECT @EntityID = EntityID,
					   @RegisterID = RegisterID,
					   @FrameworkID = FrameworkID
				FROM @TBL_ID 
				WHERE ID = @ID;

				EXEC [dbo].[GetAuditTrail]      @EntityID = @EntityID,
												@EntityTypeID = @EntityTypeID,
												@ParentEntityID = @ParentEntityID,
												@ParentEntityTypeID = @ParentEntityTypeID,											
												@StartDate = @StartDate,
												@EndDate = @EndDate,
												@UserLoginID = @UserLoginID,
												@MethodName = @MethodName;
			
				UPDATE #AuditTrailData
					SET RegisterID = CASE WHEN RegisterID IS NULL THEN @RegisterID ELSE RegisterID END,
						FrameworkID = CASE WHEN FrameworkID IS NULL THEN @FrameworkID ELSE FrameworkID END;

				DELETE FROM @TBL_ID WHERE ID = @ID;

			 END

			 UPDATE A
				SET RegisterName = (SELECT Name FROM dbo.Registers WHERE registerID = A.registerID),
					FrameworkName = (SELECT Name FROM dbo.Frameworks WHERE FrameworkID = A.FrameworkID)
			FROM #AuditTrailData A;

			--UPDATE CONTACT'S NAME & DISPLAYNAME
			UPDATE A
				SET Name = Usr.Name,
					DisplayName = Ct.DisplayName
			FROM #AuditTrailData A
				INNER JOIN dbo.ContactInst_History Hist ON Hist.HistoryID = A.NewHistoryID
				INNER JOIN dbo.Contact Ct ON CT.ContactID = Hist.ContactId
				INNER JOIN dbo.AUser Usr ON Usr.ContactID = CT.ContactID
			WHERE A.Column_Name = 'ContactId';

			SELECT FrameworkName, RegisterName,Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue,
				   Name, DisplayName
			FROM #AuditTrailData
			ORDER BY OldHistoryID;
	 
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

