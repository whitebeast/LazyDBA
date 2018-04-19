USE [msdb]
GO

BEGIN TRANSACTION

PRINT N'Creating Data collector Job...';

DECLARE @ReturnCode INT = 0,
        @JobId UNIQUEIDENTIFIER,
        @name NVARCHAR(100) = N'$(ProjectName).Data collector Job',
        @HTMLDir NVARCHAR(100),
        @Job1Command NVARCHAR(MAX),
        @Job2Command NVARCHAR(MAX),
        @Job3Command NVARCHAR(MAX),
        @Job4Command NVARCHAR(MAX),
        @Job5Command NVARCHAR(MAX),
        @Job6Command NVARCHAR(MAX),
        @Job7Command NVARCHAR(MAX),
        @Job8Command NVARCHAR(MAX)

SELECT  @JobId = job_id FROM msdb..sysjobs WHERE [name] = @name
SELECT  @HTMLDir = ConfigValue FROM [$(ProjectName)].dbo._Config WHERE ConfigItem = N'Email HTML files dir'

SELECT  
@Job1Command = 'if not exist "' + @HTMLDir + '" mkdir "' + @HTMLDir + '"',
@Job2Command = 'bcp "SELECT  REPLACE(ConfigValue,''<_Title_>'',''LazyDBA report on '' + CONVERT(VARCHAR,GETDATE(),23)) AS HTML FROM [$(ProjectName)].dbo._Config WHERE ConfigItem IN (N''Email Header'')" queryout "' + @HTMLDir + '\000.Header.tmp" -c -S . -T',
@Job3Command = 'bcp "SELECT  ConfigValue AS HTML FROM [$(ProjectName)].dbo._Config WHERE ConfigItem IN (N''Email Header 2'')" queryout "' + @HTMLDir + '\000.Header2.tmp" -c -S . -T',
@Job4Command = 'cmd /c bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedQueriesByIOCost @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\001.CachedQueriesByIOCost.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByCPUCost @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\002.CachedSPByCPUCost.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByExecCnt @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\003.CachedSPByExecCnt.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByExecTime @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\004.CachedSPByExecTime.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByExecTimeVariable @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\005.CachedSPByExecTimeVariable.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByLogicalReads @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\006.CachedSPByLogicalReads.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByLogicalWrites @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\007.CachedSPByLogicalWrites.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddCachedSPByPhysicalReads @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\008.CachedSPByPhysicalReads.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddPossibleBadIndexes @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\009.PossibleBadIndexes.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddPossibleNewIndexesByAdvantage @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\010.PossibleNewIndexesByAdvantage.tmp" -c -S . -T & ' +
'bcp "declare @HTML nvarchar(max) exec $(ProjectName).dbo.AddWaitStats @pHTML = @HTML OUTPUT SELECT @HTML as HTML" queryout "' + @HTMLDir + '\011.WaitStats.tmp" -c -S . -T',
@Job5Command = 'bcp "SELECT  ConfigValue AS HTML FROM [$(ProjectName)].dbo._Config WHERE ConfigItem IN (N''Email Footer'')" queryout "' + @HTMLDir + '\999.Footer.tmp" -c -S . -T',
@Job6Command = 'cmd /c del "' + @HTMLDir + '\Report.html" & for %f in ("' + @HTMLDir + '\*.tmp") do type %f >>"' + @HTMLDir + '\Report.html"',
@Job7Command = 'SET NOCOUNT ON;
DECLARE @Profile NVARCHAR(100),
        @Email NVARCHAR(100),
        @body VARCHAR(MAX) = ''Please look at attached detailed report'',
        @ReportDir VARCHAR(MAX);        

SELECT @Profile = ConfigValue FROM dbo._Config WHERE ConfigItem = N''Email profile name'';
SELECT @Email = ConfigValue FROM dbo._Config WHERE ConfigItem = N''Email recipients'';
SELECT @ReportDir = ConfigValue + ''\Report.html'' FROM [$(ProjectName)].dbo._Config WHERE ConfigItem = N''Email HTML files dir'';

EXEC msdb.dbo.sp_send_dbmail	
    @profile_name = @Profile,
    @recipients = @Email,
    @subject = ''LazyDBA: Email notification'',
    @body = @body,
    @body_format = ''TEXT'', -- or HTML
    @importance = ''HIGH'', --Low Normal High
    @file_attachments = @ReportDir',
@Job8Command = N'SET NOCOUNT ON;
DECLARE @PruningPeriod INT

SELECT @PruningPeriod = ConfigValue FROM [$(ProjectName)].[dbo].[_Config] WHERE ConfigItem = ''Table pruning period (in days)''

DELETE FROM [$(ProjectName)].[dbo].[CachedQueriesByIOCost] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByCPUCost] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByExecCnt] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByExecTime] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByExecTimeVariable] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByLogicalReads] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByLogicalWrites] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[CachedSPByPhysicalReads] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[PossibleBadIndexes] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[PossibleNewIndexesByAdvantage] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
DELETE FROM [$(ProjectName)].[dbo].[WaitStats] WHERE ReportDate < DATEADD(DAY,-@PruningPeriod,GETDATE()) 
'

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
    BEGIN
        EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    END

IF @JobId IS NOT NULL 
    EXEC msdb.dbo.sp_delete_job @job_id=@JobId, @delete_unused_schedule=1

SET @jobId = NULL
--IF @JobId IS NULL
BEGIN 
    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@name, 
            @enabled=1, 
            @notify_level_eventlog=0, 
            @notify_level_email=2, 
            @notify_level_netsend=0, 
            @notify_level_page=0, 
            @delete_level=0, 
            @description=N'Collect data for reporting', 
            @category_name=N'[Uncategorized (Local)]', 
            @owner_login_name=N'sa', 
            @notify_email_operator_name=N'DBA', 
            @job_id = @jobId OUTPUT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name=N'1. clean up folder', 
		    @step_id=1, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_fail_action=2, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
            @database_name=N'master', 
		    @flags=0,
		    @os_run_priority=0, @subsystem=N'CmdExec', 
		    @command=@Job1Command
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name=N'2. prepare Header file', 
		    @step_id=2, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_fail_action=2, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
            @database_name=N'master', 
		    @flags=0,
		    @os_run_priority=0, @subsystem=N'CmdExec', 
		    @command=@Job2Command
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name=N'3. prepare Header2 file', 
		    @step_id=3, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_fail_action=2, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
            @database_name=N'master', 
		    @flags=0,
		    @os_run_priority=0, @subsystem=N'CmdExec', 
		    @command=@Job3Command
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name=N'4. prepare data files', 
		    @step_id=4, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_fail_action=2, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
            @database_name=N'master', 
		    @flags=0,
		    @os_run_priority=0, @subsystem=N'CmdExec', 
		    @command=@Job4Command
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name=N'5. prepare footer file', 
		    @step_id=5, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_fail_action=2, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
            @database_name=N'master', 
		    @flags=0,
		    @os_run_priority=0, @subsystem=N'CmdExec', 
		    @command=@Job5Command
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name=N'6. prepare Report file', 
		    @step_id=6, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_fail_action=2, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
            @database_name=N'master', 
		    @flags=0,
		    @os_run_priority=0, @subsystem=N'CmdExec', 
		    @command=@Job6Command
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'7. send email', 
            @step_id=7, 
            @cmdexec_success_code=0, 
            @on_success_action=3, 
            @on_success_step_id=2, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=@Job7Command,
            @database_name=N'$(ProjectName)', 
            @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'8. clean up data', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@Job8Command, 
		@database_name=N'$(ProjectName)', 
		@flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DataCollector Job schedule', 
            @enabled=1, 
            @freq_type=8, 
            @freq_interval=1, 
            @freq_subday_type=1, 
            @freq_subday_interval=0, 
            @freq_relative_interval=0, 
            @freq_recurrence_factor=1, 
            @active_start_date=20170101, 
            @active_end_date=99991231, 
            @active_start_time=0, 
            @active_end_time=235959
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


