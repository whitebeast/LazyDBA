CREATE PROCEDURE [dbo].[DataCollector]
    @pEmailProfileName NVARCHAR(100),
    @pEmailRecipients NVARCHAR(100),
    @PruningPeriod INT = 120,
    @pDebugMode BIT = 0
AS
BEGIN

SET NOCOUNT ON;
DECLARE @ReportDate DATETIME2 = GETDATE();

EXEC AddCachedQueriesByIOCost @ReportDate;
EXEC AddCachedSPByCPUCost @ReportDate;
EXEC AddCachedSPByExecCnt @ReportDate;
EXEC AddCachedSPByExecTime @ReportDate;
EXEC AddCachedSPByExecTimeVariable @ReportDate;
EXEC AddCachedSPByLogicalReads @ReportDate;
EXEC AddCachedSPByLogicalWrites @ReportDate;
EXEC AddCachedSPByPhysicalReads @ReportDate;
EXEC AddPossibleBadIndexes @ReportDate;
EXEC AddPossibleNewIndexesByAdvantage @ReportDate;
EXEC AddWaitStats @ReportDate;

-- EXEC GetPossibleNewIndexesBySprocList;
-- EXEC GetSQLJobTimeline 1;
   
END