CREATE PROCEDURE [dbo].[LstPossibleNewIndexesByAdvantage]
    @pReportDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.PossibleNewIndexesByAdvantage
    
    SELECT
        [ReportDate],
        [Index Advantage],
        [Last User Seek Date],
        [Equality Columns],
        [Inequality Columns],
        [Included Columns],
        [Unique Compiles],
        [User Seeks],
        [Avg Total User Costs],
        [Avg User Impact],
        [Table Name],
        [Table Rows]
    FROM dbo.PossibleNewIndexesByAdvantage
    WHERE [ReportDate] = @pReportDate
    ORDER BY [PossibleNewIndexesByAdvantageId]
    ;

END