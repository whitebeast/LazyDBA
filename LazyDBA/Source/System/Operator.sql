USE [msdb]
GO
PRINT 'Creating Operator...'
DECLARE @name NVARCHAR(100) = N'DBA'
IF EXISTS (SELECT 1 FROM msdb..sysoperators WHERE [name] = @name)
	EXEC msdb.dbo.sp_delete_operator @name=@name

EXEC msdb.dbo.sp_add_operator @name=@name, 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'$(DBAemail)', 
		@category_name=N'[Uncategorized]'
GO