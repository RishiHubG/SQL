
DROP TABLE IF EXISTS TableColumnMaster

CREATE TABLE dbo.TableColumnMaster
(
ID INT IDENTITY(1,1),
UserCreated INT NOT NULL, 
DateCreated DATETIME2(0) NOT NULL DEFAULT GETDATE(), 
UserModified INT,
DateModified DATETIME2(0),
ColumnName VARCHAR(500),
IsActive BIT,
VersionNum INT NOT NULL
)
