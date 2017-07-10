﻿CREATE PROCEDURE [dbo].[GetPossibleNewIndexesBySprocList]
AS
BEGIN
SET NOCOUNT ON;

-- Find missing index warnings for cached plans in the current database
-- Note: This query could take some time on a busy instance
SELECT  TOP(25) 
        OBJECT_NAME(objectid) AS [ObjectName], 
        query_plan, 
        cp.objtype, 
        cp.usecounts
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