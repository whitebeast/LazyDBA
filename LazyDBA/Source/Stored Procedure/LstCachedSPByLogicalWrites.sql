CREATE PROCEDURE [dbo].[LstCachedSPByLogicalWrites]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByLogicalWrites
    
    SELECT
        [ReportDate],
        [SP Name],
        [Total Logical Writes],
        [Avg Logical Writes],
        [Execution Count],
        [Calls/Minute],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    FROM dbo.CachedSPByLogicalWrites
    WHERE [ReportDate] = @pReportDate
    ORDER BY [CachedSPByLogicalWritesId]
    ;

END