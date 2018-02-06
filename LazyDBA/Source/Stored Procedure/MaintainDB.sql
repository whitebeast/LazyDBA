CREATE PROCEDURE [dbo].[MaintainDB]
(
    @pActivateDefragmentation BIT = 1,
    @pActivateUpdateStatistic BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET QUOTED_IDENTIFIER ON;

    DECLARE @partitioncount INT,
            @action         VARCHAR(10),
            @start_time     DATETIME,
            @end_time       DATETIME,
            @object_id      INT,
            @index_id       INT,
            @StatisticName  VARCHAR(250),
            @no_recompute   BIT,
            @TableName      VARCHAR(250),
            @SchemaName     VARCHAR(250),
            @indexName      VARCHAR(250),
            @defrag         FLOAT,
            @partition_num  INT,
            @sql            NVARCHAR(MAX),
            @Flag1          BIT,
            @Flag2          BIT,
            @indexType      INT
    ;            
        
    DECLARE @index_defrag_statistic TABLE
        (
            start_time              DATETIME,
            end_time                DATETIME,
            database_id             SMALLINT,
            object_id               INT,
            schema_name             VARCHAR(250),
            table_name              VARCHAR(250),
            index_id                INT,
            index_name              VARCHAR(250),
            avg_frag_percent_before FLOAT,
            fragment_count_before   BIGINT,
            pages_count_before      BIGINT,
            fill_factor             TINYINT,
            partition_num           INT,
            avg_frag_percent_after  FLOAT,
            fragment_count_after    BIGINT,
            pages_count_after       BIGINT,
            action                  VARCHAR(10),
            Flag1                   BIT,
            Flag2                   BIT,
            indexType               INT
        )
    ;
BEGIN TRY
    IF @pActivateDefragmentation = 1 BEGIN;
        INSERT INTO @index_defrag_statistic 
            (
                database_id, 
                object_id, 
                schema_name,
                table_name, 
                index_id, 
                index_name, 
                avg_frag_percent_before, 
                fragment_count_before, 
                pages_count_before, 
                fill_factor, 
                partition_num,
                Flag1,
                Flag2,
                indexType
            )
        SELECT  
                dm.database_id, 
                dm.object_id, 
                s.name,
                tbl.name, 
                dm.index_id, 
                idx.name, 
                dm.avg_fragmentation_in_percent, 
                dm.fragment_count, 
                dm.page_count, 
                idx.fill_factor, 
                dm.partition_number,
                CASE WHEN c.object_id IS NULL THEN 0 ELSE 1 END AS Flag1,
                CASE WHEN c2.object_id IS NULL THEN 0 ELSE 1 END AS Flag2,
                idx.type
        FROM    [$(TargetDBName)].sys.dm_db_index_physical_stats(DB_ID('$(TargetDBName)'), NULL, NULL, NULL, NULL) AS dm 
        JOIN    [$(TargetDBName)].sys.tables AS tbl WITH(NOLOCK) ON dm.object_id = tbl.object_id
        JOIN    [$(TargetDBName)].sys.schemas AS s WITH(NOLOCK) ON tbl.schema_id = s.schema_id
        JOIN    [$(TargetDBName)].sys.indexes AS idx WITH(NOLOCK) ON dm.object_id = idx.object_id AND dm.index_id = idx.index_id
        LEFT JOIN (
                    SELECT DISTINCT object_id
                    from (
                            SELECT c.object_id, c.system_type_id, c.max_length
                            FROM   [$(TargetDBName)].sys.columns AS c 
                            WHERE ((c.system_type_id IN (34,35,99,241)) -- image, text, ntext, xml
                                    OR (c.system_type_id IN (167,231,165) AND c.max_length = -1))  -- varchar, nvarchar, varbinary
                        ) c
                   ) c ON idx.object_id = c.object_id
        LEFT JOIN (
                    SELECT distinct object_id
                    from (
                    
                            SELECT ic.object_id, ic.index_id, c.system_type_id, max_length
                            FROM [$(TargetDBName)].sys.index_columns AS ic
                            JOIN [$(TargetDBName)].sys.columns AS c
                                ON ic.object_id = c.object_id
                                AND ic.column_id = c.column_id
                            WHERE ((c.system_type_id IN (34,35,99,241)) -- image, text, ntext, xml
                                    OR (c.system_type_id IN (167,231,165) AND c.max_length = -1))  -- varchar, nvarchar, varbinary
                        ) c
                   ) c2 ON idx.object_id = c2.object_id                   
        WHERE   
                page_count > 256
            AND avg_fragmentation_in_percent > 5
            AND dm.index_id > 0
        ORDER BY dm.page_count      
        ;
        
        DECLARE defragCur CURSOR LOCAL FAST_FORWARD FOR
        SELECT 
            object_id, 
            index_id, 
            schema_name,
            table_name, 
            index_name, 
            avg_frag_percent_before, 
            partition_num,
            Flag1, 
            Flag2,
            indexType
        FROM @index_defrag_statistic
        ORDER BY object_id, index_id DESC
        ;

        OPEN defragCur
        FETCH NEXT FROM defragCur INTO @object_id, @index_id, @schemaname, @tableName, @indexName, @defrag, @partition_num, @Flag1, @Flag2, @IndexType
        WHILE @@FETCH_STATUS=0
        BEGIN
            SELECT @sql = N'ALTER INDEX [' + @indexName + '] ON [$(TargetDBName)].[' + rtrim(@SchemaName) + '].[' + rtrim(@TableName) + ']';

            SELECT @partitioncount = count (*)
            FROM [$(TargetDBName)].sys.partitions
            WHERE object_id = @object_id AND index_id = @index_id;
            
            BEGIN 
                IF (@defrag > 30)
                BEGIN
                    IF @partitioncount > 1 or (@Flag1 = 1 and @IndexType = 1) or @Flag2 = 1
                        SELECT @sql = @sql + N' REBUILD',
                               @action = 'rebuild';
                    ELSE 
                        SELECT @sql = @sql + N' REBUILD WITH (SORT_IN_TEMPDB = ON, ONLINE = ON, MAXDOP = 1)',
                               @action = 'rebuild_o';
                END
                ELSE 
                BEGIN
                    SELECT @sql = @sql + N' REORGANIZE',
                           @action = 'reorginize';
                END
            END
            
            IF @partitioncount > 1
                SELECT @sql = @sql + N' PARTITION=' + CAST(@partition_num AS nvarchar(5))
            INSERT INTO dbo._MaintenanceLog (ActionText, DateTime, ErrorMessage)
            SELECT @sql, SYSDATETIME(), ERROR_MESSAGE();
            --raiserror (@sql,0,1) with nowait;
            SELECT @start_time = GETDATE();
            
            EXEC sp_executesql @sql;
            
            SELECT @END_time = GETDATE();
            
            UPDATE @index_defrag_statistic
            SET 
                start_time = @start_time,
                END_time = @END_time,
                action = @action
            WHERE object_id = @object_id
                AND index_id = @index_id
            ;
            FETCH NEXT FROM defragCur INTO @object_id, @index_id, @schemaname, @tableName, @indexName, @defrag, @partition_num, @Flag1, @Flag2, @IndexType
        END;
        CLOSE defragCur;
        DEALLOCATE defragCur;

        UPDATE dba
        SET
            dba.avg_frag_percent_after = dm.avg_fragmentation_in_percent,
            dba.fragment_count_after = dm.fragment_count,
            dba.pages_count_after = dm.page_count
        FROM [$(TargetDBName)].sys.dm_db_index_physical_stats(DB_ID('$(TargetDBName)'), null, null, null, null) dm
        JOIN @index_defrag_statistic dba 
          ON dm.object_id = dba.object_id
         AND dm.index_id = dba.index_id
        WHERE dm.index_id > 0
        ;

        --SELECT * from @index_defrag_statistic;    
    END;
    
    
    IF @pActivateUpdateStatistic = 1 BEGIN;
        DECLARE statisticsCur CURSOR LOCAL FAST_FORWARD FOR
        SELECT SCHEMA_NAME(o.[schema_id]),o.name,s.name,s.no_recompute
        FROM (
            SELECT 
                  [object_id]
                , name
                , stats_id
                , no_recompute
                , last_update = STATS_DATE([object_id], stats_id)
            FROM [$(TargetDBName)].sys.stats WITH(NOLOCK)
            WHERE auto_created = 0
        ) s
        JOIN [$(TargetDBName)].sys.objects o WITH(NOLOCK) ON s.[object_id] = o.[object_id]
        JOIN (
            SELECT
                  p.[object_id]
                , p.index_id
                , total_pages = SUM(a.total_pages)
            FROM [$(TargetDBName)].sys.partitions p WITH(NOLOCK)
            JOIN [$(TargetDBName)].sys.allocation_units a WITH(NOLOCK) ON p.[partition_id] = a.container_id
            GROUP BY 
                  p.[object_id]
                , p.index_id
        ) p ON o.[object_id] = p.[object_id] AND p.index_id = s.stats_id
        WHERE o.[type] IN ('U', 'V')
            AND o.is_ms_shipped = 0
            AND last_update <= DATEADD(dd, 
                    CASE 
                        WHEN p.total_pages > 4096 THEN -7 -- if > 4 MB and updated more than week ago
                        ELSE 0 
                    END, CAST(current_timestamp AS DATE))
        ;
                
        OPEN statisticsCur
        FETCH FROM statisticsCur INTO @SchemaName, @TableName, @StatisticName, @no_recompute
        WHILE @@fetch_status = 0 BEGIN
            SET @sql = N'UPDATE STATISTICS [$(TargetDBName)].[' + @SchemaName + '].[' + @TableName + '] [' + @StatisticName + '] WITH FULLSCAN' + CASE WHEN @no_recompute = 1 THEN ', NORECOMPUTE' ELSE '' END + ';'
            --raiserror (@sql,0,1) with nowait;
            INSERT INTO dbo._MaintenanceLog (ActionText, DateTime, ErrorMessage)
            SELECT @sql, SYSDATETIME(), ERROR_MESSAGE();
            EXEC sp_executesql @sql;
            FETCH FROM statisticsCur INTO @SchemaName, @TableName, @StatisticName, @no_recompute
        END;
        CLOSE statisticsCur;
        DEALLOCATE statisticsCur;
           
		/*    
        SELECT  SCHEMA_NAME(o.[schema_id]) + '.' + o.name as TableName,
                s.name as StatName,
                s.last_update
        FROM (
            SELECT 
                  [object_id]
                , name
                , stats_id
                , no_recompute
                , last_update = STATS_DATE([object_id], stats_id)
            FROM [$(TargetDBName)].sys.stats WITH(NOLOCK)
            WHERE auto_created = 0
        ) s
        JOIN [$(TargetDBName)].sys.objects o WITH(NOLOCK) ON s.[object_id] = o.[object_id]
        JOIN (
            SELECT
                  p.[object_id]
                , p.index_id
                , total_pages = SUM(a.total_pages)
            FROM [$(TargetDBName)].sys.partitions p WITH(NOLOCK)
            JOIN [$(TargetDBName)].sys.allocation_units a WITH(NOLOCK) ON p.[partition_id] = a.container_id
            GROUP BY 
                  p.[object_id]
                , p.index_id
        ) p ON o.[object_id] = p.[object_id] AND p.index_id = s.stats_id
        WHERE o.[type] IN ('U', 'V')
            AND o.is_ms_shipped = 0
            AND cast(last_update as date) = CAST(current_timestamp as date)
		*/
        ; 
    END;               
END TRY
BEGIN CATCH
    INSERT INTO dbo._MaintenanceLog (ActionText, DateTime, ErrorMessage)
    SELECT @sql, SYSDATETIME(), ERROR_MESSAGE();
END CATCH        
END


/*
begin tran

exec dbo.MaintainDB

rollback tran
*/


