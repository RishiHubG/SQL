 DROP TABLE IF EXISTS Framework_Metafield_Steps_1

DECLARE @sql NVARCHAR(MAX),
    @cols NVARCHAR(MAX) = N'',
    @targettable nvarchar(max) = N'Framework_Metafield_Steps' -- Target table 
  
-- PREPARE SYNTAX TO CREATE NEW TABLE
declare @newtable nvarchar(max) = @targettable + '_1'

SELECT @cols += N', [' + name + '] ' + system_type_name + case is_nullable when 1 then ' NULL' else ' NOT NULL' end
 FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.'+ @targettable , NULL, 1);

SET @cols = STUFF(@cols, 1, 1, N'');

SET @sql = N'CREATE TABLE '+ @newtable + '(' + @cols + ') '
SELECT @sql

 EXEC sp_executesql @sql
  PRINT @sql

			 
 
/*

Add your logic here to insert your data into the Clustered Columnstore Index table

*/

-- PARTITION SWITCH PARTITION
Set @sql = 'ALTER TABLE ' + @targettable  + ' SWITCH PARTITION 1 TO ' + @newtable + ' PARTITION 1';
 
EXEC sp_executesql @sql PRINT @sql  
 
  