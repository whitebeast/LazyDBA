CREATE PROCEDURE [dbo].[AddCachedSPByLogicalWrites]
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
    [Total Logical Writes] BIGINT,
    [Avg Logical Writes] BIGINT,
    [Execution Count] BIGINT,
    [Calls/Minute] BIGINT,
    [Total Elapsed Time] BIGINT,
    [Avg Elapsed Time] BIGINT,
    [Cached Time] DATETIME
);

-- Top Cached SPs By Total Logical Writes (SQL Server 2012)
-- Logical writes relate to both memory and disk I/O pressure 
INSERT INTO [dbo].[CachedSPByLogicalWrites]
    (
        [ReportDate],
        [SP Name],
        [Total Logical Writes],
        [Avg Logical Writes],
        [Execution Count],
        [Calls/Minute],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    )
OUTPUT  inserted.[SP Name],
        inserted.[Total Logical Writes],
        inserted.[Avg Logical Writes],
        inserted.[Execution Count],
        inserted.[Calls/Minute],
        inserted.[Total Elapsed Time],
        inserted.[Avg Elapsed Time],
        inserted.[Cached Time]
INTO    @tOutput
SELECT  TOP(@pRowCnt) 
        GETDATE() AS [ReportDate],
        p.name AS [SP Name], 
        qs.total_logical_writes AS [Total Logical Writes], 
        qs.total_logical_writes/qs.execution_count AS [Avg Logical Writes], 
        qs.execution_count AS [Execution Count],
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_elapsed_time AS [Total Elapsed Time],
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND qs.total_logical_writes > 0
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        qs.total_logical_writes DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a write I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure

SET @pHTML =
    N'            <div class="header" id="7-header">Cached SP By Logical Writes</div><div class="content" id="7-content"><div class="text">' + 
    ISNULL(N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Logical Writes</th>' +
            N'<th style="width: 5%;" >Avg Logical Writes</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Logical Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Logical Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM @tOutput 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>','NO DATA') +  
        N'</div></div>'; 
SET @pHTML = REPLACE(@pHTML,'&#x0D;','');

END