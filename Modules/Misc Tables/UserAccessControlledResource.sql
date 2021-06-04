USE [agsqa]
GO

/****** Object:  Table [dbo].[AccessControlledResource]    Script Date: 04/06/2021 13:00:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserAccessControlledResource](
	[AccessControlID] [int] NOT NULL,
	[UserCreated] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[UserModified] [int] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[UserId] [int] NOT NULL,
	[Rights] [int] NOT NULL,
	[Customised] [bit] NOT NULL,
	[Read] [bit] NOT NULL,
	[Modify] [bit] NOT NULL,
	[Write] [bit] NOT NULL,
	[Administrate] [bit] NOT NULL,
	[Cut] [bit] NOT NULL,
	[Copy] [bit] NOT NULL,
	[Export] [bit] NOT NULL,
	[Delete] [bit] NOT NULL,
	[Report] [bit] NOT NULL,
	[Adhoc] [bit] NOT NULL,
 CONSTRAINT [UserAccessControlledResource_PK] PRIMARY KEY CLUSTERED 
(
	[AccessControlID] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT (getutcdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT (getutcdate()) FOR [DateModified]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Rights]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Customised]
--GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Read]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Modify]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Write]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Administrate]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Cut]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Copy]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Export]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Delete]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Report]
GO

ALTER TABLE [dbo].[UserAccessControlledResource] ADD  DEFAULT ((0)) FOR [Adhoc]
GO

ALTER TABLE [dbo].[UserAccessControlledResource]  WITH CHECK ADD  CONSTRAINT [AccessControl_UserAccessControlledResource_FK1] FOREIGN KEY([AccessControlID])
REFERENCES [dbo].[AccessControl] ([AccessControlID])
GO

ALTER TABLE [dbo].[UserAccessControlledResource] CHECK CONSTRAINT [AccessControl_UserAccessControlledResource_FK1]
GO


