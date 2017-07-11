CREATE PROCEDURE [dbo].[GetCachedSPByLogicalReadsList]
(
    @pRowCnt INT = 25
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Total Logical Reads (SQL Server 2012). Logical reads relate to memory pressure
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.total_logical_reads AS [Total Logical Reads], 
        qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads],
        qs.execution_count AS [Execution Time], 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        qs.total_logical_reads DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a memory perspective
-- You should look at this if you see signs of memory pressure

END