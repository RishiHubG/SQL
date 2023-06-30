--TEMPLATE TABLES

DROP TABLE  IF EXISTS dbo.FrameworkLookups,FrameworkAttributes,FrameworkStepItems,FrameworkSteps,Frameworks

--Frameworks: COMMON TABLE ACROSS ALL FRAMEWORKS
DROP TABLE  IF EXISTS dbo.Frameworks
CREATE TABLE dbo.Frameworks
	(
	FrameworkID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	FullSchemaJSON VARCHAR(MAX),
	Name VARCHAR(500) NOT NULL,
	FrameworkFile VARCHAR(MAX) NOT NULL,
	[Namespace]	VARCHAR(100),	
	CONSTRAINT PK_Frameworks_ID PRIMARY KEY(FrameworkID)
	)
	
	ALTER TABLE [dbo].Frameworks ADD CONSTRAINT DF_Frameworks_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

	
DROP TABLE  IF EXISTS dbo.FrameworkSteps
CREATE TABLE [dbo].[FrameworkSteps](
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NOT NULL,
	[StepName] [nvarchar](500) NOT NULL,
	[StepID] [int] IDENTITY(1,1) NOT NULL,
	ClientID INT NOT NULL,
 CONSTRAINT [PK_FrameworkSteps_StepID] PRIMARY KEY CLUSTERED 
(
	[StepID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FrameworkSteps] ADD  CONSTRAINT [DF_FrameworkSteps_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO

	--ALTER TABLE dbo.FrameworkSteps ADD CONSTRAINT FK_FrameworkSteps_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkStepItems

CREATE TABLE [dbo].[FrameworkStepItems](
	[StepItemID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	[StepID] [int] NOT NULL,
	[StepItemName] [nvarchar](100) NOT NULL,
	[StepItemType] [nvarchar](100) NOT NULL,
	[StepItemKey] [nvarchar](100) NOT NULL,
	[OrderBy] [int] NULL,
	ClientID INT NOT NULL,
 CONSTRAINT [UQ_FrameworkStepItems_StepItemKey] UNIQUE NONCLUSTERED 
(
	[StepItemKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FrameworkStepItems] ADD  CONSTRAINT [DF_FrameworkStepItems_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkAttributes
CREATE TABLE [dbo].[FrameworkAttributes](
	[AttributeID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	[StepItemID] [int] NOT NULL,
	[AttributeKey] [nvarchar](1000) NOT NULL,
	[AttributeValue] [nvarchar](max) NOT NULL,
	[OrderBy] [int] NULL,
	ClientID INT NOT NULL,
 CONSTRAINT [PK_FrameworkAttributes_AttributeID] PRIMARY KEY CLUSTERED 
(
	[AttributeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[FrameworkAttributes] ADD  CONSTRAINT [DF_FrameworkAttributes_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
GO

--ALTER TABLE dbo.FrameworkAttributes ADD CONSTRAINT FK_FrameworkAttributess_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems(StepItemID)
--ALTER TABLE dbo.FrameworkAttributes ADD CONSTRAINT FK_FrameworkAttributes_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkLookups
CREATE TABLE [dbo].[FrameworkLookups](
	[LookupID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	[StepItemID] [int] NOT NULL,
	[LookupName] [nvarchar](845) NOT NULL,
	[LookupValue] [nvarchar](max) NOT NULL,
	[LookupType] [nvarchar](100) NULL,
	[Color] [nvarchar](100) NULL,
	[MinValue] [nvarchar](100) NULL,
	[MaxValue] [nvarchar](100) NULL,
	[OrderBy] [int] NULL,
	[StepItemKey] [nvarchar](100) NOT NULL,
	ClientID INT NOT NULL,
 CONSTRAINT [UQ_FrameworkLookups_LookupName] UNIQUE NONCLUSTERED 
(
	[FrameworkID] ASC,
	[StepItemID] ASC,
	[LookupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[FrameworkLookups] ADD  CONSTRAINT [DF_FrameworkLookups_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
	--ALTER TABLE [dbo].FrameworkLookups ADD CONSTRAINT UQ_FrameworkLookups_LookupName UNIQUE(FrameworkID,StepItemID,LookupName)
GO

--ALTER TABLE dbo.FrameworkLookups ADD CONSTRAINT FK_FrameworkLookups_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems(StepItemID)
--ALTER TABLE dbo.FrameworkLookups ADD CONSTRAINT FK_FrameworkLookups_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)


DROP TABLE  IF EXISTS dbo.FrameworksEntityGridMapping
CREATE TABLE dbo.FrameworksEntityGridMapping
	(
	ID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NULL,
	FrameworkID INT,
	StepItemID INT,
	Label NVARCHAR(MAX),
	APIKey  NVARCHAR(MAX)
	)
	ALTER TABLE [dbo].FrameworksEntityGridMapping ADD CONSTRAINT DF_FrameworksEntityGridMapping_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

DROP TABLE  IF EXISTS dbo.FrameworkAttributesMapping
CREATE TABLE dbo.FrameworkAttributesMapping
	(
	ID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NULL,
	FrameworkID INT,	
	APIKey NVARCHAR(MAX),
	AttributeType NVARCHAR(MAX),
	AttributeName NVARCHAR(MAX)
	)
	ALTER TABLE [dbo].FrameworkAttributesMapping ADD CONSTRAINT DF_FrameworkAttributesMapping_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO


DROP TABLE IF EXISTS FrameworkMultiSelectStepItemValues
CREATE TABLE dbo.FrameworkMultiSelectStepItemValues
(
ID INT IDENTITY(1,1),
FrameworkID INT NOT NULL,
Entityid INT NOT NULL, 
EntityTypeID INT,
StepItemID  INT NOT NULL,
Name NVARCHAR(500) NOT NULL,
IsSelected BIT NOT NULL
)

GO

DROP TABLE IF EXISTS Frameworks_ExtendedValues
CREATE TABLE dbo.Frameworks_ExtendedValues 
	(FrameworkID INT, EntityID INT, RegisterID INT,showAdminTab NVARCHAR(500),loggedInUserRole NVARCHAR(500),loggedInUserGroup NVARCHAR(500),
	isModuleAdmin NVARCHAR(500),isSystemAdmin NVARCHAR(500),isModuleAdminGroup NVARCHAR(500), CurrentStateowner NVARCHAR(500))

	ALTER TABLE dbo.Frameworks_ExtendedValues ADD CONSTRAINT UQ_Frameworks_ExtendedValues UNIQUE (FrameworkID, EntityID,RegisterID);