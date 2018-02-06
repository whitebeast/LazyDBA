CREATE PROCEDURE [dbo].[LstCachedSPByExecCnt]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByExecCnt
    
    SELECT
        [ReportDate],
        [SP Name],
        [Execution Count],
        [Calls/Minute],
        [Avg Worker Time],
        [Total Worker Time],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    FROM dbo.CachedSPByExecCnt
    WHERE ReportDate = @pReportDate
    ORDER BY [CachedSPByExecCntId]
    ;

END