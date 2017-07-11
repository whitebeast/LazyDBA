CREATE PROCEDURE [dbo].[GetPossibleNewIndexesBySprocList]
(
    @pRowCnt INT = 25
)
AS
BEGIN
SET NOCOUNT ON;

-- Find missing index warnings for cached plans in the current database
-- Note: This query could take some time on a busy instance
SELECT  TOP(@pRowCnt) 
        OBJECT_NAME(objectid) AS [Object Name], 
        query_plan AS [Query Plan], 
        cp.objtype AS [Object Type], 
        cp.usecounts AS [Use Counts]
FROM    [$(TargetDBName)].sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY [$(TargetDBName)].sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE   CAST(query_plan AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
    AND dbid = DB_ID('$(TargetDBName)')
ORDER BY 
        cp.usecounts DESC 
OPTION (RECOMPILE);

-- Helps you connect missing indexes to specific stored procedures or queries
-- This can help you decide whether to add them or not

END