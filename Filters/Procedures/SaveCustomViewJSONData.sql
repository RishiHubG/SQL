 
 
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

CREATE OR ALTER  PROCEDURE [dbo].[SaveCustomViewJSONData]
@InputJSON		VARCHAR(MAX),
@UserLoginID	INT, 
@ViewId			INT = -1,
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
	  
		 SELECT *
		 	INTO #TMP_ALLSTEPS_order
		 FROM dbo.HierarchyFromJSON(@Columnorder) 
	 
		
		  SELECT TD.Element_ID,
				TD.Name AS ColumnName,
				CAST(TD.StringValue AS VARCHAR(MAX)) AS StringValue,
				Parent_ID
			 INTO #TMP_INSERT_order
		 FROM #TMP_ALLSTEPS_order	TD 
		 WHERE td.ValueType NOT IN ('Object','array')

		  CREATE TABLE #order(StepItemkey NVARCHAR(255),Stepitemname NVARCHAR(255),orderby INT)
	 
		 WHILE EXISTS(SELECT 1 FROM #TMP_INSERT_order)
		 BEGIN
			SELECT  @orderid = (SELECT MIN(Parent_ID) FROM #TMP_INSERT_order)
		
			SELECT @stepItemName = Stringvalue FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and ColumnName = 'colName'
			SELECT @stepItemkey = Stringvalue FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and ColumnName = 'colId'
			SELECT @orderby = ISNULL(Stringvalue,0) FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and ColumnName = 'orderid' 
			SELECT @Isselected = ISNULL(Stringvalue,0) FROM #TMP_INSERT_order WHERE Parent_ID = @orderid and ColumnName = 'isSelected' 
	 
			IF @Isselected = '1' OR  @Isselected = 'true' 
				INSERT INTO #order
				SELECT @stepItemkey,@stepItemName,@orderby

			DELETE FROM #TMP_INSERT_order where Parent_ID = @orderid

		 END 

		 SELECT @ViewId = Stringvalue FROM #TMP_INSERT1 WHERE ColumnName = 'viewId' 
  
		IF @ViewId = -1
		SET @OperationType ='INSERT'
		ELSE  
	    SET @OperationType ='UPDATE'
		
		DELETE FROM  #TMP_INSERT1 WHERE ColumnName = 'viewId' 

		IF @OperationType ='INSERT'
		BEGIN
	  
			SET @ColumnNames = STUFF
										((SELECT CONCAT(', ',QUOTENAME(ColumnName))
										FROM #TMP_INSERT1 	
										ORDER BY Element_ID
										FOR XML PATH ('')								
										),1,1,'')

			SET @ColumnValues = STUFF
										((SELECT CONCAT(', ',CHAR(39),StringValue,CHAR(39))
										FROM #TMP_INSERT1 
										ORDER BY Element_ID
										FOR XML PATH ('')								
										),1,1,'')

			SET @ColumnNames = CONCAT('Datecreated,UserCreated,datemodified,Usermodified,',@ColumnNames)
			SET @ColumnValues = CONCAT(CHAR(39),@CurrentDate,CHAR(39),',',CHAR(39),@UserID,CHAR(39),',',CHAR(39),@CurrentDate,CHAR(39),',',CHAR(39),@UserID,CHAR(39),',',@ColumnValues)

		END
		ELSE IF @OperationType ='UPDATE'
		BEGIN
			INSERT INTO #TMP_INSERT1(ColumnName,StringValue) 
			SELECT 'Usermodified',CAST(@UserID AS VARCHAR(10))
			UNION
			SELECT 'datemodified', CAST(CONVERT(DATETIME2(3),  @UTCDATE, 120) AS VARCHAR(100)) 

			DECLARE @UpdStr VARCHAR(MAX)

			SET  @UpdStr = STUFF(
								(
								SELECT CONCAT(', ',QUOTENAME(COLUMNNAME),'=',CHAR(39),StringValue,CHAR(39), CHAR(10))
								FROM #TMP_INSERT1 
								FOR XML PATH('')
								),
								1,1,'')
			 
		END

		BEGIN TRAN
		
		IF @OperationType ='INSERT'
		BEGIN
			SET @SQL = CONCAT('INSERT INTO dbo.Customviews (',@ColumnNames,') VALUES(',@ColumnValues,')')
			

			PRINT @SQL		 
		END
		ELSE IF @OperationType ='UPDATE'
		BEGIN
			SET @SQL = CONCAT('UPDATE dbo.Customviews',CHAR(10),' SET ',@UpdStr)
			SET @SQL = CONCAT(@SQL, ' WHERE viewId =', @viewId)
			PRINT @SQL
		END		
		 

		EXEC sp_executesql @SQL	

		IF @OperationType ='INSERT'
			SELECT @viewid = @@IDENTITY

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

		--===============================================================================================================================================
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




