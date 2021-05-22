 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WFAccessControlledResource](
	[WFAccessControlID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[UserModified] [int] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[UserId] [int] NOT NULL,	
	WorkFlowID INT,
	WorkFlowName NVARCHAR(500),
	StepID INT,
	StepName NVARCHAR(MAX),
	StepItemID INT,
	StepItemName NVARCHAR(MAX),
	[Rights] [int] NOT NULL,
	[Customised] [bit] NOT NULL,
	[Read] [bit] NOT NULL,
	[Modify] [bit] NOT NULL,
 CONSTRAINT [WFAccessControlledResource_PK] PRIMARY KEY CLUSTERED 
(
	[WFAccessControlID] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WFAccessControlledResource] ADD  DEFAULT (getutcdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[WFAccessControlledResource] ADD  DEFAULT (getutcdate()) FOR [DateModified]
GO

ALTER TABLE [dbo].[WFAccessControlledResource] ADD  DEFAULT ((0)) FOR [Rights]
GO

ALTER TABLE [dbo].[WFAccessControlledResource] ADD  DEFAULT ((0)) FOR [Customised]
GO

ALTER TABLE [dbo].[WFAccessControlledResource] ADD  DEFAULT ((0)) FOR [Read]
GO

ALTER TABLE [dbo].[WFAccessControlledResource] ADD  DEFAULT ((0)) FOR [Modify]
GO
 
 
