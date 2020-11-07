--https://ariely.info/Blog/tabid/83/EntryId/239/Transact-SQL-openjson-hierarchy-solution.aspx
USE junk
GO

DROP FUNCTION IF EXISTS RonenAriely_HierarchyOpenjson;
GO
create or alter function RonenAriely_HierarchyOpenjson(
      @value NVARCHAR(max)
    , @PreType int
    , @PrePath NVARCHAR(MAX)
    , @hierarchyid hierarchyid
)
returns @tempTable table (
      [key] NVARCHAR(max)
    , [value] NVARCHAR(max)
    , [PreType] int
    , [type] int
    , [PrePath] NVARCHAR(MAX)
    , [path] NVARCHAR(MAX)
    , [hierarchyid] HIERARCHYID
)
as begin
    ;with MyCTE as (
        select
            [key],
            [value],
            [PreType] = @PreType,
            [type],
            [PrePath] = @PrePath,
            [path] = iif(
                @PrePath is null,
                [key],
                iif(@PreType = 4, CONCAT(@PrePath, N'[', [key],N']'), CONCAT(@PrePath, N'.', [key]))
            ) ,
            [hierarchyid] = iif(
                @hierarchyid is null,
                --hierarchyid::GetRoot(),
                CONVERT(hierarchyid,CONCAT(N'/',ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),N'/')),
                CONVERT(hierarchyid,
                    CONCAT(
                        @hierarchyid.ToString(),
                        ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
                        ,N'/'
                    )
                )
            )
        from openjson(@value)
    )
    insert @tempTable
          
        -- type 1,2,3,4,5
        select
              c.[key]
            , c.[value]
            , c.[PreType]
            , c.[type]
            , c.[PrePath]
            , c.[path]
            , c.[hierarchyid]
        from MyCTE c
  
        --------------------------- Recursive for types 4 and 5
        -- types 5
        union all
        select
              ca.[key]
            , ca.[value]
            , ca.[PreType]
            , ca.[type]
            , ca.[PrePath]
            , ca.[path]
            , ca.[hierarchyid]
        from MyCTE c
        cross apply RonenAriely_HierarchyOpenjson(
              c.[value]
            , c.[type]
            , c.[path]
            , c.[hierarchyid]
        ) ca
        where  c.[type]>3
            -- I add check that each value fit as JSON before parse it
            -- This reduce performance but improve consistency
            -- If you sure 100% that all text is well formatted as JSON
            --   then you can remove this filter
            and isjson(c.[value])=1
          
    return
END
GO


DROP TABLE IF EXISTS #TMP

SELECT * --, [hierarchyid].ToString() AS [hierarchyid]
INTO #TMP
FROM dbo.RonenAriely_HierarchyOpenjson('{
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
}',null,null, null
)TAB
order by TAB.[hierarchyid]
--GO

------------------------------------------------------------------------------------------------------------------------- 
SELECT * FROM #TMP WHERE [KEY]='label' ORDER BY [hierarchyid]

SELECT * FROM #TMP WHERE [KEY]='label' AND value ='Columns'

SELECT * FROM #TMP 
WHERE [KEY]='label' 
	  AND hierarchyid>0x7ADAB7AE10
ORDER BY [hierarchyid]

SELECT * FROM #TMP WHERE  hierarchyid> 0x7ADAB7AE55AD6B AND hierarchyid < 0x7ADAB7AE56AD6B
AND prepath LIKE '%columns[[]0]%' --ESCAPE '\'
order by [hierarchyid]

SELECT * FROM #TMP WHERE  prepath='components[0].components[0].components[0].columns[0].components[0]'
order by [hierarchyid]

SELECT * FROM #TMP WHERE  prepath='components[0].components[0].components[0].columns[0].components[0].validate'
order by [hierarchyid]
------------------------------------------------------------------------------------------------------------------------- 


--------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #TMP1

SELECT * INTO #TMP1 FROM #TMP WHERE [KEY]='label'
 
 SELECT * FROM #TMP1
SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' ORDER BY hierarchyid ASC
SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' AND value='Columns' ORDER BY hierarchyid ASC

--GET ALL STEPS 
--BETWEEN TOP MOST ROOT(THE FRAMEWORK/TABLE) AND THE START OF THE STEP ITEMS; THESE ARE IDENTIFIED BY THE value='columns' and key='label'
SELECT * FROM #TMP1 WHERE hierarchyid >0x7AD6 AND hierarchyid <0x7ADAB7AE10 --(0x7ADAB7AE10=SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' AND value='Columns' ORDER BY hierarchyid ASC)

--GET THE KEY FOR A STEP
SELECT * 
  FROM #TMP 
WHERE [KEY]='key' 
  AND PrePath ='components[0].components[0]'
  ORDER BY hierarchyid ASC

--GET THE "COLUMNS" ROW UNDER GENERAL -> components[0].components[0] WHICH IS IDENTIFIED AS components[0].components[0].components[0].columns[0]
SELECT * FROM #TMP WHERE [KEY]='label' AND value='Columns' AND PrePath ='components[0].components[0].components[0]'

--GET ALL STEP ITEMS (UNDER THE VALUE=COLUMNS WHICH IS UNDER GENERAL)
 SELECT * 
  FROM #TMP1 
WHERE [hierarchyid] > 0x7ADAB7AE10
  ORDER BY hierarchyid ASC

 --GET ALL STEP ITEMS UNDER A STEP. NOTE: columns[0]=1ST STEP, columns[1]=2ND STEP AND SO ON...
SELECT * 
  FROM #TMP 
WHERE PrePath ='components[0].components[0].components[0].columns[0].components[0]'
  ORDER BY hierarchyid ASC


 --GET ALL STEP ITEMS UNDER THE 2ND STEP
SELECT * 
  FROM #TMP 
WHERE PrePath ='components[0].components[0].components[0].columns[1].components[0]'
  ORDER BY hierarchyid ASC

------------------------------------------------------------------------------------------------------------------------------------


DECLARE @Framework_Metafield TABLE
(
ID INT NOT NULL,
StepName VARCHAR(100) NOT NULL,
StepItemName VARCHAR(100) NOT NULL,
StepItemType VARCHAR(100) NOT NULL,
StepItemKey VARCHAR(100) NOT NULL
)

DECLARE @Framework_Metafield_Attributes TABLE 
(
ID INT IDENTITY(1,1),
MetaField INT NOT NULL,
AttributeType VARCHAR(100) NOT NULL,
AttributeKey VARCHAR(100) NOT NULL
)