﻿CREATE PROCEDURE [dbo].[AddCachedSPByExecTimeVariable]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(MAX) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @tOutput TABLE
(
    [SP Name] NVARCHAR(128),
    [Execution Count] BIGINT,
    [Min Elapsed Time] BIGINT,
    [Avg Elapsed Time] BIGINT,
    [Max Elapsed Time] BIGINT,
    [Last Elapsed Time] BIGINT,
    [Cached Time] DATETIME
);

-- Top Cached SPs By Avg Elapsed Time with execution time variability (SQL Server 2012)
INSERT INTO [dbo].[CachedSPByExecTimeVariable]
    (
        [ReportDate],
        [SP Name],
        [Execution Count],
        [Min Elapsed Time],
        [Avg Elapsed Time],
        [Max Elapsed Time],
        [Last Elapsed Time],
        [Cached Time]
    )
OUTPUT  inserted.[SP Name],
        inserted.[Execution Count],
        inserted.[Min Elapsed Time],
        inserted.[Avg Elapsed Time],
        inserted.[Max Elapsed Time],
        inserted.[Last Elapsed Time],
        inserted.[Cached Time]
INTO    @tOutput
SELECT  TOP(@pRowCnt) 
        GETDATE() AS [ReportDate],
        p.name AS [SP Name], 
        qs.execution_count AS [Execution Count], 
        qs.min_elapsed_time AS [Min Elapsed Time],
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time],
        qs.max_elapsed_time AS [Max Elapsed Time], 
        qs.last_elapsed_time AS [Last Elapsed Time],
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        [Avg Elapsed Time] DESC 
OPTION (RECOMPILE);

-- This gives you some interesting information about the variability in the
-- execution time of your cached stored procedures, which is useful for tuning

SET @pHTML =
    N'            <div class="header" id="5-header">Cached SP By Exec Time Variable</div><div class="content" id="5-content"><div class="text">' + 
    ISNULL(N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Min Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 5%;" >Max Elapsed Time</th>' +
            N'<th style="width: 5%;" >Last Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Min Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Max Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Last Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM @tOutput 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>','NO DATA') + 
        N'</div></div>';  
SET @pHTML = REPLACE(@pHTML,'&#x0D;','');

END