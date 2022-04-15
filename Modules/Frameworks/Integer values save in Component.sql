
TRUNCATE TABLE DemoComponent_DATA
TRUNCATE TABLE DemoComponent_DATA_HISTORY

--New Save
exec SaveFrameworkJSONData @EntityId=-1,@EntitytypeId=9,@ParentEntityID=1415,@ParentEntityTypeID=3,
@SpecialInputJSON=N'{"templates":[{"TemplateKey":"workingpapers","data":{"tabletemplatecontainer":{"tabletemplatedatagrid":[{"documentNae":"","workingProcedure":"","workingPaperConclusion":"","objective":"","annexureNumber":"","relevantToReport":false}]}},"dataType":"TableTemplate","apiKey":"workingPapers"}]}',
@transitionid=N'',
@InputJSON=N'{"sampleAndWeights":{"name":"New Componen","objective":"To ensure that controls are operating effectively.","dateUpdated":"","riskAssessmsent":"","conclusiononoperatingeffectivenessofcontrols":"","natureOfControlAndFrequencyOfPerformance":"","justificationForSampleSize":"","sampleSize":"","linkedFindings":{"jsonData":{}}},"systemDescription":{"container":{"isDesignAndImplementationRequired":"Yes"},"systemsampleSize":"","systemobjective":"To ensure controls are designed and implemented effectively","systemriskAssessmsent":"","systemconclusiononoperatingeffectivenessofcontrols":"","systemdescriptionaddFindings":{"jsonData":{}}},"adminContainer":{"showAdminTab":"No","loggedInUserRole":"","knowledgebasereference":"","referencenum":"","loggedInUserGroup":"","isModuleAdmin":"","isSystemAdmin":"","isModuleAdminGroup":"","currentStateOwner":""},"linkSubComponents1":{}}',
@MethodName=NULL,@UserLoginID=2747

--Update
exec SaveFrameworkJSONData @EntityId=1,@EntitytypeId=9,@ParentEntityID=1415,@ParentEntityTypeID=3,
@SpecialInputJSON=N'{"templates":[{"TemplateKey":"workingpapers","data":{"tabletemplatecontainer":{"tabletemplatedatagrid":[{"ID":1,"UserCreated":100,"DateCreated":"2022-04-15T08:33:00.000Z","UserModified":100,"DateModified":"2022-04-15T08:33:00.000Z","VersionNum":1,"TableInstanceID":1581,"ApiKey":"workingPapers","tabletemplatedatagrid":"","documentNae":"","workingProcedure":"","workingPaperConclusion":"","objective":"","annexureNumber":"","relevantToReport":"false"}]}},"dataType":"TableTemplate","apiKey":"workingPapers"}]}',
@transitionid=N'',
@InputJSON=N'{"systemDescription":{"container":{"isDesignAndImplementationRequired":"Yes","AdhocsystemsampleSize":""},"systemobjective":"To ensure controls are designed and implemented effectively","systemriskAssessmsent":"","systemconclusiononoperatingeffectivenessofcontrols":"","systemnatureOfControlAndFrequencyOfPerformance":"","systemsampleSize":"","systemrevisedSampleSize":"","systemjustificationForSampleSize":"","systemdescriptionaddFindings":{"jsonData":{}}},"sampleAndWeights":{"name":"New Componen","objective":"To ensure that controls are operating effectively.","operatingeffectivenesssampleSize":"","dateUpdated":"","riskAssessmsent":"","conclusiononoperatingeffectivenessofcontrols":"","systemdescriptionrequired_1":"","natureOfControlAndFrequencyOfPerformance":"","sampleSize":"","revisedSampleSize":"","justificationForSampleSize":"","queryGrid":"","linkedFindings":{"jsonData":{}}},"adminContainer":{"knowledgebasereference":"","referencenum":"-2","inheritWorkflowEntity":"","inheritWfEntityFrameworkid":"","showAdminTab":"No","loggedInUserRole":"","loggedInUserGroup":"","isModuleAdmin":"","isSystemAdmin":"","isModuleAdminGroup":"","currentStateOwner":""},"linkSubComponents1":{"entityLinkGrid":""}}',
@MethodName=NULL,@UserLoginID=2747

SELECT * FROM DemoComponent_DATA



SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DemoComponent_DATA'
AND (DATA_TYPE LIKE '%INT%' OR DATA_TYPE LIKE '%DATE%' OR DATA_TYPE LIKE '%FLOAT%' OR DATA_TYPE LIKE '%DECIMAL%')

 
 INSERT INTO dbo.DemoComponent_DATA(FrameworkID, [VersionNum], [UserCreated], [DateCreated], [RegisterID], [ReferenceNum], [name], [objective], [dateUpdated], [riskAssessmsent], [conclusiononoperatingeffectivenessofcontrols], [natureOfControlAndFrequencyOfPerformance], [justificationForSampleSize], [sampleSize], [systemsampleSize], [systemobjective], [systemriskAssessmsent], [systemconclusiononoperatingeffectivenessofcontrols], [isDesignAndImplementationRequired]) 
 VALUES('54', '476', '2747', '2022-04-15 09:30:16.623', '1415', '-2', 'New Componen', 'To ensure that controls are operating effectively.', , '', '', '', '',NULL , , 'To ensure controls are designed and implemented effectively', '', '', 'Yes')
