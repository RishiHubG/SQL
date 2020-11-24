USE JUNK
GO

DECLARE @inputJSON VARCHAR(MAX) ='{
     
   
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

--SELECT * FROM dbo.Registers
--SELECT * FROM dbo.RegisterProperties
--SELECT * FROM dbo.RegistersPropertiesXref
--SELECT * FROM RegisterPropertyXerf_Data

--ALTER TABLE RegisterPropertyXerf_Data ADD [Assessment Contact] [NVARCHAR] (MAX), [Level of Operation] [NVARCHAR] (MAX), [Currency] [NVARCHAR] (MAX), [Description] [NVARCHAR] (MAX), [Name] [NVARCHAR] (MAX)