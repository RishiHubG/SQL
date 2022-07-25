USE [junk]
GO
/****** Object:  Table [dbo].[HirarchyMapping_OM]    Script Date: 7/25/2022 7:08:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HirarchyMapping_OM]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[HirarchyMapping_OM](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KeyName] [varchar](100) NULL,
	[KeyValue] [int] NULL,
	[KeyType] [varchar](100) NULL
) ON [PRIMARY]
END
GO
SET IDENTITY_INSERT [dbo].[HirarchyMapping_OM] ON 
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (1, N'a', 1, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (2, N'b', 2, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (3, N'c', 3, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (4, N'd', 4, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (5, N'e', 5, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (6, N'f', 6, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (7, N'g', 7, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (8, N'h', 8, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (9, N'i', 9, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (10, N'j', 10, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (11, N'k', 11, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (12, N'l', 12, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (13, N'm', 13, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (14, N'n', 14, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (15, N'o', 15, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (16, N'p', 16, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (17, N'q', 17, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (18, N'r', 18, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (19, N's', 19, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (20, N't', 20, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (21, N'u', 21, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (22, N'v', 22, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (23, N'w', 23, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (24, N'x', 24, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (25, N'y', 25, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (26, N'z', 26, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (53, N'A', 61, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (54, N'B', 62, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (55, N'C', 63, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (56, N'D', 64, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (57, N'E', 65, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (58, N'F', 66, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (59, N'G', 67, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (60, N'H', 68, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (61, N'I', 69, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (62, N'J', 70, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (63, N'K', 71, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (64, N'L', 72, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (65, N'M', 73, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (66, N'N', 74, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (67, N'O', 75, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (68, N'P', 76, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (69, N'Q', 77, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (70, N'R', 78, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (71, N'S', 79, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (72, N'T', 80, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (73, N'U', 81, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (74, N'V', 82, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (75, N'W', 83, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (76, N'X', 84, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (77, N'Y', 85, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (78, N'Z', 86, N'SingleAlphabets')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (183, N'i', 301, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (184, N'ii', 302, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (185, N'iii', 303, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (186, N'iv', 304, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (187, N'ix', 309, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (188, N'v', 305, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (189, N'vi', 306, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (190, N'vii', 307, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (191, N'viii', 308, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (192, N'x', 310, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (193, N'xi', 311, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (194, N'xii', 312, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (195, N'xiii', 313, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (196, N'xiv', 314, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (197, N'xix', 319, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (198, N'xv', 315, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (199, N'xvi', 316, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (200, N'xvii', 317, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (201, N'xviii', 318, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (202, N'xx', 320, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (203, N'xxi', 321, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (204, N'xxii', 322, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (205, N'xxiii', 323, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (206, N'xxiv', 324, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (207, N'xxix', 329, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (208, N'xxv', 325, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (209, N'xxvi', 326, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (210, N'xxvii', 327, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (211, N'xxviii', 328, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (212, N'xxx', 330, N'RomanNumerals')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (213, N'bis', 402, N'FixedStrings')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (214, N'dec', 410, N'FixedStrings')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (215, N'quat', 404, N'FixedStrings')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (216, N'quin', 405, N'FixedStrings')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (217, N'sept', 407, N'FixedStrings')
GO
INSERT [dbo].[HirarchyMapping_OM] ([ID], [KeyName], [KeyValue], [KeyType]) VALUES (218, N'ter', 403, N'FixedStrings')
GO
SET IDENTITY_INSERT [dbo].[HirarchyMapping_OM] OFF
GO
