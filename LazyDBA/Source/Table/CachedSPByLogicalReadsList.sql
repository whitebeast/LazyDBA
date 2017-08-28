CREATE TABLE [dbo].[CachedSPByLogicalReadsList](
	[CachedSPByLogicalReadsListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByLogicalReadsList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
	[Total Logical Reads] [bigint] NOT NULL,
	[Avg Logical Reads] [bigint] NOT NULL,
	[Execution Count] [bigint] NOT NULL,
	[Calls/Minute] [bigint] NOT NULL,
	[Total Elapsed Time] [bigint] NOT NULL,
	[Avg Elapsed Time] [bigint] NOT NULL,
	[Cached Time] [datetime] NOT NULL
)
GO

CREATE INDEX ixCachedSPByLogicalReadsList_ReportDate ON CachedSPByLogicalReadsList (ReportDate)
GO