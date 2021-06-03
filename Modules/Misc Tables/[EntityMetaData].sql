use junk
go

/****** Object:  Table [dbo].[EntityMetaData]    Script Date: 03/06/2021 12:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP TABLE [EntityMetaData]
GO

CREATE TABLE [dbo].[EntityMetaData](
	[EntityTypeId] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime2](0) NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime2](0) NULL,
	[Name] [varchar](1000) NULL,
	[PluralName] [varchar](1000) NULL,
	[ChildName] [varchar](1000) NULL,
	[ChildPluralName] [varchar](1000) NULL,
	[IsActive] [bit] NULL,
	[IsMeth] [int] NULL,
 CONSTRAINT [PK_EntityMetaData] PRIMARY KEY CLUSTERED 
(
	[EntityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EntityMetaData] ADD  CONSTRAINT [DF_EntityMetaData_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO


