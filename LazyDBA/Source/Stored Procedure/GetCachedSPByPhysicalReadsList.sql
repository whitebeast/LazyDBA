CREATE PROCEDURE [dbo].[GetCachedSPByPhysicalReadsList]
(
    @pRowCnt INT = 25
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Total Physical Reads (SQL Server 2012). Physical reads relate to disk I/O pressure
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name],
        qs.total_physical_reads AS [Total Physical Reads], 
        qs.total_physical_reads/qs.execution_count AS [Avg Physical Reads], 
        qs.execution_count AS [Execution Time], 
        qs.total_logical_reads AS [Total Logical Reads],
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND qs.total_physical_reads > 0
ORDER BY 
        qs.total_physical_reads DESC, 
        qs.total_logical_reads DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a read I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure

END