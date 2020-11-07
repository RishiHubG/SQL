

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Lookups,Framework_Metafield_Attributes,Framework_Metafield

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Steps
CREATE TABLE dbo.Framework_Metafield_Steps
	(
	StepID INT IDENTITY(1,1),
	StepName NVARCHAR(500) NOT NULL,
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	CONSTRAINT PK_Framework_Metafield_StepID PRIMARY KEY(StepID)
	)

DROP TABLE  IF EXISTS dbo.Framework_Metafield
CREATE TABLE dbo.Framework_Metafield
(
MetaFieldID INT IDENTITY(1,1) ,
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
CONSTRAINT PK_Framework_Metafield_MetaFieldID PRIMARY KEY(MetaFieldID)
)

ALTER TABLE dbo.Framework_Metafield ADD CONSTRAINT FK_Framework_Metafield_StepID FOREIGN KEY(StepID) REFERENCES dbo.Framework_Metafield_Steps(StepID)


DROP TABLE  IF EXISTS dbo.Framework_Metafield_Attributes
CREATE TABLE dbo.Framework_Metafield_Attributes
(
MetaFieldAttributeID INT IDENTITY(1,1),
MetaFieldID INT NOT NULL,
AttributeKey NVARCHAR(100) NOT NULL,	
AttributeValue NVARCHAR(100) NOT NULL,
OrderBy INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
CONSTRAINT PK_Framework_Metafield_Attributes_MetaFieldAttributeID PRIMARY KEY(MetaFieldAttributeID)
)

ALTER TABLE dbo.Framework_Metafield_Attributes ADD CONSTRAINT FK_Framework_Metafield_Attributes_MetaFieldID FOREIGN KEY(MetaFieldID) REFERENCES dbo.Framework_Metafield(MetaFieldID)

DROP TABLE  IF EXISTS dbo.Framework_Metafield_Lookups
CREATE TABLE dbo.Framework_Metafield_Lookups
(
ID INT IDENTITY(1,1),
MetaFieldID INT NOT NULL,
LookupName NVARCHAR(100) NOT NULL,
LookupValue NVARCHAR(100) NOT NULL,
LookupType NVARCHAR(100) NULL,
OrderBy INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL
)

ALTER TABLE dbo.Framework_Metafield_Lookups ADD CONSTRAINT FK_Framework_Metafield_Lookups_MetaFieldAttributeID FOREIGN KEY(MetaFieldID) REFERENCES dbo.Framework_Metafield(MetaFieldID)
