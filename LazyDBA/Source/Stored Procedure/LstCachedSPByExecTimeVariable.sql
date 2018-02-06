CREATE PROCEDURE [dbo].[LstCachedSPByExecTimeVariable]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.CachedSPByExecTimeVariable
    
    SELECT
        [ReportDate],
        [SP Name],
        [Execution Count],
        [Min Elapsed Time],
        [Avg Elapsed Time],
        [Max Elapsed Time],
        [Last Elapsed Time],
        [Cached Time]
    FROM dbo.CachedSPByExecTimeVariable
    WHERE ReportDate = @pReportDate
    ORDER BY [CachedSPByExecTimeVariableId]
    ;

END