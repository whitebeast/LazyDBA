CREATE PROCEDURE [dbo].[AddCachedQueriesByIOCostList]
(
    @pRowCnt INT = 10
)
AS
BEGIN

SET NOCOUNT ON;

-- Lists the top statements by average input/output usage for the current database
INSERT INTO [dbo].[CachedQueriesByIOCostList]
    (
        [ReportDate],
        [SP Name],
        [Avg IO],
        [Execution Count],
        [Query Text]
    )
SELECT  TOP(@pRowCnt) 
        GETDATE() AS [ReportDate],
        p.name AS [SP Name],
        (qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count AS [Avg IO], 
        qs.execution_count AS [Execution Count],
        SUBSTRING(qt.[text], qs.statement_start_offset/2, 
	        CASE 
                WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2 
	        	ELSE qs.statement_end_offset 
	        END - qs.statement_start_offset) AS [Query Text]	
FROM    [$(TargetDBName)].sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY [$(TargetDBName)].sys.dm_exec_sql_text(qs.sql_handle) AS qt
JOIN    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
    ON p.object_id = qt.objectid        
WHERE   qt.[dbid] = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        [Avg IO] DESC 
OPTION (RECOMPILE);
-- Helps you find the most expensive statements for I/O by SP

END