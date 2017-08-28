CREATE TABLE [dbo].[CachedQueriesByIOCostList](
	[CachedQueriesByIOCostListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedQueriesByIOCostList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
	[Avg IO] [bigint] NOT NULL,
	[Execution Count] [bigint] NOT NULL,
	[Query Text] [nvarchar](max) NOT NULL
)
GO

CREATE INDEX ixCachedQueriesByIOCostList_ReportDate ON CachedQueriesByIOCostList (ReportDate)
GO