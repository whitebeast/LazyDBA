CREATE PROCEDURE [dbo].[GetCachedSPByCPUCostList]
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Total Worker time (SQL Server 2012). Worker time relates to CPU cost
SELECT  TOP(25) 
        p.name AS [SP Name], 
        qs.total_worker_time AS [TotalWorkerTime], 
        qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
        qs.execution_count, 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_elapsed_time, 
        qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
        qs.cached_time
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        qs.total_worker_time DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a CPU perspective
-- You should look at this if you see signs of CPU pressure

END