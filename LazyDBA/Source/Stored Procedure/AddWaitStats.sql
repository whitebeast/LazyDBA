﻿CREATE PROCEDURE [dbo].[AddWaitStats]
(
    @pHTML NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;

DECLARE @tOutput TABLE
(
    [Wait Type] NVARCHAR(60),
    [Wait Sec] DECIMAL(16,2),
    [Resource Sec] DECIMAL(16,2),
    [Signal Sec] DECIMAL(16,2),
    [Wait Count] BIGINT,
    [Wait Percentage] DECIMAL(5,2),
    [Avg Wait Sec] DECIMAL(16,4),
    [Avg Res Sec] DECIMAL(16,4),
    [Avg Sig Sec] DECIMAL(16,4)
);

-- Isolate top waits for server instance since last restart or wait statistics clear
;WITH [Waits] 
AS (
    SELECT  wait_type, 
            wait_time_ms/ 1000.0 AS [WaitS],
            (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
            signal_wait_time_ms / 1000.0 AS [SignalS],
            waiting_tasks_count AS [WaitCount],
            100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage],
            ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
    FROM    sys.dm_os_wait_stats WITH (NOLOCK)
    WHERE   [wait_type] NOT IN (
                N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
                N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
                N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
                N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
                N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
                N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
                N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
                N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
                N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
                N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
                N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
                N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
                N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
                N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
                N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
                N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
                N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
                N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
                N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
            AND waiting_tasks_count > 0)
INSERT INTO [dbo].[WaitStats]
    (
        [ReportDate],
        [Wait Type],
        [Wait Sec],
        [Resource Sec],
        [Signal Sec],
        [Wait Count],
        [Wait Percentage],
        [Avg Wait Sec],
        [Avg Res Sec],
        [Avg Sig Sec]
    )
OUTPUT  inserted.[Wait Type],
        inserted.[Wait Sec],
        inserted.[Resource Sec],
        inserted.[Signal Sec],
        inserted.[Wait Count],
        inserted.[Wait Percentage],
        inserted.[Avg Wait Sec],
        inserted.[Avg Res Sec],
        inserted.[Avg Sig Sec]
INTO    @tOutput
SELECT
        GETDATE() AS [ReportDate],
        MAX (W1.wait_type) AS [Wait Type],
        CAST (MAX (W1.WaitS) AS DECIMAL (16,2)) AS [Wait Sec],
        CAST (MAX (W1.ResourceS) AS DECIMAL (16,2)) AS [Resource Sec],
        CAST (MAX (W1.SignalS) AS DECIMAL (16,2)) AS [Signal Sec],
        MAX (W1.WaitCount) AS [Wait Count],
        CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) AS [Wait Percentage],
        CAST ((MAX (W1.WaitS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [Avg Wait Sec],
        CAST ((MAX (W1.ResourceS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [Avg Res Sec],
        CAST ((MAX (W1.SignalS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [Avg Sig Sec]
FROM    Waits AS W1
JOIN    Waits AS W2
    ON  W2.RowNum <= W1.RowNum
GROUP BY 
        W1.RowNum
HAVING  SUM (W2.Percentage) - MAX (W1.Percentage) < 99 -- percentage threshold
OPTION (RECOMPILE);

-- Cumulative wait stats are not as useful on an idle instance that is not under load or performance pressure

SET @pHTML =
    N'            <div class="header" id="11-header">Wait Statistics</div><div class="content" id="11-content"><div class="text">' + 
    ISNULL(N'<table>' + 
        N'<tr>'+
            N'<th style="width: 20%;">Wait Type</th>' +
            N'<th style="width: 5%;" >Wait (sec)</th>' +
            N'<th style="width: 5%;" >Resource (sec)</th>' +
            N'<th style="width: 5%;" >Signal (sec)</th>' +
            N'<th style="width: 5%;" >Wait count</th>' +
            N'<th style="width: 5%;" >Wait Percentage</th>' +
            N'<th style="width: 5%;" >Avg Wait (sec)</th>' +
            N'<th style="width: 5%;" >Avg Resource (sec)</th>' +
            N'<th style="width: 5%;" >Avg Signal (sec)</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([Wait Type],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Wait Sec] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Resource Sec] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Signal Sec] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Wait Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Wait Percentage] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Wait Sec] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Res Sec] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Sig Sec] AS NVARCHAR(MAX)),''),'"','')
                    FROM @tOutput 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>','NO DATA') + 
        N'</div></div>'; 
SET @pHTML = REPLACE(@pHTML,'&#x0D;','');

END