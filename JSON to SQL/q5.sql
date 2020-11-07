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

SELECT * , [hierarchyid].ToString()
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