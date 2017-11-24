CREATE TABLE [dbo].[CachedSPByLogicalWritesList](
    [CachedSPByLogicalWritesListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByLogicalWritesList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
    [Total Logical Writes] [bigint] NOT NULL,
    [Avg Logical Writes] [bigint] NOT NULL,
    [Execution Count] [bigint] NOT NULL,
    [Calls/Minute] [bigint] NOT NULL,
    [Total Elapsed Time] [bigint] NOT NULL,
    [Avg Elapsed Time] [bigint] NOT NULL,
    [Cached Time] [datetime] NOT NULL
)
GO

CREATE INDEX ixCachedSPByLogicalWritesList_ReportDate ON CachedSPByLogicalWritesList (ReportDate)
GO