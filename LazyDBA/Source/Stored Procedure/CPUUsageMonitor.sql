CREATE PROCEDURE [dbo].[CPUUsageMonitor]
(
    @pCPUTrashold TINYINT = 50
)
AS
BEGIN
    SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)),
			@DB INT,
			@Other INT

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
		SELECT 'Database CPU utilization: ' AS Text, @DB AS Value UNION ALL
        SELECT 'Other process CPU utilization: ' AS Text, @OTHER AS Value 

END