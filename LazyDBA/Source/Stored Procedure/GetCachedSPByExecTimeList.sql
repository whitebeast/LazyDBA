CREATE PROCEDURE [dbo].[GetCachedSPByExecTimeList]
(
    @pRowCnt INT = 25
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Avg Elapsed Time (SQL Server 2012)
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.execution_count AS [Execution Time], 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
        qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
        qs.total_worker_time AS [Total Worker Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        [Avg Elapsed Time] DESC 
OPTION (RECOMPILE);

-- This helps you find long-running cached stored procedures that
-- may be easy to optimize with standard query tuning techniques

END