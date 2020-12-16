 
/****** Object:  UserDefinedFunction [dbo].[HierarchyFromJSON]    Script Date: 12/16/2020 10:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [dbo].[HierarchyFromJSON](@JSONData VARCHAR(MAX))
RETURNS @ReturnTable TABLE
  (
  Element_ID INT, /* internal surrogate primary key gives the order of parsing and the list order */
  SequenceNo INT NULL, /* the sequence number in a list */
  Parent_ID INT, /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
  Object_ID INT, /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
  Name NVARCHAR(2000), /* the name of the object */
  StringValue NVARCHAR(MAX) NOT NULL, /*the string representation of the value of the element. */
  ValueType VARCHAR(10) NOT NULL /* the declared type of the value represented as a string in StringValue*/
  )
AS
  BEGIN
    DECLARE @ii INT = 1, @rowcount INT = -1;
    DECLARE @null INT =
      0, @string INT = 1, @int INT = 2, @boolean INT = 3, @array INT = 4, @object INT = 5;
 
    DECLARE @TheHierarchy TABLE
      (
      element_id INT IDENTITY(1, 1) PRIMARY KEY,
      sequenceNo INT NULL,
      Depth INT, /* effectively, the recursion level. =the depth of nesting*/
      parent_ID INT,
      Object_ID INT,
      NAME NVARCHAR(2000),
      StringValue NVARCHAR(MAX) NOT NULL,
      ValueType VARCHAR(10) NOT NULL
      );
 
    INSERT INTO @TheHierarchy
      (sequenceNo, Depth, parent_ID, Object_ID, NAME, StringValue, ValueType)
      SELECT 1, @ii, NULL, 0, 'root', @JSONData, 'object';
 
    WHILE @rowcount <> 0
      BEGIN
        SELECT @ii = @ii + 1;
 
        INSERT INTO @TheHierarchy
          (sequenceNo, Depth, parent_ID, Object_ID, NAME, StringValue, ValueType)
          SELECT Scope_Identity(), @ii, Object_ID,
            Scope_Identity() + Row_Number() OVER (ORDER BY parent_ID), [Key], Coalesce(o.Value,'null'),
            CASE o.Type WHEN @string THEN 'string'
              WHEN @null THEN 'null'
              WHEN @int THEN 'int'
              WHEN @boolean THEN 'boolean'
              WHEN @int THEN 'int'
              WHEN @array THEN 'array' ELSE 'object' END
          FROM @TheHierarchy AS m
            CROSS APPLY OpenJson(StringValue) AS o
          WHERE m.ValueType IN
        ('array', 'object') AND Depth = @ii - 1;
 
        SELECT @rowcount = @@RowCount;
      END;
 
    INSERT INTO @ReturnTable
      (Element_ID, SequenceNo, Parent_ID, Object_ID, Name, StringValue, ValueType)
      SELECT element_id, element_id - sequenceNo, parent_ID,
        CASE WHEN ValueType IN ('object', 'array') THEN Object_ID ELSE NULL END,
        CASE WHEN NAME LIKE '[0-9]%' THEN NULL ELSE NAME END,
        CASE WHEN ValueType IN ('object', 'array') THEN '' ELSE StringValue END, ValueType
      FROM @TheHierarchy;
 
    RETURN;
  END;
GO
/****** Object:  UserDefinedFunction [dbo].[FindPatternLocation]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[FindPatternLocation]
(
    @string NVARCHAR(MAX),
    @term   NVARCHAR(MAX)
)
RETURNS TABLE
AS
    RETURN 
    (
      SELECT pos = Number - LEN(@term) 
      FROM (SELECT Number, Item = LTRIM(RTRIM(SUBSTRING(@string, Number, 
      CHARINDEX(@term, @string + @term, Number) - Number)))
      FROM (SELECT ROW_NUMBER() OVER (ORDER BY [object_id])
      FROM sys.all_objects) AS n(Number)
      WHERE Number > 1 AND Number <= CONVERT(INT, LEN(@string)+1)
      AND SUBSTRING(@term + @string, Number, LEN(@term)) = @term
    ) AS y);



GO
/****** Object:  Table [dbo].[EntityImages]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityImages](
	[ImageID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[EntityTypeID] [int] NULL,
	[EntityID] [int] NULL,
	[Image] [varchar](1000) NULL,
	[isMaster] [bit] NULL,
 CONSTRAINT [PK_EntityImages_ImageID] PRIMARY KEY CLUSTERED 
(
	[ImageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EntityMetaData]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityMetaData](
	[AGSID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[Name] [varchar](1000) NULL,
	[PluralName] [varchar](1000) NULL,
	[ChildName] [varchar](1000) NULL,
	[ChildPluralName] [varchar](1000) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_EntityMetaData_AGSID] PRIMARY KEY CLUSTERED 
(
	[AGSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkAttributes]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkAttributes](
	[AttributeID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	[StepItemID] [int] NOT NULL,
	[AttributeKey] [nvarchar](100) NOT NULL,
	[AttributeValue] [nvarchar](100) NOT NULL,
	[OrderBy] [int] NULL,
 CONSTRAINT [PK_FrameworkAttributes_AttributeID] PRIMARY KEY CLUSTERED 
(
	[AttributeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkAttributes_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkAttributes_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[FrameworkID] [int] NULL,
	[AttributeID] [int] NULL,
	[StepItemID] [int] NOT NULL,
	[AttributeKey] [nvarchar](100) NOT NULL,
	[AttributeValue] [nvarchar](100) NOT NULL,
	[OrderBy] [int] NULL,
 CONSTRAINT [PK_FrameworkAttributes_historys_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkLookups]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkLookups](
	[LookupID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NULL,
	[StepItemID] [int] NOT NULL,
	[LookupName] [nvarchar](100) NOT NULL,
	[LookupValue] [nvarchar](100) NOT NULL,
	[LookupType] [nvarchar](100) NULL,
	[OrderBy] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkLookups_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkLookups_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[FrameworkID] [int] NULL,
	[LookupID] [int] NULL,
	[StepItemID] [int] NOT NULL,
	[LookupName] [nvarchar](100) NOT NULL,
	[LookupValue] [nvarchar](100) NOT NULL,
	[LookupType] [nvarchar](100) NULL,
	[OrderBy] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Frameworks]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Frameworks](
	[FrameworkID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[Name] [varchar](500) NOT NULL,
	[FrameworkFile] [varchar](max) NOT NULL,
	[Namespace] [varchar](100) NULL,
 CONSTRAINT [PK_Frameworks_ID] PRIMARY KEY CLUSTERED 
(
	[FrameworkID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Frameworks_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Frameworks_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[FrameworkID] [int] NULL,
	[Name] [varchar](500) NOT NULL,
	[FrameworkFile] [varchar](max) NOT NULL,
	[Namespace] [varchar](100) NULL,
 CONSTRAINT [PK_Frameworks_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkStepItems]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkStepItems](
	[StepItemID] [int] IDENTITY(1,1) NOT NULL,
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
 CONSTRAINT [PK_Framework_Metafield_StepItemID] PRIMARY KEY CLUSTERED 
(
	[StepItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkStepItems_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkStepItems_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[FrameworkID] [int] NULL,
	[StepItemID] [int] NULL,
	[StepID] [int] NOT NULL,
	[StepItemName] [nvarchar](100) NOT NULL,
	[StepItemType] [nvarchar](100) NOT NULL,
	[StepItemKey] [nvarchar](100) NOT NULL,
	[OrderBy] [int] NULL,
 CONSTRAINT [PK_FrameworkStepItems_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkSteps]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkSteps](
	[StepID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[FrameworkID] [int] NOT NULL,
	[StepName] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_FrameworkSteps_StepID] PRIMARY KEY CLUSTERED 
(
	[StepID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FrameworkSteps_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FrameworkSteps_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[StepID] [int] NULL,
	[FrameworkID] [int] NULL,
	[StepName] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_FrameworkSteps_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterProperties]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterProperties](
	[RegisterPropertyID] [int] IDENTITY(1,1) NOT NULL,
	[RegisterID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PropertyName] [varchar](100) NOT NULL,
	[JSONType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RegisterProperties_RegisterPropertyID] PRIMARY KEY CLUSTERED 
(
	[RegisterPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterProperties_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterProperties_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[RegisterPropertyID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[PropertyName] [varchar](100) NOT NULL,
	[JSONType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RegisterProperties_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterPropertiesXref]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterPropertiesXref](
	[RegisterPropertiesXrefID] [int] IDENTITY(1,1) NOT NULL,
	[RegisterPropertyID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NULL,
	[IsRequired] [bit] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_RegisterPropertiesXref_RegisterID_RegisterPropertyID] PRIMARY KEY CLUSTERED 
(
	[RegisterPropertiesXrefID] ASC,
	[RegisterPropertyID] ASC,
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterPropertiesXref_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterPropertiesXref_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[RegisterPropertiesXrefID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[RegisterPropertyID] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NULL,
	[IsRequired] [bit] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_RegisterPropertiesXref_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterPropertyXerf_Data]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterPropertyXerf_Data](
	[RegisterPropertyXerf_DataID] [int] IDENTITY(1,1) NOT NULL,
	[RegisterID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
 CONSTRAINT [PK_RegisterPropertyXerf_Data_RegisterID] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterPropertyXerf_Data_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterPropertyXerf_Data_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[RegisterPropertyXerf_DataID] [int] NULL,
	[RegisterID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Registers]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Registers](
	[RegisterID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[Name] [varchar](500) NOT NULL,
	[FrameworkID] [int] NULL,
	[UniverseID] [int] NULL,
	[AccessControlID] [int] NULL,
	[WorkFlowACID] [int] NULL,
	[PropagatedAccessControlID] [int] NULL,
	[PropagatedWFAccessControlID] [int] NULL,
	[HasExtendedProperties] [bit] NULL,
 CONSTRAINT [PK_Registers_RegisterID] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Registers_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Registers_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Registers_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[RegisterID] [int] NULL,
	[Name] [varchar](500) NOT NULL,
	[FrameworkID] [int] NULL,
	[UniverseID] [int] NULL,
	[AccessControlID] [int] NULL,
	[WorkFlowACID] [int] NULL,
	[PropagatedAccessControlID] [int] NULL,
	[PropagatedWFAccessControlID] [int] NULL,
	[HasExtendedProperties] [bit] NULL,
 CONSTRAINT [PK_Registers_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Universe]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Universe](
	[UniverseID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[Name] [varchar](500) NOT NULL,
	[FrameworkID] [int] NULL,
	[ParentID] [int] NULL,
	[Height] [int] NULL,
	[Depth] [int] NULL,
	[AccessControlID] [int] NULL,
	[WorkFlowACID] [int] NULL,
	[PropagatedAccessControlID] [int] NULL,
	[PropagatedWFAccessControlID] [int] NULL,
	[HasExtendedProperties] [bit] NULL,
 CONSTRAINT [PK_Universe_UniverseID] PRIMARY KEY CLUSTERED 
(
	[UniverseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Universe_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Universe_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Universe_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[UniverseID] [int] NULL,
	[Name] [varchar](500) NOT NULL,
	[FrameworkID] [int] NULL,
	[ParentID] [int] NULL,
	[Height] [int] NULL,
	[Depth] [int] NULL,
	[AccessControlID] [int] NULL,
	[WorkFlowACID] [int] NULL,
	[PropagatedAccessControlID] [int] NULL,
	[PropagatedWFAccessControlID] [int] NULL,
	[HasExtendedProperties] [bit] NULL,
 CONSTRAINT [PK_Universe_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniverseProperties]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniverseProperties](
	[UniversePropertyID] [int] IDENTITY(1,1) NOT NULL,
	[UniverseID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PropertyName] [varchar](100) NOT NULL,
	[JSONType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UniverseProperties_UniversePropertyID] PRIMARY KEY CLUSTERED 
(
	[UniversePropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniverseProperties_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniverseProperties_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[UniversePropertyID] [int] NOT NULL,
	[UniverseID] [int] NOT NULL,
	[PropertyName] [varchar](100) NOT NULL,
	[JSONType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UniverseProperties_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniversePropertiesXref]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniversePropertiesXref](
	[UniversePropertiesXrefID] [int] IDENTITY(1,1) NOT NULL,
	[UniversePropertyID] [int] NOT NULL,
	[UniverseID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NULL,
	[IsRequired] [bit] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_UniversePropertiesXref_UniverseID_UniversePropertyID] PRIMARY KEY CLUSTERED 
(
	[UniversePropertiesXrefID] ASC,
	[UniversePropertyID] ASC,
	[UniverseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniversePropertiesXref_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniversePropertiesXref_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[UniversePropertiesXrefID] [int] NOT NULL,
	[UniverseID] [int] NOT NULL,
	[UniversePropertyID] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NULL,
	[IsRequired] [bit] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_UniversePropertiesXref_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniversePropertyXerf_Data]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniversePropertyXerf_Data](
	[UniversePropertyXerf_DataID] [int] IDENTITY(1,1) NOT NULL,
	[UniverseID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
 CONSTRAINT [PK_UniversePropertyXerf_Data_UniverseID] PRIMARY KEY CLUSTERED 
(
	[UniverseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniversePropertyXerf_Data_history]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniversePropertyXerf_Data_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[VersionNum] [int] NOT NULL,
	[PeriodIdentifierID] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[UserActionID] [int] NULL,
	[UniversePropertyXerf_DataID] [int] NULL,
	[UniverseID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EntityMetaData] ADD  CONSTRAINT [DF_EntityMetaData_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkAttributes] ADD  CONSTRAINT [DF_FrameworkAttributes_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkAttributes_history] ADD  CONSTRAINT [DF_FrameworkAttributes_history_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkLookups] ADD  CONSTRAINT [DF_FrameworkLookups_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkLookups_history] ADD  CONSTRAINT [DF_FrameworkLookups_history_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Frameworks] ADD  CONSTRAINT [DF_Frameworks_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Frameworks_history] ADD  CONSTRAINT [DF_Frameworks_history_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkStepItems] ADD  CONSTRAINT [DF_FrameworkStepItems_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkStepItems_history] ADD  CONSTRAINT [DF_FrameworkStepItems_history_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkSteps] ADD  CONSTRAINT [DF_FrameworkSteps_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FrameworkSteps_history] ADD  CONSTRAINT [DF_FrameworkSteps_history_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[RegisterProperties] ADD  CONSTRAINT [FK_RegisterProperties_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[RegisterPropertiesXref] ADD  CONSTRAINT [DF_RegisterPropertiesXref_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[RegisterPropertyXerf_Data] ADD  CONSTRAINT [DF_RegisterPropertyXerf_Data_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Registers] ADD  CONSTRAINT [DF_Registers_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Universe] ADD  CONSTRAINT [DF_Universe_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[UniverseProperties] ADD  CONSTRAINT [FK_UniverseProperties_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[UniversePropertiesXref] ADD  CONSTRAINT [DF_UniversePropertiesXref_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[UniversePropertyXerf_Data] ADD  CONSTRAINT [DF_UniversePropertyXerf_Data_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[RegisterPropertiesXref]  WITH CHECK ADD  CONSTRAINT [FK_RegisterPropertiesXref_RegisterID] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[Registers] ([RegisterID])
GO
ALTER TABLE [dbo].[RegisterPropertiesXref] CHECK CONSTRAINT [FK_RegisterPropertiesXref_RegisterID]
GO
ALTER TABLE [dbo].[RegisterPropertiesXref]  WITH CHECK ADD  CONSTRAINT [FK_RegisterPropertiesXref_RegisterPropertyID] FOREIGN KEY([RegisterPropertyID])
REFERENCES [dbo].[RegisterProperties] ([RegisterPropertyID])
GO
ALTER TABLE [dbo].[RegisterPropertiesXref] CHECK CONSTRAINT [FK_RegisterPropertiesXref_RegisterPropertyID]
GO
ALTER TABLE [dbo].[RegisterPropertyXerf_Data]  WITH CHECK ADD  CONSTRAINT [FK_RegisterPropertyXerf_Data_RegisterID] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[Registers] ([RegisterID])
GO
ALTER TABLE [dbo].[RegisterPropertyXerf_Data] CHECK CONSTRAINT [FK_RegisterPropertyXerf_Data_RegisterID]
GO
ALTER TABLE [dbo].[Registers]  WITH CHECK ADD  CONSTRAINT [FK_RegisterProperties_RegisterID] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[Registers] ([RegisterID])
GO
ALTER TABLE [dbo].[Registers] CHECK CONSTRAINT [FK_RegisterProperties_RegisterID]
GO
ALTER TABLE [dbo].[Universe]  WITH CHECK ADD  CONSTRAINT [FK_UniverseProperties_UniverseID] FOREIGN KEY([UniverseID])
REFERENCES [dbo].[Universe] ([UniverseID])
GO
ALTER TABLE [dbo].[Universe] CHECK CONSTRAINT [FK_UniverseProperties_UniverseID]
GO
ALTER TABLE [dbo].[UniversePropertiesXref]  WITH CHECK ADD  CONSTRAINT [FK_UniversePropertiesXref_UniverseID] FOREIGN KEY([UniverseID])
REFERENCES [dbo].[Universe] ([UniverseID])
GO
ALTER TABLE [dbo].[UniversePropertiesXref] CHECK CONSTRAINT [FK_UniversePropertiesXref_UniverseID]
GO
ALTER TABLE [dbo].[UniversePropertiesXref]  WITH CHECK ADD  CONSTRAINT [FK_UniversePropertiesXref_UniversePropertyID] FOREIGN KEY([UniversePropertyID])
REFERENCES [dbo].[UniverseProperties] ([UniversePropertyID])
GO
ALTER TABLE [dbo].[UniversePropertiesXref] CHECK CONSTRAINT [FK_UniversePropertiesXref_UniversePropertyID]
GO
ALTER TABLE [dbo].[UniversePropertyXerf_Data]  WITH CHECK ADD  CONSTRAINT [FK_UniversePropertyXerf_Data_UniverseID] FOREIGN KEY([UniverseID])
REFERENCES [dbo].[Universe] ([UniverseID])
GO
ALTER TABLE [dbo].[UniversePropertyXerf_Data] CHECK CONSTRAINT [FK_UniversePropertyXerf_Data_UniverseID]
GO
/****** Object:  StoredProcedure [dbo].[CalculateUniverseHeightAndDepth]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 
/*==============================================================================================
OBJECT NAME	 :  dbo.CalculateUniverseHeightAndDepth
PURPOSE	     :  
CREATED BY	 :  
CREATION DATE:  

USAGE: EXEC dbo.CalculateUniverseHeightAndDepth

CHANGE HISTORY:
SNo.   MODIFIED BY		DATE 			DESCRIPTION
===============================================================================================*/

CREATE   PROCEDURE [dbo].[CalculateUniverseHeightAndDepth]
AS
BEGIN
BEGIN TRY

		SET NOCOUNT ON;	

			--GET HEIGHT===============================================================================================================================
					
			CREATE TABLE #TMP_HeightAndDepth(ID INT, Name VARCHAR(500) COLLATE DATABASE_DEFAULT,ParentID INT,Height INT,Depth INT)
			--CREATE TABLE #TMP(ID INT, Name VARCHAR(500),ParentID INT,Height INT,Depth INT,Lvl INT)

			DECLARE @ID INT=0
				
				INSERT INTO #TMP_HeightAndDepth(ID,Name,ParentID,Height,Depth)
					SELECT UniverseID,[Name],ParentID,Height,Depth FROM dbo.Universe

			--SELECT * FROM	#TMP_HeightAndDepth
			UPDATE #TMP_HeightAndDepth SET Height = 0, Depth = 0

		;WITH CTE
		AS(
			SELECT ID,NAME,ParentID, Height, Depth,
			-- Row_Number returns a bigint - max value have 19 digits
			CAST(ROW_NUMBER()OVER(PARTITION BY PARENTID ORDER BY NAME) AS VARCHAR(MAX)) AS Path,
			CAST(ROW_NUMBER()OVER(PARTITION BY PARENTID ORDER BY NAME) AS VARCHAR(MAX)) AS ReversePath
			FROM #TMP_HeightAndDepth WHERE PARENTID IS NULL
			UNION ALL
			SELECT T.ID,T.NAME,T.ParentID, T.Height, T.Depth,
			--CONCAT(C.Path ,'.' , CAST(ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME) AS VARCHAR(MAX))),
			--CONCAT(CAST(ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME) AS VARCHAR(MAX)) ,'.' , C.ReversePath)
			CAST(CONCAT(C.Path ,'.' , ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME)) AS VARCHAR(MAX)),
			CAST(CONCAT(ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME) ,'.' , C.ReversePath) AS VARCHAR(MAX))
			FROM CTE C
				 INNER JOIN #TMP_HeightAndDepth T ON T.ParentID = C.ID
		)

		SELECT *, ROW_NUMBER()OVER(ORDER BY Path) AS ROWNUM
			INTO #TMP
		FROM CTE
		ORDER BY Path

		--SELECT * FROM #TMP

		ALTER TABLE #TMP_HeightAndDepth ADD LevelPath VARCHAR(MAX) COLLATE DATABASE_DEFAULT, ReversePath VARCHAR(MAX) COLLATE DATABASE_DEFAULT, LeafNode VARCHAR(MAX) COLLATE DATABASE_DEFAULT, Path VARCHAR(MAX) COLLATE DATABASE_DEFAULT

		UPDATE T
			SET HEIGHT = TMP.ROWNUM,
				DEPTH = TMP.ROWNUM,
				LevelPath = TMP.Path,
				ReversePath= TMP.ReversePath,
				LeafNode = PARSENAME(TMP.ReversePath,1),
				Path = TMP.Path
		FROM #TMP_HeightAndDepth T
			 INNER JOIN #TMP TMP ON T.ID=TMP.ID
			 		
		UPDATE #TMP_HeightAndDepth
			SET LeafNode = SUBSTRING(Path,1,CHARINDEX('.',Path)-1)	
		WHERE LeafNode IS NULL
			  AND Path IS NOT NULL

		--SELECT * FROM #TMP_HeightAndDepth ORDER BY HEIGHT	
		-- RETURN
		--===========================================================================================================================================================

		--GET DEPTH: STAMP THE DEPTH OF THE LEAF NODE TO ALL ITS PARENTS (UP UNTIL THE ROOT LEVEL)===============================================================================================================================
						
			IF OBJECT_ID('TEMPDB..#TMP_ALLLEAFNODESWITHPARENTS') IS NOT NULL
				DROP TABLE #TMP_ALLLEAFNODESWITHPARENTS
					
			IF OBJECT_ID('TEMPDB..#TMP_LEAFNODES') IS NOT NULL
				DROP TABLE #TMP_LEAFNODES

			 --GET ALL LEAFNODES
			SELECT * 
				INTO #TMP_LEAFNODES
			FROM #TMP_HeightAndDepth T
			WHERE NOT EXISTS(SELECT 1 FROM #TMP_HeightAndDepth WHERE ParentID = T.ID) 
					AND ParentID IS NOT NULL
			 
			 --RETAIN ONE WITH THE HIGHEST DEPTH
			 ;WITH CTE_LeafNodes
			 AS(
				 SELECT *, ROW_NUMBER()OVER(PARTITION BY ParentID,LeafNode ORDER BY Depth DESC) AS RowNum
				 FROM #TMP_LEAFNODES
			 )
			 DELETE FROM CTE_LeafNodes WHERE RowNum > 1
					

			 --THE TOP MOST PARENT'S DEPTH IS THE MAXIMUM HEIGHT AMONGST ALL ITS CHILDREN===================
			 SELECT LeafNode, MAX(Height) AS Depth
				INTO #TMP_ParentDepth
			 FROM #TMP_LEAFNODES 
			 GROUP BY LeafNode
			 
			 UPDATE TMP
			  SET Depth = T.Depth 
			  FROM #TMP_HeightAndDepth TMP
				   INNER JOIN #TMP_ParentDepth T ON T.LeafNode = TMP.LeafNode			  
			  WHERE TMP.ParentID IS NULL
			  --==============================================================================================

			--GET THE DEPTH OF THE REMAINING HIERARCHY: EACH DEPTH IS THE MAXIMUM HEIGHT FROM AMONGST ALL IT'S CHILDREN, IF NO CHILD THEN DEPTH IS SAME AS HEIGHT
			 SELECT *, SUBSTRING(T.LevelPath,1,pos-1) AS LevelPath_ToUpdate
				INTO #TMP_LevelPath_ToUpdate
			 FROM #TMP_LEAFNODES T
				  CROSS APPLY dbo.FindPatternLocation(T.LevelPath,'.')				  
			
			--DELETE THE TOP MOST PARENTS WHICH HAVE ALREADY BEEN STAMPED	
			DELETE T FROM #TMP_LevelPath_ToUpdate T WHERE EXISTS(SELECT 1 FROM #TMP_ParentDepth WHERE LeafNode=T.LevelPath_ToUpdate)

			;WITH CTE
			AS(
				SELECT *, ROW_NUMBER()OVER(PARTITION BY  LevelPath_ToUpdate ORDER BY Depth DESC) AS RowNum
				FROM #TMP_LevelPath_ToUpdate
			  )
			  DELETE FROM CTE WHERE ROWNUM > 1

			UPDATE T
				SET DEPTH = P.Depth
			FROM #TMP_HeightAndDepth T
				 INNER JOIN #TMP_LevelPath_ToUpdate P ON P.LevelPath_ToUpdate=T.LevelPath
			
			--SELECT * FROM #TMP_HeightAndDepth ORDER BY HEIGHT	
		--============================================================================================================================						
	
						--UPDATE HEIGHT & DEPTH IN THE MAIN TABLE
					 	UPDATE S
							SET Height = T.Height,
								Depth = T.Depth 
						FROM #TMP_HeightAndDepth T
								INNER JOIN dbo.Universe S ON S.UniverseID = T.ID					
					 										
				

			IF OBJECT_ID('TEMPDB..#TMP') IS NOT NULL
				DROP TABLE #TMP

			IF OBJECT_ID('TEMPDB..#LeafNodes') IS NOT NULL
				DROP TABLE #LeafNodes

			IF OBJECT_ID('TEMPDB..#LeafNodesWithDepth') IS NOT NULL
				DROP TABLE #LeafNodesWithDepth

			IF OBJECT_ID('TEMPDB..#TMP_HeightAndDepth') IS NOT NULL
				DROP TABLE #TMP_HeightAndDepth

			IF OBJECT_ID('TEMPDB..#TMP_GroupBy') IS NOT NULL
				DROP TABLE 	#TMP_GroupBy
		
			IF OBJECT_ID('TEMPDB..#TMP_Parents') IS NOT NULL
				DROP TABLE 	#TMP_Parents

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()

			IF OBJECT_ID('TEMPDB..#TMP') IS NOT NULL
				DROP TABLE #TMP

			IF OBJECT_ID('TEMPDB..#LeafNodes') IS NOT NULL
				DROP TABLE #LeafNodes

			IF OBJECT_ID('TEMPDB..#LeafNodesWithDepth') IS NOT NULL
				DROP TABLE #LeafNodesWithDepth

			IF OBJECT_ID('TEMPDB..#TMP_HeightAndDepth') IS NOT NULL
				DROP TABLE #TMP_HeightAndDepth
		
			IF OBJECT_ID('TEMPDB..#TMP_LevelPath_ToUpdate') IS NOT NULL
				DROP TABLE 	#TMP_LevelPath_ToUpdate


END CATCH

END

GO
/****** Object:  StoredProcedure [dbo].[CreateFrameworkSchemaTables]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.CreateFrameworkSchemaTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		 
USAGE:          	EXEC dbo.CreateFrameworkSchemaTables @FrameworkID=1,@VersionNum=1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/
 CREATE   PROCEDURE [dbo].[CreateFrameworkSchemaTables]
@FrameworkID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON;
	PRINT 'STARTING CreateSchemaTables...'

--DROP TABLE IF EXISTS TAB_FrameworkLookups
--drop table IF EXISTS TAB_FrameworkAttributes
--drop table IF EXISTS TAB_FrameworkStepItems
--drop table IF EXISTS TAB_FrameworkSteps
--DROP TABLE IF EXISTS TAB_Frameworks

/*
USE JUNK
GO
DROP TABLE IF EXISTS TAB_FrameworkLookups_history
drop table IF EXISTS TAB_FrameworkAttributes_history
drop table IF EXISTS TAB_FrameworkStepItems_history
drop table IF EXISTS TAB_FrameworkSteps_history
--DROP TABLE IF EXISTS TAB_Frameworks_history
*/

DECLARE @NewTableName VARCHAR(100)='TAB'
DECLARE @TableInitial VARCHAR(100) = @NewTableName
DECLARE @TBL TABLE(ID INT IDENTITY(1,1),NewTableName VARCHAR(500),Item VARCHAR(MAX))
DECLARE @ID INT, @TemplateTableName VARCHAR(100),@ParentTableName VARCHAR(100), @SQL NVARCHAR(MAX) = ''
DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500),KeyColName VARCHAR(100), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX),TableType VARCHAR(100))
DECLARE @TBL_List_Constraints TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX))
DECLARE @ConstraintSQL NVARCHAR(MAX),@HistoryTable VARCHAR(50)= '_history',@TableCheck VARCHAR(500)
DECLARE @DropConstraintsSQL NVARCHAR(MAX),@TableType VARCHAR(100),@KeyColName VARCHAR(100)


	--GET THE CURRENT VERSION NO.: THIS WILL ACTUALLY BE PASSED FROM THE PREVIOUS SCRIPT/CODE:ParseJSON_v2.sql
	--DECLARE @VersionNum INT = (SELECT MAX(VersionNum) FROM dbo.Frameworks_history)
 

--DECLARE @DropConstraints_SQL VARCHAR(MAX) = 'ALTER TABLE [dbo].[FrameworkStepItems] DROP CONSTRAINT [FK_FrameworkStepItems_StepID];
--									ALTER TABLE [dbo].[FrameworkAttributes] DROP CONSTRAINT [FK_FrameworkAttributes_StepItemID];
--									ALTER TABLE [dbo].[FrameworkLookups] DROP CONSTRAINT [FK_FrameworkLookups_StepItemID];
--									ALTER TABLE [dbo].FrameworkSteps DROP CONSTRAINT PK_FrameworkSteps_StepID;
--									ALTER TABLE [dbo].FrameworkStepItems DROP CONSTRAINT PK_FrameworkStepItems_StepItemID;
--									ALTER TABLE [dbo].FrameworkAttributes DROP CONSTRAINT PK_FrameworkAttributes_StepItemID;'


INSERT INTO @TBL_List(TemplateTableName,KeyColName,ParentTableName,TableType,ConstraintSQL)
VALUES	('FrameworkLookups','LookupValue','FrameworkStepItems','Lookups','ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemsID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]) '),
		('FrameworkAttributes','AttributeKey','FrameworkStepItems','Attributes','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID); ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]); '),		
		('FrameworkStepItems','StepItemKey','FrameworkSteps','StepItems','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID) ;ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT [FK_<TABLENAME>_StepID] FOREIGN KEY ( [StepID] ) REFERENCES [dbo].[<ParentTableName>] ([StepID]) '),
		('FrameworkSteps','StepName','','Steps','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepID PRIMARY KEY(StepID)')
		--,('Frameworks','Name','','','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_ID PRIMARY KEY(ID)')

	INSERT INTO @TBL_List_Constraints(TemplateTableName)
		SELECT TemplateTableName FROM @TBL_List	

UPDATE @TBL_List SET NewTableName = CONCAT(@NewTableName,'_',TemplateTableName)
UPDATE @TBL_List SET ParentTableName = CONCAT(@NewTableName,'_',ParentTableName) WHERE ParentTableName <> ''

DROP TABLE IF EXISTS #TBL_ConstraintsList
SELECT * INTO #TBL_ConstraintsList FROM @TBL_List

DROP TABLE IF EXISTS #TBL_OperationTypeList
SELECT IDENTITY(INT,1,1) AS ID,TemplateTableName,KeyColName,TableType INTO #TBL_OperationTypeList FROM @TBL_List WHERE TableType <> ''

 DECLARE @cols NVARCHAR(MAX) = N''
--SELECT * FROM @TBL_List

WHILE EXISTS(SELECT 1 FROM @TBL_List)
BEGIN
	 
	SELECT @ID = MIN(ID) FROM @TBL_List

	SELECT @TemplateTableName = TemplateTableName,
		   @NewTableName = NewTableName,
		   @ParentTableName = ParentTableName,
		   @ConstraintSQL = ConstraintSQL,
		   @TableType = TableType,
		   @KeyColName = KeyColName
	FROM @TBL_List 
	WHERE ID = @ID

		 --GENERATE COLUMNS LIST FOR TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		 SELECT @cols = CONCAT(@cols,N', [' , [NAME], '] ' , system_type_name , CASE WHEN is_identity_column = 1 THEN ' IDENTITY(1,1) PRIMARY KEY ' END,case is_nullable WHEN 1 THEN ' NULL' ELSE ' NOT NULL' END)
		 FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.'+ @TemplateTableName , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');
				
		IF @TemplateTableName LIKE '%FrameworkLookups%' OR @TemplateTableName LIKE '%FrameworkAttributes%'
			SET @SQL = CONCAT('DROP TABLE IF EXISTS ',@NewTableName, ';',CHAR(10))

		SET @SQL = CONCAT(@SQL,'IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME =''',@NewTableName,''')', CHAR(10))
		SET @SQL = CONCAT(@SQL, N' CREATE TABLE dbo.[', @NewTableName , '](', @cols, ') ', CHAR(10), CHAR(10))
		--SET @TableCheck = CONCAT('IF NOT EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME=''',@NewTableName ,''')')
		--SET @SQL = CONCAT(@TableCheck,CHAR(10),@SQL,';', CHAR(10), CHAR(10))	
		PRINT @SQL
		--CREATE THE ACTUAL TABLE BASED ON THE TEMPLATE TABLE SCHEMA
		EXEC sp_executesql @SQL 

		SELECT @SQL = '', @cols = ''

		--INSERT DATA INTO MAIN TABLE
		SELECT @cols += N', [' + name + '] ' 
		FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName) , NULL, 1);		

		SET @cols = STUFF(@cols, 1, 1, N'');
		
		SET @SQL = CONCAT('INSERT INTO dbo.',@NewTableName,'(', @cols, ') ', CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,' T', CHAR(10))
		SET @SQL = CONCAT(@SQL, 'WHERE NOT EXISTS(SELECT 1 FROM dbo.',@NewTableName, ' WHERE VersionNum = ', @VersionNum,' AND FrameworkID=',@FrameworkID,' AND ',@KeyColName,' = T.',@KeyColName,');', CHAR(10))
		--IF @TemplateTableName NOT LIKE '%FrameworkLookups%'
		SET @SQL = CONCAT('SET IDENTITY_INSERT ',@NewTableName,' ON ;', CHAR(10),@SQL, CHAR(10),'SET IDENTITY_INSERT ',@NewTableName,' OFF ;')
		PRINT @SQL
		EXEC sp_executesql @SQL 

		--UPDATE VERSION NUMBER		
		SET @SQL = CONCAT('UPDATE dbo.',@NewTableName,CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SET VersionNum = ',@VersionNum, CHAR(10))
		SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, CHAR(10))
		PRINT @SQL
		EXEC sp_executesql @SQL
		---------------------------------------------------------------------------------------------------------------------------
	
		SELECT @SQL = '', @cols = ''

		 --GENERATE COLUMNS LIST FOR HISTORY TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		 SELECT @cols = CONCAT(@cols,N', [' + name + '] ', system_type_name,  CASE WHEN is_identity_column = 1 THEN ' IDENTITY(1,1) PRIMARY KEY ' END,case is_nullable when 1 then ' NULL' else ' NOT NULL' end)
		 FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName,@HistoryTable) , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');

		--SET @SQL = CONCAT('DROP TABLE IF EXISTS ',@NewTableName)
		SET @SQL = CONCAT(N' CREATE TABLE dbo.[', @NewTableName ,@HistoryTable, '](', @cols, ') ')		
		SET @TableCheck = CONCAT('IF NOT EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME=''',@NewTableName ,@HistoryTable,''')')
		SET @SQL = CONCAT(@TableCheck,CHAR(10),@SQL,';', CHAR(10), CHAR(10))		
			
		PRINT @SQL
		
		--CREATE THE ACTUAL HISTORY TABLE BASED ON THE TEMPLATE TABLE SCHEMA
		EXEC sp_executesql @SQL 
		
		SELECT @SQL = '', @cols = ''

		--INSERT DATA INTO HISTORY TABLE		
		SELECT @cols += N', [' + name + '] ' 
		FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName,@HistoryTable) , NULL, 1)
		WHERE NAME <> 'HistoryID';

		SET @cols = STUFF(@cols, 1, 1, N'');

		SET @SQL = CONCAT('INSERT INTO dbo.',@NewTableName,@HistoryTable,'(', @cols, ') ', CHAR(10))		
		--IF @VersionNum = 1
		--	SET @cols = REPLACE(@cols,'[OperationType]','''INSERT''')
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,@HistoryTable,';', CHAR(10))		
		PRINT @SQL
		EXEC sp_executesql @SQL 

		SET @SQL = ''

		--UPDATE CURRENT IDENTIFIER IN HISTORY TABLE FOR OLDER VERSIONS
		SET @SQL = CONCAT('UPDATE dbo.',@NewTableName,@HistoryTable,CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SET PeriodIdentifierID = 0', CHAR(10))
		SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, ' AND VersionNum < ',@VersionNum, CHAR(10))		
		PRINT @SQL
		EXEC sp_executesql @SQL

		SET @SQL = ''
		
		--UPDATE VERSION NUMBER (THIS APPLIES ONLY TO LIST/STEPS/STEPITEMS TABLES)			
		--SET @SQL = CONCAT('UPDATE dbo.',@NewTableName,@HistoryTable,CHAR(10))		
		--SET @SQL = CONCAT(@SQL, 'SET VersionNum = ',@VersionNum, CHAR(10))
		--SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, CHAR(10))
		--SET @SQL = CONCAT(@SQL, ' AND ''',@NewTableName,''' LIKE ''%List%'' OR ''',@NewTableName,''' LIKE ''%Steps%'' OR ''',@NewTableName,''' LIKE ''%StepItems%'' ', CHAR(10))
		--PRINT @SQL
		--EXEC sp_executesql @SQL		
		---------------------------------------------------------------------------------------------------------------------------
		--RETURN
			
	DELETE FROM @TBL_List WHERE ID = @ID
	DELETE FROM @TBL WHERE NewTableName = @NewTableName
	SELECT @cols = '',@SQL='',@DropConstraintsSQL=''
	--RETURN
END
		
		--UPDATE OPERATION TYPE FLAG IN FRAMEWORK HISTORY TABLES==============================================
		IF @VersionNum > 1
			EXEC dbo.UpdateFrameworkHistoryOperationType @FrameworkID = @FrameworkID, @TableInitial = @TableInitial, @VersionNum = @VersionNum		
		--====================================================================================================

		 --SELECT * FROM @TBL		 	 
		 --SELECT * FROM #TBL_ConstraintsList
		 DROP TABLE IF EXISTS #TBL_List
		 SELECT * INTO #TBL_List FROM #TBL_ConstraintsList

		-- SELECT * FROM #TBL_List
		 --RETURN

 /*
--MOVE DATA FROM TEMPLATE TABLES TO FRAMEWORK & FRAMEWORK HISTORY TABLES
WHILE EXISTS(SELECT 1 FROM #TBL_List)
BEGIN
	 
	SELECT @ID = MIN(ID) FROM #TBL_List

	SELECT @TemplateTableName = TemplateTableName,
		   @NewTableName = NewTableName,
		   @ParentTableName = ParentTableName,
		   @ConstraintSQL = ConstraintSQL
	FROM #TBL_List 
	WHERE ID = @ID
			 
	 
	---- PARTITION SWITCH PARTITION
	SET @SQL = CONCAT('ALTER TABLE ', @TemplateTableName,' SWITCH PARTITION 1 TO ',@NewTableName,' PARTITION 1');
 
	EXEC sp_executesql @SQL 
	PRINT @sql  

	---- PARTITION SWITCH PARTITION: FOR HISTORY TABLES
	SET @SQL = CONCAT('ALTER TABLE ', @TemplateTableName,@HistoryTable,' SWITCH PARTITION 1 TO ',@NewTableName,@HistoryTable,' PARTITION 1');	
	EXEC sp_executesql @SQL 
	PRINT @sql  
			
	DELETE FROM #TBL_List WHERE ID = @ID
	DELETE FROM #TBL_List WHERE NewTableName = @NewTableName
	SELECT @SQL=''
	--RETURN
END		
*/
		
		PRINT 'CreateSchemaTables Completed...'
END		
GO
/****** Object:  StoredProcedure [dbo].[ParseAssessmentJSON]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseAssessmentJSON
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE ASSESSMENT PROPERTIES
				    2. PROPERTIES CAN ONLY BE INSERTED/DELETED (NO UPDATES); FOR MARKING OPERATION TYPE=DELETE: WHEN A PROPERTY IS REMOVED THE PROPERTY IS NOT DELETED FROM THE TABLE BUT MARKED AS INACTIVE
					   COLUMN FROM _DATA TABLE IS ALSO NOT REMOVED	
USAGE:             
					DECLARE @inputJSON VARCHAR(MAX) ='{
     
						"name": {
							"label": "Name",
							"tableView": true,
							"validate": {
								"required": true,
								"minLength": 3,
								"maxLength": 500
							},
							"key": "name",
							"properties": {
								"StepName": "General"
							},
							"type": "textfield",
							"input": true
						},
						"description": {
							"label": "Description",
							"autoExpand": false,
							"tableView": true,
							"key": "description",
							"properties": {
								"StepName": "General"
							},
							"type": "textarea",
							"input": true
						},
						"currency": {
							"label": "Currency",
							"widget": "choicesjs",
							"tableView": true,
							"data": {
								"values": [
									{
										"label": "USD",
										"value": "USD"
									},
									{
										"label": "INR",
										"value": "INR"
									},
									{
										"label": "ZAR",
										"value": "ZAR"
									},
									{
										"label": "GBP",
										"value": "GBP"
									}
								]
							},
							"selectThreshold": 0.3,
							"key": "currency",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"levelOfOperation": {
							"label": "Level of Operation",
							"widget": "choicesjs",
							"tableView": true,
							"data": {
								"values": [
									{
										"label": "Busienss Unit",
										"value": "Busienss Unit"
									},
									{
										"label": "Area",
										"value": "Area"
									},
									{
										"label": "Region",
										"value": "Region"
									},
									{
										"label": "Country",
										"value": "Country"
									},
									{
										"label": "Global",
										"value": "Global"
									}
								]
							},
							"selectThreshold": 0.3,
							"key": "levelOfOperation",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"assessmentContact": {
							"label": "Assessment Contact",
							"widget": "choicesjs",
							"tableView": true,
							"dataSrc": "custom",
							"data": {
								"values": [
									{
										"label": "",
										"value": ""
									}
								]
							},
							"dataType": "auto",
							"selectThreshold": 0.3,
							"key": "assessmentContact",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						}
					}'

					EXEC dbo.ParseAssessmentJSON @RegisterName ='ABC',@inputJSON = @inputJSON,@UserCreated = 100,@UserModified=NULL

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE   PROCEDURE [dbo].[ParseAssessmentJSON]
@RegisterName VARCHAR(500),
@inputJSON VARCHAR(MAX) = NULL,
@UserCreated INT,
@UserModified INT = NULL
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
	BEGIN TRAN

	DECLARE @ID INT,			
			@VersionNum INT,
			@RegisterID INT,
			@SQL NVARCHAR(MAX),
			@IsDataTypesCompatible BIT = 1
			
 DROP TABLE IF EXISTS #TMP_Objects
 DROP TABLE IF EXISTS #TMP_Assessments
 DROP TABLE IF EXISTS #TMP_NewRegisterProperties
 DROP TABLE IF EXISTS #TMP_AssessmentData
 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
 DROP TABLE IF EXISTS #TMP_RegisterPropertiesXref
 CREATE TABLE #TMP_NewRegisterProperties(RegisterPropertyID INT,RegisterID INT,PropertyName VARCHAR(1000))
	
	--LIST OF COMPATIBLE DATA TYPES==============================================================
		DECLARE @DataTypes TABLE
		 (
		 JSONType VARCHAR(50),
		 DataType VARCHAR(50),
		 DataTypeLength VARCHAR(50),
		 CompatibleTypes VARCHAR(500)
		 )

		 INSERT INTO @DataTypes (JSONType,DataType,DataTypeLength,CompatibleTypes)
			SELECT 'textfield','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'selectboxes','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'select','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'textarea','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'number','INT',NULL,'INT,FLOAT,DECIMAL,BIGINT,NVARCHAR' UNION ALL
			SELECT 'datetime','DATETIME',NULL,'DATETIME,DATE' UNION ALL
			SELECT 'date','DATE',NULL,'DATE,DATETIME,'

			--SELECT * FROM @DataTypes
	--===========================================================================================

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)

  SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS	
	   --AND StringValue <> ''
	  
	  -- SELECT * FROM #TMP_Objects

	    --GET ALL THE CHILD ELEMENTS FOR A PARENT
		;WITH CTE
		AS
		(	--PARENT
			SELECT CAST('' AS VARCHAR(50)) ParentName, Element_ID,Parent_ID,SequenceNo,[Name] AS KeyName,StringValue,ValueType,CAST('Object' AS VARCHAR(50)) AS ElementType
			FROM #TMP_Objects
			--WHERE Element_ID = 2
			      

			UNION ALL

			--CHILD ITEMS
			SELECT CAST(C.KeyName as varchar(50)),TMP.Element_ID,TMP.Parent_ID,TMP.SequenceNo,TMP.[Name],TMP.StringValue,TMP.ValueType,CAST('ObjectItems' AS VARCHAR(50)) AS ElementType
			FROM CTE C 
				 INNER JOIN #TMP_ALLSTEPS TMP ON TMP.Parent_ID = C.Element_ID			
			WHERE TMP.Name IN ('label','type')
		)

		SELECT *, 
			  CAST(NULL AS VARCHAR(100)) AS DataType,
			  CAST(NULL AS VARCHAR(100)) AS DataTypeLength,
			  CAST(NULL AS VARCHAR(100)) AS JSONType,
			  CAST(NULL AS VARCHAR(100)) AS CompatibleTypes
			INTO #TMP_Assessments
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')
		
		UPDATE TA
		SET DataType = DT.DataType,
			DataTypeLength = DT.DataTypeLength,
			JSONType = TA.StringValue,
			CompatibleTypes = DT.CompatibleTypes
		FROM #TMP_Assessments TA
			 INNER JOIN @DataTypes DT ON DT.JSONType = TA.StringValue
		WHERE TA.KeyName ='type'
		
		UPDATE TA 
				SET DataType= TA_Type.DataType,
					DataTypeLength= TA_Type.DataTypeLength,
					JSONType = TA_Type.StringValue,
					CompatibleTypes = TA_Type.CompatibleTypes
			FROM #TMP_Assessments TA
			     INNER JOIN #TMP_Assessments TA_Type ON TA.Parent_ID = TA_Type.Parent_ID
			WHERE TA.KeyName ='Label'
			      AND TA_Type.KeyName ='Type'

		--SELECT * FROM #TMP_Assessments
		--RETURN
		SELECT @VersionNum = VersionNum + 1,
			   @RegisterID = RegisterID
		FROM dbo.Registers 
		WHERE Name=@RegisterName
				 
		IF @RegisterID IS NULL
		BEGIN
			SET @VersionNum = 1

			INSERT INTO dbo.Registers(Name,UserCreated,VersionNum)
				SELECT @RegisterName, @UserCreated, @VersionNum

			SET @RegisterID =SCOPE_IDENTITY()
		END
		--ELSE
		--BEGIN
		--	 --POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
		--	EXEC dbo.UpdateAssessmentHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

		--	UPDATE dbo.Registers
		--	SET VersionNum = @VersionNum,
		--		UserModified = @UserModified,
		--		DateModified = GETUTCDATE()
		--	WHERE RegisterID = @RegisterID
	 --  END		
		--SELECT * FROM #TMP_Assessments
		--RETURN

		  --=================================================================================================================================
			IF @VersionNum > 1 
			BEGIN
				
				--CHECK FOR DATA TYPE COMPATIBILITY-----------------------------------------------------------------------------------------------
				DROP TABLE IF EXISTS #TMP_DataTypeMismatch

				SELECT @RegisterID AS RegisterID, @UserCreated AS UserCreated, @VersionNum AS VersionNum,TA.StringValue,TA.JSONType AS New_JSONType,
					  TA.DataType AS New_DataType,RP.JsonType AS Old_JSONType,DT.CompatibleTypes AS Old_CompatibleTypes
					 ,CHARINDEX(TA.DataType,DT.CompatibleTypes,1) AS Flag
					INTO #TMP_DataTypeMismatch
				FROM #TMP_Assessments TA
					INNER JOIN dbo.RegisterProperties RP ON RP.RegisterID = @RegisterID AND RP.PropertyName = TA.StringValue 
					INNER JOIN @DataTypes DT ON DT.JSONType = RP.JSONType
				WHERE TA.KeyName ='Label'
					  AND RP.VersionNum = @VersionNum - 1
					  AND CHARINDEX(TA.DataType,DT.CompatibleTypes,1) = 0
								  				
				IF EXISTS(SELECT 1
							FROM #TMP_DataTypeMismatch
						  )						
				BEGIN
					SELECT * FROM #TMP_DataTypeMismatch;
					THROW 50005, N'Data Type Compatibility Mismatch!!', 16;					
					ROLLBACK
					RETURN
				END
				-------------------------------------------------------------------------------------------------------------------------------------
					
					--IF "Type" FOR A PROPERTY HAS CHANGED
					UPDATE RP
					SET JsonType = TA.JsonType,
						VersionNum = @VersionNum,
						UserModified = @UserModified,
						DateModified = GETUTCDATE()
					FROM dbo.RegisterProperties RP
						 INNER JOIN #TMP_Assessments TA ON RegisterID = @RegisterID AND PropertyName = TA.StringValue
					WHERE RP.RegisterID = @RegisterID
						  AND RP.JSONType <> TA.JSONType
						  AND KeyName ='Label'

				--POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
				EXEC dbo.UpdateAssessmentHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

				UPDATE dbo.Registers
				SET VersionNum = @VersionNum,
					UserModified = @UserModified,
					DateModified = GETUTCDATE()
				WHERE RegisterID = @RegisterID

			END
		--==========================================================================================================================================================
			
			--IF "Type" FOR A PROPERTY HAS CHANGED
			--IF @VersionNum > 1
			--BEGIN

			--	UPDATE RP
			--	SET JsonType = TA.JsonType,
			--		VersionNum = @VersionNum,
			--		UserModified = @UserModified,
			--		DateModified = GETUTCDATE()
			--	FROM dbo.RegisterProperties RP
			--		 INNER JOIN #TMP_Assessments TA ON RegisterID = @RegisterID AND PropertyName = TA.StringValue
			--	WHERE RP.RegisterID = @RegisterID
			--		  AND RP.JSONType <> TA.JSONType
			--		  AND KeyName ='Label'

			--END
			--INSERT NEW PROPERTIES (IF ANY)
			INSERT INTO dbo.RegisterProperties(RegisterID,UserCreated,VersionNum,PropertyName,JSONType)
				OUTPUT INSERTED.RegisterPropertyID, inserted.RegisterID,INSERTED.PropertyName INTO #TMP_NewRegisterProperties(RegisterPropertyID,RegisterID,PropertyName)
			SELECT @RegisterID, @UserCreated, @VersionNum,StringValue,JSONType
			FROM #TMP_Assessments TA
			WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterProperties WHERE RegisterID = @RegisterID AND PropertyName = TA.StringValue)-- AND VersionNum = @VersionNum) 
			      AND KeyName ='Label'
			
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.RegisterProperties
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID

			/*
				SELECT RegisterPropertyID,RegisterID,PropertyName,1 AS IsActive
					INTO #TMP_RegisterPropertiesXref
				FROM #TMP_NewRegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
				
				UNION
			*/
				--INSERT MISSING PROPERTIES AS WELL: THIS IS TO HANDLE ANY DELETES IN THE CURRENT VERSION
				SELECT RP.RegisterPropertyID,RP.RegisterID,RP.PropertyName,0 AS IsActive
					INTO #TMP_MissingRegistersProperties
				FROM dbo.RegisterProperties RP 
					  INNER JOIN RegisterPropertiesXref RPX ON RPX.RegisterPropertyID = RP.RegisterPropertyID AND RPX.RegisterID=RP.RegisterID
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_Assessments WHERE StringValue = RP.PropertyName AND KeyName ='Label')
					  AND RP.RegisterID = @RegisterID
					   AND RPX.IsActive = 1

				--INSERT BACK A PROPERTY WHICH WAS REMOVED EARLIER
				SELECT RP.RegisterPropertyID,RP.RegisterID,RP.PropertyName,1 AS IsActive
					INTO #TMP_ActivateMissingRegistersProperties
				FROM dbo.RegisterProperties RP
					 INNER JOIN RegisterPropertiesXref RPX ON RPX.RegisterPropertyID = RP.RegisterPropertyID AND RPX.RegisterID=RP.RegisterID
				WHERE EXISTS(SELECT 1 FROM #TMP_Assessments TA WHERE TA.StringValue = RP.PropertyName AND KeyName ='Label')
					 AND RP.RegisterID = @RegisterID
					 AND RPX.IsActive = 0	
			
			INSERT INTO dbo.RegisterPropertiesXref(RegisterPropertyID,RegisterID,UserCreated,VersionNum,PropertyName,IsActive)
				SELECT RegisterPropertyID, RegisterID,@UserCreated,@VersionNum,PropertyName,1
				FROM #TMP_NewRegisterProperties --#TMP_NewRegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.RegisterPropertiesXref
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID

			--INACTIVATE THE PROPERTIES WHICH WERE REMOVED
			UPDATE RPX
			SET IsActive = 0,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.RegisterPropertiesXref RPX		
			WHERE RegisterID = @RegisterID
				 AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX.PropertyName AND RegisterPropertyID = RPX.RegisterPropertyID)
			
			--ACTIVATE THE PROPERTIES WHICH WERE ADDED BACK
			UPDATE RPX
			SET IsActive = 1,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.RegisterPropertiesXref RPX		
			WHERE RegisterID = @RegisterID
				 AND EXISTS(SELECT 1 FROM #TMP_ActivateMissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX.PropertyName AND RegisterPropertyID = RPX.RegisterPropertyID)
				 			
							
			SELECT * INTO #TMP_AssessmentData 
			FROM #TMP_Assessments
			WHERE KeyName ='Label'
			
			--SELECT * FROM #TMP_AssessmentData
			--RETURN

				DECLARE @DataCols VARCHAR(MAX) 
				 SET @DataCols =STUFF(
							 (SELECT CONCAT(', [',TA.StringValue,'] [', TA.DataType,'] ', TA.DataTypeLength)
							 FROM #TMP_AssessmentData TA								  
							  WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.StringValue AND C.object_id =OBJECT_ID('RegisterPropertyXerf_Data'))
							 FOR XML PATH('')
							 )
							 ,1,1,'')
				PRINT @DataCols	

				IF @DataCols IS NOT NULL
				BEGIN
					SET @SQL = CONCAT(N' ALTER TABLE dbo.RegisterPropertyXerf_Data ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					--CREATE _DATA_HISTORY TABLE
					SET @SQL = CONCAT(N' ALTER TABLE dbo.RegisterPropertyXerf_Data_history ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					
					--CREATE TRIGGER
					DECLARE @cols VARCHAR(MAX) = ''

					SELECT @cols = CONCAT(@cols,N', [',name,'] ')
					FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.RegisterPropertyXerf_Data' , NULL, 1)
					
					SET @cols = STUFF(@cols, 1, 1, N'');
									 

					IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME ='RegisterPropertyXerf_Data_Insert')						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '

					SET @SQL = CONCAT(@SQL,N' dbo.RegisterPropertyXerf_Data_Insert
									   ON  dbo.RegisterPropertyXerf_Data
									   AFTER INSERT
									AS 
									BEGIN
										SET NOCOUNT ON;

										INSERT INTO dbo.RegisterPropertyXerf_Data_history(<ColumnList>)
											SELECT <columnList>
											FROM INSERTED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				END
		 --RETURN
	 		
			--POPULATE THE HISTORY TABLES FOR THE FIRST VERSION OF DATA (AFTER ALL THE DATA HAS BEEN POPULATED IN THE MAIN TABLES)
			IF @VersionNum = 1 OR EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties)
				EXEC dbo.UpdateAssessmentHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

			--UPDATE OPERATION TYPE IN HISTORY TABLE-------
			IF @VersionNum > 1
			BEGIN

			--UPDATE RPX_Hist
			--	SET OperationType = 'DELETE'				 
			--FROM dbo.RegisterPropertiesXref_history RPX_Hist
			--	 INNER JOIN dbo.RegisterPropertiesXref RPX ON RPX.RegisterID=RPX_Hist.RegisterID AND RPX.RegisterPropertyID=RPX_Hist.RegisterPropertyID
			--WHERE RPX_Hist.VersionNum = @VersionNum
			--	  AND Rpx.IsActive = 0
				 
			UPDATE RPX_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.RegisterPropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				  AND RPX_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX_Hist.PropertyName AND RegisterPropertyID = RPX_Hist.RegisterPropertyID)
			
			UPDATE RP_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.RegisterProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RP_Hist.PropertyName AND RegisterPropertyID = RP_Hist.RegisterPropertyID)


			UPDATE RPX_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.RegisterPropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				  AND RPX_Hist.RegisterID = @RegisterID
				  AND (EXISTS(SELECT 1 FROM #TMP_ActivateMissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX_Hist.PropertyName AND RegisterPropertyID = RPX_Hist.RegisterPropertyID)
					   OR EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties  WHERE RegisterID=@RegisterID AND PropertyName=RPX_Hist.PropertyName AND RegisterPropertyID = RPX_Hist.RegisterPropertyID)
					  )
			
			UPDATE RP_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.RegisterProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties WHERE RegisterID=@RegisterID AND PropertyName=RP_Hist.PropertyName AND RegisterPropertyID = RP_Hist.RegisterPropertyID)
				  
		 	UPDATE RP_Hist
				SET OperationType = 'UPDATE'				 
			FROM dbo.RegisterProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM RegisterProperties_history WHERE RegisterID=@RegisterID AND PropertyName=RP_Hist.PropertyName AND RegisterPropertyID = RP_Hist.RegisterPropertyID
								AND VersionNum = RP_Hist.VersionNum - 1
								AND JSONType <> RP_Hist.JSONType
							)
	
			END
			------------------------------------------------
		
		 COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK
	END CATCH	
	
		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_Assessments
		 DROP TABLE IF EXISTS #TMP_NewRegisterProperties
		 DROP TABLE IF EXISTS #TMP_AssessmentData
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
		 DROP TABLE IF EXISTS #TMP_RegisterPropertiesXref
		 DROP TABLE IF EXISTS #TMP_RegistersProperties
		 --------------------------------------------------------

END
GO
/****** Object:  StoredProcedure [dbo].[ParseFrameworkJSONData]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseFrameworkJSONData
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					Steps: ASSUMPTION: 1. STEPS VERSIONING CAN ONLY BE LIMITED TO INSERT OR DELETE (i.e. A STEP(A TAB) CAN BE ADDED OR REMOVED ONLY)
									   2. STEPNAME/STEPITEM (FOR _DATA COLUMNS) WILL BE IN FORMAT: STEPNAME.STEPITEM 
										  IT CAN HAVE MULTIPLE DOTS IN BETWEEN BUT TEXT BEFORE THE 1ST DOT IS ALWAYS A STEP NAME, TEXT AFTER THE LAST DOT IS ALWAYS A STEP ITEM (FOR _DATA COLUMNS)
										  SO THE FIRST PART IS STEPNAME, THE LAST PART IS THE NAME OF THE COLUMN FOR _DATA TABLE, THE STEPITEM NAME IS THE ONE WITH "LABEL"
USAGE:          	EXEC dbo.ParseFrameworkJSONData  @Name = 'TAB',
													 @UserCreated=100,
													 @inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE   PROCEDURE [dbo].[ParseFrameworkJSONData]
@Name VARCHAR(100),
@InputJSON VARCHAR(MAX) = NULL,
@UserCreated INT
AS
BEGIN
	SET NOCOUNT ON;

--EMPTY THE TEMPLATE TABLES----------------------
TRUNCATE TABLE dbo.FrameworkLookups_history
TRUNCATE TABLE dbo.FrameworkAttributes_history
TRUNCATE TABLE dbo.FrameworkStepItems_history
TRUNCATE TABLE dbo.FrameworkSteps_history

TRUNCATE TABLE dbo.FrameworkLookups
TRUNCATE TABLE dbo.FrameworkAttributes
TRUNCATE TABLE dbo.FrameworkStepItems
TRUNCATE TABLE dbo.FrameworkSteps
------------------------------------------------
 
DROP TABLE IF EXISTS #TMP_ALLSTEPS 

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)

 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =2
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =20

 --SELECT * FROM #TMP_ALLSTEPS
 --RETURN

 DROP TABLE IF EXISTS #TMP_Objects

 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS
	   --AND Element_ID<=12 --FILTERING OUT USERCREATED,DATECREATED,SUBMIT ETC.
	   AND Name NOT IN ('userCreated','dateCreated','userModified','dateModified','submit')
	  -- AND NAME IN ('Name','riskCategory1')
	    
 
-- SELECT * FROM #TMP_Objects
 --RETURN
	 	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500), --='XYZ',
			@StepItemType VARCHAR(500),		 
			@StepItemName VARCHAR(500),
			@LookupValues VARCHAR(1000),
			@StepItemID INT,			
			@VersionNum INT,
			@StepItemKey VARCHAR(100),
			--@Name VARCHAR(100) = 'TAB',
			@SQL NVARCHAR(MAX),
			@FrameworkID INT,
			@IsAvailable BIT,
			@TemplateTableName SYSNAME,
			@Counter INT = 1,
			@AttributeID INT, @LookupID INT
	 	
	--BUILD SCHEMA FOR _DATA TABLE============================================================================================	 
	 DROP TABLE IF EXISTS TAB_DATA -- REMOVE THIS LATER, NOT REQUIRED

	 DECLARE @DayString VARCHAR(20)='day'
	 DECLARE @SQL_ID VARCHAR(MAX)='ID INT IDENTITY(1,1)'
	 DECLARE @StaticCols VARCHAR(MAX) =	 
	 'UserCreated INT NOT NULL, 
	 DateCreated DATETIME2(0) NOT NULL, 
	 UserModified INT,
	 DateModified DATETIME2(0),
	 VersionNum INT NOT NULL'
	 
	 DROP TABLE IF EXISTS #TMP_DATA
     DROP TABLE IF EXISTS #TMP_DATA_DAY
	 DROP TABLE IF EXISTS #TMP_DATA_DOT
	 DROP TABLE IF EXISTS #TMP_DATA_StepName	 

	 SELECT TOB.Element_ID, TOB.NAME,TA.StringValue, CAST(NULL AS VARCHAR(50)) AS DataType,
			CAST(NULL AS VARCHAR(50)) AS DataTypeLength,
			CAST(NULL AS VARCHAR(500)) AS StepName
		INTO #TMP_DATA
	 FROM #TMP_Objects TOB
		 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TOB.Element_ID
	 WHERE TA.Name = 'type'
	
	 UPDATE #TMP_DATA
		SET DataType = CASE WHEN StringValue IN ('textfield','selectboxes','select','textarea','email','URL','phoneNumber','tags','signature','password','button') THEN 'NVARCHAR' 
							WHEN StringValue IN ('number','checkbox','radio') THEN 'INT'
							WHEN StringValue = 'datetime' THEN 'DATETIME' 							
							WHEN StringValue = 'currency' THEN 'FLOAT'
							WHEN StringValue = 'time' THEN 'TIME'
					   END
	
	UPDATE #TMP_DATA
		SET DataTypeLength = CASE WHEN DataType = 'NVARCHAR' THEN '(MAX)'
							 END
		
	 SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos
		INTO #TMP_DATA_DAY
	 FROM #TMP_DATA T
		  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB
	WHERE T.StringValue= @DayString
	GROUP BY T.Element_ID,T.Name
	
	INSERT INTO #TMP_DATA(Element_ID, NAME,StringValue,DataType)
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Day'),@DayString,'INT'
		FROM #TMP_DATA_DAY
		UNION
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Month'),@DayString,'INT'
		FROM #TMP_DATA_DAY
		UNION
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Year'),@DayString,'INT'
		FROM #TMP_DATA_DAY
		UNION
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Date'),@DayString,'INT'
		FROM #TMP_DATA_DAY
	
	--SINCE WE HAVE CREATED 4 NEW COLUMNS OUT OF THIS REMOVE THIS RECORD
	DELETE TD FROM #TMP_DATA TD WHERE EXISTS(SELECT 1 FROM #TMP_DATA_DAY WHERE Name=TD.Name) AND StringValue='day'
	
	--EXTRACT STEP ITEM(AFTER LAST DOT) & STEP NAME(BEFORE FIRST DOT)-----------------
	SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos,MIN(TAB.pos) AS MinPos
		INTO #TMP_DATA_DOT
	 FROM #TMP_DATA T
		  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB		
	GROUP BY T.Element_ID,T.Name

	--STEP ITEM FOR _DATA COLUMNS
	UPDATE TD
		SET Name = SUBSTRING(TDD.Name,TDD.Pos+1,len(TDD.Name))
	FROM #TMP_DATA TD
		 INNER JOIN #TMP_DATA_DOT TDD ON TD.Element_ID=TDD.Element_ID
	WHERE TD.StringValue <> @DayString
	 
	--STEP NAME
	UPDATE TD
		SET StepName = SUBSTRING(TDD.Name,1,TDD.MinPos-1)
	FROM #TMP_DATA TD
		 INNER JOIN #TMP_DATA_DOT TDD ON TD.Element_ID=TDD.Element_ID
	WHERE TD.StringValue <> @DayString
	-----------------------------------------------------------------------------------
				
	 DECLARE @DataCols VARCHAR(MAX) 
	 SET @DataCols = --STUFF(
					 (SELECT CONCAT(', [',[Name],'] [', DataType,'] ', DataTypeLength)
					 FROM #TMP_DATA
					 FOR XML PATH('')
					 )
					 --,1,1,'')
	PRINT @DataCols	

	SET @DataCols = CONCAT(@SQL_ID,@DataCols,CHAR(10),',',@StaticCols)
	SET @SQL = CONCAT(N' CREATE TABLE dbo.', @Name ,'_data',CHAR(10), '(', @DataCols, ') ',CHAR(10))
	PRINT @SQL
	
	EXEC sp_executesql @SQL	
	--===========================================================================================================================

			
	DECLARE @TableName SYSNAME = 'dbo.Frameworks'
	SET @SQL = ''
	
	--GET THE FrameworkID & VERSION NO.: CHECK FOR THE EXISTENCE OF THE JSONKEY		
		--SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10)) --ASSUSMPTION:Frameworks IS ALREADY AVAILABLE
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM ',@TableName,')', CHAR(10))	--ASSUSMPTION:Frameworks IS ALREADY AVAILABLE
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @FrameworkID = FrameworkID, @VersionNum = VersionNum + 1 FROM ',@TableName,' WHERE Name = ''', @Name,''' ORDER BY FrameworkID DESC');	
		SET @SQL = CONCAT(@SQL,' IF @FrameworkID IS NULL ')
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @FrameworkID = MAX(FrameworkID) + 1,@VersionNum = MAX(VersionNum) + 1 FROM ',@TableName);
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE SELECT @FrameworkID = 1, @IsAvailable = NULL, @VersionNum = 1;', CHAR(10))	--FIRST RECORD
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@FrameworkID INT OUTPUT, @VersionNum INT OUTPUT, @IsAvailable BIT OUTPUT',@FrameworkID OUTPUT, @VersionNum OUTPUT,@IsAvailable OUTPUT;

	IF @VersionNum IS NULL
		SET @VersionNum = 1

	--INSERT NEW JSONKEY(NAME) IF IT DOES NOT EXIST=====================================================================================		
	IF @IsAvailable IS NULL OR @IsAvailable = 0	
	BEGIN
		SET IDENTITY_INSERT dbo.Frameworks ON;

		INSERT INTO dbo.Frameworks (FrameworkID,Name,FrameworkFile,UserCreated,DateCreated,VersionNum)
			SELECT  @FrameworkID,
					@Name,	
					@inputJSON,		
					@UserCreated,
					GETUTCDATE(),
					@VersionNum

		--SET @FrameworkID = SCOPE_IDENTITY()	
		SET IDENTITY_INSERT dbo.Frameworks OFF;
	END	
	ELSE ---RECORDS ALREADY AVAILABLE FOR PREVIOUS VERSIONS		
		UPDATE dbo.Frameworks
			SET VersionNum = @VersionNum,
				UserModified = 1,
				DateModified = GETUTCDATE()
		WHERE FrameworkID = @FrameworkID --AND Name = @Name
 --==================================================================================================================================
		
 				
--PROCESS THE STEP ITEMS ONE BY ONE
 WHILE EXISTS(SELECT 1 FROM #TMP_Objects)
 BEGIN
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

		SELECT @ID = MIN(Element_ID) FROM #TMP_Objects
		
		--GET ALL THE CHILD ELEMENTS FOR A PARENT
		;WITH CTE
		AS
		(	--PARENT
			SELECT CAST('' AS VARCHAR(50)) ParentName, Element_ID,Parent_ID,SequenceNo,[Name] AS KeyName,StringValue,ValueType,CAST('Object' AS VARCHAR(50)) AS ElementType
			FROM #TMP_Objects
			WHERE Element_ID = @ID

			UNION ALL

			--CHILD ITEMS
			SELECT CAST(C.KeyName as varchar(50)),TMP.Element_ID,TMP.Parent_ID,TMP.SequenceNo,TMP.[Name],TMP.StringValue,TMP.ValueType,CAST('ObjectItems' AS VARCHAR(50)) AS ElementType
			FROM CTE C 
				 INNER JOIN #TMP_ALLSTEPS TMP ON TMP.Parent_ID = C.Element_ID			
		)

		SELECT *
			INTO #TMP 
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')		
		--WHERE ISNULL(KeyName,'') <> '' 
		--	  AND Parent_ID > 0
		
		SELECT @StepItemType = (SELECT StringValue FROM #TMP WHERE KeyName ='type' AND Parent_ID = @ID),
			   @StepItemName = (SELECT StringValue FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
			   @StepItemKey = (SELECT StringValue FROM #TMP WHERE KeyName ='key' AND Parent_ID = @ID),	
			   @StepName  = (SELECT TOP 1 TD.StepName FROM #TMP T INNER JOIN #TMP_DATA TD ON T.Parent_ID = TD.Element_ID )  
			   			    		
	
		--CHECK FOR THE EXISTENCE OF THE STEP======================================================================================================		
		SELECT @SQL = '', @StepID= NULL,@IsAvailable = NULL
		SET @TemplateTableName = 'FrameworkSteps'
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
		
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepID = StepID FROM ',@TableName,' WHERE FrameworkID = ', @FrameworkID,' AND StepName = ''', @StepName,''' ORDER BY StepID DESC;', CHAR(10));				
		SET @SQL = CONCAT(@SQL,' IF @StepID IS NULL ')
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TemplateTableName,CHAR(10));	
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TableName);	
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))		--FIRST VERSION
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS IN THE VERY FIRST VERSION
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = StepID FROM ',@TemplateTableName,' WHERE FrameworkID = ', @FrameworkID,' AND StepName = ''', @StepName,'''',CHAR(10));
		SET @SQL = CONCAT(@SQL,' IF @StepID IS NULL ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TemplateTableName,CHAR(10));	
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = 1, @IsAvailable = NULL;', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@StepID INT OUTPUT,@IsAvailable BIT OUTPUT',@StepID OUTPUT,@IsAvailable OUTPUT;
		
		IF @IsAvailable IS NULL OR @IsAvailable = 0		
		BEGIN			
				SET IDENTITY_INSERT dbo.FrameworkSteps ON;
				
				INSERT INTO dbo.FrameworkSteps (StepID,FrameworkID,StepName,DateCreated,UserCreated,VersionNum)
					SELECT @StepID,@FrameworkID,@StepName,GETUTCDATE(),@UserCreated,@VersionNum	
			
				--SET @StepID = SCOPE_IDENTITY()
				SET IDENTITY_INSERT dbo.FrameworkSteps OFF;
		END
		ELSE
			UPDATE dbo.FrameworkSteps
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETUTCDATE()
			WHERE StepID = @StepID			
		--===========================================================================================================================================

		IF NOT EXISTS(SELECT 1 FROM [dbo].[FrameworkSteps_history] WHERE FrameworkID=@FrameworkID AND StepID=@StepID AND VersionNum=@VersionNum AND StepName=@StepName)
			INSERT INTO [dbo].[FrameworkSteps_history]
					   (StepID,
						FrameworkID,
						[StepName]
					   ,[UserCreated]
					   ,[DateCreated]				   
					   ,[VersionNum],
					   PeriodIdentifierID)
					SELECT	@StepID,
							@FrameworkID,
							@StepName,
							1,
							GETUTCDATE(),
							@VersionNum,
							1
										
		IF @StepID IS NOT NULL
		BEGIN
				
			--CHECK FOR THE EXISTENCE OF THE STEPITEM======================================================================================================
			SELECT @SQL = '', @StepItemID= NULL,@IsAvailable = NULL
			SET @TemplateTableName = 'FrameworkStepItems'
			SET @TableName = CONCAT(@Name,'_',@TemplateTableName)

			SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
			--STEPITEMKEY IS THE UNIQUE IDENTIFIER SO CAN OMIT STEPID
			--SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepItemID = StepItemID FROM ',@TableName,' WHERE FrameworkID =',@FrameworkID,' AND StepID = ', @StepID,' AND StepItemKey = ''', @StepItemKey,''' ORDER BY StepItemID DESC;', CHAR(10));	
			SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepItemID = StepItemID FROM ',@TableName,' WHERE FrameworkID =',@FrameworkID,' AND StepItemKey = ''', @StepItemKey,''' ORDER BY StepItemID DESC;', CHAR(10));	
			SET @SQL = CONCAT(@SQL,' IF @StepItemID IS NULL ')
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TemplateTableName,CHAR(10));	
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TableName);	
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))		--FIRST VERSION
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS IN THE VERY FIRST VERSION
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = StepItemID FROM ',@TemplateTableName,' WHERE FrameworkID = ', @FrameworkID,' AND StepItemKey = ''', @StepItemKey,'''',CHAR(10));
			SET @SQL = CONCAT(@SQL,' IF @StepItemID IS NULL ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TemplateTableName,CHAR(10));	
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = 1, @IsAvailable = NULL;', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))	
			PRINT @SQL  
			EXEC sp_executesql @SQL, N'@StepItemID INT OUTPUT,@IsAvailable BIT OUTPUT',@StepItemID OUTPUT,@IsAvailable OUTPUT;
		
		IF @IsAvailable IS NULL OR @IsAvailable = 0
		BEGIN

					SET IDENTITY_INSERT dbo.FrameworkStepItems ON;

					INSERT INTO dbo.FrameworkStepItems (StepItemID,FrameworkID,StepID,StepItemName,StepItemType,StepItemKey,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT  @StepItemID,
								@FrameworkID,
								@StepID,								
								@StepItemName,
								@StepItemType,
								@StepItemKey,
								(SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
								GETUTCDATE(),@UserCreated,@VersionNum	

					--SET @StepItemID = SCOPE_IDENTITY()
					SET IDENTITY_INSERT dbo.FrameworkStepItems OFF;				
		END
		ELSE IF NOT EXISTS(SELECT 1 FROM FrameworkStepItems WHERE StepItemKey = @StepItemKey AND StepID = @StepID) --KEY MOVED TO A DIFFERENT STEP
				UPDATE dbo.FrameworkStepItems
					SET StepID = @StepID,
						VersionNum = @VersionNum
				WHERE StepItemKey = @StepItemKey
		ELSE
			UPDATE dbo.FrameworkStepItems
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETUTCDATE()
			WHERE @StepItemID = StepItemID --StepItemKey = @StepItemKey
			
			IF NOT EXISTS(SELECT 1 FROM [dbo].[FrameworkStepItems_history] WHERE FrameworkID=@FrameworkID AND StepID=@StepID AND StepItemID=@StepItemID AND VersionNum=@VersionNum)
				INSERT INTO [dbo].[FrameworkStepItems_history]
						   (FrameworkID,
							StepItemID,
							[StepID]
						   ,[StepItemName]
						   ,[StepItemType]
						   ,[StepItemKey]
						   ,[OrderBy]
						   ,[UserCreated]
						   ,[DateCreated]						  
						   ,[VersionNum],
						   PeriodIdentifierID)
				SELECT @FrameworkID,
					   @StepItemID,
					   @StepID,
					   @StepItemName,
					   @StepItemType,
					   @StepItemKey,
					   (SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
					   1,
					   GETUTCDATE(),
					   @VersionNum,
					   1 
				--IF @StepItemID IS NULL
				--	SELECT @StepItemID = StepItemID
				--	FROM dbo.FrameworkStepItems
				--	WHERE StepItemKey = @StepItemKey
			
				DELETE FROM #TMP WHERE KeyName IN ('Label','type','key') AND Parent_ID = @ID	
								
				--SELECT * FROM #TMP 
				--RETURN				
					
		--GET ATTRIBUTE/LOOKUP ID FOR NEW DATA THAT NEEDS TO BE INSERTED
		--================================================================================================================================== 		
		SELECT @SQL = ''
		SET @TemplateTableName = 'FrameworkAttributes'
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' SELECT @AttributeID = MAX(AttributeID) + 1 FROM ',@TableName);						
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@AttributeID INT OUTPUT',@AttributeID OUTPUT;

		
		IF @AttributeID IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.FrameworkAttributes)
			SET @AttributeID = 0;
		ELSE IF EXISTS(SELECT 1 FROM dbo.FrameworkAttributes)
			SELECT @AttributeID  = MAX(AttributeID) + 1 FROM dbo.FrameworkAttributes
						
		SELECT @SQL = ''
		SET @TemplateTableName = 'FrameworkLookups'
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM ',@TableName,')', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @LookupID = MAX(LookupID) + 1 FROM ',@TableName);						
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@LookupID INT OUTPUT',@LookupID OUTPUT;
			
		IF @LookupID IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.FrameworkLookups)		
			SET @LookupID = 0;			
		ELSE IF EXISTS(SELECT 1 FROM dbo.FrameworkLookups)		
			SELECT @LookupID  = MAX(LookupID) + 1 FROM dbo.FrameworkLookups
		--==================================================================================================================================
					
					SET IDENTITY_INSERT dbo.[FrameworkAttributes] ON;
		
					--GET THE STEPITEM ATTRIBUTES					 				
					INSERT INTO dbo.FrameworkAttributes(AttributeID,FrameworkID,StepItemID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)							
						SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @AttributeID,
							   @FrameworkID,@StepItemID,StringValue,KeyName,SequenceNo,GETUTCDATE(),@UserCreated ,@VersionNum
							FROM #TMP T
							WHERE (Parent_ID = @ID
								 OR
								 ParentName = 'validate'	
								 )
						--AND NOT EXISTS (SELECT 1 
						--				FROM dbo.FrameworkAttributes FMA
						--				WHERE FMA.StepItemID=@StepItemID 
						--						AND FMA.AttributeKey=T.KeyName
						--				)
					
					 SET IDENTITY_INSERT dbo.[FrameworkAttributes] OFF;
				--UPDATE FMA
				--	SET VersionNum = @VersionNum
				--FROM dbo.FrameworkAttributes FMA
				--	 INNER JOIN #TMP TAB ON FMA.StepItemID=@StepItemID AND FMA.AttributeKey=TAB.KeyName
				--WHERE TAB.Parent_ID = @ID
				--	  OR
				--	 TAB.ParentName = 'validate'				

				SET IDENTITY_INSERT dbo.FrameworkLookups ON;

				--GET THE LOOKUPS ATTRIBUTES
				IF @StepItemType = 'selectboxes'
				BEGIN
			
					SET @LookupValues = STUFF
										((SELECT CONCAT(', ',StringValue)
										FROM #TMP 
										WHERE Parent_ID <> @ID
											 AND KeyName ='value'
										FOR XML PATH ('')
										),1,1,'')
						--SELECT @LookupValues

						--IF NOT EXISTS (SELECT 1 
						--				FROM dbo.FrameworkLookups FMA
						--				WHERE FrameworkID = @FrameworkID
						--					  AND StepItemID=@StepItemID 
						--					  AND LookupName=@StepItemName
						--			)

						
						 INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
							SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
								   @FrameworkID,@StepItemID,@LookupValues,@StepItemName,1,GETUTCDATE(),@UserCreated,@VersionNum						
				END
				ELSE		
				IF @StepItemType = 'select'
				BEGIN				
						
						SELECT Parent_ID,
							   MAX(CASE WHEN KeyName='Label' THEN StringValue ELSE '' END) AS LookupName,
							   MAX(CASE WHEN KeyName='Value' THEN StringValue ELSE '' END) AS LookupValue,
							   CAST(NULL AS VARCHAR(50)) AS LookupType
							INTO #TMP_Lookups
						FROM #TMP 
						WHERE Parent_ID <> @ID
							 AND KeyName IN ('label','value')
							 GROUP BY Parent_ID

						UPDATE #TMP_Lookups
							SET LookupType = CASE WHEN TRY_PARSE(LookupValue AS INT) IS NOT NULL THEN 'Value'
												   ELSE 
												   CASE WHEN CHARINDEX('-',LookupValue)>0 THEN 'Range' 
												   ELSE
												   'String'
												   END
												   END

							 --SELECT * FROM #TMP_Lookups	
					
						 INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,LookupType,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   LookupValue,
										   LookupName,
										   LookupType,	 		  
											Parent_ID,
											GETUTCDATE(),
											@UserCreated,
											@VersionNum	
									FROM #TMP_Lookups T
									--WHERE NOT EXISTS (SELECT 1 
									--					FROM dbo.FrameworkLookups FMA
									--					WHERE FrameworkID = @FrameworkID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.LookupName
									--				)					
							
				END
				ELSE
										
								INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   StringValue,
										   KeyName,
										   SequenceNo,
										   GETUTCDATE(),
										   @UserCreated,
										   @VersionNum
									FROM #TMP T
									WHERE Parent_ID <> @ID
										AND KeyName ='value'
									--AND NOT EXISTS (SELECT 1 
									--					FROM dbo.FrameworkLookups FMA
									--					WHERE FrameworkID = @FrameworkID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.KeyName
									--				)			
					
					SET IDENTITY_INSERT dbo.FrameworkLookups OFF;
										
					--UPDATE dbo.FrameworkLookups SET VersionNum = @VersionNum
		
		END	--END OF OUTERMOST IF -> IF @StepID IS NOT NULL

		DELETE FROM #TMP_Objects WHERE Element_ID = @ID
		--DELETE FROM @Framework_Metafield
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

		SELECT @StepID = NULL, @StepItemID = NULL, @IsAvailable = NULL, @SQL = NULL, @TemplateTableName = NULL,
			   @AttributeID = NULL, @LookupID = NULL
		
 END

		--SELECT * from dbo.Frameworks
		--SELECT * from dbo.FrameworkSteps
		--SELECT * from dbo.FrameworkStepItems
		--SELECT * from dbo.FrameworkAttributes
		--SELECT * from dbo.FrameworkLookups

		--POPULATE TEMPLATE HISTORY TABLES**************************************************************************************
		--DECLARE @PeriodIdentifierID INT = (SELECT MAX(VersionNum) + 1 FROM dbo.Frameworks_history WHERE Name = @Name)

		--IF @PeriodIdentifierID IS NULL
		--	SET @PeriodIdentifierID = 1

		DECLARE @PeriodIdentifierID TINYINT = 1
		
		UPDATE [dbo].[Frameworks_history]
			SET PeriodIdentifierID = 0,
				UserModified = 1,
				DateModified = GETUTCDATE()
		WHERE FrameworkID = @FrameworkID
			  AND VersionNum < @VersionNum

		INSERT INTO [dbo].[Frameworks_history]
				   (FrameworkID,
					Name,
					FrameworkFile
				   ,[UserCreated]
				   ,[DateCreated]				   
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT  @FrameworkID,
				@Name,	
				@inputJSON,		
				@UserCreated,
				GETUTCDATE(),
				@VersionNum,
				@PeriodIdentifierID
		
		INSERT INTO [dbo].[FrameworkAttributes_history]
				   (FrameworkID,
					AttributeID,
				    [StepItemID]
				   ,[AttributeKey]
				   ,[AttributeValue]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT		@FrameworkID,
				    AttributeID,
					[StepItemID]
				   ,[AttributeKey]
				   ,[AttributeValue]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   @PeriodIdentifierID
		FROM dbo.[FrameworkAttributes]
		ORDER BY [OrderBy]

		
		INSERT INTO [dbo].[FrameworkLookups_history]
				   (FrameworkID,
					LookupID,
					[StepItemID]
				   ,[LookupName]
				   ,[LookupValue]
				   ,[LookupType]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT		@FrameworkID,
					LookupID,
					[StepItemID]
				   ,[LookupName]
				   ,[LookupValue]
				   ,[LookupType]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   @PeriodIdentifierID    
		FROM dbo.FrameworkLookups
		ORDER BY [OrderBy]

		--UPDATE dbo.Frameworks_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Steps_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Attributes_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Lookups_history SET PeriodIdentifierID = @VersionNum
		
	--**********************************************************************************************************************************	
		
		PRINT 'ParseJSONData Completed...'
			 
		EXEC dbo.CreateFrameworkSchemaTables @FrameworkID = @FrameworkID, @VersionNum = @VersionNum

END
GO
/****** Object:  StoredProcedure [dbo].[ParseUniverseJSON]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseUniverseJSON
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE ASSESSMENT PROPERTIES
				    2. PROPERTIES CAN ONLY BE INSERTED/DELETED (NO UPDATES); FOR MARKING OPERATION TYPE=DELETE: WHEN A PROPERTY IS REMOVED THE PROPERTY IS NOT DELETED FROM THE TABLE BUT MARKED AS INACTIVE
					   COLUMN FROM _DATA TABLE IS ALSO NOT REMOVED	
USAGE:             
					DECLARE @inputJSON VARCHAR(MAX) ='{
     
						"name": {
							"label": "Name",
							"tableView": true,
							"validate": {
								"required": true,
								"minLength": 3,
								"maxLength": 500
							},
							"key": "name",
							"properties": {
								"StepName": "General"
							},
							"type": "textfield",
							"input": true
						},
						"description": {
							"label": "Description",
							"autoExpand": false,
							"tableView": true,
							"key": "description",
							"properties": {
								"StepName": "General"
							},
							"type": "textarea",
							"input": true
						},
						"currency": {
							"label": "Currency",
							"widget": "choicesjs",
							"tableView": true,
							"data": {
								"values": [
									{
										"label": "USD",
										"value": "USD"
									},
									{
										"label": "INR",
										"value": "INR"
									},
									{
										"label": "ZAR",
										"value": "ZAR"
									},
									{
										"label": "GBP",
										"value": "GBP"
									}
								]
							},
							"selectThreshold": 0.3,
							"key": "currency",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"levelOfOperation": {
							"label": "Level of Operation",
							"widget": "choicesjs",
							"tableView": true,
							"data": {
								"values": [
									{
										"label": "Busienss Unit",
										"value": "Busienss Unit"
									},
									{
										"label": "Area",
										"value": "Area"
									},
									{
										"label": "Region",
										"value": "Region"
									},
									{
										"label": "Country",
										"value": "Country"
									},
									{
										"label": "Global",
										"value": "Global"
									}
								]
							},
							"selectThreshold": 0.3,
							"key": "levelOfOperation",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"assessmentContact": {
							"label": "Assessment Contact",
							"widget": "choicesjs",
							"tableView": true,
							"dataSrc": "custom",
							"data": {
								"values": [
									{
										"label": "",
										"value": ""
									}
								]
							},
							"dataType": "auto",
							"selectThreshold": 0.3,
							"key": "assessmentContact",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						}
					}'

					EXEC dbo.ParseUniverseJSON @UniverseName ='ABC',@inputJSON = @inputJSON,@UserCreated = 100,@UserModified=NULL

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE   PROCEDURE [dbo].[ParseUniverseJSON]
@UniverseName VARCHAR(500),
@inputJSON VARCHAR(MAX) = NULL,
@UserCreated INT,
@UserModified INT = NULL
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
	BEGIN TRAN

	DECLARE @ID INT,			
			@VersionNum INT,
			@UniverseID INT,
			@SQL NVARCHAR(MAX),
			@IsDataTypesCompatible BIT = 1
			
 DROP TABLE IF EXISTS #TMP_Objects
 DROP TABLE IF EXISTS #TMP_Assessments
 DROP TABLE IF EXISTS #TMP_NewUniverseProperties
 DROP TABLE IF EXISTS #TMP_AssessmentData
 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
 DROP TABLE IF EXISTS #TMP_UniversePropertiesXref
 CREATE TABLE #TMP_NewUniverseProperties(UniversePropertyID INT,UniverseID INT,PropertyName VARCHAR(1000))
	
	--LIST OF COMPATIBLE DATA TYPES==============================================================
		DECLARE @DataTypes TABLE
		 (
		 JSONType VARCHAR(50),
		 DataType VARCHAR(50),
		 DataTypeLength VARCHAR(50),
		 CompatibleTypes VARCHAR(500)
		 )

		 INSERT INTO @DataTypes (JSONType,DataType,DataTypeLength,CompatibleTypes)
			SELECT 'textfield','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'selectboxes','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'select','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'textarea','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'number','INT',NULL,'INT,FLOAT,DECIMAL,BIGINT,NVARCHAR' UNION ALL
			SELECT 'datetime','DATETIME',NULL,'DATETIME,DATE' UNION ALL
			SELECT 'date','DATE',NULL,'DATE,DATETIME,'

			--SELECT * FROM @DataTypes
	--===========================================================================================

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)

  SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS	
	   --AND StringValue <> ''
	  
	  -- SELECT * FROM #TMP_Objects

	    --GET ALL THE CHILD ELEMENTS FOR A PARENT
		;WITH CTE
		AS
		(	--PARENT
			SELECT CAST('' AS VARCHAR(50)) ParentName, Element_ID,Parent_ID,SequenceNo,[Name] AS KeyName,StringValue,ValueType,CAST('Object' AS VARCHAR(50)) AS ElementType
			FROM #TMP_Objects
			--WHERE Element_ID = 2
			      

			UNION ALL

			--CHILD ITEMS
			SELECT CAST(C.KeyName as varchar(50)),TMP.Element_ID,TMP.Parent_ID,TMP.SequenceNo,TMP.[Name],TMP.StringValue,TMP.ValueType,CAST('ObjectItems' AS VARCHAR(50)) AS ElementType
			FROM CTE C 
				 INNER JOIN #TMP_ALLSTEPS TMP ON TMP.Parent_ID = C.Element_ID			
			WHERE TMP.Name IN ('label','type')
		)

		SELECT *, 
			  CAST(NULL AS VARCHAR(100)) AS DataType,
			  CAST(NULL AS VARCHAR(100)) AS DataTypeLength,
			  CAST(NULL AS VARCHAR(100)) AS JSONType,
			  CAST(NULL AS VARCHAR(100)) AS CompatibleTypes
			INTO #TMP_Assessments
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')
		
		UPDATE TA
		SET DataType = DT.DataType,
			DataTypeLength = DT.DataTypeLength,
			JSONType = TA.StringValue,
			CompatibleTypes = DT.CompatibleTypes
		FROM #TMP_Assessments TA
			 INNER JOIN @DataTypes DT ON DT.JSONType = TA.StringValue
		WHERE TA.KeyName ='type'
		
		UPDATE TA 
				SET DataType= TA_Type.DataType,
					DataTypeLength= TA_Type.DataTypeLength,
					JSONType = TA_Type.StringValue,
					CompatibleTypes = TA_Type.CompatibleTypes
			FROM #TMP_Assessments TA
			     INNER JOIN #TMP_Assessments TA_Type ON TA.Parent_ID = TA_Type.Parent_ID
			WHERE TA.KeyName ='Label'
			      AND TA_Type.KeyName ='Type'

		--SELECT * FROM #TMP_Assessments
		--RETURN
		SELECT @VersionNum = VersionNum + 1,
			   @UniverseID = UniverseID
		FROM dbo.Universe 
		WHERE Name=@UniverseName
				 
		IF @UniverseID IS NULL
		BEGIN
			SET @VersionNum = 1

			INSERT INTO dbo.Universe(Name,UserCreated,VersionNum)
				SELECT @UniverseName, @UserCreated, @VersionNum

			SET @UniverseID =SCOPE_IDENTITY()
		END
		--ELSE
		--BEGIN
		--	 --POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
		--	EXEC dbo.UpdateUniverseHistoryTables @UniverseID = @UniverseID,@VersionNum = @VersionNum

		--	UPDATE dbo.Universe
		--	SET VersionNum = @VersionNum,
		--		UserModified = @UserModified,
		--		DateModified = GETUTCDATE()
		--	WHERE UniverseID = @UniverseID
	 --  END		
		--SELECT * FROM #TMP_Assessments
		--RETURN

		  --=================================================================================================================================
			IF @VersionNum > 1 
			BEGIN
				
				--CHECK FOR DATA TYPE COMPATIBILITY-----------------------------------------------------------------------------------------------
				DROP TABLE IF EXISTS #TMP_DataTypeMismatch

				SELECT @UniverseID AS UniverseID, @UserCreated AS UserCreated, @VersionNum AS VersionNum,TA.StringValue,TA.JSONType AS New_JSONType,
					  TA.DataType AS New_DataType,RP.JsonType AS Old_JSONType,DT.CompatibleTypes AS Old_CompatibleTypes
					 ,CHARINDEX(TA.DataType,DT.CompatibleTypes,1) AS Flag
					INTO #TMP_DataTypeMismatch
				FROM #TMP_Assessments TA
					INNER JOIN dbo.UniverseProperties RP ON RP.UniverseID = @UniverseID AND RP.PropertyName = TA.StringValue 
					INNER JOIN @DataTypes DT ON DT.JSONType = RP.JSONType
				WHERE TA.KeyName ='Label'
					  AND RP.VersionNum = @VersionNum - 1
					  AND CHARINDEX(TA.DataType,DT.CompatibleTypes,1) = 0
								  				
				IF EXISTS(SELECT 1
							FROM #TMP_DataTypeMismatch
						  )						
				BEGIN
					SELECT * FROM #TMP_DataTypeMismatch;
					THROW 50005, N'Data Type Compatibility Mismatch!!', 16;					
					ROLLBACK
					RETURN
				END
				-------------------------------------------------------------------------------------------------------------------------------------
					
					--IF "Type" FOR A PROPERTY HAS CHANGED
					UPDATE RP
					SET JsonType = TA.JsonType,
						VersionNum = @VersionNum,
						UserModified = @UserModified,
						DateModified = GETUTCDATE()
					FROM dbo.UniverseProperties RP
						 INNER JOIN #TMP_Assessments TA ON UniverseID = @UniverseID AND PropertyName = TA.StringValue
					WHERE RP.UniverseID = @UniverseID
						  AND RP.JSONType <> TA.JSONType
						  AND KeyName ='Label'

				--POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
				EXEC dbo.UpdateUniverseHistoryTables @UniverseID = @UniverseID,@VersionNum = @VersionNum

				UPDATE dbo.Universe
				SET VersionNum = @VersionNum,
					UserModified = @UserModified,
					DateModified = GETUTCDATE()
				WHERE UniverseID = @UniverseID

			END
		--==========================================================================================================================================================
			
			--IF "Type" FOR A PROPERTY HAS CHANGED
			--IF @VersionNum > 1
			--BEGIN

			--	UPDATE RP
			--	SET JsonType = TA.JsonType,
			--		VersionNum = @VersionNum,
			--		UserModified = @UserModified,
			--		DateModified = GETUTCDATE()
			--	FROM dbo.UniverseProperties RP
			--		 INNER JOIN #TMP_Assessments TA ON UniverseID = @UniverseID AND PropertyName = TA.StringValue
			--	WHERE RP.UniverseID = @UniverseID
			--		  AND RP.JSONType <> TA.JSONType
			--		  AND KeyName ='Label'

			--END
			--INSERT NEW PROPERTIES (IF ANY)
			INSERT INTO dbo.UniverseProperties(UniverseID,UserCreated,VersionNum,PropertyName,JSONType)
				OUTPUT INSERTED.UniversePropertyID, inserted.UniverseID,INSERTED.PropertyName INTO #TMP_NewUniverseProperties(UniversePropertyID,UniverseID,PropertyName)
			SELECT @UniverseID, @UserCreated, @VersionNum,StringValue,JSONType
			FROM #TMP_Assessments TA
			WHERE NOT EXISTS(SELECT 1 FROM dbo.UniverseProperties WHERE UniverseID = @UniverseID AND PropertyName = TA.StringValue)-- AND VersionNum = @VersionNum) 
			      AND KeyName ='Label'
			
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.UniverseProperties
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE UniverseID = @UniverseID

			/*
				SELECT UniversePropertyID,UniverseID,PropertyName,1 AS IsActive
					INTO #TMP_UniversePropertiesXref
				FROM #TMP_NewUniverseProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.UniversePropertiesXref WHERE UniversePropertyID= TR.UniversePropertyID AND UniverseID = @UniverseID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
				
				UNION
			*/
				--INSERT MISSING PROPERTIES AS WELL: THIS IS TO HANDLE ANY DELETES IN THE CURRENT VERSION
				SELECT RP.UniversePropertyID,RP.UniverseID,RP.PropertyName,0 AS IsActive
					INTO #TMP_MissingUniverseProperties
				FROM dbo.UniverseProperties RP 
					  INNER JOIN UniversePropertiesXref RPX ON RPX.UniversePropertyID = RP.UniversePropertyID AND RPX.UniverseID=RP.UniverseID
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_Assessments WHERE StringValue = RP.PropertyName AND KeyName ='Label')
					  AND RP.UniverseID = @UniverseID
					   AND RPX.IsActive = 1

				--INSERT BACK A PROPERTY WHICH WAS REMOVED EARLIER
				SELECT RP.UniversePropertyID,RP.UniverseID,RP.PropertyName,1 AS IsActive
					INTO #TMP_ActivateMissingUniverseProperties
				FROM dbo.UniverseProperties RP
					 INNER JOIN UniversePropertiesXref RPX ON RPX.UniversePropertyID = RP.UniversePropertyID AND RPX.UniverseID=RP.UniverseID
				WHERE EXISTS(SELECT 1 FROM #TMP_Assessments TA WHERE TA.StringValue = RP.PropertyName AND KeyName ='Label')
					 AND RP.UniverseID = @UniverseID
					 AND RPX.IsActive = 0	
			
			INSERT INTO dbo.UniversePropertiesXref(UniversePropertyID,UniverseID,UserCreated,VersionNum,PropertyName,IsActive)
				SELECT UniversePropertyID, UniverseID,@UserCreated,@VersionNum,PropertyName,1
				FROM #TMP_NewUniverseProperties --#TMP_NewUniverseProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.UniversePropertiesXref WHERE UniversePropertyID= TR.UniversePropertyID AND UniverseID = @UniverseID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.UniversePropertiesXref
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE UniverseID = @UniverseID

			--INACTIVATE THE PROPERTIES WHICH WERE REMOVED
			UPDATE RPX
			SET IsActive = 0,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.UniversePropertiesXref RPX		
			WHERE UniverseID = @UniverseID
				 AND EXISTS(SELECT 1 FROM #TMP_MissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX.PropertyName AND UniversePropertyID = RPX.UniversePropertyID)
			
			--ACTIVATE THE PROPERTIES WHICH WERE ADDED BACK
			UPDATE RPX
			SET IsActive = 1,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.UniversePropertiesXref RPX		
			WHERE UniverseID = @UniverseID
				 AND EXISTS(SELECT 1 FROM #TMP_ActivateMissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX.PropertyName AND UniversePropertyID = RPX.UniversePropertyID)
				 			
							
			SELECT * INTO #TMP_AssessmentData 
			FROM #TMP_Assessments
			WHERE KeyName ='Label'
			
			--SELECT * FROM #TMP_AssessmentData
			--RETURN

				DECLARE @DataCols VARCHAR(MAX) 
				 SET @DataCols =STUFF(
							 (SELECT CONCAT(', [',TA.StringValue,'] [', TA.DataType,'] ', TA.DataTypeLength)
							 FROM #TMP_AssessmentData TA								  
							  WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.StringValue AND C.object_id =OBJECT_ID('UniversePropertyXerf_Data'))
							 FOR XML PATH('')
							 )
							 ,1,1,'')
				PRINT @DataCols	

				IF @DataCols IS NOT NULL
				BEGIN
					SET @SQL = CONCAT(N' ALTER TABLE dbo.UniversePropertyXerf_Data ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					--CREATE _DATA_HISTORY TABLE
					SET @SQL = CONCAT(N' ALTER TABLE dbo.UniversePropertyXerf_Data_history ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					
					--CREATE TRIGGER
					DECLARE @cols VARCHAR(MAX) = ''

					SELECT @cols = CONCAT(@cols,N', [',name,'] ')
					FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.UniversePropertyXerf_Data' , NULL, 1)
					
					SET @cols = STUFF(@cols, 1, 1, N'');
									 

					IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME ='UniversePropertyXerf_Data_Insert')						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '

					SET @SQL = CONCAT(@SQL,N' dbo.UniversePropertyXerf_Data_Insert
									   ON  dbo.UniversePropertyXerf_Data
									   AFTER INSERT
									AS 
									BEGIN
										SET NOCOUNT ON;

										INSERT INTO dbo.UniversePropertyXerf_Data_history(<ColumnList>)
											SELECT <columnList>
											FROM INSERTED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				END
		 --RETURN
	 		
			--POPULATE THE HISTORY TABLES FOR THE FIRST VERSION OF DATA (AFTER ALL THE DATA HAS BEEN POPULATED IN THE MAIN TABLES)
			IF @VersionNum = 1 OR EXISTS(SELECT 1 FROM #TMP_NewUniverseProperties)
				EXEC dbo.UpdateUniverseHistoryTables @UniverseID = @UniverseID,@VersionNum = @VersionNum

			--UPDATE OPERATION TYPE IN HISTORY TABLE-------
			IF @VersionNum > 1
			BEGIN

			--UPDATE RPX_Hist
			--	SET OperationType = 'DELETE'				 
			--FROM dbo.UniversePropertiesXref_history RPX_Hist
			--	 INNER JOIN dbo.UniversePropertiesXref RPX ON RPX.UniverseID=RPX_Hist.UniverseID AND RPX.UniversePropertyID=RPX_Hist.UniversePropertyID
			--WHERE RPX_Hist.VersionNum = @VersionNum
			--	  AND Rpx.IsActive = 0
				 
			UPDATE RPX_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.UniversePropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				  AND RPX_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX_Hist.PropertyName AND UniversePropertyID = RPX_Hist.UniversePropertyID)
			
			UPDATE RP_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.UniverseProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RP_Hist.PropertyName AND UniversePropertyID = RP_Hist.UniversePropertyID)


			UPDATE RPX_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.UniversePropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				  AND RPX_Hist.UniverseID = @UniverseID
				  AND (EXISTS(SELECT 1 FROM #TMP_ActivateMissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX_Hist.PropertyName AND UniversePropertyID = RPX_Hist.UniversePropertyID)
					   OR EXISTS(SELECT 1 FROM #TMP_NewUniverseProperties  WHERE UniverseID=@UniverseID AND PropertyName=RPX_Hist.PropertyName AND UniversePropertyID = RPX_Hist.UniversePropertyID)
					  )
			
			UPDATE RP_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.UniverseProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM #TMP_NewUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RP_Hist.PropertyName AND UniversePropertyID = RP_Hist.UniversePropertyID)
				  
		 	UPDATE RP_Hist
				SET OperationType = 'UPDATE'				 
			FROM dbo.UniverseProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM UniverseProperties_history WHERE UniverseID=@UniverseID AND PropertyName=RP_Hist.PropertyName AND UniversePropertyID = RP_Hist.UniversePropertyID
								AND VersionNum = RP_Hist.VersionNum - 1
								AND JSONType <> RP_Hist.JSONType
							)
	
			END
			------------------------------------------------
		
		 COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK
	END CATCH	
	
		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_Assessments
		 DROP TABLE IF EXISTS #TMP_NewUniverseProperties
		 DROP TABLE IF EXISTS #TMP_AssessmentData
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
		 DROP TABLE IF EXISTS #TMP_UniversePropertiesXref
		 DROP TABLE IF EXISTS #TMP_UniverseProperties
		 --------------------------------------------------------

END
GO
/****** Object:  StoredProcedure [dbo].[UpdateAssessmentHistoryTables]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.UpdateAssessmentHistoryTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		INSERT HISTORICAL DATA IN Registers_history,RegisterProperties_history,RegisterPropertiesXref_history
USAGE:        		EXEC dbo.UpdateAssessmentHistoryTables @RegisterID =1,@versionNum = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE   PROCEDURE [dbo].[UpdateAssessmentHistoryTables]
@RegisterID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON; 
		
		DECLARE @PeriodIdentifierID INT = 1

		INSERT INTO [dbo].[Registers_history]
				   ([UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum]
				   ,[PeriodIdentifierID]
				   ,[OperationType]
				   ,[UserActionID]
				   ,[RegisterID]
				   ,[Name]
				   ,[FrameworkID]
				   ,[UniverseID]
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties])
		SELECT [UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,@VersionNum
				   ,@PeriodIdentifierID
				   ,NULL
				   ,NULL
				   ,[RegisterID]
				   ,[Name]
				   ,[FrameworkID]
				   ,[UniverseID]
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties]
		FROM dbo.Registers R
		WHERE RegisterID = @RegisterID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[Registers_history] WHERE [RegisterID]=R.[RegisterID] AND Name=R.NAME AND VersionNum = @VersionNum)

		INSERT INTO [dbo].[RegisterProperties_history]
           ([UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,[VersionNum]
           ,[PeriodIdentifierID]
           ,[OperationType]
           ,[UserActionID]
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName],
		   [JSONType])
		SELECT  [UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,@VersionNum
           ,@PeriodIdentifierID
           ,NULL
           ,NULL
           ,[RegisterPropertyID]
           ,[RegisterID]
           ,[PropertyName],
		   [JSONType]
		FROM dbo.RegisterProperties R
		WHERE RegisterID = @RegisterID
			  AND NOT EXISTS(SELECT 1 FROM [dbo].[RegisterProperties_history] WHERE [RegisterID]=R.[RegisterID] AND RegisterPropertyID=R.RegisterPropertyID AND VersionNum = @VersionNum)

    	INSERT INTO [dbo].[RegisterPropertiesXref_history]
					([UserCreated]
					,[DateCreated]
					,[UserModified]
					,[DateModified]
					,[VersionNum]
					,[PeriodIdentifierID]
					,[OperationType]
					,[UserActionID]
					,[RegisterPropertiesXrefID]
					,[RegisterID]
					,[RegisterPropertyID]
					,[PropertyName]
					,[IsRequired]
					,[IsActive])
		SELECT [UserCreated]
			,[DateCreated]
			,[UserModified]
			,[DateModified]
			,@VersionNum
			,@PeriodIdentifierID
			,NULL
			,NULL
			,[RegisterPropertiesXrefID]
			,[RegisterID]
			,[RegisterPropertyID]
			,[PropertyName]
			,[IsRequired]
			,[IsActive]
		FROM dbo.RegisterPropertiesXref R
		WHERE RegisterID = @RegisterID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[RegisterPropertiesXref_history] WHERE [RegisterID]=R.[RegisterID] AND RegisterPropertyID=R.RegisterPropertyID AND VersionNum = @VersionNum)


		UPDATE dbo.Registers_history SET PeriodIdentifierID = 0 WHERE RegisterID = @RegisterID AND VersionNum < @VersionNum		
		UPDATE dbo.RegisterProperties_history SET PeriodIdentifierID = 0 WHERE RegisterID = @RegisterID AND VersionNum < @VersionNum
		UPDATE dbo.RegisterPropertiesXref_history SET PeriodIdentifierID = 0 WHERE RegisterID = @RegisterID AND VersionNum < @VersionNum

END
GO
/****** Object:  StoredProcedure [dbo].[UpdateFrameworkHistoryOperationType]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.UpdateFrameworkHistoryOperationType
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE ASSESSMENT PROPERTIES
				    2. PROPERTIES CAN ONLY BE INSERTED/DELETED (NO UPDATES)   
USAGE:          	EXEC dbo.UpdateFrameworkHistoryOperationType @FrameworkID =1,@TableInitial='TAB',@VersionNum=1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE   PROCEDURE [dbo].[UpdateFrameworkHistoryOperationType]
@FrameworkID INT,
@TableInitial VARCHAR(100),
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON;
		
		/*
		DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500),KeyColName VARCHAR(100), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX),TableType VARCHAR(100))

		INSERT INTO @TBL_List(TemplateTableName,KeyColName,ParentTableName,TableType,ConstraintSQL)
		VALUES	('FrameworkLookups','LookupValue','FrameworkStepItems','Lookups','ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemsID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]) '),
			('FrameworkAttributes','AttributeKey','FrameworkStepItems','Attributes','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID); ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]); '),		
			('FrameworkStepItems','StepItemKey','FrameworkSteps','StepItems','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID) ;ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT [FK_<TABLENAME>_StepID] FOREIGN KEY ( [StepID] ) REFERENCES [dbo].[<ParentTableName>] ([StepID]) '),
			('FrameworkSteps','StepName','','','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepID PRIMARY KEY(StepID)')
		DROP TABLE IF EXISTS #TBL_OperationTypeList
		SELECT IDENTITY(INT,1,1) AS ID,TemplateTableName,KeyColName,TableType INTO #TBL_OperationTypeList FROM @TBL_List WHERE TableType <> ''
		*/

		IF @VersionNum > 1
		BEGIN
	
				DROP TABLE IF EXISTS #TMP_OperationType
				CREATE TABLE #TMP_OperationType(HistoryTableName VARCHAR(100),CommonID INT,KeyColName VARCHAR(100),ModuleName VARCHAR(50),KeyName VARCHAR(100),OldValue VARCHAR(MAX),NewValue VARCHAR(MAX),OperationType VARCHAR(50),TableType VARCHAR(50))

				DECLARE @ID INT,@TemplateTableName VARCHAR(100),@TableType VARCHAR(100),@KeyColName VARCHAR(100)
				DECLARE @PrevVersionNum INT = @VersionNum - 1, @Query NVARCHAR(MAX), @HistTableSuffix VARCHAR(50)='_history'
				DECLARE @cols VARCHAR(MAX)='',@HistoryTableName VARCHAR(500),@KeyName VARCHAR(500),@SelectCols VARCHAR(MAX),@CommonID INT

				SET @TableInitial = CONCAT('dbo.',@TableInitial)

				WHILE EXISTS(SELECT 1 FROM #TBL_OperationTypeList)
				BEGIN
		
						SELECT @ID = MIN(ID) FROM #TBL_OperationTypeList

						SELECT @TemplateTableName = TemplateTableName,
							   @KeyColName = KeyColName,
							   @TableType = TableType
						FROM #TBL_OperationTypeList 
						WHERE ID = @ID		 

						SET @HistoryTableName = CONCAT(@TableInitial,'_',@TemplateTableName,@HistTableSuffix)

						DROP TABLE IF EXISTS #TMP_Items
						CREATE TABLE #TMP_Items(CommonID INT,KeyName VARCHAR(100),KeyValue VARCHAR(1000),VersionNum INT)
						
						IF @TableType = 'Steps'		
							SET @Query = CONCAT('SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepID AS CommonID, Curr.StepName AS KeyName,Curr.StepName AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_FrameworkSteps_history Curr
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,')
													      AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''		
													)TAB'
												)	
						IF @TableType = 'StepItems'		
							SET @Query = CONCAT('SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepItemID AS CommonID, Curr.StepItemKey AS KeyName,Curr.StepItemName AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_FrameworkStepItems_history Curr
														 INNER JOIN ',@TableInitial,'_FrameworkSteps_history Curr_Steps ON Curr_Steps.StepID = Curr.StepID 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,')
													      AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''
														  
													UNION
													
													--CASE WHEN A STEPITEM IS MOVED TO ANOTHER STEP
													SELECT DISTINCT Curr.StepItemID AS CommonID,''StepID'' AS KeyName,CAST(Curr.StepID AS VARCHAR(10)) AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_FrameworkStepItems_history Curr
														 INNER JOIN ',@TableInitial,'_FrameworkSteps_history Curr_Steps ON Curr_Steps.StepID = Curr.StepID 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,')
													      AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''		 		
													)TAB'
												)		
						ELSE IF @TableType = 'Attributes'
							SET @Query = CONCAT('	SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepItemID AS CommonID, Curr.AttributeKey AS KeyName,Curr.AttributeValue AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_FrameworkAttributes_history Curr	
														 INNER JOIN ',@TableInitial,'_FrameworkStepItems_history Curr_Met ON Curr_Met.StepItemID = Curr.StepItemID	
														 INNER JOIN ',@TableInitial,'_FrameworkSteps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,') 
														  AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''		
													)TAB' 
												)
							ELSE IF @TableType = 'Lookups'
							SET @Query = CONCAT('SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepItemID AS CommonID, Curr.LookupValue AS KeyName,Curr.LookupName AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_FrameworkLookups_history Curr	
														 INNER JOIN ',@TableInitial,'_FrameworkStepItems_history Curr_Met ON Curr_Met.StepItemID = Curr.StepItemID	
														 INNER JOIN ',@TableInitial,'_FrameworkSteps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,') 
														  AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''
													)TAB' 
											  )
			
							PRINT @Query

							INSERT INTO #TMP_Items(CommonID,KeyName,KeyValue,VersionNum)	
								EXEC (@Query)

						INSERT INTO #TMP_OperationType(HistoryTableName,CommonID,KeyColName,ModuleName,KeyName,OldValue,NewValue,OperationType,TableType)
							SELECT @HistoryTableName,
								   CommonID,	
								   @KeyColName,
								   @TableType AS ModuleName,
								   KeyName,
								   MAX(CASE WHEN VersionNum = @PrevVersionNum THEN KeyValue END) AS OldValue,
								   MAX(CASE WHEN VersionNum = @VersionNum THEN KeyValue END) AS NewValue,
								   CAST(NULL AS VARCHAR(50)) AS OperationType,
								   @TableType
							FROM #TMP_Items
							GROUP BY CommonID, KeyName

						--SELECT * FROM #TMP_Items						
						--RETURN

						UPDATE #TMP_OperationType
							SET OperationType = 'UPDATE'
						WHERE ModuleName = @TableType
							  AND OldValue <> NewValue
							  AND OldValue IS NOT NULL

						UPDATE #TMP_OperationType
							SET OperationType = 'DELETE'
						WHERE ModuleName = @TableType	
							  AND NewValue IS NULL						  
							  AND OldValue IS NOT NULL							  

						UPDATE #TMP_OperationType
							SET OperationType = 'INSERT'
						WHERE ModuleName = @TableType
							  AND NewValue IS NOT NULL
							  AND OldValue IS NULL
						
						DELETE FROM #TBL_OperationTypeList WHERE ID = @ID
						DELETE FROM #TMP_Items				
						SELECT @Query = NULL,@HistoryTableName = NULL
						
					END		--END OF -> WHILE LOOP

					--SELECT * FROM #TMP_OperationType					
					
					--PROCESS DELETES=============================================================================================================
					
					DROP TABLE IF EXISTS #TMP_DELETES

					SELECT IDENTITY(INT,1,1) AS ID, * INTO #TMP_DELETES FROM #TMP_OperationType WHERE OperationType ='DELETE'
					--SELECT * FROM #TMP_DELETES
					WHILE EXISTS(SELECT 1 FROM #TMP_DELETES)
					BEGIN
						
						SELECT @ID = MIN(ID) FROM #TMP_DELETES

						SELECT @HistoryTableName = HistoryTableName,
							   @KeyColName = KeyColName,
							   @KeyName = KeyName,
							   @CommonID = CommonID,
							   @TableType = TableType
						FROM #TMP_DELETES 
						WHERE ID = @ID	
						
						SELECT @cols = CONCAT(@cols,N', ', name , ' ')
						FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM ', @HistoryTableName) , NULL, 1)
						WHERE NAME <> 'HistoryID';

						SET @cols = STUFF(@cols, 1, 1, N'');						  
							
							IF @cols <> ''
							BEGIN
								SET @SelectCols = @cols
								SET @SelectCols = REPLACE(@SelectCols,'OperationType','''DELETE''')
								SET @SelectCols = REPLACE(@SelectCols,'VersionNum',@VersionNum)
								SET @SelectCols = REPLACE(@SelectCols,'PeriodIdentifierID','1')
								SET @Query = CONCAT('INSERT INTO ',@HistoryTableName,'(',@cols,')', CHAR(10))
								SET @Query = CONCAT(@Query,' SELECT ',@SelectCols,' FROM ',@HistoryTableName, CHAR(10))
								SET @Query = CONCAT(@Query, ' WHERE FrameworkID=',@FrameworkID,' AND VersionNum=',@VersionNum - 1, ' AND ',@KeyColName,'=''',@KeyName,'''')

								IF @TableType IN ('StepItems','Attributes','Lookups')
									SET @Query = CONCAT(@Query, ' AND StepItemID = ', @CommonID, ';')
								ELSE IF @TableType = 'Steps'
									SET @Query = CONCAT(@Query, ' AND StepID = ', @CommonID, ';')
								PRINT @Query
								EXEC sp_executesql @Query 
							END

							SET @cols = ''
							DELETE FROM #TMP_DELETES WHERE ID = @ID				
							SET @Query = NULL	

					END
					--==========================================================================================================================================================
					
					--AS DELETES HAVE ALREADY BEEN PROCESSED BY ABOVE SNIPPET
					DELETE FROM #TMP_OperationType WHERE OperationType ='DELETE'				
					
					--FOR StepItems,Attributes,Lookups: UPDATE THE OPERATION TYPE FLAG IN HISTORY TABLE
					SET @Query = STUFF(
										(SELECT CONCAT('; ','UPDATE ',HistoryTableName,' SET OperationType=''',OperationType, ''' WHERE FrameworkID = ',@FrameworkID,' AND VersionNum=',@VersionNum,CASE WHEN KeyName <>'StepID' THEN CONCAT(' AND ',KeyColName,'=''',KeyName,'''') END, ' AND StepItemID = ', CommonID, ';', CHAR(10))
										FROM #TMP_OperationType
										WHERE OperationType IS NOT NULL 
											  AND TableType IN ('StepItems','Attributes','Lookups')
										FOR XML PATH('')
										),1,1,''
									  )
	
					PRINT @Query
					IF @Query IS NOT NULL
						EXEC (@Query)

					--FOR STEPS:UPDATE THE OPERATION TYPE FLAG IN HISTORY TABLE
					SET @Query = STUFF(
										(SELECT CONCAT('; ','UPDATE ',HistoryTableName,' SET OperationType=''',OperationType, ''' WHERE FrameworkID = ',@FrameworkID,' AND VersionNum=',@VersionNum,' AND ',KeyColName,'=''',KeyName,''' AND StepID = ', CommonID, ';', CHAR(10))
										FROM #TMP_OperationType
										WHERE OperationType IS NOT NULL 
											  AND TableType = 'Steps'
										FOR XML PATH('')
										),1,1,''
									  )
	
					PRINT @Query
					IF @Query IS NOT NULL
						EXEC (@Query)
			
				   DROP TABLE IF EXISTS #TMP_OperationType

		END	--IF @VersionNum > 1

END
 
GO
/****** Object:  StoredProcedure [dbo].[UpdateUniverseHistoryTables]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.UpdateUniverseHistoryTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		INSERT HISTORICAL DATA IN Universe_history,UniverseProperties_history,UniversePropertiesXref_history
USAGE:        		EXEC dbo.UpdateUniverseHistoryTables @UniverseID =1,@versionNum = 1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE   PROCEDURE [dbo].[UpdateUniverseHistoryTables]
@UniverseID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON; 
		
		DECLARE @PeriodIdentifierID INT = 1

		INSERT INTO [dbo].[Universe_history]
				   ([UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum]
				   ,[PeriodIdentifierID]
				   ,[OperationType]
				   ,[UserActionID]
				   ,[UniverseID]
				   ,[Name]
				   ,[FrameworkID]
				    ,ParentID
					,Height
					,Depth				  
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties])
		SELECT [UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,@VersionNum
				   ,@PeriodIdentifierID
				   ,NULL
				   ,NULL
				   ,[UniverseID]
				   ,[Name]
				   ,[FrameworkID]
				     ,ParentID
					,Height
					,Depth					 
				   ,[AccessControlID]
				   ,[WorkFlowACID]
				   ,[PropagatedAccessControlID]
				   ,[PropagatedWFAccessControlID]
				   ,[HasExtendedProperties]
		FROM dbo.Universe R
		WHERE UniverseID = @UniverseID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[Universe_history] WHERE [UniverseID]=R.[UniverseID] AND Name=R.NAME AND VersionNum = @VersionNum)

		INSERT INTO [dbo].[UniverseProperties_history]
           ([UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,[VersionNum]
           ,[PeriodIdentifierID]
           ,[OperationType]
           ,[UserActionID]
           ,[UniversePropertyID]
           ,[UniverseID]
           ,[PropertyName],
		   [JSONType])
		SELECT  [UserCreated]
           ,[DateCreated]
           ,[UserModified]
           ,[DateModified]
           ,@VersionNum
           ,@PeriodIdentifierID
           ,NULL
           ,NULL
           ,[UniversePropertyID]
           ,[UniverseID]
           ,[PropertyName],
		   [JSONType]
		FROM dbo.UniverseProperties R
		WHERE UniverseID = @UniverseID
			  AND NOT EXISTS(SELECT 1 FROM [dbo].[UniverseProperties_history] WHERE [UniverseID]=R.[UniverseID] AND UniversePropertyID=R.UniversePropertyID AND VersionNum = @VersionNum)

    	INSERT INTO [dbo].[UniversePropertiesXref_history]
					([UserCreated]
					,[DateCreated]
					,[UserModified]
					,[DateModified]
					,[VersionNum]
					,[PeriodIdentifierID]
					,[OperationType]
					,[UserActionID]
					,[UniversePropertiesXrefID]
					,[UniverseID]
					,[UniversePropertyID]
					,[PropertyName]
					,[IsRequired]
					,[IsActive])
		SELECT [UserCreated]
			,[DateCreated]
			,[UserModified]
			,[DateModified]
			,@VersionNum
			,@PeriodIdentifierID
			,NULL
			,NULL
			,[UniversePropertiesXrefID]
			,[UniverseID]
			,[UniversePropertyID]
			,[PropertyName]
			,[IsRequired]
			,[IsActive]
		FROM dbo.UniversePropertiesXref R
		WHERE UniverseID = @UniverseID
		      AND NOT EXISTS(SELECT 1 FROM [dbo].[UniversePropertiesXref_history] WHERE [UniverseID]=R.[UniverseID] AND UniversePropertyID=R.UniversePropertyID AND VersionNum = @VersionNum)


		UPDATE dbo.Universe_history SET PeriodIdentifierID = 0 WHERE UniverseID = @UniverseID AND VersionNum < @VersionNum		
		UPDATE dbo.UniverseProperties_history SET PeriodIdentifierID = 0 WHERE UniverseID = @UniverseID AND VersionNum < @VersionNum
		UPDATE dbo.UniversePropertiesXref_history SET PeriodIdentifierID = 0 WHERE UniverseID = @UniverseID AND VersionNum < @VersionNum

END
GO
/****** Object:  StoredProcedure [dbo].[ValidateUniverse_HeightAndDepth]    Script Date: 12/16/2020 10:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*==============================================================================================
OBJECT NAME	 :  dbo.ValidateUniverse_HeightAndDepth_NG
PURPOSE	     :  VALIDATES IF THE PARENT DEPTH IN THE UNIVERSE TABLE MATCHES WITH THE HIGHEST DEPTH OF IT'S CHIDLREN
				THE FINAL RESULTSET SHOULD NOT RETURNING ANYTHING, IF IT DOES THEN THE DEPTH OF RETURNED UNIVERSE HAVE NOT BEEN STAMPED CORRECTLY
CREATED BY	 :  
CREATION DATE:  

USAGE: EXEC dbo.ValidateUniverse_HeightAndDepth

CHANGE HISTORY:
SNo.   MODIFIED BY		DATE 			DESCRIPTION
===============================================================================================*/

CREATE   PROCEDURE [dbo].[ValidateUniverse_HeightAndDepth]
AS
BEGIN

	IF OBJECT_ID('TEMPDB..#TMP') IS NOT NULL
		DROP TABLE #TMP

	IF OBJECT_ID('TEMPDB..#T') IS NOT NULL
		DROP TABLE #T

	SELECT UniverseID AS ID,ParentID,Height,Depth INTO #TMP FROM dbo.UNIVERSE

	DECLARE @ID INT, @UniverseID INT

	DECLARE @TBL_InValidHierarchy TABLE(UniverseID INT)
	CREATE TABLE #T(Depth INT)

	--LOOP THROUGH THE COMPLETE HIERARCHY: ASSUMPTION IS HIERARCHY IS CREATED AS PER INCREASING ORDER OF PK
	WHILE EXISTS(SELECT 1 FROM #TMP)
	BEGIN
		
			SELECT @ID = MIN(ID) FROM #TMP
			--SELECT @UniverseID = UniverseID FROM #TMP WHERE ID = @ID

			--GET ALL CHILDRENT OF A NODE
			;WITH CTE
			AS(
				SELECT ID,ParentID, Height, Depth
				FROM #TMP WHERE ID=@ID
				UNION ALL
				SELECT T.ID,T.ParentID, T.Height, T.Depth
				FROM CTE C
					 INNER JOIN #TMP T ON T.ParentID = C.ID
			)
			,CTE2 AS
			(
			SELECT *,ROW_NUMBER()OVER(ORDER BY HEIGHT) AS ROWNUM			
			FROM CTE
			)

			--CHECK IF THE DEPTH IS THE SAME AS THE HIGHEST DEPTH OF ITS CHILDREN
			INSERT INTO #T(Depth)
			SELECT Depth FROM CTE2 WHERE ROWNUM=1			
			UNION
			SELECT MAX(Depth) FROM CTE2
	
			IF (SELECT COUNT(*) FROM #T)>1
				INSERT INTO @TBL_InValidHierarchy (UniverseID) VALUES(@ID)
					
			DELETE FROM #TMP WHERE ID = @ID
			DELETE FROM #T
	END

	SELECT * FROM @TBL_InValidHierarchy

END



GO
