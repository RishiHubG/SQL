DROP TABLE IF EXISTS TAB_Framework_Metafield_Lookups
drop table IF EXISTS TAB_Framework_Metafield_Attributes
drop table IF EXISTS TAB_Framework_Metafield
drop table IF EXISTS TAB_Framework_Metafield_steps

ALTER TABLE Framework_Metafield SWITCH PARTITION 1 TO TAB_Framework_Metafield PARTITION 1
ALTER TABLE Framework_Metafield_Attributes SWITCH PARTITION 1 TO TAB_Framework_Metafield_Attributes PARTITION 1
ALTER TABLE Framework_Metafield_Lookups SWITCH PARTITION 1 TO TAB_Framework_Metafield_Lookups PARTITION 1
ALTER TABLE Framework_Metafield_steps SWITCH PARTITION 1 TO TAB_Framework_Metafield_steps PARTITION 1
 

 SELECT * 
FROM
 (SELECT obj.name + '.' +col.name as colName, idx.name, idx.is_unique, idx.is_primary_key, idx.is_unique_constraint
  FROM 
    sys.indexes idx INNER JOIN
    sys.objects obj ON idx.object_id = obj.object_id INNER JOIN
    sys.index_columns idxcol ON idxcol.index_id = idx.index_id AND idxcol.object_id = idx.object_id INNER JOIN
    sys.columns col ON col.column_id=idxcol.column_id AND col.object_id = idxcol.object_id
  WHERE obj.type_desc NOT IN ('SYSTEM_TABLE', 'INTERNAL_TABLE')) a
WHERE a.is_primary_key = 1