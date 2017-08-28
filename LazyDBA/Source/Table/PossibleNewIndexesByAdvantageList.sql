CREATE TABLE [dbo].[PossibleNewIndexesByAdvantageList](
	[PossibleNewIndexesByAdvantageListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkPossibleNewIndexesByAdvantageList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [Index Advantage] [decimal](18, 2) NOT NULL,
	[Last User Seek Date] [datetime] NOT NULL,
	[Equality Columns] [nvarchar](4000) NOT NULL,
	[Inequality Columns] [nvarchar](4000) NOT NULL,
	[Included Columns] [nvarchar](4000) NOT NULL,
	[Unique Compiles] [bigint] NOT NULL,
	[User Seeks] [bigint] NOT NULL,
	[Avg Total User Costs] [float] NOT NULL,
	[Avg User Impact] [float] NOT NULL,
	[Table Name] [sysname] NOT NULL,
	[Table Rows] [bigint] NOT NULL
)
GO

CREATE INDEX ixPossibleNewIndexesByAdvantageList_ReportDate ON PossibleNewIndexesByAdvantageList (ReportDate)
GO