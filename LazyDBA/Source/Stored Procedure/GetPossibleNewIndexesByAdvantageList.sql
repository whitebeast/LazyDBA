CREATE PROCEDURE [dbo].[GetPossibleNewIndexesByAdvantageList]
(   
    @pRowCnt INT = 10,
    @pHTML NVARCHAR(max) OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tPossibleNewIndexesByAdvantageList') IS NOT NULL DROP TABLE #tPossibleNewIndexesByAdvantageList;

-- Missing Indexes for current database by Index Advantage
SELECT	DISTINCT
        TOP (@pRowCnt)
		CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [Index Advantage], 
		migs.last_user_seek AS [Last User Seek Date], 
		mid.equality_columns AS [Equality Columns], 
		mid.inequality_columns AS [Inequality Columns], 
		mid.included_columns AS [Included Columns],
		migs.unique_compiles AS [Unique Compiles], 
		migs.user_seeks AS [User Seeks], 
		migs.avg_total_user_cost AS [Avg Total User Costs], 
		migs.avg_user_impact AS [Avg User Impact],
		t.name AS [Table Name],
		p.rows AS [Table Rows]
INTO #tPossibleNewIndexesByAdvantageList
FROM	sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
JOIN	sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
	ON migs.group_handle = mig.index_group_handle
JOIN	sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
	ON mig.index_handle = mid.index_handle
JOIN	[$(TargetDBName)].sys.partitions AS p WITH (NOLOCK)
	ON p.[object_id] = mid.[object_id]
JOIN    [$(TargetDBName)].sys.tables AS t WITH (NOLOCK)
    ON t.object_id = mid.[object_id]
WHERE	mid.database_id = DB_ID('$(TargetDBName)') 
ORDER BY 
		[Index Advantage] DESC 
OPTION (RECOMPILE);

-- Look at index advantage, last user seek time, number of user seeks to help determine source and importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 5%;" >Index Advantage</th>' +
            N'<th style="width: 10%;">Last User Seek Date</th>' +
            N'<th style="width: 20%;">Equality Columns</th>' +
            N'<th style="width: 20%;">Inequality Columns</th>' +
            N'<th style="width: 20%;">Included Columns</th>' +
            N'<th style="width: 5%;" >Unique Compiles</th>' +
            N'<th style="width: 5%;" >User Seeks</th>' +
            N'<th style="width: 5%;" >Avg Total User Costs</th>' +
            N'<th style="width: 5%;" >Avg User Impact</th>' +
            N'<th style="width: 10%;">Table Name</th>' +
            N'<th style="width: 5%;" >Table Rows</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL(CAST([Index Advantage] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(CONVERT(VARCHAR,ISNULL([Last User Seek Date],''),121),'"',''),'', 
                           td=REPLACE(ISNULL([Equality Columns],''),'"',''),'', 
                           td=REPLACE(ISNULL([Inequality Columns],''),'"',''),'', 
                           td=REPLACE(ISNULL([Included Columns],''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([Unique Compiles] AS NVARCHAR(MAX)),''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([User Seeks] AS NVARCHAR(MAX)),''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([Avg Total User Costs] AS NVARCHAR(MAX)),''),'"',''),'',                       
                           td=REPLACE(ISNULL(CAST([Avg User Impact] AS NVARCHAR(MAX)),''),'"',''),'', 
                           td=REPLACE(ISNULL([Table Name],''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([Table Rows] AS NVARCHAR(MAX)),''),'"','')
                    FROM #tPossibleNewIndexesByAdvantageList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

IF OBJECT_ID('tempdb..#tPossibleNewIndexesByAdvantageList') IS NOT NULL DROP TABLE #tPossibleNewIndexesByAdvantageList;

END