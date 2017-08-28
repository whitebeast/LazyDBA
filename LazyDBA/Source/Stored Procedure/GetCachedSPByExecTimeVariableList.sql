CREATE PROCEDURE [dbo].[GetCachedSPByExecTimeVariableList]
(
    @pReportDate DATETIME2,
    @pRowCnt INT = 10
)
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Avg Elapsed Time with execution time variability (SQL Server 2012)
INSERT INTO [dbo].[CachedSPByExecTimeVariableList]
    (
        [ReportDate],
        [SP Name],
        [Execution Count],
        [Min Elapsed Time],
        [Avg Elapsed Time],
        [Max Elapsed Time],
        [Last Elapsed Time],
        [Cached Time]
    )
SELECT  TOP(@pRowCnt) 
        @pReportDate,
        p.name AS [SP Name], 
        qs.execution_count AS [Execution Count], 
        qs.min_elapsed_time AS [Min Elapsed Time],
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time],
        qs.max_elapsed_time AS [Max Elapsed Time], 
        qs.last_elapsed_time AS [Last Elapsed Time],
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        [Avg Elapsed Time] DESC 
OPTION (RECOMPILE);

-- This gives you some interesting information about the variability in the
-- execution time of your cached stored procedures, which is useful for tuning

END