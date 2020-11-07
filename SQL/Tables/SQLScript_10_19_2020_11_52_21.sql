-- Create table [dbo].[ColList]
Print 'Create table [dbo].[ColList]'
CREATE TABLE [dbo].[ColList](
  [ID] [int]  NOT NULL,
  [SnapshotID] [int]  NOT NULL,
  [UserCreated] [bigint]  NOT NULL,
  [DateCreated] [datetime]  NOT NULL,
  [UserModified] [bigint]  NOT NULL,
  [DateModified] [datetime]  NOT NULL,
  [SQLExpression] [varchar](MAX)  NOT NULL,
  [IsActive] [bit]  NOT NULL,
  [ActualColumnName] [varchar](MAX)  NOT NULL,
  [TablelColumnName] [varchar](100)  NOT NULL,
  CONSTRAINT [PK_Table_1] PRIMARY KEY NONCLUSTERED ([ID]),
);
GO

-- Create table [dbo].[Table_1]
Print 'Create table [dbo].[Table_1]'
CREATE TABLE [dbo].[Table_1](
  [Col1] [nchar](10)  NULL,
  [ID_FK] [int]  NOT NULL,
  CONSTRAINT [Table_1_PK] PRIMARY KEY NONCLUSTERED ([ID_FK]),
);
GO

-- Add relationship [Table_1_ColList_FK] to table [dbo].[Table_1]'
Print 'Add relationship [Table_1_ColList_FK] to table [dbo].[Table_1]'
ALTER TABLE [dbo].[Table_1]
  ADD CONSTRAINT [Table_1_ColList_FK] FOREIGN KEY ([ID_FK]) REFERENCES [dbo].[ColList] 
([ID]);
GO

