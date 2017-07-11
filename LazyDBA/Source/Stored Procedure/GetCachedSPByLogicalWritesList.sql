CREATE PROCEDURE [dbo].[GetCachedSPByLogicalWritesList]
(
    @pRowCnt INT = 25
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Total Logical Writes (SQL Server 2012)
-- Logical writes relate to both memory and disk I/O pressure 
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.total_logical_writes AS [Total Logical Writes], 
        qs.total_logical_writes/qs.execution_count AS [Avg Logical Writes], 
        qs.execution_count AS [Execution Time],
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_elapsed_time AS [Total Elapsed Time],
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND qs.total_logical_writes > 0
ORDER BY 
        qs.total_logical_writes DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a write I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure

END