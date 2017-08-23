﻿CREATE PROCEDURE [dbo].[GetPossibleBadIndexesList]
(   
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tPossibleBadIndexesList') IS NOT NULL DROP TABLE #tPossibleBadIndexesList;

-- Possible Bad NC Indexes (writes > reads)
SELECT  TOP(@pRowCnt)
		t.name AS [Table Name], 
		i.name AS [Index Name], 
		i.is_disabled AS [Is Disabled], 
		i.is_hypothetical AS [Is Hypothetical], 
		i.has_filter AS [Has Filter], 
		i.fill_factor AS [Fill Factor],
		user_updates AS [Total Writes], 
		user_seeks + user_scans + user_lookups AS [Total Reads],
		user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
INTO #tPossibleBadIndexesList
FROM	[$(TargetDBName)].sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
JOIN	[$(TargetDBName)].sys.indexes AS i WITH (NOLOCK) 
    ON	s.[object_id] = i.[object_id]
	AND i.index_id = s.index_id
JOIN    [$(TargetDBName)].sys.tables AS t WITH (NOLOCK) 
    ON  t.object_id = s.object_id 
WHERE	s.database_id = DB_ID('$(TargetDBName)')
	AND user_updates > (user_seeks + user_scans + user_lookups)
	AND i.index_id > 1
    AND t.is_ms_shipped = 0 -- user tables only
ORDER BY 
		[Difference] DESC, 
		[Total Writes] DESC, 
		[Total Reads] ASC 
OPTION (RECOMPILE);

-- Look for indexes with high numbers of writes and zero or very low numbers of reads
-- Consider your complete workload, and how long your instance has been running
-- Investigate further before dropping an index!

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 15%;">Table Name</th>' +
            N'<th style="width: 40%;">Index Name</th>' +
            N'<th style="width: 5%;" >Is Disabled</th>' +
            N'<th style="width: 5%;" >Is Hypothetical</th>' +
            N'<th style="width: 5%;" >Has Filter</th>' +
            N'<th style="width: 5%;" >Fill Factor</th>' +
            N'<th style="width: 5%;" >Total Writes</th>' +
            N'<th style="width: 5%;" >Total Reads</th>' +
            N'<th style="width: 5%;" >Difference</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([Table Name],''),'"',''),'',      
                           td=REPLACE(ISNULL([Index Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Is Disabled] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Is Hypothetical] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Has Filter] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Fill Factor] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Difference] AS NVARCHAR(MAX)),''),'"','')
                    FROM #tPossibleBadIndexesList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tPossibleBadIndexesList') IS NOT NULL DROP TABLE #tPossibleBadIndexesList;

END