use junk
go

/****** Object:  Table [dbo].[EntityAdminForm]    Script Date: 03/06/2021 12:46:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP TABLE [EntityAdminForm]
GO

CREATE TABLE [dbo].[EntityAdminForm](
	[AdminFormId] [int] IDENTITY(1,1) NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[UserModified] [int] NULL,
	[DateModified] [datetime] NULL,
	[EntitytypeId] [int] NULL,
	[FormJson] [nvarchar](max) NULL,
	[UserLoginId] [int] NULL,
	[VersionNum] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdminFormId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_EntityAdminForm_EntityTypeID] UNIQUE NONCLUSTERED 
(
	[EntitytypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[EntityAdminForm] ADD  DEFAULT (getutcdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[EntityAdminForm]  WITH CHECK ADD FOREIGN KEY([EntitytypeId])
REFERENCES [dbo].[EntityMetaData] ([EntityTypeId])
GO


