﻿CREATE TABLE [dbo].[CachedSPByExecCntList](
	[CachedSPByExecCntListId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkCachedSPByExecCntList PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [SP Name] [sysname] NOT NULL,
	[Execution Count] [bigint] NOT NULL,
	[Calls/Minute] [bigint] NOT NULL,
	[Avg Worker Time] [bigint] NOT NULL,
	[Total Worker Time] [bigint] NOT NULL,
	[Total Elapsed Time] [bigint] NOT NULL,
	[Avg Elapsed Time] [bigint] NOT NULL,
	[Cached Time] [datetime] NOT NULL
)
GO

CREATE INDEX ixCachedSPByExecCntList_ReportDate ON CachedSPByExecCntList (ReportDate)
GO