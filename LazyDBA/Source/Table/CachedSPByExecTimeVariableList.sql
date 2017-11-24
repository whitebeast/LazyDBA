CREATE TABLE [dbo].[CachedSPByExecTimeVariableList](
    [CachedSPByExecTimeVariableListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByExecTimeVariableList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
    [Execution Count] [bigint] NOT NULL,
    [Min Elapsed Time] [bigint] NOT NULL,
    [Avg Elapsed Time] [bigint] NOT NULL,
    [Max Elapsed Time] [bigint] NOT NULL,
    [Last Elapsed Time] [bigint] NOT NULL,
    [Cached Time] [datetime] NOT NULL
)
GO

CREATE INDEX ixCachedSPByExecTimeVariableList_ReportDate ON CachedSPByExecTimeVariableList (ReportDate)
GO