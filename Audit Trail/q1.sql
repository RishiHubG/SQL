--Dev1/AGS@123
USE DEVDB
GO

	SELECT *
	FROM dbo.Frameworks
	WHERE FrameworkID = 335

	SELECT * FROM EntityMetaData

	SELECT * FROM NewAuditFramework_data WHERE ID=335
	SELECT * FROM NewAuditFramework_data_history  WHERE ID=335 ORDER BY DateModified 

	SELECT * FROM Frameworks WHERE frameworkid IN (335)

	SELECT * FROM NewAuditFramework_data WHERE ID=330
	SELECT * FROM NewAuditFramework_FrameworkStepItems
 
	--IF @ParentEntityTypeID = 3
	DECLARE @FrameworkID int = (SELECT frameworkid FROM Registers WHERE registerid = @ParentEntityID)
	DECLARE @TableName VARCHAR(500) 

	SELECT @TableName = CONCAT(Name,'_DATA') ,
		   @VersionNum = VersionNum
	FROM dbo.Frameworks 
	WHERE FrameworkID = @FrameworkID

	SELECT * FROM ContactInst

	ALTER TABLE ContactInst_history ADD  [EntityTypeId] INT, [EntityId] INT

SELECT HistoryID,
		LAG(NAME)OVER(ORDER BY HISTORYID) AS [OldValue.Name],
		name AS NewValue_Name		
FROM NewAuditFramework_data_history  
WHERE ID=335 ORDER BY DateModified 

SELECT CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS [OldValue]', CHAR(10)),*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NewAuditFramework_data_history'
AND COLUMN_NAME NOT IN ('HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid')

DROP TABLE IF EXISTS #TMP

SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
		DATA_TYPE
	INTO #TMP
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NewAuditFramework_data_history'
AND COLUMN_NAME NOT IN ('HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid');

UPDATE #TMP
	SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
WHERE DATA_TYPE IN('datetime', 'decimal');

UPDATE #TMP
	SET COL = REPLACE(Col,'LAG',' CAST(LAG')
WHERE DATA_TYPE IN('datetime', 'decimal');

UPDATE #TMP
	SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
WHERE DATA_TYPE IN('datetime', 'decimal');

SELECT * FROM #TMP

				DECLARE @str VARCHAR(MAX)	
				SET	@str = 			 
						STUFF((
						SELECT  CONCAT(', ',Col, CHAR(10))
						FROM #TMP									 
						ORDER BY ID
						FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
						,1,2,'') 
						
				--PRINT @str
				
				SET @Str = CONCAT('SELECT ', @Str, 'FROM NewAuditFramework_data_history  
												    WHERE ID=335 ORDER BY DateModified '
								  )
				PRINT @str

				EXEC(@Str)
				
				SELECT ID, COLUMN_NAME,
					   tab.DateModified,
					   DATA_TYPE,
					   tab.OldValue,
					   tab.NewValue
				FROM #TMP
					 CROSS APPLY(SELECT TOP 100 PERCENT DateModified,'referencenum' AS ColName, referencenum AS NewValue, LAG(referencenum)OVER(ORDER BY HISTORYID) AS [OldValue]  FROM NewAuditFramework_data_history  
												    WHERE ID=335 ORDER BY DateModified  )TAB
				WHERE COLUMN_NAME = tab.ColName
				ORDER BY ID


				--==========================================================================================	
					
					DECLARE @ID INT = 335
					DROP TABLE IF EXISTS #TMP

					SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
							DATA_TYPE
						INTO #TMP
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'NewAuditFramework_data_history'
					AND COLUMN_NAME NOT IN ('FrameworkID','HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid','PeriodIdentifier','OperationType');

					
					UPDATE #TMP
						SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'LAG',' CAST(LAG')
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');


					--SELECT * FROM #TMP

						DECLARE @SQL VARCHAR(MAX)
						SET @SQL = 'SELECT ID, COLUMN_NAME,tab.DateModified, DATA_TYPE,tab.OldValue,tab.NewValue
									FROM #TMP
										 CROSS APPLY(SELECT TOP 100 PERCENT DateModified,''<Column_Name>'' AS ColName, <Col> FROM NewAuditFramework_data_history  
																		WHERE ID=<ID> ORDER BY DateModified
													)TAB
									WHERE COLUMN_NAME = tab.ColName
									'
						SET @SQL =  REPLACE(@SQL,'<ID>', @ID)

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

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL

						 PRINT @STR

						 EXEC(@str)
			
			 --==========================================================================================



--==========================================================================================	
					 USE VKB_NEW
					GO
					DECLARE @ID INT = 1442
					DROP TABLE IF EXISTS #TMP

					SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
							DATA_TYPE
						INTO #TMP
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'NewAuditFramework_data_history'
					AND COLUMN_NAME NOT IN ('FrameworkID','HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid','PeriodIdentifier','OperationType');

					
					UPDATE #TMP
						SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'LAG',' CAST(LAG')
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');


					--SELECT * FROM #TMP

						DECLARE @SQL VARCHAR(MAX)
						SET @SQL = 'SELECT ID, COLUMN_NAME,tab.HistoryID,tab.DateModified, DATA_TYPE,tab.OldValue,tab.NewValue
									FROM #TMP
										 CROSS APPLY(SELECT TOP 100 PERCENT HistoryID,DateModified,''<Column_Name>'' AS ColName, <Col> FROM NewAuditFramework_data_history  
																		WHERE ID=<ID> ORDER BY DateModified
													)TAB
									WHERE COLUMN_NAME = tab.ColName
										AND column_name=''actualstartDate''
									'
						SET @SQL =  REPLACE(@SQL,'<ID>', @ID)

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

						 CREATE TABLE #TMPHistData(ID INT, Column_Name VARCHAR(500),HistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL

						 PRINT @STR

						 INSERT INTO #TMPHistData(ID,Column_Name,HistoryID,DateModified,Data_Type,OldValue,NewValue)
							EXEC(@str)	
								
								
								 ;WITH CTE
								 AS
								 (
								   SELECT *, ROW_NUMBER()OVER(PARTITION BY Column_Name,DateModified Order By OldValue) AS RowNum
								   FROM #TMPHistData
								 )
								 SELECT * FROM CTE
			
			 --==========================================================================================
			 
			 --operationtype,Notify,RoleTypeID - FOR AUDIT
			 SELECT * FROM ContactInst_history
	
	SELECT * FROM NewAuditFramework_data_history WHERE id=1442
	SELECT * FROM Registers WHERE FRAMEWORKID=6
--==========================================================================================	
						 USE VKB_NEW
						GO
					DECLARE @ID INT = 1442
					DROP TABLE IF EXISTS #TMP

					DECLARE @TableName VARCHAR(500) = 'NewAuditFramework_data_history'

					SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
							DATA_TYPE
						INTO #TMP
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = @TableName
					AND COLUMN_NAME NOT IN ('FrameworkID','HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid','PeriodIdentifier','OperationType');

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

 
						DECLARE @SQL VARCHAR(MAX)
						SET @SQL = 'SELECT ID, COLUMN_NAME,tab.OldHistoryID,tab.NewHistoryID,tab.DateModified, DATA_TYPE,tab.OldValue,tab.NewValue
									FROM #TMP
										 CROSS APPLY(SELECT TOP 100 PERCENT HistoryID AS NewHistoryID,LAG(HISTORYID)OVER(ORDER BY HISTORYID) AS OldHistoryID,
																DateModified,''<Column_Name>'' AS ColName, <Col> FROM <TableName> 
																		WHERE ID=<ID> ORDER BY DateModified
													)TAB
									WHERE COLUMN_NAME = tab.ColName
										--AND column_name=''actualstartDate''
									'
						SET @SQL =  REPLACE(@SQL,'<ID>', @ID)
						SET @SQL =  REPLACE(@SQL,'<TableName>', @TableName)

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

						 CREATE TABLE #TMPHistData(ID INT, Column_Name VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL

						 PRINT @STR

						 INSERT INTO #TMPHistData(ID,Column_Name,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)
							EXEC(@str)	
								
								
								 ;WITH CTE
								 AS
								 (
								   SELECT *--, ROW_NUMBER()OVER(PARTITION BY Column_Name,DateModified Order By OldValue) AS RowNum
								   FROM #TMPHistData
								   WHERE OldHistoryID IS NOT NULL
								 )
								 SELECT * FROM CTE
								 WHERE ISNULL(OldValue,-1) <> ISNULL(NewValue,-1)
								 ORDER BY NewHistoryID
			
			 --==========================================================================================

		

			

			 USE VKB_NEW
			 GO

			  SELECT frameworkid FROM Registers WHERE registerid = 1

 
	SELECT *
	FROM dbo.Frameworks 
	WHERE FrameworkID = 6

	SELECT auditOjectives, auditStatus, actualcompletiondate,actualstartdate,* FROM NewAuditFramework_data_history WHERE ID=1442


	EXEC dbo.GetAuditTrail  @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-08-31',
							@UserLoginID = 1

			
			--DELETE FROM AuditTrailColumns WHERE ColumnNAme =''
		 	SELECT * FROM AuditTrailColumns ORDER BY TABLENAME
			ALTER TABLE AuditTrailColumns ADD SqlString VARCHAR(MAX)
			SELECT * FROM Contact
			SELECT * FROM RoleType

			UPDATE AuditTrailColumns SET SqlString=NULL WHERE id in (5,6)

			UPDATE AuditTrailColumns
				SET SqlString ='UPDATE TMP
									SET NewValue = Cnt.DisplayName
								FROM #TMPHistData TMP
									 INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.OldValue;
		
								UPDATE TMP
									SET NewValue = Cnt.DisplayName
								FROM #TMPHistData TMP
									 INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.NewValue;'
			where TableName = 'ContactInst_history'

			UPDATE AuditTrailColumns
				SET SqlString ='UPDATE TMP
										SET NewValue = RT.Name
									FROM #TMPHistData TMP
										 INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.OldValue;

								UPDATE TMP
										SET NewValue = RT.Name
									FROM #TMPHistData TMP
										 INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.NewValue;'
			where TableName = 'ContactInst_history'
				  AND ColumnNAme ='RoleTypeID'

			UPDATE TMP
				SET NewValue = Cnt.DisplayName
			FROM #TMPHistData TMP
			     INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.OldValue;
		
			UPDATE TMP
				SET NewValue = Cnt.DisplayName
			FROM #TMPHistData TMP
			     INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.NewValue;
		
		UPDATE TMP
				SET NewValue = RT.Name
			FROM #TMPHistData TMP
			     INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.OldValue;

		UPDATE TMP
				SET NewValue = RT.Name
			FROM #TMPHistData TMP
			     INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.NewValue;

			UPDATE AuditTrailColumns SET TableName ='NewAuditFramework_data_history' WHERE TableName ='NewAuditFramework_data'

			INSERT INTO dbo.AuditTrailColumns(TableName,TableType,ColumnName,ToInclude)
				SELECT 'NewAuditFramework_data_history',1,TAB.ColName,2
				FROM (VALUES('FrameworkID'),('HistoryID'),('ID'),('UserCreated'),('DateCreated'),('UserModified'),('DateModified'),('VersionNum'),('registerid'),('PeriodIdentifier'),('OperationType'))
				TAB(ColName)
				WHERE NOT EXISTS(SELECT 1 FROM AuditTrailColumns where TABLENAME = 'NewAuditFramework_data_history' AND ColumnName = TAB.ColName)
				


				SELECT TOP 100 PERCENT HistoryID AS NewHistoryID,LAG(HISTORYID)OVER(ORDER BY HISTORYID) AS OldHistoryID,
																DateModified,'OperationType' AS ColName, OperationType AS NewValue, LAG(OperationType)OVER(ORDER BY HISTORYID) AS OldValue
				FROM ContactInst_history 
				 	WHERE entityid = 1442 AND DateModified BETWEEN '2022-08-15 00:00:00.000000' AND '2022-08-31 00:00:00.000000' ORDER BY DateModified


		UPDATE AuditTrailColumns
		SET SqlString ='UPDATE TMP           SET OldValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.OldValue AND TMP.Column_Name = ''ContactId'';
						UPDATE TMP           SET NewValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.NewValue AND TMP.Column_Name = ''ContactId'';
						UPDATE TMP           SET StepItemName = Hist.OperationType   FROM #TMPHistData TMP            INNER JOIN dbo.ContactInst_History Hist ON Hist.HistoryID = TMP.NewHistoryID AND TMP.Column_Name = ''ContactId'';'
		WHERE ColumnName ='ContactId'

		UPDATE AuditTrailColumns
		SET SqlString ='UPDATE TMP            SET OldValue = RT.Name           FROM #TMPHistData TMP             INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.OldValue AND TMP.Column_Name = ''RoleTypeID'';          
						UPDATE TMP            SET NewValue = RT.Name           FROM #TMPHistData TMP             INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.NewValue AND TMP.Column_Name = ''RoleTypeID'';'
		WHERE ColumnName ='RoleTypeID'


		EXEC dbo.GetAuditTrail     @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-09-14',
							@UserLoginID = 1

EXEC dbo.GetAuditTrail  @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-08-31',
							@UserLoginID = 1

EXEC dbo.GetAuditTrail  @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-09-30',
							@UserLoginID = 1


USE VKB_NEW

--CREATE HIST TABLE & TRIGGER: INSERT/DELETE
SELECT * FROM ENTITYCHILDLINKFRAMEWORK

SELECT * FROM EntityChildLinkFramework_history ORDER BY HistoryID DESC

linktype:
1=child
2=link

if entitytypeid=9
CHECK FRAMEWORKID/ENTITYID

EX: IF VALUES FOUND IN FROM THEN: PICK NEW FRAMEWORKID/ENTITYID VALUES -
OLDVALUE=NAME OF ToFrameWorkId FROM FRAMEWORKS TABLE FOR THIS TOFRAMEWORKID
NEWVALUE=_DATA TABLE OF FOR TOFRAMEWORKID FRAMEWORK, PICK THE NAME

SELECT * FROM EntityChildLinkFramework_history ORDER BY HistoryID DESC

DECLARE @EntityID int=1442, @FrameworkID INT=6
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

SELECT @DateModified, @OldValue, @NewValue,@OperationType


select * from NewAuditComponent_data where id = 2090
EXEC dbo.GetAuditTrail  @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1

select * from EntityChildLinkFramework_history WHERE FROMENTITYID=1442
select * from EntityChildLinkFramework_history order by 1 desc
If Linktype = 1 then Link
If Linktype = 2 - Child

Add Link  Add/Delete Historyid
Add Child

							Add / Delete / 

							Contact-oldValue-NewValue

							Contact - Add / Delete / Modify Datatype = String  ContactName|Roletype|Notify ContactName-Roletype-Notify

							select * from userlogin where active = 1


							SELECT * FROM dbo.AuditTrailColumns 

--==============================================
--CASE 2
IF @EntityTypeID=3=FOR REGISTERS THEN PULL ALLFROM DATA TABLE USING REGISTERID AS FILTER IN _DATA TABLE AND GET AUDIT TRAIL FOR ALL THESE RECORDS
@EntityID=REGISTERID
SELECT frameworkid FROM Registers WHERE registerid = @EntityID
--REGISTERS
EXEC dbo.GetAuditTrail  @EntityID=1,
							@EntityTypeID=3,
							@ParentEntityID=1,
							@ParentEntityTypeID=2,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1

--CASE 3
IF @EntityTypeID=2=FOR UNIVERSE THEN PULL go to registers TO PULL ALL REGISTERS AND THEN SAME PROCESS AS CASE# 2 ABOVE
THIS CAN HAVE MULTIPLE FRAMEWORK AS EACH REGISTER IS TIED TO ONE FRAMEWORK
@EntityID=UNIVERSEID
--For All registers under the universe
SELECT frameworkid, RegisterID FROM Registers WHERE universeid = @EntityID
SELECT frameworkid, RegisterID FROM Registers WHERE universeid = 1

--UNIVERSE
EXEC dbo.GetAuditTrail  @EntityID=1,
							@EntityTypeID=2,
							@ParentEntityID=NULL,
							@ParentEntityTypeID=NULL,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1
--==============================================

			DECLARE @RegisterList VARCHAR(MAX)
			DECLARE @TableName_Data VARCHAR(500),@SQL VARCHAR(MAX)
			DECLARE @TBL_ID TABLE(ID INT, RegisterID INT,FrameWorkID INT)

				--For All registers under the universe
				SELECT @RegisterList = STRING_AGG(RegisterID,',')					 
				FROM dbo.Registers 
				WHERE universeid = 1;
				 
				SET @TableName_Data = 'NewAuditFramework_data_history'; --= --CONCAT(@TableName,'_data_history'); 
				SET @SQL = CONCAT('SELECT ID, RegisterID FROM ',@TableName_Data,' WHERE RegisterID IN (',@RegisterList,') AND DateModified BETWEEN ''',@StartDate,''' AND ''', @EndDate,'''')
				
				INSERT INTO @TBL_ID (ID, RegisterID)
					EXEC(@SQL);

					SELECT * FROM @TBL_ID

SELECT * FROM Registers WHERE registerid = 1--@EntityID
SELECT * FROM Frameworks WHERE FRAMEWORKID = 6
SELECT * FROM NewAuditFramework_data_history where registerid=1

SELECT F.NAME,R.NAME
FROM dbo.Registers R 
	 INNER JOIN dbo.Frameworks F ON F.FrameworkID = R.frameworkid
WHERE registerid = 1--@EntityID

SELECT * FROM Frameworks WHERE FRAMEWORKID = 6
SELECT * FROM NewAuditFramework_data_history where registerid=1


SELECT * FROM NewAuditFramework_data_history where ID=1442

DROP TABLE IF EXISTS #TMP
CREATE TABLE #TMP(ID INT, Column_Name VARCHAR(500),StepItemName VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

INSERT INTO #TMP (ID,Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)

--HANDLES ALL CASES: ADD ENTITYID AS ANOTHER COLUMN?
--CAN LOOP THROUGH CASE 2 & 3
BEGIN

DROP TABLE IF EXISTS #AuditTrailData
CREATE TABLE #AuditTrailData(RegisterName VARCHAR(500), FrameworkName NVARCHAR(1000),ID INT, Column_Name VARCHAR(500),StepItemName VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

DECLARE @I INT=1
WHILE @I<=2		
BEGIN
IF @I=2
SET @I=11
EXEC dbo.TEST1  @EntityID=11,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-03-1',
							@EndDate = '2022-10-30',
							@UserLoginID = 1,
							@MethodName= NULL,
							@LogRequest =1;

							SET @I=@I+1
END
SELECT ID,Column_Name,StepItemName,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue
			FROM #AuditTrailData
			ORDER BY OldHistoryID;
END
SELECT * FROM #TMP


EXEC dbo.GetAuditTrail   @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1

--SINGLE ENTITY
EXEC dbo.GetAuditTrailByType  @EntityID=1442,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1;
--REGISTER
EXEC dbo.GetAuditTrailByType  @EntityID=1,
							@EntityTypeID=3,
							@ParentEntityID=1,						
							@ParentEntityTypeID=2,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1

SELECT * FROM Registers WHERE registerid=3

USE VKB_NEW
GO
EXEC dbo.GetAuditTrailByType  @EntityID=1509,
							@EntityTypeID=9,
							@ParentEntityID=6,
							@ParentEntityTypeID=3,
							@StartDate = '2022-10-01',
							@EndDate = '2022-11-30',
							@UserLoginID = 2752;



--SINGLE ENTITY
EXEC dbo.GetAuditTrailByType  @EntityID=1509,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1;

SELECT * FROM UserLogin WHERE UserLoginID=2440
--Name
SELECT * FROM AUser WHERE UserID=406
--DisplayName
SELECT * FROM Contact WHERE ContactID=1205

SELECT Usr.Name, CT.DisplayName 
FROM dbo.ContactInst_history Hist
	 INNER JOIN dbo.Contact Ct ON CT.ContactID =Hist.ContactId
	 INNER JOIN dbo.AUser Usr ON Usr.ContactID = CT.ContactID
WHERE Hist.HistoryID=118920
	

SELECT DISTINCT EntityId FROM ContactInst_history WHERE HistoryID IN (118920,
130269,
140234,
145778,
157129,
167115,
172659,
184012,
241107,
264192,
275793,
290658,
301157)


SELECT * FROM dbo.AuditTrailColumns;

--ROLLBACK COMMIT
SET XACT_ABORT ON;
BEGIN TRAN;
UPDATE AuditTrailColumns
	SET SqlString='
UPDATE TMP           SET OldValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.OldValue AND TMP.Column_Name = ''ContactId'';        
UPDATE TMP           SET NewValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.NewValue AND TMP.Column_Name = ''ContactId'';        
UPDATE TMP           SET StepItemName = Hist.OperationType   FROM #TMPHistData TMP            INNER JOIN dbo.ContactInst_History Hist ON Hist.HistoryID = TMP.NewHistoryID AND TMP.Column_Name = ''ContactId'';
UPDATE TMP           SET Name = Usr.Name, DisplayName = CT.Name  FROM #TMPHistData TMP  INNER JOIN dbo.ContactInst_History Hist ON Hist.HistoryID = TMP.NewHistoryID AND TMP.Column_Name = ''ContactId''
																			INNER JOIN dbo.Contact Ct ON CT.ContactID =Hist.ContactId
																			INNER JOIN dbo.AUser Usr ON Usr.ContactID = CT.ContactID;' 
WHERE TableName ='ContactInst_history' AND ColumnName = 'ContactId'


--SINGLE ENTITY
EXEC dbo.GetAuditTrailByType  @EntityID=1509,
							@EntityTypeID=0,
							@ParentEntityID=1,
							@ParentEntityTypeID=0,
							@StartDate = '2022-08-15',
							@EndDate = '2022-10-30',
							@UserLoginID = 1;

SELECT * FROM UserLogin WHERE UserLoginID=2440
--Name
SELECT * FROM AUser WHERE UserID=406
--DisplayName
SELECT * FROM Contact WHERE ContactID=1205

SELECT Usr.Name, CT.DisplayName 
FROM dbo.ContactInst_history Hist
	 INNER JOIN dbo.Contact Ct ON CT.ContactID =Hist.ContactId
	 INNER JOIN dbo.AUser Usr ON Usr.ContactID = CT.ContactID
WHERE Hist.HistoryID=118920
	

SELECT DISTINCT EntityId FROM ContactInst_history WHERE HistoryID IN (118920,
130269,
140234,
145778,
157129,
167115,
172659,
184012,
241107,
264192,
275793,
290658,
301157)


SELECT * FROM dbo.AuditTrailColumns;

--ROLLBACK COMMIT
SET XACT_ABORT ON;
BEGIN TRAN;
UPDATE AuditTrailColumns
	SET SqlString='
UPDATE TMP           SET OldValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.OldValue AND TMP.Column_Name = ''ContactId'';        
UPDATE TMP           SET NewValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.NewValue AND TMP.Column_Name = ''ContactId'';        
UPDATE TMP           SET StepItemName = Hist.OperationType   FROM #TMPHistData TMP            INNER JOIN dbo.ContactInst_History Hist ON Hist.HistoryID = TMP.NewHistoryID AND TMP.Column_Name = ''ContactId'';'
WHERE TableName ='ContactInst_history' AND ColumnName = 'ContactId'