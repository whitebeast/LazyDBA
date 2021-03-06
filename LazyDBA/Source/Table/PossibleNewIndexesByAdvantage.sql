﻿CREATE TABLE [dbo].[PossibleNewIndexesByAdvantage](
    [PossibleNewIndexesByAdvantageId] INT IDENTITY(1,1) NOT NULL CONSTRAINT pkPossibleNewIndexesByAdvantage PRIMARY KEY CLUSTERED,
    [ReportDate] DATETIME2 NOT NULL,
    [Index Advantage] [decimal](18, 2) NOT NULL,
    [Last User Seek Date] [datetime] NOT NULL,
    [Equality Columns] [nvarchar](4000) NOT NULL,
    [Inequality Columns] [nvarchar](4000) NULL,
    [Included Columns] [nvarchar](4000) NOT NULL,
    [Unique Compiles] [bigint] NOT NULL,
    [User Seeks] [bigint] NOT NULL,
    [Avg Total User Costs] [float] NOT NULL,
    [Avg User Impact] [float] NOT NULL,
    [Table Name] [sysname] NOT NULL,
    [Table Rows] [bigint] NOT NULL,
    [Index Script] [nvarchar](4000) NOT NULL
)
GO

CREATE INDEX ixPossibleNewIndexesByAdvantage_ReportDate ON PossibleNewIndexesByAdvantage (ReportDate)
GO