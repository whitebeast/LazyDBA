CREATE PROCEDURE [dbo].[GetCachedSPByExecCntList]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tCachedSPByExecCntList') IS NOT NULL DROP TABLE #tCachedSPByExecCntList;

-- Top Cached SPs By Execution Count (SQL Server 2012)
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.execution_count AS [Execution Count],
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
        qs.total_worker_time AS [Total Worker Time],  
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time],
        qs.cached_time AS [Cached Time]
INTO #tCachedSPByExecCntList
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK) 
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo.Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        qs.execution_count DESC 
OPTION (RECOMPILE);

-- Tells you which cached stored procedures are called the most often
-- This helps you characterize and baseline your workload

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%; ">Execution Count</th>' +
            N'<th style="width: 5%; ">Calls/Minute</th>' +
            N'<th style="width: 5%; ">Avg Worker Time</th>' +
            N'<th style="width: 5%; ">Total Worker Time</th>' +
            N'<th style="width: 5%; ">Total Elapsed Time</th>' +
            N'<th style="width: 5%; ">Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByExecCntList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tCachedSPByExecCntList') IS NOT NULL DROP TABLE #tCachedSPByExecCntList;

END