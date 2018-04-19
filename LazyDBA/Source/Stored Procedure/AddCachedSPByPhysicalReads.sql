CREATE PROCEDURE [dbo].[AddCachedSPByPhysicalReads]
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
    [Total Physical Reads] BIGINT,
    [Avg Physical Reads] BIGINT,
    [Execution Count] BIGINT,
    [Total Logical Reads] BIGINT,
    [Total Elapsed Time] BIGINT,
    [Avg Elapsed Time] BIGINT,
    [Cached Time] DATETIME
);

-- Top Cached SPs By Total Physical Reads (SQL Server 2012). Physical reads relate to disk I/O pressure
INSERT INTO [dbo].[CachedSPByPhysicalReads]
    (
        [ReportDate],
        [SP Name],
        [Total Physical Reads],
        [Avg Physical Reads],
        [Execution Count],
        [Total Logical Reads],
        [Total Elapsed Time],
        [Avg Elapsed Time],
        [Cached Time]
    )
OUTPUT  inserted.[SP Name],
        inserted.[Total Physical Reads],
        inserted.[Avg Physical Reads],
        inserted.[Execution Count],
        inserted.[Total Logical Reads],
        inserted.[Total Elapsed Time],
        inserted.[Avg Elapsed Time],
        inserted.[Cached Time]
INTO    @tOutput
SELECT  TOP(@pRowCnt) 
        GETDATE() AS [ReportDate],
        p.name AS [SP Name],
        qs.total_physical_reads AS [Total Physical Reads], 
        qs.total_physical_reads/qs.execution_count AS [Avg Physical Reads], 
        qs.execution_count AS [Execution Count], 
        qs.total_logical_reads AS [Total Logical Reads],
        qs.total_elapsed_time AS [Total Elapsed Time], 
        qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
        qs.cached_time AS [Cached Time]
FROM    [$(TargetDBName)].sys.procedures AS p WITH (NOLOCK)
JOIN    [$(TargetDBName)].sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON  p.[object_id] = qs.[object_id]
WHERE   qs.database_id = DB_ID('$(TargetDBName)')
    AND qs.total_physical_reads > 0
    AND NOT EXISTS (SELECT 1 FROM dbo._Exception AS e WHERE e.ObjectName = p.name)
ORDER BY 
        qs.total_physical_reads DESC, 
        qs.total_logical_reads DESC 
OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a read I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure

SET @pHTML =
    N'            <div class="header" id="8-header">Cached SP By Physical Reads</div><div class="content" id="8-content"><div class="text">' + 
    ISNULL(N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Physical Reads</th>' +
            N'<th style="width: 5%;" >Avg Physical Reads</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Total Logical Reads</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Physical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Physical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Logical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM @tOutput 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>','NO DATA') + 
        N'</div></div>';   
SET @pHTML = REPLACE(@pHTML,'&#x0D;','');

END