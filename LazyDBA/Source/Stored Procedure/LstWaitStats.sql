﻿CREATE PROCEDURE [dbo].[LstWaitStats]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) FROM dbo.WaitStats
    
    SELECT
        [ReportDate],
        [Wait Type],
        [Wait Sec],
        [Resource Sec],
        [Signal Sec],
        [Wait Count],
        [Wait Percentage],
        [Avg Wait Sec],
        [Avg Res Sec],
        [Avg Sig Sec]
    FROM dbo.WaitStats
    WHERE [ReportDate] = @pReportDate
    ORDER BY [WaitStatsId]
    ;

END
