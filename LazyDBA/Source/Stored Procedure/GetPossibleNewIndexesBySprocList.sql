CREATE PROCEDURE [dbo].[GetPossibleNewIndexesBySprocList]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tPossibleNewIndexesBySprocList') IS NOT NULL DROP TABLE #tPossibleNewIndexesBySprocList;

-- Find missing index warnings for cached plans in the current database
-- Note: This query could take some time on a busy instance
SELECT  TOP(@pRowCnt) 
        OBJECT_NAME(objectid) AS [Object Name], 
        query_plan AS [Query Plan], 
        cp.objtype AS [Object Type], 
        cp.usecounts AS [Use Counts]
INTO #tPossibleNewIndexesBySprocList
FROM    sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE   CAST(query_plan AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
    AND dbid = DB_ID('$(TargetDBName)')
ORDER BY 
        cp.usecounts DESC 
OPTION (RECOMPILE);

-- Helps you connect missing indexes to specific stored procedures or queries
-- This can help you decide whether to add them or not

SET @pHTML =
    N'<table>
        <tr>'+
            N'<th>Object Name</th>' +
            N'<th>Query Plan</th>' +
            N'<th>Object Type</th>' +
            N'<th>Use Counts</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL(CAST([Object Name] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Query Plan] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Object Type] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Use Counts] AS NVARCHAR(MAX)),''),'"','')
                    FROM #tPossibleNewIndexesByAdvantageList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tPossibleNewIndexesBySprocList') IS NOT NULL DROP TABLE #tPossibleNewIndexesBySprocList;

END