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
  "display": "form",
  "settings": {
    "pdf": {
      "id": "FID-1604035504068",
      "src": "file:///D:/Projects/Dev/Test.html"
    }
  },
  "components": [
    {
      "label": "Tabs",
      "components": [
        {
          "label": "General",
          "key": "general",
          "components": [
            {
              "columns": [
                {
                  "components": [
                    {
                      "label": "Name",
                      "tableView": true,
                      "validate": {
                        "required": true,
                        "minLength": 1,
                        "maxLength": 500
                      },
                      "key": "name",
                      "type": "textfield",
                      "input": true,
                      "hideOnChildrenHidden": false
                    },
                    {
                      "label": "Reference",
                      "tableView": true,
                      "inputFormat": "html",
                      "key": "reference",
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
                      "label": "Reference",
                      "disabled": true,
                      "tableView": true,
                      "validate": {
                        "unique": true
                      },
                      "unique": true,
                      "key": "reference1",
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
              ],
              "tableView": false,
              "key": "columns",
              "type": "columns",
              "input": false
            }
          ]
        },
        {
          "label": "Details",
          "key": "details",
          "components": [
            {
              "label": "Risk Description",
              "tableView": true,
              "inputFormat": "html",
              "key": "riskDescription",
              "type": "textfield",
              "input": true
            },
            {
              "columns": [
                {
                  "components": [
                    {
                      "label": "Applicable Factor",
                      "optionsLabelPosition": "right",
                      "tableView": false,
                      "defaultValue": {
                        "": false,
                        "strategic": false,
                        "busienss": false,
                        "management": false
                      },
                      "values": [
                        {
                          "label": "Strategic",
                          "value": "strategic",
                          "shortcut": ""
                        },
                        {
                          "label": "Busienss",
                          "value": "busienss",
                          "shortcut": ""
                        },
                        {
                          "label": "Management",
                          "value": "management",
                          "shortcut": ""
                        }
                      ],
                      "key": "riskCategory1",
                      "type": "selectboxes",
                      "input": true,
                      "inputType": "checkbox",
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
                      "label": "Risk Category 1",
                      "widget": "choicesjs",
                      "tableView": true,
                      "data": {
                        "values": [
                          {
                            "label": "Nature",
                            "value": "nature"
                          },
                          {
                            "label": "Machinery",
                            "value": "machinery"
                          },
                          {
                            "label": "Legal",
                            "value": "legal"
                          }
                        ]
                      },
                      "selectThreshold": 0.3,
                      "key": "riskCategory2",
                      "type": "select",
                      "indexeddb": {
                        "filter": {}
                      },
                      "input": true,
                      "hideOnChildrenHidden": false
                    },
                    {
                      "label": "Risk Category 2",
                      "widget": "choicesjs",
                      "tableView": true,
                      "data": {
                        "values": [
                          {
                            "label": "Flood",
                            "value": "flood"
                          },
                          {
                            "label": "Fire",
                            "value": "fire"
                          },
                          {
                            "label": "Earthquake",
                            "value": "earthquake"
                          }
                        ]
                      },
                      "selectThreshold": 0.3,
                      "key": "riskCategory3",
                      "type": "select",
                      "indexeddb": {
                        "filter": {}
                      },
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
              ],
              "tableView": false,
              "key": "categoriseRisk",
              "type": "columns",
              "input": false
            }
          ]
        },
        {
          "label": "Rating",
          "key": "rating",
          "components": [
            {
              "components": [
                {
                  "label": "Likelyhood",
                  "mask": false,
                  "spellcheck": true,
                  "tableView": false,
                  "delimiter": false,
                  "requireDecimal": false,
                  "inputFormat": "plain",
                  "validate": {
                    "required": true,
                    "min": 0,
                    "max": 100
                  },
                  "key": "likelyhood",
                  "type": "number",
                  "input": true
                },
                {
                  "label": "Financial Impact",
                  "mask": false,
                  "spellcheck": true,
                  "tableView": false,
                  "delimiter": true,
                  "requireDecimal": true,
                  "inputFormat": "plain",
                  "key": "financialImpact",
                  "type": "number",
                  "input": true,
                  "decimalLimit": 2
                },
                {
                  "label": "Inherent Rating",
                  "tableView": true,
                  "calculateValue": "value = data.likelyhood/100 + data.FinancialImpact;",
                  "key": "inherentRating",
                  "type": "textfield",
                  "input": true
                }
              ]
            }
          ]
        },
        {
          "label": "Summary",
          "key": "summary",
          "components": [
            {
              "label": "Overall Comment",
              "autoExpand": false,
              "tableView": true,
              "key": "overallComment",
              "type": "textarea",
              "input": true
            }
          ]
        }
      ],
      "tableView": false,
      "key": "tabs",
      "type": "tabs",
      "input": false
    }
  ]
}',null,null, null
)TAB
order by TAB.[hierarchyid]
--GO

------------------------------------------------------------------------------------------------------------------------- 

--DROP TABLE IF EXISTS TMP
--SELECT IDENTITY(INT,1,1) AS ID,* INTO TMP FROM #TMP   order by [hierarchyid]
SELECT * FROM #TMP   order by [hierarchyid]

RETURN

SELECT * FROM #TMP WHERE PrePath='components[0]'
SELECT * FROM #TMP WHERE PrePath='components[0].components[0]'
SELECT * FROM #TMP WHERE PrePath='components[0].components[0].components[0].columns[0].components[0]'
SELECT * FROM #TMP WHERE PrePath='components[0].components[1].components[1].columns[0].components[0]'


SELECT * FROM #TMP WHERE [KEY]='label' order by [hierarchyid]

SELECT * FROM #TMP WHERE [KEY]='label' AND value ='Columns'

--SELECT * FROM #TMP1 WHERE hierarchyid >0x7AD6 AND hierarchyid <0x7ADAB7AD60 --(0x7ADAB7AE10=SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' AND value='Columns' ORDER BY hierarchyid ASC)

SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' AND value='Columns' ORDER BY hierarchyid ASC

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

DROP TABLE IF EXISTS #TMP1

SELECT * into #tmp1 FROM #TMP WHERE [KEY]='label'
 
 DROP TABLE IF EXISTS TMP

 SELECT IDENTITY(INT,1,1) AS ID,* INTO TMP FROM #tmp   ORDER BY hierarchyid ASC

 SELECT * FROM #tmp1   ORDER BY hierarchyid ASC
SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' ORDER BY hierarchyid ASC
SELECT TOP 1 * FROM #TMP WHERE [KEY]='label' AND value='Columns'

--GET ALL STEPS BETWEEN TOP MOST ROOT(THE FRAMEWORK/TABLE AND THE START OF THE STEP ITEMS)
SELECT * FROM #TMP1 WHERE hierarchyid >0x7AD6 AND hierarchyid <0x7ADAB7AE10

SELECT * 
  FROM #TMP 
WHERE PrePath ='components[0].components[3].components[0]'
  ORDER BY hierarchyid ASC