--https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/
USE junk
GO

IF EXISTS (SELECT * FROM sys.types WHERE name LIKE 'Hierarchy')
    SET NOEXEC On
  go
  CREATE TYPE dbo.Hierarchy AS TABLE
  /*Markup languages such as JSON and XML all represent object data as hierarchies. Although it looks very different to the entity-relational model, it isn't. It is rather more a different perspective on the same model. The first trick is to represent it as a Adjacency list hierarchy in a table, and then use the contents of this table to update the database. This Adjacency list is really the Database equivalent of any of the nested data structures that are used for the interchange of serialized information with the application, and can be used to create XML, OSX Property lists, Python nested structures or YAML as easily as JSON.
  Adjacency list tables have the same structure whatever the data in them. This means that you can define a single Table-Valued  Type and pass data structures around between stored procedures. However, they are best held at arms-length from the data, since they are not relational tables, but something more like the dreaded EAV (Entity-Attribute-Value) tables. Converting the data from its Hierarchical table form will be different for each application, but is easy with a CTE. You can, alternatively, convert the hierarchical table into XML and interrogate that with XQuery
  */
  (
     element_id INT primary key, /* internal surrogate primary key gives the order of parsing and the list order */
     sequenceNo [int] NULL, /* the place in the sequence for the element */
     parent_ID INT,/* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
     Object_ID INT,/* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
     NAME NVARCHAR(2000),/* the name of the object, null if it hasn't got one */
     StringValue NVARCHAR(MAX) NOT NULL,/*the string representation of the value of the element. */
     ValueType VARCHAR(10) NOT null /* the declared type of the value represented as a string in StringValue*/
  )
  go
  SET NOEXEC OFF
  GO

DECLARE @MyHierarchy Hierarchy, @xml XML

  INSERT INTO @MyHierarchy
    SELECT Element_ID, SequenceNo, Parent_ID, Object_ID, Name, StringValue, ValueType
 FROM dbo.JSONHierarchy('{
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
  ,DEFAULT,DEFAULT,DEFAULT)

  --SELECT * FROM @MyHierarchy

  --RETURN

   

   SELECT @xml = dbo.ToXML(@MyHierarchy)
  --SELECT @xml --to validate the XML, we convert the string to XML

  --SELECT TAB.COL.value('(@label)[1]','VARCHAR(100)'),
		-- TAB.COL.value('(components/item/@label)[1]','VARCHAR(100)'),
		-- TAB.COL.value('(components/item/@key)[1]','VARCHAR(100)')
  --FROM @xml.nodes('/root/components/item')TAB(COL)

  
  --SELECT TAB.COL.value('(@label)[1]','VARCHAR(100)'),
		-- TAB.COL.value('(components/item/@label)[1]','VARCHAR(100)'),
		-- TAB.COL.value('(components/item/@key)[1]','VARCHAR(100)')
  --FROM @xml.nodes('/root/components/item/components/item/columns')TAB(COL)



DECLARE @inputJSON VARCHAR(MAX)=
'{
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

    SELECT *
 FROM dbo.HierarchyFromJSON(@inputJSON)