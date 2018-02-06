CREATE PROCEDURE [dbo].[LstPossibleBadIndexes]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.PossibleBadIndexes
    
    SELECT
        [ReportDate],
        [Table Name],
        [Index Name],
        [Is Disabled],
        [Is Hypothetical],
        [Has Filter],
        [Fill Factor],
        [Total Writes],
        [Total Reads],
        [Difference]
    FROM dbo.PossibleBadIndexes
    WHERE [ReportDate] = @pReportDate
    ORDER BY [PossibleBadIndexesId]
    ;

END