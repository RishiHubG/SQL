USE [VKB_NEW]
GO
/****** Object:  Trigger [dbo].[trg_ContactInst_Insert]    Script Date: 9/5/2022 2:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER TRIGGER  [dbo].[trg_EntityChildLinkFramework_Insert]
				ON  [dbo].[EntityChildLinkFramework]
				AFTER INSERT, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
							
							DECLARE @OperationType VARCHAR(100), @HistoryID INT

							--GET OPERATION TYPE
							IF EXISTS(SELECT 1 FROM INSERTED) AND  NOT EXISTS(SELECT 1 FROM DELETED) --INSERT
								SET @OperationType = 'INSERT'
							ELSE IF NOT EXISTS(SELECT 1 FROM INSERTED) AND  EXISTS(SELECT 1 FROM DELETED) --DELETE
								SET @OperationType = 'DELETE'

							   --UPDATE PeriodIdentifier = 0 FOR ALL PREVIOUS RECORDS
							 --  UPDATE Hist
								--	SET [PeriodIdentifier] = 0
								--FROM dbo.[EntityChildLinkFramework_history] Hist INNER JOIN Inserted I ON I.ContactInstId = Hist.ContactInstId 							
							
							IF @OperationType = 'INSERT'
							INSERT INTO dbo.[EntityChildLinkFramework_history]([ChildEntityId], [UserCreated], [DateCreated], [UserModified], [DateModified], [LinkType], [FromFrameworkId], [FromEntityId], [ToFrameWorkId], [ToEntityid], [apikey], [EntityTypeid],[PeriodIdentifier], OperationType)
								SELECT  [ChildEntityId], [UserCreated], [DateCreated], [UserModified], [DateModified], [LinkType], [FromFrameworkId], [FromEntityId], [ToFrameWorkId], [ToEntityid], [apikey], [EntityTypeid],1,
										@OperationType
								FROM INSERTED;	
							ELSE
							INSERT INTO dbo.[EntityChildLinkFramework_history]([ChildEntityId], [UserCreated], [DateCreated], [UserModified], [DateModified], [LinkType], [FromFrameworkId], [FromEntityId], [ToFrameWorkId], [ToEntityid], [apikey], [EntityTypeid],[PeriodIdentifier], OperationType)
								SELECT  [ChildEntityId], [UserCreated], [DateCreated], [UserModified], [DateModified], [LinkType], [FromFrameworkId], [FromEntityId], [ToFrameWorkId], [ToEntityid], [apikey], [EntityTypeid],0,
										@OperationType
								FROM DELETED;	
							
							--SELECT @HistoryID = MAX(HistoryID) FROM dbo.[EntityChildLinkFramework_history] Hist INNER JOIN Inserted I ON I.ContactInstId = Hist.ContactInstId;
							
							----UPDATE PeriodIdentifier = 1 FOR THE LATEST RECORD
							--UPDATE dbo.[EntityChildLinkFramework_history]
							--	SET PeriodIdentifier = 1,
							--		DateModified = GETUTCDATE(),
							--		OperationType = @OperationType
							--WHERE HistoryID = @HistoryID;

END
