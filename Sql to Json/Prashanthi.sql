USE VKB_NEW
go
EXEC GetAuditDetails_Report_test 1577,3316

1. Remove id, parentID
2. Each dataset is either a single parent or all children of a single parent
3. Add a final resultset: DataSet    ParentDataset  
OR if #3 is tricky:
2. Retain ID
3. Add a final resultset: DataSet    ParentDataset     ParentDatasetID     ChildDataSetID

Dataset ParentDataset    ParentId     ChildID
1			NULL          NULL 
2			 1            
3            1
4             1
5             1
6             5    2  
6             5    1
7		      6   Material 
8             6
7			   6   1		1
7			   6   1		4
7              6   2        3
7              6   2		2

9            7


USE VKB_NEW
go
EXEC T1 1577,3316
 