CREATE PROCEDURE [dbo].[LstCachedSPByExecTime]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByExecTime
    
    SELECT
        [ReportDate],
        [SP Name],
        [Avg Elapsed Time],
        [Total Elapsed Time],
        [Execution Count],
        [Calls/Minute],
        [Avg Worker Time],
        [Total Worker Time],
        [Cached Time]
    FROM dbo.CachedSPByExecTime
    WHERE ReportDate = @pReportDate
    ORDER BY [CachedSPByExecTimeId]
    ;

END