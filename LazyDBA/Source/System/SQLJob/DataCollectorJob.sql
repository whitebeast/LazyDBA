USE [msdb]
GO

BEGIN TRANSACTION

PRINT N'Creating Data collector Job...';

DECLARE @ReturnCode INT = 0,
		@JobId UNIQUEIDENTIFIER,
		@name NVARCHAR(100) = N'$(ProjectName).Data collector Job'

SELECT	@JobId = job_id
FROM	msdb..sysjobs 
WHERE	[name] = @name

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

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1. Run DataCollector procedure', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=
N'DECLARE @Profile NVARCHAR(100),
         @Email NVARCHAR(100),
         @PruningPeriod INT

SELECT @Profile = ConfigValue FROM dbo._Config WHERE ConfigItem = N''Email profile name'';
SELECT @Email = ConfigValue FROM dbo._Config WHERE ConfigItem = N''Email recipients'';
SELECT @PruningPeriod = ConfigValue FROM dbo._Config WHERE ConfigItem = N''History table pruning period'';

EXEC dbo.[DataCollector]
    @pEmailProfileName = @Profile,
    @pEmailRecipients = @Email,
    @PruningPeriod = @PruningPeriod,
    @pDebugMode = 0',
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


