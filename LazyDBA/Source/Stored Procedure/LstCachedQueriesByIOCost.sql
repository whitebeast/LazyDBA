CREATE PROCEDURE [dbo].[LstCachedQueriesByIOCost]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedQueriesByIOCost
    
    SELECT
        [ReportDate],
        [SP Name],
        [Avg IO],
        [Execution Count],
        [Query Text]
    FROM dbo.CachedQueriesByIOCost
    WHERE ReportDate = @pReportDate
    ORDER BY [CachedQueriesByIOCostId]
    ;

END