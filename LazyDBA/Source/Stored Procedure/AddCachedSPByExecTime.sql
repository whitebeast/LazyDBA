CREATE PROCEDURE [dbo].[AddCachedSPByExecTime]
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
    [Avg Elapsed Time] BIGINT,
    [Total Elapsed Time] BIGINT,
    [Execution Count] BIGINT,
    [Calls/Minute] BIGINT,
    [Avg Worker Time] BIGINT,
    [Total Worker Time] BIGINT,
    [Cached Time] DATETIME
);

-- Top Cached SPs By Avg Elapsed Time (SQL Server 2012)
INSERT INTO [dbo].[CachedSPByExecTime]
    (
        [ReportDate],
        [SP Name],
        [Avg Elapsed Time],
        [Total Elapsed Time],
        [Execution Count],
        [Calls/Minute],
        [Avg Worker Time],
        [Total Worker Time],
        [Cached Time]
    )
OUTPUT  inserted.[SP Name],
        inserted.[Avg Elapsed Time],
        inserted.[Total Elapsed Time],
        inserted.[Execution Count],
        inserted.[Calls/Minute],
        inserted.[Avg Worker Time],
        inserted.[Total Worker Time],
        inserted.[Cached Time]
INTO    @tOutput
SELECT  TOP(@pRowCnt) 
        GETDATE() AS [ReportDate],
        p.name AS [SP Name], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.execution_count AS [Execution Count], 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
        qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
        qs.total_worker_time AS [Total Worker Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        [Avg Elapsed Time] DESC 
OPTION (RECOMPILE);

-- This helps you find long-running cached stored procedures that
-- may be easy to optimize with standard query tuning techniques

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Avg Worker Time</th>' +
            N'<th style="width: 5%;" >Total Worker Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM @tOutput 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

END