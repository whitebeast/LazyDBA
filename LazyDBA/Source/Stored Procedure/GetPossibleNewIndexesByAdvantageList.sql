CREATE PROCEDURE [dbo].[GetPossibleNewIndexesByAdvantageList]
AS
BEGIN
SET NOCOUNT ON;

-- Missing Indexes for current database by Index Advantage
SELECT	DISTINCT 
		CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS 'IndexAdvantage', 
		migs.last_user_seek AS 'LastUserSeekDate', 
		mid.[statement] AS 'Database.Schema.Table',
		mid.equality_columns AS 'EqualityColumns', 
		mid.inequality_columns AS 'InequalityColumns', 
		mid.included_columns AS 'IncludedColumns',
		migs.unique_compiles AS 'UniqueCompiles', 
		migs.user_seeks AS 'UserSeeks', 
		migs.avg_total_user_cost AS 'AvgTotalUserCosts', 
		migs.avg_user_impact AS 'AvgUserImpact',
		OBJECT_NAME(mid.[object_id]) AS 'TableName', 
		p.rows AS 'TableRows'
FROM	[$(TargetDBName)].sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
JOIN	[$(TargetDBName)].sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
	ON migs.group_handle = mig.index_group_handle
JOIN	[$(TargetDBName)].sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
	ON mig.index_handle = mid.index_handle
JOIN	[$(TargetDBName)].sys.partitions AS p WITH (NOLOCK)
	ON p.[object_id] = mid.[object_id]
WHERE	mid.database_id = DB_ID('$(TargetDBName)') 
ORDER BY 
		'IndexAdvantage' DESC 
OPTION (RECOMPILE);

-- Look at index advantage, last user seek time, number of user seeks to help determine source and importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!

END