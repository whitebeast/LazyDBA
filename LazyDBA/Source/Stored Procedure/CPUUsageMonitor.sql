CREATE PROCEDURE [dbo].[CPUUsageMonitor]
(
    @pCPUTrashold TINYINT = 50
)
AS
BEGIN
    SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	DECLARE @ts_now BIGINT = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)),
			@DB INT,
			@Other INT,
            @ErrMsg NVARCHAR(1000)

	SELECT TOP(60) 
		   @DB = AVG(SQLProcessUtilization),
		   @Other = AVG(100 - SystemIdle - SQLProcessUtilization)
	FROM (
            SELECT  record.value('(./Record/@id)[1]', 'int') AS record_id, 
				    record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle], 
				    record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization], 
				    [timestamp] 
		    FROM (
				    SELECT	[timestamp], 
				    		CONVERT(xml, record) AS [record] 
				    FROM	sys.dm_os_ring_buffers WITH (NOLOCK)
				    WHERE	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
				    	AND record LIKE N'%<SystemHealth>%'
            ) AS x
    ) AS y 
	OPTION (RECOMPILE);

	IF @DB + @Other >= @pCPUTrashold
		SET @ErrMsg = 'Database CPU utilization: ' + CAST(@DB AS NVARCHAR) + CHAR(13) + 'Other process CPU utilization: ' + CAST(@Other AS NVARCHAR);
        RAISERROR(@ErrMsg, 16, 1);

END