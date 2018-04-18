CREATE PROCEDURE [dbo].[AddCachedQueriesByIOCost]
(
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(MAX) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @tOutput TABLE
(
    [SP Name] NVARCHAR(128),
    [Avg IO] BIGINT,
    [Execution Count] BIGINT,
    [Query Text] NVARCHAR(MAX)
);

-- Lists the top statements by average input/output usage for the current database
INSERT INTO [dbo].[CachedQueriesByIOCost]
    (
        [ReportDate],
        [SP Name],
        [Avg IO],
        [Execution Count],
        [Query Text]
    )
OUTPUT  inserted.[SP Name], 
        inserted.[Avg IO], 
        inserted.[Execution Count], 
        inserted.[Query Text] 
INTO @tOutput
SELECT  TOP(@pRowCnt) 
        GETDATE() AS [ReportDate],
        p.name AS [SP Name],
        (qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count AS [Avg IO], 
        qs.execution_count AS [Execution Count],
        SUBSTRING(qt.[text], qs.statement_start_offset/2,8000) AS [Query Text]	
FROM    [$(TargetDBName)].sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY [$(TargetDBName)].sys.dm_exec_sql_text(qs.sql_handle) AS qt
JOIN    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
    ON p.object_id = qt.objectid        
WHERE   qt.[dbid] = DB_ID('$(TargetDBName)')
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        [Avg IO] DESC 
OPTION (RECOMPILE);
-- Helps you find the most expensive statements for I/O by SP

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 10%;">SP Name</th>' +
            N'<th style="width: 3%;">Avg IO</th>' +
            N'<th style="width: 2%;">Execution Count</th>' +
            N'<th style="width: 85%;">Query Text</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Avg IO] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL([Query Text],''),'"','') 
                    FROM @tOutput
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';  
        ;

END