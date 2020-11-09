--TEMPLATE TABLES FOR HISTORY
USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Lookups_history,Framework_Metafield_Attributes_history,Framework_Metafield_history,Framework_Metafield_Steps_history,Frameworks_List_history


DROP TABLE  IF EXISTS dbo.Frameworks_List_history
CREATE TABLE dbo.Frameworks_List_history
	(
	HistoryID INT IDENTITY(1,1),
	ID INT,
	JSONFile VARCHAR(500) NOT NULL,
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	CurrentIdentifier INT NOT NULL,
	OperationType VARCHAR(50),
	UserActionID INT
	--CONSTRAINT PK_Frameworks_List_history_HistoryID PRIMARY KEY(HistoryID)
	)

	
DROP TABLE  IF EXISTS dbo.Framework_Metafield_Steps_history
CREATE TABLE dbo.Framework_Metafield_Steps_history
	(
	HistoryID INT IDENTITY(1,1),
	StepID INT,
	StepName NVARCHAR(500) NOT NULL,
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	CurrentIdentifier INT NOT NULL,
	OperationType VARCHAR(50),
	UserActionID INT
	--,CONSTRAINT PK_Framework_Metafield_Steps_history_HistoryID PRIMARY KEY(HistoryID)
	)

DROP TABLE  IF EXISTS dbo.Framework_Metafield_history
CREATE TABLE dbo.Framework_Metafield_history
(
HistoryID INT IDENTITY(1,1),
MetaFieldID INT ,
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
UserActionID INT
--,CONSTRAINT PK_Framework_Metafield_history_HistoryID PRIMARY KEY(HistoryID)
)

--ALTER TABLE dbo.Framework_Metafield_history ADD CONSTRAINT FK_Framework_Metafield_history_StepID FOREIGN KEY(StepID) REFERENCES dbo.Framework_Metafield_Steps_history(StepID)


DROP TABLE  IF EXISTS dbo.Framework_Metafield_Attributes_history
CREATE TABLE dbo.Framework_Metafield_Attributes_history
(
HistoryID INT IDENTITY(1,1),
MetaFieldAttributeID INT,
MetaFieldID INT NOT NULL,
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
UserActionID INT
--,CONSTRAINT PK_Framework_Metafield_Attributes_history_HistoryID PRIMARY KEY(HistoryID)
)

--ALTER TABLE dbo.Framework_Metafield_Attributes_history ADD CONSTRAINT FK_Framework_Metafield_Attributes_history_MetaFieldID FOREIGN KEY(MetaFieldID) REFERENCES dbo.Framework_Metafield_history(MetaFieldID)

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Lookups_history
CREATE TABLE dbo.Framework_Metafield_Lookups_history
(
HistoryID INT IDENTITY(1,1),
ID INT,
MetaFieldID INT NOT NULL,
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

--ALTER TABLE dbo.Framework_Metafield_Lookups_history ADD CONSTRAINT FK_Framework_Metafield_Lookups_history_MetaFieldAttributeID FOREIGN KEY(MetaFieldID) REFERENCES dbo.Framework_Metafield_history(MetaFieldID)
