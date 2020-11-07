USE junk
GO

DECLARE @json NVARCHAR(MAX)
SET @json =
N'{
 "EmployeeInfo":{
    "display": "form"   ,
	 "settings": {
        "pdf": {
            "id": "FID-1603285935522",
            "src": "file:///D:/Projects/Dev/Test.html"
        }
    },
	
	 "components": [
        {
            "label": "Framework"
		}
		]	 
	}
}'

SELECT   ISJSON(@json), JSON_VALUE(@json, '$.EmployeeInfo.components[0].label')

SELECT * FROM OPENJSON(@json)
GO
DECLARE @json NVARCHAR(MAX)
SET @json =
N'{
    "display": "form"   ,
	 "settings": {
        "pdf": {
            "id": "FID-1603285935522",
            "src": "file:///D:/Projects/Dev/Test.html"
        }
    },
	
	 "components": [
        {
            "label": "Framework"
		}
		]	 
	
}'

SELECT   ISJSON(@json), JSON_VALUE(@json, '$.components[0].label')
SELECT  * FROM openjson(@json)

GO
DECLARE @json NVARCHAR(MAX)
SET @json =
N'{
    "display": "form"   ,
	 "settings": {
        "pdf": {
            "id": "FID-1603285935522",
            "src": "file:///D:/Projects/Dev/Test.html"
        }
    },	
	 "components": [
         {
            "label": "Framework",
			"components": [
                {
                    "label": "General",
                    "key": "general"
				}
			]
         }
		]	
}'

SELECT  * FROM openjson(@json)

GO


DECLARE @json NVARCHAR(MAX)
SET @json =
N' {              "label": "Framework",     "components": [                  {                      "label": "General",                      "key": "general"      }     ]           }'

SELECT  JSON_VALUE(@json, '$.label') AS TableName,
JSON_VALUE(@json, '$.components[0].label') AS [StepName],
JSON_VALUE(@json, '$.components[0].key') AS [Key],
* FROM openjson(@json)
GO


GO
DECLARE @json NVARCHAR(MAX)
SET @json =
N'{
    "display": "form"   ,
	 "settings": {
        "pdf": {
            "id": "FID-1603285935522",
            "src": "file:///D:/Projects/Dev/Test.html"
        }
    },	
	 "components": [
          {
            "label": "Framework",
            "components": [
                {
                    "label": "General",
                    "key": "general",
                    "components": [
                        {
                            "input": false,
                            "key": "columns",
                            "tableView": false,
                            "label": "Columns",
                            "type": "columns",
                            "columns": [
                                {
                                    "components": [
                                        {
                                            "label": "Name",
                                            "description": "abcd",
                                            "tooltip": "efgh",
                                            "prefix": "aa",
                                            "suffix": "bb",
                                            "hidden": true,
                                            "hideLabel": true,
                                            "showWordCount": true,
                                            "showCharCount": true,
                                            "mask": true,
                                            "tableView": true,
                                            "validate": {
                                                "required": true,
                                                "minLength": 3,
                                                "maxLength": 500
                                            },
                                            "key": "name",
                                            "type": "textfield",
                                            "input": true,
                                            "hideOnChildrenHidden": false
                                        }
                                    ],
                                    "width": 6,
                                    "offset": 0,
                                    "push": 0,
                                    "pull": 0,
                                    "size": "md"
                                },
                                {
                                    "components": [
                                        {
                                            "label": "Description",
                                            "tableView": true,
                                            "validate": {
                                                "required": true
                                            },
                                            "key": "description",
                                            "type": "textfield",
                                            "input": true,
                                            "hideOnChildrenHidden": false
                                        }
                                    ],
                                    "width": 6,
                                    "offset": 0,
                                    "push": 0,
                                    "pull": 0,
                                    "size": "md"
                                }
                            ]
                        }
                    ]
                }
		]	
}
]
}'

SELECT isjson(@json),* FROM openjson(@json)

GO
