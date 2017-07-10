CREATE PROCEDURE [dbo].[GetPossibleBadIndexesList]
AS
BEGIN
SET NOCOUNT ON;

SELECT 
		OBJECT_NAME(s.[object_id]) AS 'TableName', 
		i.name AS 'IndexName', 
		i.index_id AS 'IndexId', 
		i.is_disabled AS 'IsDisabled', 
		i.is_hypothetical AS 'IsHypothetical', 
		i.has_filter AS 'HasFilter', 
		i.fill_factor AS 'FillFactor',
		user_updates AS 'TotalWrites', 
		user_seeks + user_scans + user_lookups AS 'TotalReads',
		user_updates - (user_seeks + user_scans + user_lookups) AS 'Difference'
FROM	[$(TargetDBName)].sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
JOIN	[$(TargetDBName)].sys.indexes AS i WITH (NOLOCK) 
	ON	s.[object_id] = i.[object_id]
	AND i.index_id = s.index_id
WHERE	OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
	AND s.database_id = DB_ID('$(TargetDBName)')
	AND user_updates > (user_seeks + user_scans + user_lookups)
	AND i.index_id > 1
ORDER BY 
		'Difference' DESC, 
		'TotalWrites' DESC, 
		'TotalReads' ASC 
OPTION (RECOMPILE);

END