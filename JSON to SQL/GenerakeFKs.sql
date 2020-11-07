 
 DROP TABLE IF EXISTS #TMP

SELECT
parent_object_id,
name,
referenced_object_id,
object_id,
is_disabled,
delete_referential_action,
update_referential_action,
STUFF((SELECT '' + COL_NAME(fk.parent_object_id, fkc.parent_column_id)
from sys.foreign_key_columns fkc
where fkc.constraint_object_id = fk.object_id
ORDER BY fkc.constraint_column_id
FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)')
,1,0,'') parentCols ,
STUFF((SELECT '' + COL_NAME(fk.referenced_object_id, fkc.referenced_column_id)
from sys.foreign_key_columns fkc
where fkc.constraint_object_id = fk.object_id
ORDER BY fkc.constraint_column_id
FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)')
,1,0,'') referCols
INTO #TMP
FROM sys.foreign_keys as fk
 
SELECT 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
 +' ADD CONSTRAINT ' +
QUOTENAME(name) + ' FOREIGN KEY ( ' + QUOTENAME(parentCols) + ' ) REFERENCES ' +
QUOTENAME(OBJECT_SCHEMA_NAME(referenced_object_id)) + '.' + QUOTENAME( OBJECT_NAME(referenced_object_id))
+ ' (' + QUOTENAME(referCols) + ') '
AS create_fk_script
FROM #TMP
ORDER BY QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) , QUOTENAME(OBJECT_NAME(parent_object_id)) ;

SELECT 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
 +' DROP CONSTRAINT ' +
QUOTENAME(name)  
AS drop_create_fk_script
FROM #TMP
ORDER BY QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) , QUOTENAME(OBJECT_NAME(parent_object_id)) ;
 