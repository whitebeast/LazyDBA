CREATE TABLE [dbo].[CachedQueriesByIOCost](
    [CachedQueriesByIOCostId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedQueriesByIOCost PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
    [Avg IO] [bigint] NOT NULL,
    [Execution Count] [bigint] NOT NULL,
    [Query Text] [nvarchar](max) NOT NULL
)
GO

CREATE INDEX ixCachedQueriesByIOCost_ReportDate ON CachedQueriesByIOCost (ReportDate)
GO