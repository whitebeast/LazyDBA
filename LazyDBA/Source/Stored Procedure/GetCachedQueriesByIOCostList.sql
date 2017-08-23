CREATE PROCEDURE [dbo].[GetCachedQueriesByIOCostList]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tCachedQueriesByIOCostList') IS NOT NULL DROP TABLE #tCachedQueriesByIOCostList;

-- Lists the top statements by average input/output usage for the current database
SELECT  TOP(@pRowCnt) 
        OBJECT_NAME(qt.objectid, dbid) AS [SP Name],
        (qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count AS [Avg IO], 
        qs.execution_count AS [Execution Count],
        SUBSTRING(qt.[text], qs.statement_start_offset/2, 
	        CASE 
                WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2 
	        	ELSE qs.statement_end_offset 
	        END - qs.statement_start_offset) AS [Query Text]	
INTO #tCachedQueriesByIOCostList
FROM    [$(TargetDBName)].sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY [$(TargetDBName)].sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE   qt.[dbid] = DB_ID('$(TargetDBName)')
ORDER BY 
        [Avg IO] DESC 
OPTION (RECOMPILE);
-- Helps you find the most expensive statements for I/O by SP

SET @pHTML =
    N'<table>
        <tr>'+
            N'<th style="width: 10%;">SP Name</th>' +
            N'<th style="width: 3%;">Avg IO</th>' +
            N'<th style="width: 2%;">Execution Count</th>' +
            N'<th style="width: 85%;">Query Text</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL(CAST([SP Name] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Avg IO] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Query Text] AS NVARCHAR(MAX)),''),'"','') 
                    FROM #tCachedQueriesByIOCostList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';  
        ;

IF OBJECT_ID('tempdb..#tCachedQueriesByIOCostList') IS NOT NULL DROP TABLE #tCachedQueriesByIOCostList;

END