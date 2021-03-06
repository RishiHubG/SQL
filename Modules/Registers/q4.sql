
DECLARE @inputJSON VARCHAR(MAX) ='{
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

EXEC dbo.ParseAssessmentJSON @inputJSON = @inputJSON, @UserLoginID=100,@FullSchemaJSON = @inputJSON

SELECT * FROM Registers
SELECT * FROM RegisterProperties
SELECT * FROM RegisterProperties_history
SELECT * FROM RegisterPropertiesXref
SELECT * FROM RegisterPropertyXerf_Data