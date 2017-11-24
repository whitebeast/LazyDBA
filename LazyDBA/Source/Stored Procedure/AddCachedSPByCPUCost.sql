CREATE PROCEDURE [dbo].[AddCachedSPByCPUCostList]
(
    @pReportDate DATETIME2,
    @pRowCnt INT = 10
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Total Worker time (SQL Server 2012). Worker time relates to CPU cost
INSERT INTO [dbo].[CachedSPByCPUCostList]
    (
        [ReportDate],
        [SP Name],
        [Total Worker Time],
        [Avg Worker Time],
        [Execution Count],
        [Calls/Minute],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    )
SELECT  TOP(@pRowCnt) 
        @pReportDate,
        p.name AS [SP Name], 
        qs.total_worker_time AS [Total Worker Time], 
        qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
        qs.execution_count AS [Execution Count], 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        qs.total_worker_time DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a CPU perspective
-- You should look at this if you see signs of CPU pressure

END