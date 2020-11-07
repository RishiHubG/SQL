-- SCRIPT TO GENERATE THE CREATION SCRIPT OF ALL PK AND UNIQUE CONSTRAINTS.
DECLARE @SchemaName varchar(100)='dbo'
DECLARE @TableName varchar(256)='Framework_Metafield'

SELECT OBJECT_NAME(O.OBJECT_ID) AS NameofConstraint,
SCHEMA_NAME(O.schema_id) AS SchemaName,
OBJECT_NAME(O.parent_object_id) AS TableName,
O.type_desc AS ConstraintType,
CONCAT('ALTER TABLE [dbo].',OBJECT_NAME(O.parent_object_id),' DROP CONSTRAINT ',OBJECT_NAME(O.OBJECT_ID))AS DropConstraintsSQL,
CONCAT('ALTER TABLE [dbo].',OBJECT_NAME(O.parent_object_id),' ADD CONSTRAINT PK_<TABLENAME> PRIMARY KEY()') 
--CONCAT('ALTER TABLE dbo.',OBJECT_NAME(O.parent_object_id),' ADD CONSTRAINT [PK_Framework_Metafield_MetaFieldID] PRIMARY KEY CLUSTERED(MetaFieldID ASC)'
FROM sys.objects O
	INNER JOIN sys.tables t on t.object_id=o.parent_object_id
WHERE o.type_desc IN ('PRIMARY_KEY_CONSTRAINT','FOREIGN_KEY_CONSTRAINT')
	AND schema_name(t.schema_id)= @SchemaName and t.name IN ('Framework_Metafield','Framework_Metafield_Steps','Framework_Metafield_Attributes')

DECLARE @PK_Constraint VARCHAR(MAX)='
ALTER TABLE [dbo].[Framework_Metafield] ADD CONSTRAINT [PK_Framework_Metafield_MetaFieldID] PRIMARY KEY CLUSTERED(MetaFieldID ASC) 
'

SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,
SCHEMA_NAME(schema_id) AS SchemaName,
OBJECT_NAME(parent_object_id) AS TableName,
type_desc AS ConstraintType
FROM sys.objects 
WHERE type_desc IN ('FOREIGN_KEY_CONSTRAINT','PRIMARY_KEY_CONSTRAINT')
 

 SELECT * 
FROM
 (SELECT obj.name AS TableNAme,col.name as colName, idx.name, idx.is_unique, idx.is_primary_key, idx.is_unique_constraint
  FROM 
    sys.indexes idx 
	INNER JOIN sys.objects obj ON idx.object_id = obj.object_id 	
	INNER JOIN sys.index_columns idxcol ON idxcol.index_id = idx.index_id AND idxcol.object_id = idx.object_id 
	INNER JOIN sys.columns col ON col.column_id=idxcol.column_id AND col.object_id = idxcol.object_id
	INNER JOIN sys.tables t on t.object_id=col.object_id
  WHERE obj.type_desc NOT IN ('SYSTEM_TABLE', 'INTERNAL_TABLE')
		and t.name IN ('Framework_Metafield','Framework_Metafield_Steps','Framework_Metafield_Attributes')
		) a
WHERE a.is_primary_key = 1
 

 SELECT  
	CONCAT(', ', 'ALTER TABLE [dbo].',OBJECT_NAME(O.parent_object_id),' DROP CONSTRAINT ',OBJECT_NAME(O.OBJECT_ID),';')
FROM sys.objects O
		INNER JOIN sys.tables t on t.object_id=o.parent_object_id
	WHERE o.type_desc IN ('PRIMARY_KEY_CONSTRAINT','FOREIGN_KEY_CONSTRAINT')
		AND schema_name(t.schema_id)= 'dbo' 
		AND t.name IN ('Framework_Metafield','Framework_Metafield_Steps','Framework_Metafield_Attributes','Framework_Metafield_Lookups')
FOR XML PATH ('')