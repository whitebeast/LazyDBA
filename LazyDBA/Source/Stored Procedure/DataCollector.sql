CREATE PROCEDURE [dbo].[DataCollector]
    @pEmailProfileName NVARCHAR(100),
    @pEmailRecipients NVARCHAR(100),
    @PruningPeriod INT = 120,
    @pDebugMode BIT = 0
AS
BEGIN

SET NOCOUNT ON;
DECLARE @ReportDate DATETIME2 = GETDATE();

EXEC GetCachedQueriesByIOCostList @ReportDate;
EXEC GetCachedSPByCPUCostList @ReportDate;
EXEC GetCachedSPByExecCntList @ReportDate;
EXEC GetCachedSPByExecTimeList @ReportDate;
EXEC GetCachedSPByExecTimeVariableList @ReportDate;
EXEC GetCachedSPByLogicalReadsList @ReportDate;
EXEC GetCachedSPByLogicalWritesList @ReportDate;
EXEC GetCachedSPByPhysicalReadsList @ReportDate;
EXEC GetPossibleBadIndexesList @ReportDate;
EXEC GetPossibleNewIndexesByAdvantageList @ReportDate;
EXEC GetWaitStatsList @ReportDate;

-- EXEC GetPossibleNewIndexesBySprocList;
-- EXEC GetSQLJobTimeline 1;
   
END