CREATE PROCEDURE [dbo].[LstCachedSPByCPUCost]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByCPUCost
    
    SELECT
        [ReportDate],
        [SP Name],
        [Total Worker Time],
        [Avg Worker Time],
        [Execution Count],
        [Calls/Minute],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    FROM dbo.CachedSPByCPUCost
    WHERE ReportDate = @pReportDate
    ORDER BY [CachedSPByCPUCostId]
    ;

END