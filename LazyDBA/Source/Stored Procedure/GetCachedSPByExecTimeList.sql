CREATE PROCEDURE [dbo].[GetCachedSPByExecTimeList]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tCachedSPByExecTimeList') IS NOT NULL DROP TABLE #tCachedSPByExecTimeList;

-- Top Cached SPs By Avg Elapsed Time (SQL Server 2012)
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.execution_count AS [Execution Count], 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
        qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
        qs.total_worker_time AS [Total Worker Time], 
        qs.cached_time AS [Cached Time]
INTO #tCachedSPByExecTimeList
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        [Avg Elapsed Time] DESC 
OPTION (RECOMPILE);

-- This helps you find long-running cached stored procedures that
-- may be easy to optimize with standard query tuning techniques

SET @pHTML =
    N'<table>
        <tr>'+
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
                           td=REPLACE(ISNULL(CAST([SP Name] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByExecTimeList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tCachedSPByExecTimeList') IS NOT NULL DROP TABLE #tCachedSPByExecTimeList;

END