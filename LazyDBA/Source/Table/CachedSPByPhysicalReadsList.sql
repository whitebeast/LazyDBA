CREATE TABLE [dbo].[CachedSPByPhysicalReadsList](
	[CachedSPByPhysicalReadsListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByPhysicalReadsList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
	[Total Physical Reads] [bigint] NOT NULL,
	[Avg Physical Reads] [bigint] NOT NULL,
	[Execution Count] [bigint] NOT NULL,
	[Total Logical Reads] [bigint] NOT NULL,
	[Total Elapsed Time] [bigint] NOT NULL,
	[Avg Elapsed Time] [bigint] NOT NULL,
	[Cached Time] [datetime] NOT NULL
)
GO

CREATE INDEX ixCachedSPByPhysicalReadsList_ReportDate ON CachedSPByPhysicalReadsList (ReportDate)
GO