USE [VKB_NEW]
GO
/****** Object:  Trigger [dbo].[trg_ContactInst_Insert]    Script Date: 9/21/2022 2:01:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER  [dbo].[trg_ContactInst_Insert]
				ON  [dbo].[ContactInst]
				AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
							
							DECLARE @OperationType VARCHAR(100), @HistoryID INT

							--GET OPERATION TYPE
							IF EXISTS(SELECT 1 FROM INSERTED) AND  NOT EXISTS(SELECT 1 FROM DELETED) --INSERT
								SET @OperationType = 'INSERT'
							ELSE IF EXISTS(SELECT 1 FROM INSERTED) AND  EXISTS(SELECT 1 FROM DELETED) --UPDATE
								SET @OperationType = 'UPDATE'
							ELSE IF NOT EXISTS(SELECT 1 FROM INSERTED) AND EXISTS(SELECT 1 FROM DELETED) --UPDATE
								SET @OperationType = 'DELETE'

							   --UPDATE PeriodIdentifier = 0 FOR ALL PREVIOUS RECORDS
							   UPDATE Hist
									SET [PeriodIdentifier] = 0
								FROM dbo.[ContactInst_history] Hist INNER JOIN Inserted I ON I.ContactInstId = Hist.ContactInstId 							
									
							INSERT INTO dbo.[ContactInst_history]( [ContactInstId], [UserCreated], [DateCreated], [UserModified], [DateModified], [RoleTypeID], [ContactId], [Notify], [FrameworkId], [EntityTypeId], [EntityId],[PeriodIdentifier])
								SELECT  [ContactInstId], [UserCreated], [DateCreated], [UserModified], [DateModified], [RoleTypeID], [ContactId], [Notify], [FrameworkId], [EntityTypeId], [EntityId],1
								FROM INSERTED;	
							
							SELECT @HistoryID = MAX(HistoryID) FROM dbo.[ContactInst_history] Hist INNER JOIN Inserted I ON I.ContactInstId = Hist.ContactInstId;
							
							--UPDATE PeriodIdentifier = 1 FOR THE LATEST RECORD
							UPDATE dbo.[ContactInst_history]
								SET PeriodIdentifier = 1,
									DateModified = GETUTCDATE(),
									OperationType = @OperationType
							WHERE HistoryID = @HistoryID;

END
