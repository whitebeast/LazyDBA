CREATE PROCEDURE [dbo].[GetPossibleBadIndexesList]
(   
    @pReportDate DATETIME2,
    @pRowCnt INT = 10
)
AS
BEGIN
SET NOCOUNT ON;

-- Possible Bad NC Indexes (writes > reads)
INSERT INTO [dbo].[PossibleBadIndexesList]
    (
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
    )
SELECT  TOP(@pRowCnt)
		@pReportDate,
        t.name AS [Table Name], 
		i.name AS [Index Name], 
		i.is_disabled AS [Is Disabled], 
		i.is_hypothetical AS [Is Hypothetical], 
		i.has_filter AS [Has Filter], 
		i.fill_factor AS [Fill Factor],
		user_updates AS [Total Writes], 
		user_seeks + user_scans + user_lookups AS [Total Reads],
		user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
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

END