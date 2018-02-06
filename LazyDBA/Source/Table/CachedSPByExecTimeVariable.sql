CREATE TABLE [dbo].[CachedSPByExecTimeVariable](
    [CachedSPByExecTimeVariableId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByExecTimeVariable PRIMARY KEY CLUSTERED,
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

CREATE INDEX ixCachedSPByExecTimeVariable_ReportDate ON CachedSPByExecTimeVariable (ReportDate)
GO