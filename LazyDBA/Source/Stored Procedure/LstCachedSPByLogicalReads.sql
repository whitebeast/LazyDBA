CREATE PROCEDURE [dbo].[LstCachedSPByLogicalReads]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByLogicalReads
    
    SELECT
        [ReportDate],
        [SP Name],
        [Total Logical Reads],
        [Avg Logical Reads],
        [Execution Count],
        [Calls/Minute],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    FROM dbo.CachedSPByLogicalReads
    WHERE ReportDate = @pReportDate
    ORDER BY [CachedSPByLogicalReadsId]
    ;

END