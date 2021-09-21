USE AGSQA
GO

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

DROP TABLE IF EXISTS TableColumnMaster_history

CREATE TABLE dbo.TableColumnMaster_history
(
HistoryID INT IDENTITY(1,1),
ID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
PeriodIdentifierID INT NULL,
OperationType VARCHAR(50),
ColumnName VARCHAR(500),
IsActive BIT
)
