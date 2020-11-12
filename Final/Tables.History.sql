--TEMPLATE TABLES FOR HISTORY
USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Framework_Lookups_history,Framework_Attributes_history,Framework_history,Framework_Steps_history,Frameworks_List_history


DROP TABLE  IF EXISTS dbo.Frameworks_List_history
CREATE TABLE dbo.Frameworks_List_history
	(
	HistoryID INT IDENTITY(1,1),
	FileID INT,
	JSONFileKey VARCHAR(500) NOT NULL,
	JSONFileText VARCHAR(MAX) NOT NULL,
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	CurrentIdentifier INT NOT NULL,
	OperationType VARCHAR(50),
	UserActionID INT,
	CONSTRAINT PK_Frameworks_List_history_HistoryID PRIMARY KEY(HistoryID)
	)

	
DROP TABLE  IF EXISTS dbo.Framework_Steps_history
CREATE TABLE dbo.Framework_Steps_history
	(
	HistoryID INT IDENTITY(1,1),
	StepID INT,
	FileID INT,
	StepName NVARCHAR(500) NOT NULL,
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	CurrentIdentifier INT NOT NULL,
	OperationType VARCHAR(50),
	UserActionID INT,
	CONSTRAINT PK_Framework_Steps_history_HistoryID PRIMARY KEY(HistoryID)
	)

DROP TABLE  IF EXISTS dbo.Framework_StepItems_history
CREATE TABLE dbo.Framework_StepItems_history
(
HistoryID INT IDENTITY(1,1),
FileID INT,
StepItemID INT ,
StepID INT NOT NULL,
StepItemName NVARCHAR(100) NOT NULL,
StepItemType NVARCHAR(100) NOT NULL,
StepItemKey NVARCHAR(100) NOT NULL,
OrderBy INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
CurrentIdentifier INT NOT NULL,
OperationType VARCHAR(50),
UserActionID INT,
CONSTRAINT PK_Framework_StepItems_history_HistoryID PRIMARY KEY(HistoryID)
)

--ALTER TABLE dbo.Framework_StepItems_history ADD CONSTRAINT FK_Framework_StepItems_history_StepID FOREIGN KEY(StepID) REFERENCES dbo.Framework_Steps_history(StepID)


DROP TABLE  IF EXISTS dbo.Framework_Attributes_history
CREATE TABLE dbo.Framework_Attributes_history
(
HistoryID INT IDENTITY(1,1),
FileID INT,
AttributeID INT,
StepItemID INT NOT NULL,
AttributeKey NVARCHAR(100) NOT NULL,	
AttributeValue NVARCHAR(100) NOT NULL,
OrderBy INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
CurrentIdentifier INT NOT NULL,
OperationType VARCHAR(50),
UserActionID INT,
CONSTRAINT PK_Framework_Attributes_historys_history_HistoryID PRIMARY KEY(HistoryID)
)

--ALTER TABLE dbo.Framework_Attributes_history ADD CONSTRAINT FK_Framework_Attributes_history_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.Framework_StepItems_history(StepItemID)

DROP TABLE  IF EXISTS dbo.Framework_Lookups_history
CREATE TABLE dbo.Framework_Lookups_history
(
HistoryID INT IDENTITY(1,1),
FileID INT,
ID INT,
StepItemID INT NOT NULL,
LookupName NVARCHAR(100) NOT NULL,
LookupValue NVARCHAR(100) NOT NULL,
LookupType NVARCHAR(100) NULL,
OrderBy INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
CurrentIdentifier INT NOT NULL,
OperationType VARCHAR(50),
UserActionID INT
)

--ALTER TABLE dbo.Framework_Lookups_history ADD CONSTRAINT FK_Framework_Lookups_history_history_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.Framework_StepItems_history(StepItemID)
