USE [VKB_NEW]
GO
/****** Object:  StoredProcedure [dbo].[GetAuditDetails_Report_test]    Script Date: 5/19/2023 4:05:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[T1] 
	@entityid INT,
	@UserLoginID INT
AS
BEGIN

SET NOCOUNT ON;

SET XACT_ABORT ON;

	DECLARE    @MethodName	 NVARCHAR(255)= Null	
--	SELECT @entityid = JSON_VALUE(@InputJSON,'$.data.auditReport.auditName')

	IF(@entityid IS NULL) 
	 BEGIN 
		SELECT 'Invalid Report Parameter'
		RETURN 
	 END 

	DECLARE @UserID INT,@ErrorMessage NVARCHAR(255)	
	DECLARE @ObjectName VARCHAR(100) = OBJECT_NAME(@@PROCID),
			@Params VARCHAR(MAX),
						 @FrameworkID INT = 6

	IF(@MethodName IS NULL) SET @MethodName = @ObjectName


	select  @Params= event_info 
	from    sys.dm_exec_input_buffer(@@spid, current_request_id())

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT	

	DROP TABLE IF EXISTS #entitylist
	CREATE TABLE #entitylist(Id INT IDENTITY(1,1),componentId INT,componentname NVARCHAR(2000),
							 subcomponentid INT,subcomponentname NVARCHAR(2000), 
							procedureId INT,Procedurename NVARCHAR(2000), 
							findingid INT,findingname NVARCHAR(2000),
							 findingApplicable NVARCHAR(MAX),	findingCriteria NVARCHAR(MAX)	,findingDescription	 NVARCHAR(MAX),
							findingRisk	 NVARCHAR(MAX),findingRecommendation  NVARCHAR(MAX)	,classificationOfFinding  NVARCHAR(MAX),	managementComments  NVARCHAR(MAX),	actualDate DATE,
							Numberoferror NVARCHAR(255),subcomponenterror INT,Procerror INT,Valueoferroridentitfied Float ,Reference NVARCHAR(2000),RootCause NVARCHAR(2000),findingname_navurl NVARCHAR(MAX),							
							DesignImplementationandOperatingEffectiveness NVARCHAR(2000),additionalinformation NVARCHAR(MAX),Issuetracking  NVARCHAR(2000))


	DROP TABLE IF EXISTS #Datasets
	CREATE TABLE #datasets(DataSetId INT,ParentdatasetId INT,childRowId INT,ParentrowId INT)



							--AuditName NVARCHAR(2000),AuditRefNo NVARCHAR(2000),
	DECLARE @auditName NVARCHAR(2000),@Auditrefno NVARCHAR(2000),@auditid INT

	SELECT @auditName = name, @Auditrefno = referencenum FROM NewAuditFramework_data where Id = @entityid

	SELECT @auditid = @entityid

	IF @UserID IS NOT NULL
	BEGIN	

			DROP TABLE IF EXISTS #TMP_CHILD,#Componentfinding,#TMP_allfinding,#entitylist1,#TMP_allfinding_Count

			DECLARE @auditor NVARCHAR(MAX),@Reviewer NVARCHAR(MAX),@Bumanager NVARCHAR(2000)

			--SELECT @auditor = (SELECT )

			select @auditor = COALESCE(@auditor + ', ', '') + DisplayName  from ContactInst ci INNER JOIN Contact c  ON c.ContactID = ci.ContactId where EntityId = @auditid and FrameworkId= @FrameworkID and RoleTypeID = 4 and isnull(DisplayName,'')!=''
 
			 select @Reviewer = COALESCE(@Reviewer + ', ', '') + DisplayName  from ContactInst ci INNER JOIN Contact c  ON c.ContactID = ci.ContactId where EntityId = @auditid and FrameworkId= @FrameworkID and RoleTypeID = 3 and isnull(DisplayName,'')!=''
 
			 select @Bumanager = businessunitmanager from QuestionstoManager1_data where inheritWorkflowEntity = @auditid

			CREATE TABLE #entitylist1(Id INT IDENTITY(1,1),componentId INT,componentname NVARCHAR(2000),
								componentReference NVARCHAR(2000),
								subcomponentid INT,subcomponentname NVARCHAR(2000),
								subcomponentreference NVARCHAR(2000),
								procedureId INT,Procedurename NVARCHAR(2000),
								findingreference NVARCHAR(2000),
								findingid INT,findingname NVARCHAR(2000),
							
								Numberoferror NVARCHAR(255),subcomponenterror INT,Procerror INT,Valueoferroridentitfied Float,classificationoffinding NVARCHAR(MAX),orderby INT )


  

			;WITH cte AS (
					SELECT a.ChildEntityId,a.FromEntityId,a.FromFrameworkId,a.ToFrameWorkId,ToEntityid,a.LinkType,
					0 as RowNumber
					FROM EntityChildLinkFramework a
					WHERE FromEntityId = @auditid and FromFrameworkId = 6
					UNION ALL
					SELECT a.ChildEntityId,a.FromEntityId,a.FromFrameworkId,a.ToFrameWorkId,a.ToEntityid,a.LinkType,RowNumber+1 AS RowNumber
					FROM EntityChildLinkFramework a
					JOIN cte c ON a.FromEntityId = c.ToEntityid
					and a.FromFrameworkId=c.ToFrameWorkId)
				SELECT ToEntityid as componentId ,f.name
		 		INTO #TMP_CHILD  
				FROM cte
				INNER JOIN NewAuditComponent_data f
				on cte.ToEntityid = f.id and f.FrameworkID = 7 

			--	select * from #TMP_CHILD

				;WITH cte AS (
					SELECT distinct a.ChildEntityId,a.FromEntityId,a.FromFrameworkId,a.ToFrameWorkId,ToEntityid,a.LinkType,e.componentId,
					0 as RowNumber
					FROM EntityChildLinkFramework a
					INNER JOIN #TMP_CHILD e ON a.FromEntityId= e.componentId and FromFrameworkId = 7
				--	WHERE FromEntityId = 1429 and FromFrameworkId = 6
					UNION ALL
					SELECT a.ChildEntityId,a.FromEntityId,a.FromFrameworkId,a.ToFrameWorkId,a.ToEntityid,a.LinkType,componentId,RowNumber+1 AS RowNumber
					FROM EntityChildLinkFramework a
					JOIN cte c ON a.FromEntityId = c.ToEntityid
					and a.FromFrameworkId=c.ToFrameWorkId)
				SELECT ChildEntityId,FromEntityId,FromFrameworkId,ToFrameWorkId,ToEntityid,LinkType,RowNumber,CONCAT(f.name,'_DATA') AS Tablename,componentId
				INTO #Componentfinding  
				FROM cte
				INNER JOIN Frameworks f
				on cte.ToFrameWorkId = f.FrameworkID
				INNER JOIN newfindings_data fd on   fd.Id =cte.ToEntityid and fd.findingApplicable='Yes'
				WHERE ToFrameWorkId = 10

				;WITH cte AS (
					SELECT a.ChildEntityId,a.FromEntityId,a.FromFrameworkId,a.ToFrameWorkId,ToEntityid,a.LinkType,
					0 as RowNumber
					FROM EntityChildLinkFramework a
					WHERE FromEntityId = @auditid and FromFrameworkId = 6
					UNION ALL
					SELECT a.ChildEntityId,a.FromEntityId,a.FromFrameworkId,a.ToFrameWorkId,a.ToEntityid,a.LinkType,RowNumber+1 AS RowNumber
					FROM EntityChildLinkFramework a
					JOIN cte c ON a.FromEntityId = c.ToEntityid
					and a.FromFrameworkId=c.ToFrameWorkId)
				SELECT ChildEntityId,FromEntityId,FromFrameworkId,ToFrameWorkId,ToEntityid,LinkType,RowNumber,f.name,f.classificationOfFinding
				INTO #TMP_allfinding  FROM cte
				INNER JOIN NewFindings_data f
				on cte.ToFrameWorkId = f.FrameworkID and f.Id = cte.ToEntityid and f.findingApplicable ='Yes'

				 
				DECLARE @SQL NVARCHAR(MAX),@CurYear NVARCHAR(20),@Prevyear1 NVARCHAR(20),@Prevyear2 NVARCHAR(20),@Prevyear3 NVARCHAR(20)

				SELECT @CurYear = YEAR(GETUTCDATE())
				SELECT @Prevyear1 = @CurYear-1
				SELECT @Prevyear2 = @CurYear-2
				SELECT @Prevyear3 = @CurYear-3 

				ALTER TABLE #TMP_CHILD ADD Year1 NVARCHAR(20) ,Year2 NVARCHAR(20) ,Year3 NVARCHAR(20) ,Year4 NVARCHAR(20) 

				CREATE TABLE #TMP_allfinding_Count (findingName NVARCHAR(2000), Year1 NVARCHAR(20) ,Year2 NVARCHAR(20) ,Year3 NVARCHAR(20) ,Year4 NVARCHAR(20),orderby INT )

				

				 INSERT INTO #TMP_allfinding_Count(findingName,Year1,orderby)
				 SELECT classificationOfFinding AS findingName, count(1) , CASE WHEN classificationOfFinding = 'Material Control Weakness'  THEN 1
																				WHEN classificationOfFinding = 'Control Weakness' THEN 2
																				WHEN classificationOfFinding = 'Administrative'  THEN 3 END
								from #TMP_allfinding GROUP BY classificationOfFinding

				

				UPDATE e1
				set e1.Year1 = ISNULL(a.cnt,0)
				FROM #TMP_CHILD e1
				INNER JOIN (SELECT COUNT(e.ToEntityid)as cnt,componentId from #Componentfinding e group by componentId ) a
		 		ON	e1.componentId = a.componentId

			 

			 INSERT INTO #entitylist(componentId,subcomponentid,procedureId,findingid)
			select DISTINCT ef.ToEntityid--,CONCAT( f.Name,'_DATA') --,ef2.apikey,
				,ef2.ToEntityid,ef3.ToEntityid,ef4.ToEntityid
			FROM EntityChildLinkFramework ef
				LEFT JOIN EntityChildLinkFramework ef2
					ON ef.ToFrameWorkId = ef2.FromFrameworkId
					and ef.ToEntityid = ef2.FromEntityId
					LEFT JOIN EntityChildLinkFramework ef3
					ON ef2.ToFrameWorkId = ef3.FromFrameworkId
					and ef2.ToEntityid = ef3.FromEntityId
					LEFT JOIN EntityChildLinkFramework ef4
					ON ef3.ToFrameWorkId = ef4.FromFrameworkId
					and ef3.ToEntityid = ef4.FromEntityId
			WHERE ef.FromFrameworkId=@FrameworkID --and apikey = 'Subcomponents'
			and ef.FromEntityId = @EntityID and ef4.ToEntityid is not null

			INSERT INTO #entitylist1(componentId,subcomponentid,procedureId,findingid)
			SELECT DISTINCT  componentId,subcomponentid,procedureId,findingid
			FROM #entitylist

			
			INSERT INTO #entitylist1(componentId,subcomponentid,procedureId,findingid)
			SELECT DISTINCT componentId,NULL,NULL,ef.ToEntityid
			FROM #entitylist e
			INNER JOIN EntityChildLinkFramework ef
			ON e.componentId = ef.FromEntityId
			AND ef.FromFrameworkId = 7 and ef.ToFrameWorkId = 10

			INSERT INTO #entitylist1(componentId,subcomponentid,procedureId,findingid)
			SELECT DISTINCT  componentId,subcomponentid,NULL,ef.ToEntityid
			FROM #entitylist e
			INNER JOIN EntityChildLinkFramework ef
			ON e.subcomponentid = ef.FromEntityId
			AND ef.FromFrameworkId = 8 and ef.ToFrameWorkId = 10

			INSERT INTO #entitylist1(componentId,subcomponentid,procedureId,findingid)
			SELECT DISTINCT  NULL,NULL,NULL,ef.ToEntityid
			FROM EntityChildLinkFramework ef
			WHERE ef.FromEntityId = @EntityID
			AND ef.FromFrameworkId = 6 and ef.ToFrameWorkId = 10

				--INSERT INTO #entitylist1(componentId,subcomponentid,procedureId,findingid)
				--select DISTINCT ef.ToEntityid--,CONCAT( f.Name,'_DATA') --,ef2.apikey,
				--	,ef2.ToEntityid,ef3.ToEntityid,ef4.ToEntityid 
				--FROM EntityChildLinkFramework ef
				--	LEFT JOIN EntityChildLinkFramework ef2
				--		ON ef.ToFrameWorkId = ef2.FromFrameworkId
				--		and ef.ToEntityid = ef2.FromEntityId
				--		LEFT JOIN EntityChildLinkFramework ef3
				--		ON ef2.ToFrameWorkId = ef3.FromFrameworkId
				--		and ef2.ToEntityid = ef3.FromEntityId
				--		LEFT JOIN EntityChildLinkFramework ef4
				--		ON ef3.ToFrameWorkId = ef4.FromFrameworkId
				--		and ef3.ToEntityid = ef4.FromEntityId
				--WHERE ef.FromFrameworkId=@FrameworkID --and apikey = 'Subcomponents'
				--and ef.FromEntityId = @auditid and ef4.ToEntityid is not null


				UPDATE e	
				SET Procedurename = ad.name
				--,e.Procedurename_navurl = '9/'+CAST(ad.id as NVARCHAR(10))+'/3/' +CAST(registerId as NVARCHAR(10)) --/Entitytypeid/Entityid/Parententitytypeid/Parententityid
				,Procerror = ad.numberoferrors
				,Numberoferror = CONCAT(ISNULL(numberoferrors,0),'/',ISNULL(revisedsamplesize,sampleSize))
				,Valueoferroridentitfied = valueOfErrorsIdentified
				FROM #entitylist1 e
				INNER JOIN NewProcedures_data ad
					ON e.procedureId = ad.id

				UPDATE e
				SET e.subcomponenterror = a.suberror
				FROM #entitylist1 e
				INNER JOIN(SELECT sum(ISNULL(Procerror,0)) as suberror,subcomponentId FROM #entitylist1
				GROUP BY subcomponentId) a
				ON e.subcomponentId = a.subcomponentid

			 
				UPDATE e
				SET e.componentname = ad.name
				,e.componentReference = case when knowledgebasereference is null then ad.referencenum else knowledgebasereference  end
				FROM #entitylist1 e
				INNER JOIN NewAuditComponent_data ad
				ON e.componentId = ad.Id

				UPDATE e
				SET e.classificationoffinding = ad.classificationOfFinding,
				e.findingname = ad.name,
				e.findingreference = case when knowledgebasereference is null then ad.referencenum else knowledgebasereference  end
				FROM #entitylist1 e
				INNER JOIN NewFindings_data ad
				ON e.findingid = ad.Id

				 UPDATE e
				SET orderby = CASE WHEN classificationOfFinding = 'Material Control Weakness'  THEN 1
																				WHEN classificationOfFinding = 'Control Weakness' THEN 2
																				WHEN classificationOfFinding = 'Administrative'  THEN 3 END
				FROM #entitylist1 e

				 

				DELETE FROM #entitylist1 where findingid not in (select ToEntityid FROM #TMP_allfinding)

				UPDATE e
				SET e.subcomponentname = ad.name
				,e.subcomponentreference = case when knowledgebasereference is null then ad.referencenum else knowledgebasereference  end
				FROM #entitylist1 e
				INNER JOIN NewAuditSubcomponents_data ad
				ON e.subcomponentid = ad.Id
				 
				

				 DECLARE @TBL TABLE(Dataset INT, strJson VARCHAR(MAX))
				 DROP TABLE IF EXISTS #TMP_DS1

				   select Name AS AUDITNAME,referencenum AS AUDITNO,ISNULL(suggestedOverallRiskRating1_Name,'') AS OVERALLRATING,actualcompletiondate, 
				(FORMAT(periodunderreviewfrom,'dd/MM/yyyy') + ' - '+ FORMAT(periodunderreviewto,'dd/MM/yyyy')  ) AS AUDITPERIOD,
				coalesce(executivesummary, '') as EXECSUMMARY
				,coalesce(goodPractices, '') as GOODPRACTICES
				,JSON_QUERY('["' + ISNULL(@auditor,'') + '"]') AS AUDITORSLIST
				,JSON_QUERY('["' + @Reviewer + '"]') AS AUDITREVIEWERS,
				FORMAT(CAST(GETDATE() AS DATE),'dd/MM/yyyy')  AS AUDITREPORTDATE 
				INTO #TMP_DS1
				from NewAuditFramework_data WHERE  Id = @auditid

				INSERT INTO @TBL (Dataset,strJson)
				SELECT 1, (SELECT * 
								FROM #TMP_DS1
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)

				--SELECT * FROM @TBL
				--RETURN

				DROP TABLE IF EXISTS #TMP_DS2

				 select  name as 'compname',ISNULL(year1,0) AS 'year1',ISNULL(year2,0) AS 'year2', ISNULL(year3,0) AS 'year3',ISNULL(year4,0) AS 'year4'  
					INTO #TMP_DS2
				 from #TMP_CHILD WHERE ISNULL(year1,0) != 0 

				 INSERT INTO @TBL (Dataset,strJson)
				 SELECT 2, (SELECT * 
								FROM #TMP_DS2
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)
				

				UPDATE @TBL
					SET strJson = CONCAT('"Child1": [',strJson,']')
				WHERE DataSet = 2;

				--SELECT * FROM @TBL
				--RETURN
				 select 'Total' as 'TOTAL',SUM(CAST(Year1 AS INT)) AS year1,ISNULL(SUM(CAST(Year2 AS INT)),'') AS year2,ISNULL(SUM(CAST(Year3 AS INT)),'') AS year3,
				ISNULL(SUM(CAST(Year4 AS INT)),'') AS  year4   
					INTO #TMP_DS3
				from #TMP_CHILD 

				 INSERT INTO @TBL (Dataset,strJson)
				 SELECT 3, (SELECT * 
								FROM #TMP_DS3
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)
				
				UPDATE @TBL
					SET strJson = CONCAT('"Child2": [',strJson,']')
				WHERE DataSet = 3;

				 select  ISNULL(year1,0) as 'year1',ISNULL(year2,0) AS 'year2', ISNULL(year3,0) AS 'year3',ISNULL(year4,0) AS 'year4',  findingName as findingname 			
					INTO #TMP_DS4 
				from #TMP_allfinding_Count

				INSERT INTO @TBL (Dataset,strJson)
				 SELECT 4, (SELECT * 
								FROM #TMP_DS4
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)

				UPDATE @TBL
					SET strJson = CONCAT('"Child3": [',strJson,']')
				WHERE DataSet = 4;

				--SELECT * FROM @TBL
				--RETURN
			--	select * from #entitylist1

				SELECT DISTINCT m1.classificationoffinding AS FindingName ,orderby AS Id  
					INTO #TMP_DS5
				FROM #entitylist1 m1 order by orderby

				INSERT INTO @TBL (Dataset,strJson)
				 SELECT 5, (SELECT * 
								FROM #TMP_DS5
								WHERE ID = 2
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)

				UPDATE @TBL
					SET strJson = CONCAT('"Child4": [',strJson,']')
				WHERE DataSet = 5;

				--SELECT * FROM @TBL
				--RETURN

				SELECT *,   ROW_NUMBER() OVer (order by FindingName) AS Id 
					INTO #TMP_DS6
				FROM (
				SELECT DISTINCT m2.classificationoffinding AS FindingName , m2.componentReference as SNO, m2.componentname ,m2.componentId AS NAME  FROM #entitylist1 m2 ) a 
				order by 1
				
				INSERT INTO @TBL (Dataset,strJson)
				 SELECT 6, (SELECT * 
								FROM #TMP_DS6
								WHERE ID = 1
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)

				UPDATE @TBL
					SET strJson = CONCAT('"Child5": [',strJson,']')
				WHERE DataSet = 6;

				SELECT * FROM @TBL
				RETURN

				SELECT classificationoffinding AS FindingName ,m3.findingreference AS SNO, m3.findingname AS NAME,ISNULL(m3.Numberoferror,'') AS ErrorCount,ISNULL(m3.Valueoferroridentitfied,'') AS 'ErrorValue',0 AS ReportedY2,0 AS ReportedY3,0 as ReportedY4 ,m3.componentId
				 ,   ROW_NUMBER() OVer (order by FindingName) AS Id 
			 	from #entitylist1 m3

				INSERT INTO #datasets
				SELECT 1,NULL,NULL,NULL
				UNION ALL
				SELECT 2,1,NULL,NULL
				UNION ALL
				SELECT 3,1,NULL,NULL
				UNION ALL
				SELECT 4,1,NULL,NULL
				UNION ALL
				SELECT 5,1,NULL,NULL
				UNION ALL
				SELECT 6,5,1,2
				UNION ALL
				SELECT 6,5,2,1
				UNION ALL
				SELECT 7,6,1,1
				UNION ALL
				SELECT 7,6,2,2
				UNION ALL
				SELECT 7,6,3,2
				UNION ALL
				SELECT 7,6,4,1

				SELECT * FROM #datasets
					

	 END		--END OF USER PERMISSION CHECK
	ELSE IF @UserID IS NULL
	 SELECT  @ErrorMessage ='User Session has expired, Please re-login'

	--SELECT @ErrorMessage AS ErrorMessage
	--SELECT @Json AS JsonData , CONCAT(REPLACE(@Auditrefno,'/','-'),'_', @auditName)  AS OutFileName
 





 END