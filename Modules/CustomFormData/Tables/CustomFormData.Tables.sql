USE AGSQA
GO

DROP TABLE IF EXISTS TableColumnMaster

CREATE TABLE dbo.TableColumnMaster
(
ID INT IDENTITY(1,1),
UserCreated INT NOT NULL, 
DateCreated DATETIME2(0) NOT NULL DEFAULT GETUTCDATE(), 
UserModified INT,
DateModified DATETIME2(0),
ColumnName VARCHAR(500),
IsActive BIT,
VersionNum INT NOT NULL,
CustomFormsInstanceID INT
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
IsActive BIT,
CustomFormsInstanceID INT
)


DROP TABLE IF EXISTS TemplateTableColumnMaster

CREATE TABLE dbo.TemplateTableColumnMaster
(
ID INT IDENTITY(1,1),
UserCreated INT NOT NULL, 
DateCreated DATETIME2(0) NOT NULL DEFAULT GETUTCDATE(), 
UserModified INT,
DateModified DATETIME2(0),
ColumnName VARCHAR(500),
IsActive BIT,
VersionNum INT NOT NULL,
CustomFormsInstanceID INT
)

DROP TABLE IF EXISTS TemplateTableColumnMaster_history

CREATE TABLE dbo.TemplateTableColumnMaster_history
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
IsActive BIT,
CustomFormsInstanceID INT
)


DROP TABLE IF EXISTS [Table_EntityMapping]

CREATE TABLE [dbo].[Table_EntityMapping](
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[TableID] [int] NULL,
	[EntityID] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	[FullSchemaJSON] [varchar](MAX) NULL,
	EntityTypeID INT,
	APIKey NVARCHAR(4000),
	TableInstanceID INT IDENTITY(1,1) PRIMARY KEY
)  
 

ALTER TABLE [dbo].[Table_EntityMapping] ADD  DEFAULT (GETUTCDATE()) FOR [DateCreated]

DROP TABLE IF EXISTS [Table_EntityMapping_history]

CREATE TABLE [dbo].[Table_EntityMapping_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	TableInstanceID INT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[TableID] [int] NULL,
	[EntityID] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	EntityTypeID INT,
	APIKey NVARCHAR(4000),
	[FullSchemaJSON] [varchar](MAX) NULL,
	[OperationType] [varchar](50) NULL
) 