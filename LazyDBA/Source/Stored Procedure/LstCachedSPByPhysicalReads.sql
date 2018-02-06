CREATE PROCEDURE [dbo].[LstCachedSPByPhysicalReads]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByPhysicalReads
    
    SELECT
        [ReportDate],
        [SP Name],
        [Total Physical Reads],
        [Avg Physical Reads],
        [Execution Count],
        [Total Logical Reads],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    FROM dbo.CachedSPByPhysicalReads
    WHERE [ReportDate] = @pReportDate
    ORDER BY [CachedSPByPhysicalReadsId]
    ;

END