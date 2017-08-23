CREATE PROCEDURE [dbo].[GetCachedSPByLogicalWritesList]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tCachedSPByLogicalWritesList') IS NOT NULL DROP TABLE #tCachedSPByLogicalWritesList;

-- Top Cached SPs By Total Logical Writes (SQL Server 2012)
-- Logical writes relate to both memory and disk I/O pressure 
SELECT  TOP(@pRowCnt) 
        p.name AS [SP Name], 
        qs.total_logical_writes AS [Total Logical Writes], 
        qs.total_logical_writes/qs.execution_count AS [Avg Logical Writes], 
        qs.execution_count AS [Execution Count],
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_elapsed_time AS [Total Elapsed Time],
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
INTO #tCachedSPByLogicalWritesList
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

SET @pHTML =
    N'<table>
        <tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Logical Writes</th>' +
            N'<th style="width: 5%;" >Avg Logical Writes</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL(CAST([SP Name] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Logical Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Logical Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByLogicalWritesList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tCachedSPByLogicalWritesList') IS NOT NULL DROP TABLE #tCachedSPByLogicalWritesList;

END