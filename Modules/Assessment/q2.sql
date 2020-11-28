USE JUNK
GO

/*
--CREATE TABLES
:setvar path "E:\New Company\GitHub\SQL\Modules\Assessment\Tables\"
:r $(path)\Tables.Registers.sql
:r $(path)\Tables.Registers_History.sql

--CREATE FUNCTION
:SETVAR path "E:\New Company\GitHub\SQL\Modules\Assessment\Function\"
:r $(path)\HierarchyFromJSON.SQL

--CREATE TRIGGERS
:setvar path "E:\New Company\GitHub\SQL\Modules\Assessment\Triggers\"
:r $(path)\Trg_RegisterProperties_Insert.sql
:r $(path)\Trg_Registers_Insert.sql
:r $(path)\Trg_RegistersPropertiesXref_Data_Insert.sql
:r $(path)\Trg_RegistersPropertiesXref_Insert.sql
*/
--CREATE TABLES
--:setvar path "E:\New Company\GitHub\SQL\Modules\Assessment\Tables\"
--:r $(path)\Tables.Registers.sql
--:r $(path)\Tables.Registers_History.sql
/*
NOTES:
1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE ASSESSMENT PROPERTIES
2. PROPERTIES CAN ONLY BE INSERTED/DELETED (NO UPDATES)

SELECT * FROM dbo.Registers
SELECT * FROM dbo.RegisterProperties
SELECT * FROM dbo.RegistersPropertiesXref
SELECT * FROM RegisterPropertyXerf_Data

SELECT * FROM dbo.Registers_history
SELECT * FROM dbo.RegisterProperties_history
SELECT * FROM dbo.RegistersPropertiesXref_history
SELECT * FROM RegisterPropertyXerf_Data_history

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
			SELECT 'number','INT',null,'INT,FLOAT,DECIMAL,BIGINT' UNION ALL
			SELECT 'datetime','DATETIME',NULL,'DATETIME,DATE' UNION ALL
			SELECT 'date','DATE',NULL,'DATE,DATETIME,'

	SELECT * FROM @DataTypes
	 
*/
--rollback
DECLARE @inputJSON VARCHAR(MAX) ='{
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

EXEC dbo.ParseAssessmentJSON @RegisterName ='ABC',@inputJSON = @inputJSON

/*
SELECT * FROM dbo.Registers
SELECT * FROM dbo.RegisterProperties
SELECT * FROM dbo.RegistersPropertiesXref
SELECT * FROM RegisterPropertyXerf_Data

SELECT * FROM dbo.Registers_history
SELECT * FROM dbo.RegisterProperties_history
SELECT * FROM dbo.RegistersPropertiesXref_history
SELECT * FROM RegisterPropertyXerf_Data_history

*/
--ALTER TABLE RegisterPropertyXerf_Data ADD [Assessment Contact] [NVARCHAR] (MAX), [Level of Operation] [NVARCHAR] (MAX), [Currency] [NVARCHAR] (MAX), [Description] [NVARCHAR] (MAX), [Name] [NVARCHAR] (MAX)