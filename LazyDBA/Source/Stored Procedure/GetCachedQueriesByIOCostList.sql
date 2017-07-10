CREATE PROCEDURE [dbo].[GetCachedQueriesByIOCostList]
AS
BEGIN

SET NOCOUNT ON;

-- Lists the top statements by average input/output usage for the current database
SELECT  TOP(50) 
        OBJECT_NAME(qt.objectid, dbid) AS [SP Name],
        (qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count AS [Avg IO], 
        qs.execution_count AS [Execution Count],
        SUBSTRING(qt.[text], qs.statement_start_offset/2, 
	        CASE 
                WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2 
	        	ELSE qs.statement_end_offset 
	        END - qs.statement_start_offset)/2 AS [Query Text]	
FROM    [$(TargetDBName)].sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY [$(TargetDBName)].sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE   qt.[dbid] = DB_ID('$(TargetDBName)')
ORDER BY 
        [Avg IO] DESC 
OPTION (RECOMPILE);

-- Helps you find the most expensive statements for I/O by SP

END