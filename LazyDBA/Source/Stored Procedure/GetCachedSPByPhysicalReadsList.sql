CREATE PROCEDURE [dbo].[GetCachedSPByPhysicalReadsList]
(
    @pReportDate DATETIME2,
    @pRowCnt INT = 10
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Total Physical Reads (SQL Server 2012). Physical reads relate to disk I/O pressure
INSERT INTO [dbo].[CachedSPByPhysicalReadsList]
    (
        [ReportDate],
        [SP Name],
        [Total Physical Reads],
        [Avg Physical Reads],
        [Execution Count],
        [Total Logical Reads],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    )
SELECT  TOP(@pRowCnt) 
        @pReportDate,
        p.name AS [SP Name],
        qs.total_physical_reads AS [Total Physical Reads], 
        qs.total_physical_reads/qs.execution_count AS [Avg Physical Reads], 
        qs.execution_count AS [Execution Count], 
        qs.total_logical_reads AS [Total Logical Reads],
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND qs.total_physical_reads > 0
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        qs.total_physical_reads DESC, 
        qs.total_logical_reads DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a read I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure

END