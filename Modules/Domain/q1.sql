USE JUNK
GO
SELECT * FROM universe

/*
--CREATE TABLES
:setvar path "E:\New Company\GitHub\SQL\Modules\Assessment\Tables\"
:r $(path)\Tables.Universe.sql
:r $(path)\Tables.Universe_History.sql

--CREATE FUNCTION
:SETVAR path "E:\New Company\GitHub\SQL\Modules\Assessment\Function\"
:r $(path)\HierarchyFromJSON.SQL

--CREATE TRIGGERS
:setvar path "E:\New Company\GitHub\SQL\Modules\Assessment\Triggers\"
:r $(path)\Trg_UniverseProperties_Insert.sql
:r $(path)\Trg_Universe_Insert.sql
:r $(path)\Trg_UniversePropertiesXref_Data_Insert.sql
:r $(path)\Trg_UniversePropertiesXref_Insert.sql
*/
--CREATE TABLES
--:setvar path "E:\New Company\GitHub\SQL\Modules\Assessment\Tables\"
--:r $(path)\Tables.Universe.sql
--:r $(path)\Tables.Universe_History.sql
/*
NOTES:
1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE ASSESSMENT PROPERTIES
2. PROPERTIES CAN ONLY BE INSERTED/DELETED (NO UPDATES)

SELECT * FROM dbo.Universe
SELECT * FROM dbo.UniverseProperties
SELECT * FROM dbo.UniversePropertiesXref
SELECT * FROM UniversePropertyXerf_Data

SELECT * FROM dbo.Universe_history
SELECT * FROM dbo.UniverseProperties_history
SELECT * FROM dbo.UniversePropertiesXref_history
SELECT * FROM UniversePropertyXerf_Data_history

		DECLARE @DataTypes TABLE
		 (
		 JSONType VARCHAR(50),
		 DataType VARCHAR(50),
		 DataTypeLength VARCHAR(50),
		 CompatibleTypes VARCHAR(500)
		 )

		 INSERT INTO @DataTypes (JSONType,DataType,DataTypeLength,CompatibleTypes)
						SELECT 'textfield','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'selectboxes','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'select','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'textarea','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'number','INT',NULL,'INT,FLOAT,DECIMAL,BIGINT,NVARCHAR' UNION ALL
			SELECT 'datetime','DATETIME',NULL,'DATETIME,DATE' UNION ALL
			SELECT 'date','DATE',NULL,'DATE,DATETIME,'

	SELECT * FROM @DataTypes
	 
*/
 
--rollback
DECLARE @inputJSON VARCHAR(MAX) ='{
"new": {		
        "label": "newCol",
		"type":"number"		
		},
"test6": {		
        "label": "test6",
		"type":"number"		
		},
"test5": {		
        "label": "test5",
		"type":"textfield"		
		},
 "test4": {		
        "label": "test4",
		"type":"textfield"
		},
 "test2": {		
        "label": "test2",
		"type":"textfield"
		},
  "test1": {		
        "label": "test1",
		"type":"textfield"
		},
     "test": {		
        "label": "test",
		"type":"textfield"
		},
    "name": {		
        "label": "Name",
        "tableView": true,
        "validate": {
            "required": true,
            "minLength": 3,
            "maxLength": 500
        },
        "key": "name",
        "properties": {
            "StepName": "General"
        },
        "type": "textfield",
        "input": true
    },
    "description": {
        "label": "Description",
        "autoExpand": false,
        "tableView": true,
        "key": "description",
        "properties": {
            "StepName": "General"
        },
        "type": "textarea",
        "input": true
    },
    "currency": {
        "label": "Currency",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "USD",
                    "value": "USD"
                },
                {
                    "label": "INR",
                    "value": "INR"
                },
                {
                    "label": "ZAR",
                    "value": "ZAR"
                },
                {
                    "label": "GBP",
                    "value": "GBP"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "currency",
        "properties": {
            "StepName": "Assessment Attributes"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true
    },
    "levelOfOperation": {
        "label": "Level of Operation",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Busienss Unit",
                    "value": "Busienss Unit"
                },
                {
                    "label": "Area",
                    "value": "Area"
                },
                {
                    "label": "Region",
                    "value": "Region"
                },
                {
                    "label": "Country",
                    "value": "Country"
                },
                {
                    "label": "Global",
                    "value": "Global"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "levelOfOperation",
        "properties": {
            "StepName": "Assessment Attributes"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true
    },
    "assessmentContact": {
        "label": "Assessment Contact",
        "widget": "choicesjs",
        "tableView": true,
        "dataSrc": "custom",
        "data": {
            "values": [
                {
                    "label": "",
                    "value": ""
                }
            ]
        },
        "dataType": "auto",
        "selectThreshold": 0.3,
        "key": "assessmentContact",
        "properties": {
            "StepName": "Assessment Attributes"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true
    }
}'

EXEC dbo.ParseUniverseJSON @UniverseName ='ABC',@inputJSON = @inputJSON, @UserLoginID=100,@FullSchemaJSON = @inputJSON

/*
SELECT * FROM dbo.Universe
SELECT * FROM dbo.UniverseProperties
SELECT * FROM dbo.UniversePropertiesXref
SELECT * FROM UniversePropertyXerf_Data

SELECT * FROM dbo.Universe_history
SELECT * FROM dbo.UniverseProperties_history
SELECT * FROM dbo.UniversePropertiesXref_history
SELECT * FROM UniversePropertyXerf_Data_history

SELECT * FROM UniversePropertyXerf_Data
SELECT * FROM UniversePropertyXerf_Data_history

TRUNCATE TABLE UniversePropertyXerf_Data_history
TRUNCATE TABLE UniversePropertyXerf_Data
*/
--ALTER TABLE UniversePropertyXerf_Data ADD [Assessment Contact] [NVARCHAR] (MAX), [Level of Operation] [NVARCHAR] (MAX), [Currency] [NVARCHAR] (MAX), [Description] [NVARCHAR] (MAX), [Name] [NVARCHAR] (MAX)

SELECT * FROM AccessControlledResource

SELECT * FROM aUSER
AUTHTYPE=2=UG
IF UG THEN ALL USERS UNDER THIS GRP. THEN PROVIDE SAME PERMISSIONS TO THESE USERS AS WELL
AccessControlledResource.Customized=0 for THESE USERS

SELECT * FROM USERGROUP


Put a check for this, RETURN FROM PROC.: @EntityTypeid <> 2 OR @ParentEntityTypeid <> 2 : 

NEW TABLE: WFAccessControlledResource
SAME COLS. AS IN AccessControlledResource UPTO Modify
WorkFlowID,WorkFlowName,StepID,StepName,StepItemID,StepItemName


IF ENTITYID IS -1 THEN CREATE NEW ACCESS CONTROL ID: EXISTING PROC.
IF ENTITYID IS -1 THEN CREATE NEW WORKFLOW ID: EXISTING PROC.
IF ENTITYID IS -1 , EntityTypeid=2, ParentEntityTypeid=2 , ParentEntityID=some no., SAY 100, THEN THIS IS THE CHILD OF UNNIVERSEID 100
IF ENTITYID IS not -1 THEN ACCESS CONTROL ID OF THE ENTITYID(UNIVERSEID)
AccessControlledResource.Customized=1

IF domianinherentpermissions IS TRUE AND @ParentEntityID IS NOT NULL THEN 
BEGIN
1. PARENTID''S ACCESSCONTROLID=ParentAccessControlID
2. ACCESSCONTROLID WILL HAVE SAME PERMISSIONS AS OF PARENTID i.e. FIND AccessControlID(parentID) in AccessControlledResource and replicate for AccessControlID
3. FIRST REMOVE EXISTING PERMISSIONS FOR ACCESSCONTROLID THAT WE POPULATE IN STEP# 2 ABOVE AND THEN CREATE NEW PERMISSIONS IN AccessControlledResource
END

IF PARENT IS NULL THEN ROOT HT/DEPTH

SELECT * FROM Universe
ADD NEW COLUMN: PAREntWORKflowACID ,IsinheritedWORKflowACID 

IF WFinheritpermissions IS TRUE AND WorkFlowACIDID IS NOT NULL THEN --@WorkFlowID WILL BE AVAILABLE IN WF PERMISSION JSON
BEGIN
1. PARENTID''S WorkFlowACID =PAREntWORKflowACID
2. ACCESSCONTROLID WILL HAVE SAME PERMISSIONS AS OF PARENTID i.e. FIND AccessControlID(parentID) in AccessControlledResource and replicate for AccessControlID
3. FIRST REMOVE EXISTING PERMISSIONS FOR ACCESSCONTROLID THAT WE POPULATE IN STEP# 2 ABOVE AND THEN CREATE NEW PERMISSIONS IN NEW TABLE WFAccessControlledResource
END


AccessControlledResource: audit trail???


AccessControlid --> PAREntAccessControlid --> Isinherited --> PropagatedAccessControlid
WORKflowACID --> PAREntWORKflowACID --> IsinheritedWORKflowACID --> PropagatedWFAccessControlid

Domain 1
	Domain 2
		Domain 3 is inherit

NEw table -
DOMAINFRAMEWORKMAPPING: UniverseID, FrameWorkID, 4 standard cols.
UniverseID=EntityID,Frameworkid=fetch frameworkID based on name in FrameworkList node
 
ALTER TABLE Universe ALTER COLUMN VersionNum INT NULL
SELECT * FROM UNIVERSE
-- 
DELETE FROM Universe WHERE UniverseID>1
exec SaveUniverseJSONData 
@EntityId=-1,
@EntitytypeId=2,
@ParentEntityID=112,
@ParentEntityTypeID=2,
@UniverseName=N'Domain3',
@Description=N'Domain1 description',
@InputJSON=N'{"attributes":{"currency":"usd","exchangeRate":1.1},"domainpermissiona":[{"userUserGroup":"testname","userid":2, "read":false,"modify":true,"write":true,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false},{"userUserGroup":"test8","userid":3,"modify":true,"write":true,"cut":true,"copy":true,"delete":false,"administrate":false,"adhoc":false}],"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"test8","userid":3,"read":false,"modify":true,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"control1","stepstepItem":"step","stepname":"controlDetail","view":true},{"userUserGroup":"test9","userid":3,"workflowname":"control1","stepstepItem":"stepItem","stepname":"controlDetail","view":true,"modify":true}],"WFinheritpermissions":false,"frameworklist":{"control":true,"control2":true}}',
@MethodName=NULL,@UserLoginID=3202

Qs:
1.What will be ParentId if entityID=-1??
2. column "view" is not available in AccessControlledResource??
3. GetNewAccessControllId - AccessControlId not returned from the proc??