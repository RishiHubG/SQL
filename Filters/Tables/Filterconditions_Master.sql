
/****** Object:  Table [dbo].[Filterconditions_Master]    Script Date: 2/26/2022 11:10:05 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Filterconditions_Master]') AND type in (N'U'))
DROP TABLE [dbo].[Filterconditions_Master]
GO
/****** Object:  Table [dbo].[Filterconditions_Master]    Script Date: 2/26/2022 11:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Filterconditions_Master](
	[FiltertypeId] [int] IDENTITY(1,1) NOT NULL,
	[DataType] [nvarchar](2000) NULL,
	[Criteria] [varchar](255) NULL,
	[Active] [int] NULL,
	[ValueReq] [int] NULL,
	[OperatorType] [varchar](50) NULL,
	[daysRequired] [int] NULL,
	[currentDaterequired] [int] NULL,
 CONSTRAINT [PK__Filterco__7A82FCFDA2A476FC] PRIMARY KEY CLUSTERED 
(
	[FiltertypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Filterconditions_Master] ON 
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (1, N'textfield', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (2, N'textfield', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (3, N'textfield', N'Contains', 1, 1, N'LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (4, N'textfield', N'Does Not Contains', 1, 1, N'NOT LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (5, N'textfield', N'Starts With', 1, 1, N'LIKE ''%<COLVALUE>''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (6, N'textfield', N'Does Not Start With', 1, 1, N'NOT LIKE ''%<COLVALUE>''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (7, N'textfield', N'Ends With', 1, 1, N'LIKE ''<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (8, N'textfield', N'Does Not End With', 1, 1, N'NOT LIKE ''<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (9, N'textfield', N'Is Empty', 1, 1, N'ISNULL(<COLNAME>,'''') = ''''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (10, N'textfield', N'IS Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (11, N'textfield', N'Equal to Field', 1, 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (12, N'select', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (13, N'select', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (14, N'select', N'Contains', 1, 1, N'LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (15, N'select', N'Does Not Contains', 1, 1, N'NOT LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (16, N'select', N'Starts With', 1, 1, N'LIKE ''%<COLVALUE>''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (17, N'select', N'Does Not Start With', 1, 1, N'NOT LIKE ''%<COLVALUE>''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (18, N'select', N'Ends With', 1, 1, N'LIKE ''<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (19, N'select', N'Does Not End With', 1, 1, N'NOT LIKE ''<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (20, N'select', N'Is Empty', 1, 1, N'ISNULL(<COLNAME>,'''') = ''''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (21, N'select', N'IS Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (22, N'select', N'Equal to Field', 1, 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (34, N'textarea', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (35, N'textarea', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (36, N'textarea', N'Contains', 1, 1, N'LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (37, N'textarea', N'Does Not Contains', 1, 1, N'NOT LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (38, N'textarea', N'Starts With', 1, 1, N'LIKE ''%<COLVALUE>''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (39, N'textarea', N'Does Not Start With', 1, 1, N'NOT LIKE ''%<COLVALUE>''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (40, N'textarea', N'Ends With', 1, 1, N'LIKE ''<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (41, N'textarea', N'Does Not End With', 1, 1, N'NOT LIKE ''<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (42, N'textarea', N'Is Empty', 1, 1, N'ISNULL(<COLNAME>,'''') = ''''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (43, N'textarea', N'IS Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (44, N'textarea', N'Equal to Field', 1, 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (45, N'selectboxes', N'Contains', 1, 1, N'LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (46, N'selectboxes', N'Does Not Contains', 1, 1, N'NOT LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (47, N'selectboxes', N'Is Empty', 1, 1, N'ISNULL(<COLNAME>,'''') = ''''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (48, N'selectboxes', N'IS Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (49, N'selectboxes', N'Contains Field', 1, 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (50, N'datetime', N'Equals', 1, 1, N'=', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (51, N'datetime', N'Not Equals', 1, 1, N'<>', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (52, N'datetime', N'Less Than', 1, 1, N'<', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (53, N'datetime', N'Less Than Or Equal to', 1, 1, N'<=', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (54, N'datetime', N'Greater Than', 1, 1, N'>', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (55, N'datetime', N'Greater Than or Equal to', 1, 1, N'>=', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (56, N'datetime', N'Between', 1, 2, N'Between', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (57, N'datetime', N'Not Between', 1, 2, N'Not Between', NULL, 1)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (58, N'datetime', N'Empty', 1, 1, N'Is Empty', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (59, N'datetime', N'Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (60, N'number', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (61, N'number', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (62, N'number', N'Less Than', 1, 1, N'<', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (63, N'number', N'Less Than Or Equal to', 1, 1, N'<=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (64, N'number', N'Greater Than', 1, 1, N'>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (65, N'number', N'Greater Than or Equal to', 1, 1, N'>=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (66, N'number', N'Between', 1, 2, N'Between', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (67, N'number', N'Not Between', 1, 2, N'Not Between', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (68, N'number', N'Empty', 1, 1, N'Is Empty', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (69, N'number', N'Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (74, N'Customtext', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (75, N'Customtext', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (76, N'Customtext', N'Contains', 1, 1, N'LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (77, N'Customtext', N'Does Not Contains', 1, 1, N'NOT LIKE ''%<COLVALUE>%''', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (78, N'datetime', N'Last N Days', 1, 1, NULL, 1, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (79, N'checkbox', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (80, N'Customtext', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (81, N'datetime', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (82, N'number', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (83, N'radio', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (84, N'select', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (85, N'selectboxes', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (86, N'textarea', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (87, N'textfield', N'-Select-', 1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (88, N'checkbox', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (89, N'checkbox', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (90, N'checkbox', N'Empty', 1, 1, N'Is Empty', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (91, N'checkbox', N'IS Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (92, N'radio', N'Equals', 1, 1, N'=', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (93, N'radio', N'Not Equals', 1, 1, N'<>', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (94, N'radio', N'Empty', 1, 1, N'Is Empty', NULL, NULL)
GO
INSERT [dbo].[Filterconditions_Master] ([FiltertypeId], [DataType], [Criteria], [Active], [ValueReq], [OperatorType], [daysRequired], [currentDaterequired]) VALUES (95, N'radio', N'IS Not Empty', 1, 1, N'ISNULL(<COLNAME>,'''') <> '''' ', NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Filterconditions_Master] OFF
GO
