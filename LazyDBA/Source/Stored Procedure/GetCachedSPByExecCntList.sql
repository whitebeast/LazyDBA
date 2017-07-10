﻿CREATE PROCEDURE [dbo].[GetCachedSPByExecCntList]
AS
BEGIN

SET NOCOUNT ON;

-- Top Cached SPs By Execution Count (SQL Server 2012)
SELECT  TOP(100) 
        p.name AS [SP Name], 
        qs.execution_count,
        ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
        qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
        qs.total_worker_time AS [TotalWorkerTime],  
        qs.total_elapsed_time, 
        qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
        qs.cached_time
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK) 
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
ORDER BY 
        qs.execution_count DESC 
OPTION (RECOMPILE);

-- Tells you which cached stored procedures are called the most often
-- This helps you characterize and baseline your workload

END