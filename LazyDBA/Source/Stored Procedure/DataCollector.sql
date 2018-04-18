CREATE PROCEDURE [dbo].[DataCollector]
    @pEmailProfileName NVARCHAR(128),
    @pEmailRecipients NVARCHAR(256),
    @pDebug BIT = 0
AS
BEGIN

SET NOCOUNT ON;

DECLARE @CachedQueriesByIOCost          NVARCHAR(MAX),
        @CachedSPByCPUCost              NVARCHAR(MAX),
        @CachedSPByExecCnt              NVARCHAR(MAX),
        @CachedSPByExecTime             NVARCHAR(MAX),
        @CachedSPByExecTimeVariable     NVARCHAR(MAX),
        @CachedSPByLogicalReads         NVARCHAR(MAX),
        @CachedSPByLogicalWrites        NVARCHAR(MAX),
        @CachedSPByPhysicalReads        NVARCHAR(MAX),
        @PossibleBadIndexes             NVARCHAR(MAX),
        @PossibleNewIndexesByAdvantage  NVARCHAR(MAX),
        @WaitStats                      NVARCHAR(MAX)

DECLARE @body VARCHAR(MAX) = 'No info found...',
        @header VARCHAR(MAX),
        @header2 VARCHAR(MAX),
        @data VARCHAR(MAX),
        @footer VARCHAR(MAX),
        @Id INT,
        @ReportName VARCHAR(100),
        @HTML VARCHAR(MAX)
        --@FileName NVARCHAR(100) = 'LazyDBA report on ' + CONVERT(NVARCHAR,GETDATE(),23) + '.html',
        --@SQL NVARCHAR(MAX)
;        

DECLARE @tData TABLE
(
    Id INT IDENTITY(1,1),
    ReportName NVARCHAR(128),
    HTML VARCHAR(MAX)
)

EXEC AddCachedQueriesByIOCost           @pHTML = @CachedQueriesByIOCost OUTPUT;
EXEC AddCachedSPByCPUCost               @pHTML = @CachedSPByCPUCost OUTPUT;
EXEC AddCachedSPByExecCnt               @pHTML = @CachedSPByExecCnt OUTPUT;
EXEC AddCachedSPByExecTime              @pHTML = @CachedSPByExecTime OUTPUT;
EXEC AddCachedSPByExecTimeVariable      @pHTML = @CachedSPByExecTimeVariable OUTPUT;
EXEC AddCachedSPByLogicalReads          @pHTML = @CachedSPByLogicalReads OUTPUT;
EXEC AddCachedSPByLogicalWrites         @pHTML = @CachedSPByLogicalWrites OUTPUT;
EXEC AddCachedSPByPhysicalReads         @pHTML = @CachedSPByPhysicalReads OUTPUT;
EXEC AddPossibleBadIndexes              @pHTML = @PossibleBadIndexes OUTPUT;
EXEC AddPossibleNewIndexesByAdvantage   @pHTML = @PossibleNewIndexesByAdvantage OUTPUT;
EXEC AddWaitStats                       @pHTML = @WaitStats OUTPUT;

-- EXEC GetPossibleNewIndexesBySprocList;
-- EXEC GetSQLJobTimeline 1;

INSERT INTO @tData (ReportName, HTML) VALUES
('Cached Queries By IO Cost',@CachedQueriesByIOCost),
('Cached SP By CPU Cost',@CachedSPByCPUCost),
('Cached SP By Execution Count',@CachedSPByExecCnt),
('Cached SP By Execution Time',@CachedSPByExecTime),
('Cached SP By Execution Time By Variable',@CachedSPByExecTimeVariable),
('Cached SP By Logical Reads',@CachedSPByLogicalReads),
('Cached SP By Logical Writes',@CachedSPByLogicalWrites),
('Cached SP By Physical Reads',@CachedSPByPhysicalReads),
('Possible Bad Indexes',@PossibleBadIndexes),
('Possible New Indexes By Advantage',@PossibleNewIndexesByAdvantage),
('Wait Statistics',@WaitStats)

IF (SELECT SUM(LEN(ISNULL(HTML,0))) FROM @tData) > 0
BEGIN
    
    SELECT  @header = REPLACE(MAX(CASE WHEN ConfigItem = 'Email Header' THEN ConfigValue ELSE '' END),'<_Title_>','LazyDBA report on ' + CONVERT(VARCHAR,GETDATE(),23)),
            @header2= MAX(CASE WHEN ConfigItem = 'Email Header 2' THEN ConfigValue ELSE '' END),
            @data   = MAX(CASE WHEN ConfigItem = 'Email Data'   THEN ConfigValue ELSE '' END),
            @footer = MAX(CASE WHEN ConfigItem = 'Email Footer' THEN ConfigValue ELSE '' END)
    FROM    dbo._Config
    WHERE   ConfigItem IN ('Email Header', 'Email Header 2', 'Email Data', 'Email Footer')
    ;
    
    SET @body = @header + @header2
    
    DECLARE cur CURSOR FAST_FORWARD FOR  
    SELECT Id, ReportName, ISNULL(HTML,'NO DATA') AS HTML 
    FROM @tData
    ORDER BY Id;

    OPEN cur   
    FETCH NEXT FROM cur INTO @Id, @ReportName, @HTML    

    WHILE @@FETCH_STATUS = 0   
    BEGIN   
    
        SET @body = @body + REPLACE(REPLACE(REPLACE(@data,'<_Id_>',CAST(@Id AS VARCHAR)),'<_ReportName_>',@ReportName),'<_HTML_>',@HTML)
        FETCH NEXT FROM cur INTO @Id, @ReportName, @HTML 
        
    END   

    CLOSE cur;
    DEALLOCATE cur;

    SET @body = @body + @footer
END

--SELECT @body AS Body INTO ##tMail

IF @pDebug = 0 
    EXEC msdb.dbo.sp_send_dbmail	
        @profile_name = @pEmailProfileName,
        @recipients = @pEmailRecipients,
        @subject = 'LazyDBA: Email notification',
        @body = @body,
        @body_format = 'HTML', -- or TEXT
        @importance = 'HIGH' --Low Normal High
        /*
        ,@query='set nocount on; select * from ##tMail',
        @attach_query_result_as_file=1,
        @query_attachment_filename = @FileName,
        @execute_query_database = 'tempdb',
        @query_result_width =32767,
	    @query_result_header = 0,
	    @query_no_truncate = 1
        --@query_result_no_padding = 1  -- prevent SQL adding padding spaces in the result
        */
ELSE SELECT @body--, * FROM ##tMail   

--IF OBJECT_ID('tempdb..##tMail') IS NOT NULL DROP TABLE ##tMail;

END