CREATE PROCEDURE [dbo].[DataCollector]
    --@pEmailProfileName NVARCHAR(100),
    --@pEmailRecipients NVARCHAR(100),
    --@PruningPeriod INT = 120,
    --@pDebugMode BIT = 0
AS
BEGIN

SET NOCOUNT ON;

EXEC AddCachedQueriesByIOCost;
EXEC AddCachedSPByCPUCost;
EXEC AddCachedSPByExecCnt;
EXEC AddCachedSPByExecTime;
EXEC AddCachedSPByExecTimeVariable;
EXEC AddCachedSPByLogicalReads;
EXEC AddCachedSPByLogicalWrites;
EXEC AddCachedSPByPhysicalReads;
EXEC AddPossibleBadIndexes;
EXEC AddPossibleNewIndexesByAdvantage;
EXEC AddWaitStats;

-- EXEC GetPossibleNewIndexesBySprocList;
-- EXEC GetSQLJobTimeline 1;
   
END