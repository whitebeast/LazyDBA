CREATE TABLE [dbo].[PossibleBadIndexes](
    [PossibleBadIndexesId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkPossibleBadIndexes PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [Table Name] [sysname] NOT NULL,
    [Index Name] [sysname] NOT NULL,
    [Is Disabled] [bit] NOT NULL,
    [Is Hypothetical] [bit] NOT NULL,
    [Has Filter] [bit] NOT NULL,
    [Fill Factor] [tinyint] NOT NULL,
    [Total Writes] [bigint] NOT NULL,
    [Total Reads] [bigint] NOT NULL,
    [Difference] [bigint] NOT NULL
)
GO

CREATE INDEX ixPossibleBadIndexes_ReportDate ON PossibleBadIndexes (ReportDate)
GO