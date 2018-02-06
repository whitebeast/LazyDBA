CREATE PROCEDURE [dbo].[AddPossibleNewIndexesByAdvantage]
(   
    @pRowCnt INT = 10
)
AS
BEGIN
SET NOCOUNT ON;

-- Missing Indexes for current database by Index Advantage
INSERT INTO [dbo].[PossibleNewIndexesByAdvantageList]
    (
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
    )
SELECT	DISTINCT
        TOP (@pRowCnt)
        GETDATE() AS [ReportDate],
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

END