CREATE PROCEDURE [dbo].[GetCachedSPByLogicalReadsList]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tCachedSPByLogicalReadsList') IS NOT NULL DROP TABLE #tCachedSPByLogicalReadsList;

-- Top Cached SPs By Total Logical Reads (SQL Server 2012). Logical reads relate to memory pressure
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.total_logical_reads AS [Total Logical Reads], 
        qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads],
        qs.execution_count AS [Execution Count], 
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
INTO #tCachedSPByLogicalReadsList
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        qs.total_logical_reads DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a memory perspective
-- You should look at this if you see signs of memory pressure

SET @pHTML =
    N'<table>
        <tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Logical Reads</th>' +
            N'<th style="width: 5%;" >Avg Logical Reads</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL(CAST([SP Name] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Logical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Logical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByLogicalReadsList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tCachedSPByLogicalReadsList') IS NOT NULL DROP TABLE #tCachedSPByLogicalReadsList;

END