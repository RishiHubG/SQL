USE [VKB_NEW]
GO

/****** Object:  Table [dbo].[EntityChildLinkFramework]    Script Date: 9/27/2022 3:41:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EntityChildLinkFramework_history](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,	
	[PeriodIdentifier] [int] NOT NULL,
	[OperationType] [varchar](50) NULL,
	[ChildEntityId] [int] NOT NULL,
	[UserCreated] [int] NULL,
	[DateCreated] [datetime] NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime] NULL,
	[LinkType] [int] NULL,
	[FromFrameworkId] [int] NULL,
	[FromEntityId] [int] NULL,
	[ToFrameWorkId] [int] NULL,
	[ToEntityid] [int] NULL,
	[apikey] [nvarchar](2000) NULL,
	[EntityTypeid] [int] NULL,
  CONSTRAINT [PK_EntityChildLinkFramework_history_HistoryID] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

