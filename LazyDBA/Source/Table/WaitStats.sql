CREATE TABLE [dbo].[WaitStats](
    [WaitStatsId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkWaitStats PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [Wait Type] [nvarchar](60) NOT NULL,
    [Wait Sec] [decimal](16, 2) NOT NULL,
    [Resource Sec] [decimal](16, 2) NOT NULL,
    [Signal Sec] [decimal](16, 2) NOT NULL,
    [Wait Count] [bigint] NOT NULL,
    [Wait Percentage] [decimal](5, 2) NOT NULL,
    [Avg Wait Sec] [decimal](16, 4) NOT NULL,
    [Avg Res Sec] [decimal](16, 4) NOT NULL,
    [Avg Sig Sec] [decimal](16, 4) NOT NULL
)
GO

CREATE INDEX ixWaitStats_ReportDate ON WaitStats (ReportDate)
INCLUDE (
    [Wait Type],
    [Wait Sec],
    [Resource Sec],
    [Signal Sec],
    [Wait Count],
    [Wait Percentage],
    [Avg Wait Sec],
    [Avg Res Sec],
    [Avg Sig Sec]
)
GO