
/****** Object:  StoredProcedure [dbo].[SaveCustomViewJSONData]    Script Date: 3/2/2022 1:19:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.SaveCustomViewJSONData
CREATION DATE:      2021-10-08
AUTHOR:             Prashanthi
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveCustomViewJSONData   @UserLoginID=100,
													 @inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
1		  2022-02-06			Rishi Nayar				ADDED NEW PROCEDURE "SaveFilterExpression" TO BUILD FILTER EXPRESSION
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[SaveCustomViewJSONData]
@InputJSON		VARCHAR(MAX),
@UserLoginID	INT, 
@MethodName		NVARCHAR(200)=NULL,
@LogRequest		BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @UserID INT
		
	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	
	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @UTCDATE DATETIME2(3) = GETUTCDATE()
	DECLARE @FixedColumns VARCHAR(1000) 
	DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX),@OperationType VARCHAR(50),@CurrentDate DATETIME2(3) =  GETUTCDATE()
	DECLARE @Id INT , @jsonform NVARCHAR(MAX),@linkapikey NVARCHAR(255) , @Searchgrid NVARCHAR(MAX), @Columnorder NVARCHAR(MAX),@Properties NVARCHAR(MAX),@orderid INT,@stepItemName NVARCHAR(2000),@stepItemkey NVARCHAR(2000)
	,@orderby INT,@Isselected BIT

 
	DROP TABLE IF EXISTS #order

	DROP TABLE IF EXISTS #TMP_INSERT_order
 
	DROP TABLE IF EXISTS #TMP_ALLSTEPS_order 


	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 
	
	 
		;WITH CTE
		AS
		(
		SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.OBJECT_ID AS ObjectID,
			   TAB.pos,
			   T.StringValue,	
			   CAST(NULL AS VARCHAR(500)) AS KeyName,			   
				ROW_NUMBER()OVER(PARTITION BY T.Element_ID,T.Name ORDER BY TAB.pos DESC) AS RowNum
		 FROM #TMP_ALLSTEPS T
			  OUTER APPLY dbo.[FindPatternLocation](T.Name,'.')TAB	 
		 WHERE Parent_ID = 0
		)
		
		SELECT *
			INTO #TMP_DATA_KEYNAME
		FROM CTE
		WHERE RowNum = 1

		UPDATE #TMP_DATA_KEYNAME
			SET KeyName = SUBSTRING(Name,Pos+1,len(Name))
		WHERE Pos > 0	 	 
		
		
		 SELECT TD.Element_ID,
				TD.Name AS ColumnName,
				CAST(TD.StringValue AS VARCHAR(MAX)) AS StringValue,
				Parent_ID
			INTO #TMP_INSERT1
		 FROM #TMP_ALLSTEPS	TD 
		 WHERE td.ValueType NOT IN ('Object','array')
		 and  Parent_ID  in (Select  OBJECT_ID FROM #TMP_ALLSTEPS where Name is NOT NULL)		  

		
		SELECT @Columnorder = columns FROM OpenJson(@InputJson)
		WITH(columns NVARCHAR(MAX) AS JSON) 
	  
		 --SELECT *
		 --	INTO #TMP_ALLSTEPS_order
		 --FROM dbo.HierarchyFromJSON(@Columnorder) 
	 
--SEPARATE OUT CONTACT LIST
	;WITH CTE_order
	AS
	(		
		SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.OBJECT_ID AS ObjectID,			   
			   T.StringValue,
			   1 as Lvl
		 FROM #TMP_ALLSTEPS T			  
		 WHERE Name ='columns'

		 UNION ALL

		 SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.OBJECT_ID AS ObjectID,			   
			   T.StringValue,
			   C.Lvl+1
		 FROM CTE_order C
			  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
	)

	SELECT *
		INTO #TMP_ALLSTEPS_order
	FROM CTE_order

	 DELETE T FROM #TMP_INSERT1 T WHERE EXISTS(SELECT 1 FROM #TMP_ALLSTEPS_order WHERE Element_ID = T.Element_ID)

	select * into #TMP_INSERT_order from #TMP_ALLSTEPS_order

	DECLARE @Name NVARCHAR(2000),@EntityTypeId INT,@EntityId INT,@ParentEntityTypeId INT,@ParentEntityId INT,@viewType INT,@viewId INT
	SELECT @Name = viewName ,@EntityTypeId = EntityTypeId,@EntityId=EntityId,@ParentEntityTypeId=ParentEntityTypeId,@ParentEntityId=ParentEntityId,@viewType=viewType
	,@viewId= viewId
	FROM OpenJson(@InputJson)
	WITH (
		viewName nvarchar(255) ,
		EntityTypeId INT,
		EntityId INT,
		ParentEntityTypeId INT,
		ParentEntityId INT,
		viewId INT,
		viewType INT)

		  CREATE TABLE #order(StepItemkey NVARCHAR(255),Stepitemname NVARCHAR(255),orderby INT)
	 
		 WHILE EXISTS(SELECT 1 FROM #TMP_INSERT_order)
		 BEGIN
			SELECT  @orderid = (SELECT MIN(Parent_ID) FROM #TMP_INSERT_order)
		
			SELECT @stepItemName = Stringvalue FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and name = 'colName'
			SELECT @stepItemkey = Stringvalue FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and name = 'colId'
			SELECT @orderby = ISNULL(Stringvalue,0) FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and name = 'orderid' 
			SELECT @Isselected = ISNULL(Stringvalue,0) FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and name = 'isSelected' 
	 
			IF @Isselected = '1' OR  @Isselected = 'true' 
				INSERT INTO #order
				SELECT @stepItemkey,@stepItemName,@orderby

			DELETE FROM #TMP_INSERT_order where Parent_ID = @orderid

		 END 

		IF @ViewId = -1
		SET @OperationType ='INSERT'
		ELSE  
	    SET @OperationType ='UPDATE'
		
	BEGIN TRAN
		

		IF @OperationType ='INSERT'
		BEGIN	
			IF @viewType= 3
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM Customviews where EntityId = @EntityId and EntityTypeId = @EntityTypeId and ParentEntityId = @ParentEntityId and ParentEntityTypeId= @ParentEntityTypeId
									AND usercreated = @userId and viewType= 3)
				BEGIN
					INSERT INTO Customviews(UserCreated,DateCreated,UserModified,DateModified,ViewName,ViewType,EntityTypeId,EntityId,ParentEntityTypeId,ParentEntityId)
					SELECT @UserID,@UTCDATE,@UserID,@UTCDATE,@Name,@viewType,@EntityTypeId,@EntityId,@ParentEntityTypeId,@ParentEntityId

					SELECT @viewid = SCOPE_IDENTITY()
				END
				ELSE
					SELECT @viewId = viewId FROM Customviews where EntityId = @EntityId and EntityTypeId = @EntityTypeId and ParentEntityId = @ParentEntityId and ParentEntityTypeId= @ParentEntityTypeId
									AND usercreated = @userId  and viewType= 3
			END
			ELSE IF @viewType= 4
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM Customviews where EntityId = @EntityId and EntityTypeId = @EntityTypeId and ParentEntityId = @ParentEntityId and ParentEntityTypeId= @ParentEntityTypeId
									AND viewType= 4)
				BEGIN
					INSERT INTO Customviews(UserCreated,DateCreated,UserModified,DateModified,ViewName,ViewType,EntityTypeId,EntityId,ParentEntityTypeId,ParentEntityId)
					SELECT @UserID,@UTCDATE,@UserID,@UTCDATE,@Name,@viewType,@EntityTypeId,@EntityId,@ParentEntityTypeId,@ParentEntityId

					SELECT @viewid = SCOPE_IDENTITY()
				END
				ELSE
					SELECT @viewId = viewId FROM Customviews where EntityId = @EntityId and EntityTypeId = @EntityTypeId and ParentEntityId = @ParentEntityId and ParentEntityTypeId= @ParentEntityTypeId
									 and viewType= 4
			END
			ELSE
			BEGIN
				INSERT INTO Customviews(UserCreated,DateCreated,UserModified,DateModified,ViewName,ViewType,EntityTypeId,EntityId,ParentEntityTypeId,ParentEntityId)
				SELECT @UserID,@UTCDATE,@UserID,@UTCDATE,@Name,@viewType,@EntityTypeId,@EntityId,@ParentEntityTypeId,@ParentEntityId

				SELECT @viewid = SCOPE_IDENTITY()
			END

			
		END
		ELSE IF @OperationType ='UPDATE'
		BEGIN
			UPDATE Customviews
			SET ViewName = @Name
			,ViewType = @viewType
			,UserModified = @UserID
			,DateModified = @UTCDATE
			WHERE ViewId= @viewId
		END

		IF EXISTS (SELECT 1 FROM Customviews_columnorder where viewid = @ViewId)
			DELETE FROM Customviews_columnorder where viewid = @ViewId

		INSERT INTO Customviews_columnorder(
		UserCreated	     ,
		DateCreated	     ,
		UserModified	 ,
		DateModified	 ,
		ViewId			 ,
		StepItemName	 ,
		StepItemkey		 ,
		Orderby			 
		)
		SELECT @UserID,@UTCDATE,@UserID,@UTCDATE,@ViewId,Stepitemname,StepItemkey,orderby
		FROM #order

		--CALL SAVE FILTER===============================================================================================================================
		IF ISNULL(@InputJSON,'') <> ''
			EXEC dbo.SaveFilterExpression @InputJSON = @InputJSON, @UserLoginID = @UserLoginID, @MethodName = @MethodName, @LogRequest = @LogRequest
		--===============================================================================================================================================
		
		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=',@viewId ) 
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			--PRINT @PARAMS
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		COMMIT

		SELECT NULL AS ErrorMessage

		SELECT @viewId  AS Id
		

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=',@viewId )
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
		 --------------------------------------------------------
END
