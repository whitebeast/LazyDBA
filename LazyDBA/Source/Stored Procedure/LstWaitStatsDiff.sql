CREATE PROCEDURE [dbo].[LstWaitStatsDiff]
    @pReportDate DATETIME2 = NULL
AS
BEGIN 
    SET NOCOUNT ON;
    DECLARE @PrevDate DATETIME2;

    IF @pReportDate IS NULL
        SELECT @pReportDate = MAX(ReportDate) 
        FROM dbo.WaitStatsList
    
    SELECT @PrevDate = MAX(ReportDate) 
    FROM dbo.WaitStatsList
    WHERE ReportDate < @pReportDate

    ;WITH cte AS (
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
        FROM dbo.WaitStatsList
        WHERE ReportDate IN (@PrevDate,@pReportDate)
    ) 
    SELECT 
            c.[ReportDate] AS [Cur ReportDate],
            p.[ReportDate] AS [Prev ReportDate],
            COALESCE(c.[Wait Type],p.[Wait Type]) AS [Wait Type],
            c.[Wait Sec] AS [Cur Wait Sec],
            p.[Wait Sec] AS [Prev Wait Sec],
            CASE 
                WHEN c.[Wait Sec] < p.[Wait Sec] THEN '-1' 
                WHEN c.[Wait Sec] > p.[Wait Sec] THEN '1' 
                ELSE '0' 
            END AS [State Wait Sec],
            ISNULL(c.[Wait Sec] - p.[Wait Sec],0) AS [Diff Wait Sec],
            c.[Resource Sec] AS [Cur Resource Sec],
            p.[Resource Sec] AS [Prev Resource Sec],
            CASE 
                WHEN c.[Resource Sec] < p.[Resource Sec] THEN '-1' 
                WHEN c.[Resource Sec] > p.[Resource Sec] THEN '1' 
                ELSE '0' 
            END AS [State Resource Sec],
            ISNULL(c.[Resource Sec] - p.[Resource Sec],0) AS [Diff Resource Sec],
            c.[Signal Sec] AS [Cur Signal Sec],
            p.[Signal Sec] AS [Prev Signal Sec],
            CASE 
                WHEN c.[Signal Sec] < p.[Signal Sec] THEN '-1' 
                WHEN c.[Signal Sec] > p.[Signal Sec] THEN '1'
                ELSE '0' 
            END AS [State Signal Sec],
            ISNULL(c.[Signal Sec] - p.[Signal Sec],0) AS [Diff Signal Sec],
            c.[Wait Count] AS [Cur Wait Count],
            p.[Wait Count] AS [Prev Wait Count],
            CASE 
                WHEN c.[Wait Count] < p.[Wait Count] THEN '-1' 
                WHEN c.[Wait Count] > p.[Wait Count] THEN '1' 
                ELSE '0' 
            END AS [State Wait Count],
            ISNULL(c.[Wait Count] - p.[Wait Count],0) AS [Diff Wait Count],
            c.[Wait Percentage] AS [Cur Wait Percentage],
            p.[Wait Percentage] AS [Prev Wait Percentage],
            CASE 
                WHEN c.[Wait Percentage] < p.[Wait Percentage] THEN '-1' 
                WHEN c.[Wait Percentage] > p.[Wait Percentage] THEN '1' 
                ELSE '0' 
            END AS [State Wait Percentage],
            ISNULL(c.[Wait Percentage] - p.[Wait Percentage],0) AS [Diff Wait Percentage],
            c.[Avg Wait Sec] AS [Cur Avg Wait Sec],
            p.[Avg Wait Sec] AS [Prev Avg Wait Sec],
            CASE 
                WHEN c.[Avg Wait Sec] < p.[Avg Wait Sec] THEN '-1' 
                WHEN c.[Avg Wait Sec] > p.[Avg Wait Sec] THEN '1'
                ELSE '0' 
            END AS [State Avg Wait Sec],
            ISNULL(c.[Avg Wait Sec] - p.[Avg Wait Sec],0) AS [Diff Avg Wait Sec],
            c.[Avg Res Sec] AS [Cur Avg Res Sec],
            p.[Avg Res Sec] AS [Prev Avg Res Sec],
            CASE 
                WHEN c.[Avg Res Sec] < p.[Avg Res Sec] THEN '-1' 
                WHEN c.[Avg Res Sec] > p.[Avg Res Sec] THEN '1' 
                ELSE '0'
            END AS [State Avg Res Sec],
            ISNULL(c.[Avg Res Sec] - p.[Avg Res Sec],0) AS [Diff Avg Res Sec],
            c.[Avg Sig Sec] AS [Cur Avg Sig Sec],
            p.[Avg Sig Sec] AS [Prev Avg Sig Sec],
            CASE 
                WHEN c.[Avg Sig Sec] < p.[Avg Sig Sec] THEN '-1' 
                WHEN c.[Avg Sig Sec] > p.[Avg Sig Sec] THEN '1' 
                ELSE '0' 
            END AS [State Avg Sig Sec],
            ISNULL(c.[Avg Sig Sec] - p.[Avg Sig Sec],0) AS [Diff Avg Sig Sec]
    FROM cte AS c
    FULL JOIN cte AS p ON p.[Wait Type] = c.[Wait Type] AND p.ReportDate = @PrevDate
    WHERE c.ReportDate = @pReportDate
    ;

END
