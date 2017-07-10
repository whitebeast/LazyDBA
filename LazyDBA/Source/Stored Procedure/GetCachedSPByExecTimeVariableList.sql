﻿CREATE PROCEDURE [dbo].[GetCachedSPByExecTimeVariableList]
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Avg Elapsed Time with execution time variability (SQL Server 2012)
SELECT  TOP(25) 
        p.name AS [SP Name], 
        qs.execution_count, 
        qs.min_elapsed_time,
        qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
        qs.max_elapsed_time, 
        qs.last_elapsed_time,  qs.cached_time
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        avg_elapsed_time DESC 
OPTION (RECOMPILE);

-- This gives you some interesting information about the variability in the
-- execution time of your cached stored procedures, which is useful for tuning

END