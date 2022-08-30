SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetAuditTrailData
CREATION DATE:      2022-08-30
AUTHOR:             Rishi Nayar
DESCRIPTION:		USED IN GetAuditTrail
USAGE:          	EXEC dbo.[GetAuditTrailData] @TableID =1,
												@EntityID=1442,
												@EntityTypeID=0,
												@ParentEntityID=1,
												@ParentEntityTypeID=0,
												@StartDate = '2022-08-15',
												@EndDate = '2022-08-31',
												@UserLoginID = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/
 
CREATE OR ALTER PROCEDURE [dbo].[GetAuditTrailData]
@TableID INT,
@EntityID INT,
@EntityTypeID INT,
@ParentEntityID INT,
@ParentEntityTypeID INT,
@StartDate DATETIME2(6),
@EndDate DATETIME2(6),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL
AS
BEGIN
 
	SET NOCOUNT ON; 

	IF @EntityID IS NULL 
		RAISERROR ('Invalid Paramters, Please re-try!!',16,1)

 

		DECLARE @SQL NVARCHAR(MAX) 
		DECLARE @OperationType VARCHAR(50)
		DECLARE @TableName VARCHAR(500) 
		CREATE TABLE #TMP(ID INT IDENTITY(1,1), COLUMN_NAME VARCHAR(500), Col NVARCHAR(MAX), DATA_TYPE VARCHAR(500))

	IF @TableID = 1 --DYNAMIC
	BEGIN

	DECLARE @FrameworkID INT = (SELECT frameworkid FROM Registers WHERE registerid = @ParentEntityID)	

	SELECT @TableName = Name
	FROM dbo.Frameworks 
	WHERE FrameworkID = @FrameworkID

	IF @TableName IS NULL
	BEGIN
		PRINT '_DATA TABLE NOT AVAILABLE!!'
		RETURN
	END

			DECLARE @TableName_StepItems VARCHAR(500) = CONCAT(@TableName,'_FrameworkStepItems');
			DECLARE @TableName_Data VARCHAR(500) = CONCAT(@TableName,'_data_history'); 

			INSERT INTO #TMP(COLUMN_NAME,Col,DATA_TYPE)
				SELECT COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
								DATA_TYPE
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = @TableName_Data
				AND COLUMN_NAME NOT IN ('FrameworkID','HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid','PeriodIdentifier','OperationType');

	END
	ELSE -- STATIC
	BEGIN
			SET @TableName_Data = 'ContactInst_history';

			INSERT INTO #TMP(COLUMN_NAME,Col,DATA_TYPE)
				SELECT COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
								DATA_TYPE
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = @TableName_Data
				AND COLUMN_NAME IN ('RoleTypeID','Notify','OperationType');

	END
		
			--==========================================================================================	
					

					DECLARE @strDT VARCHAR(500) = 'CONVERT(NVARCHAR(MAX),<ColName>,20)'
					
					UPDATE #TMP
						SET COL = REPLACE(Col,COLUMN_NAME,REPLACE(@strDT,'<ColName>', COLUMN_NAME))
					WHERE DATA_TYPE = 'datetime'
					 
					UPDATE #TMP
						SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
					WHERE DATA_TYPE IN('decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'LAG',' CAST(LAG')
					WHERE DATA_TYPE IN('decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
					WHERE DATA_TYPE IN('decimal','bigint','int');
					 
						 
						SET @SQL = 'SELECT ID, COLUMN_NAME,tab.OldHistoryID,tab.NewHistoryID,tab.DateModified, DATA_TYPE,tab.OldValue,tab.NewValue
									FROM #TMP
										 CROSS APPLY(SELECT TOP 100 PERCENT HistoryID AS NewHistoryID,LAG(HISTORYID)OVER(ORDER BY HISTORYID) AS OldHistoryID,
																DateModified,''<Column_Name>'' AS ColName, <Col> FROM <TableName> 
																		WHERE ID = <ID> <DateFilter> ORDER BY DateModified
													)TAB
									WHERE COLUMN_NAME = tab.ColName
										--AND column_name=''actualstartDate''
									'

						IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL
							SET @SQL =  REPLACE(@SQL,'<DateFilter>', 'AND DateModified BETWEEN ''<StartDate>'' AND ''<EndDate>''')

						SET @SQL =  REPLACE(@SQL,'<ID>', @EntityID)
						SET @SQL =  REPLACE(@SQL,'<StartDate>', @StartDate)
						SET @SQL =  REPLACE(@SQL,'<EndDate>', @EndDate)
						SET @SQL =  REPLACE(@SQL,'<TableName>', @TableName_Data)

					DROP TABLE IF EXISTS #TMP_SQL;

					SELECT *,
						REPLACE(
								REPLACE(ColString,'<Column_Name>',COLUMN_NAME),
								'<Col>', Col) AS strSQL
						INTO #TMP_SQL
					FROM #TMP
						 CROSS APPLY(VALUES(@SQL))TAB(ColString);	
						 
						 --SELECT STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 --FROM #TMP_SQL
						 DROP TABLE IF EXISTS #TMPHistData;

						 CREATE TABLE #TMPHistData(ID INT, Column_Name VARCHAR(500),StepItemName VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL;

						 SET @Str = CONCAT('INSERT INTO #TMPHistData(ID,Column_Name,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)', @STR)

						 PRINT @STR

						 --INSERT INTO #TMPHistData(ID,Column_Name,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)
							EXEC(@str)	
								
								--DELETE DATA THAT IS NOT REQUIRED
								 DELETE FROM #TMPHistData
								 WHERE OldHistoryID IS NULL --FIRST VALUE OF EACH COLUMN WILL HAVE OldHistoryID AS NULL (DUE TO LAG), DON'T NEED THIS
										 --IGNORE OLDVALUE/NEWVLAUE NULL/EMPTY STRING COMBINATIONS
									    OR ((NULLIF(OldValue,'') IS NULL AND NULLIF(NewValue,'') IS NULL) )
								 
								 IF @TableID = 1 --DYNAMIC
								 BEGIN
									 --FETCH STEPITEMNAME
									 SET @SQL = CONCAT('UPDATE Hist
															SET StepItemName = StepItems.StepItemName
														FROM #TMPHistData Hist
															 INNER JOIN ',@TableName_StepItems,' StepItems ON StepItems.StepItemKey = Hist.Column_Name
															 WHERE StepItems.FrameworkID = ',@FrameworkID
													 )								
									PRINT @SQL
									EXEC(@SQL)
								END

								/*
								 ;WITH CTE
								 AS
								 (
								   SELECT *--, ROW_NUMBER()OVER(PARTITION BY Column_Name,DateModified Order By OldValue) AS RowNum
								   FROM #TMPHistData
								   /* HANDLED IN THE ABOVE DELETE
								   WHERE OldHistoryID IS NOT NULL --FIRST VALUE OF EACH COLUMN WILL HAVE OldHistoryID AS NULL (DUE TO LAG), DON'T NEED THIS
										 --IGNORE OLDVALUE/NEWVLAUE NULL/EMPTY STRING COMBINATIONS
									     AND NOT (NULLIF(OldValue,'') IS NULL AND NULLIF(NewValue,'') IS NULL) 
									*/
								 )
								 SELECT * FROM CTE
								 WHERE ISNULL(OldValue,-1) <> ISNULL(NewValue,-1)
								 ORDER BY NewHistoryID
								*/

								 SELECT * FROM #TMPHistData
								 WHERE ISNULL(OldValue,-1) <> ISNULL(NewValue,-1)
								 ORDER BY NewHistoryID

			 --==========================================================================================
			 
		--DROP TEMP TABLES--------------------------------------	
		 DROP TABLE IF EXISTS #TMP
		 --------------------------------------------------------
END

