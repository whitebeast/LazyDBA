CREATE TABLE [dbo].[CachedSPByPhysicalReads](
    [CachedSPByPhysicalReadsId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByPhysicalReads PRIMARY KEY CLUSTERED,
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

CREATE INDEX ixCachedSPByPhysicalReads_ReportDate ON CachedSPByPhysicalReads (ReportDate)
GO