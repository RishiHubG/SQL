USE junk
GO

CREATE OR ALTER FUNCTION [dbo].[SmartParseJSON] (@json NVARCHAR(MAX))
RETURNS @Parsed TABLE (Parent NVARCHAR(MAX),Path NVARCHAR(MAX),Level INT,Param NVARCHAR(4000),Type NVARCHAR(255),Value NVARCHAR(MAX),GenericPath NVARCHAR(MAX))
AS
BEGIN
    -- Author: Vitaly Borisov
    -- Create date: 2018-03-23
    ;WITH crData AS (
        SELECT CAST(NULL AS NVARCHAR(4000)) COLLATE DATABASE_DEFAULT AS [Parent]
            ,j.[Key] AS [Param],j.Value,j.Type
            ,j.[Key] AS [Path],0 AS [Level]
            ,j.[Key] AS [GenericPath]
        FROM OPENJSON(@json) j
        UNION ALL
        SELECT CAST(d.Path AS NVARCHAR(4000)) COLLATE DATABASE_DEFAULT AS [Parent]
            ,j.[Key] AS [Param],j.Value,j.Type 
            ,d.Path + CASE d.Type WHEN 5 THEN '.' WHEN 4 THEN '[' ELSE '' END + j.[Key] + CASE d.Type WHEN 4 THEN ']' ELSE '' END AS [Path]
            ,d.Level+1
            ,d.GenericPath + CASE d.Type WHEN 5 THEN '.' + j.[Key] ELSE '' END AS [GenericPath]
        FROM crData d 
        CROSS APPLY OPENJSON(d.Value) j
        WHERE ISJSON(d.Value) = 1
    )
    INSERT INTO @Parsed(Parent, Path, Level, Param, Type, Value, GenericPath)
    SELECT d.Parent,d.Path,d.Level,d.Param
        ,CASE d.Type 
            WHEN 1 THEN CASE WHEN TRY_CONVERT(UNIQUEIDENTIFIER,d.Value) IS NOT NULL THEN 'UNIQUEIDENTIFIER' ELSE 'NVARCHAR(MAX)' END 
            WHEN 2 THEN 'INT' 
            WHEN 3 THEN 'BIT' 
            WHEN 4 THEN 'Array' 
            WHEN 5 THEN 'Object' 
                ELSE 'NVARCHAR(MAX)'
         END AS [Type]
        ,CASE 
            WHEN d.Type = 3 AND d.Value = 'true' THEN '1'
            WHEN d.Type = 3 AND d.Value = 'false' THEN '0'
                ELSE d.Value
         END AS [Value]
        ,d.GenericPath
    FROM crData d
    OPTION(MAXRECURSION 1000) /*Limit to 1000 levels deep*/
    ;
    RETURN;
END
GO

DECLARE @json NVARCHAR(MAX) = '{"Objects":[{"SomeKeyID":1,"Value":3}],"SomeParam":"Lalala"}';
SELECT j.Parent, j.Path, j.Level, j.Param, j.Type, j.Value, j.GenericPath 
FROM dbo.SmartParseJSON(@json) j;

GO

DECLARE @json NVARCHAR(MAX) = '{
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
}';
DROP TABLE IF EXISTS #ParsedData;
SELECT j.Parent, j.Path, j.Level, j.Param, j.Type, j.Value, j.GenericPath 
INTO #ParsedData
FROM dbo.SmartParseJSON(@json) j;

SELECT COALESCE(p2.GenericPath,p.GenericPath) AS [GenericPath]
    ,COALESCE(p2.Param,p.Param) AS [Param]
    ,COALESCE(p2.Value,p.Value) AS [Value]
FROM #ParsedData p
LEFT JOIN #ParsedData p1 ON p1.Parent = p.Path AND p1.Level = 1
LEFT JOIN #ParsedData p2 ON p2.Parent = p1.Path AND p2.Level = 2
WHERE p.Level = 0
;
DROP TABLE IF EXISTS #ParsedData;

 

