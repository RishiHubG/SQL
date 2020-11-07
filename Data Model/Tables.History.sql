

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Lookups_history,Framework_Metafield_Attributes_history,Framework_Metafield_history,Framework_Metafield_Steps_history

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Steps_history
CREATE TABLE dbo.Framework_Metafield_Steps_history
	(
	HistoryID INT IDENTITY(1,1) PRIMARY KEY,
	SessionID INT,
	StepID INT,
	StepName NVARCHAR(500) NOT NULL,
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,	--SAME AS MAIN TABLE VERSIONNUM		3
	CurrentIdentifier INT NOT NULL,   --CURRENT,
	OperationType NVARCHAR(50) ---dml operation						1
	)

DROP TABLE  IF EXISTS dbo.Framework_Metafield_history
CREATE TABLE dbo.Framework_Metafield_history
(
HistoryID INT IDENTITY(1,1) PRIMARY KEY,
SessionID INT,
MetaFieldID INT,
StepID INT NOT NULL,
StepName NVARCHAR(100) NOT NULL,
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
OperationType NVARCHAR(50) NOT NULL 
)

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Attributes_history
CREATE TABLE dbo.Framework_Metafield_Attributes_history
(
HistoryID INT IDENTITY(1,1) PRIMARY KEY,
SessionID INT,
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
OperationType NVARCHAR(50) NOT NULL 
)



DROP TABLE  IF EXISTS dbo.Framework_Metafield_Lookups_history
CREATE TABLE dbo.Framework_Metafield_Lookups_history
(
HistoryID INT IDENTITY(1,1) PRIMARY KEY,
SessionID INT,
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
OperationType NVARCHAR(50) NOT NULL 
)
