CREATE PROCEDURE [dbo].[GetSQLJobTimeline]
    @pMinRuntimeInSec INT = 10,
    @pEmailProfileName NVARCHAR(100),
    @pEmailRecipients NVARCHAR(100)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @DT datetime,
        @StartDT datetime = getdate() - 1,
        @EndDT datetime = getdate(),
        @body varchar(1000) = 'No job runtime info found...',
        @query varchar(4000) = '',
        @attach_query_result_as_file BIT = 0,
        @filename varchar(100) = 'JobTimeline.html';
                
DECLARE @tJobRunTime TABLE (JobName NVARCHAR(100), CatName NVARCHAR(100), SDT DATETIME, EDT DATETIME);

IF OBJECT_ID('tempdb..##tSQLJobTimeline') IS NOT NULL DROP TABLE ##tSQLJobTimeline;
CREATE TABLE ##tSQLJobTimeline (ID INT IDENTITY(1,1) NOT NULL, HTML VARCHAR(8000) NULL);

INSERT INTO @tJobRunTime
SELECT	job.name AS JobName,
		cat.name AS CatName,
		CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 120) AS SDT,
		DATEADD(s,
					((run_duration/10000)%100 * 3600) + ((run_duration/100)%100 * 60) + run_duration%100 ,
					CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 120) 
				) AS EDT
FROM	msdb.dbo.sysjobs job 
LEFT JOIN msdb.dbo.sysjobhistory his ON his.job_id = job.job_id
JOIN msdb.dbo.syscategories cat	ON job.category_id = cat.category_id
WHERE	CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 120) BETWEEN @StartDT AND @EndDT
    AND step_id = 0 -- step_id = 0 is the entire job, step_id > 0 is actual step number
    AND	((run_duration/10000)%100 * 3600) + ((run_duration/100)%100 * 60) + run_duration%100 > @pMinRuntimeInSec  -- Ignore trivial runtimes
ORDER BY SDT;

IF EXISTS (SELECT 1 FROM @tJobRunTime) 
BEGIN

    INSERT INTO ##tSQLJobTimeline (HTML) 
    SELECT '
	    <head>
	    <!--<META HTTP-EQUIV="refresh" CONTENT="3">-->
	    <script type="text/javascript" src="https://www.google.com/jsapi?autoload={''modules'':[{''name'':''visualization'', ''version'':''1'',''packages'':[''timeline'']}]}"></script>
        <script type="text/javascript">
	    google.setOnLoadCallback(drawChart);
	    function drawChart() {
        var container = document.getElementById(''JobTimeline'');
	    var chart = new google.visualization.Timeline(container);
	    var dataTable = new google.visualization.DataTable();
        dataTable.addColumn({ type: ''string'', id: ''Position'' });
	    dataTable.addColumn({ type: ''string'', id: ''Name'' });
	    dataTable.addColumn({ type: ''date'', id: ''Start'' });
	    dataTable.addColumn({ type: ''date'', id: ''End'' });
	    dataTable.addRows([
    ';

    INSERT INTO ##tSQLJobTimeline (HTML) 
    SELECT  '		[ ' 
		    +'''' + CatName  + ''', '
		    +'''' + JobName  + ''', '
		    +'new Date('
		    +     cast(DATEPART(year ,  SDT) as varchar(4))
		    +', '+cast(DATEPART(month,  SDT) -1 as varchar(4)) --Java months count from 0
		    +', '+cast(DATEPART(day,    SDT) as varchar(4))
		    +', '+cast(DATEPART(hour,   SDT) as varchar(4))
		    +', '+cast(DATEPART(minute, SDT) as varchar(4))
		    +', '+cast(DATEPART(second, SDT) as varchar(4)) 
		    +'), '

		    +'new Date('

		    +     cast(DATEPART(year,   EDT) as varchar(4))
		    +', '+cast(DATEPART(month,  EDT) -1 as varchar(4)) --Java months count from 0
		    +', '+cast(DATEPART(day,    EDT) as varchar(4))
		    +', '+cast(DATEPART(hour,   EDT) as varchar(4))
		    +', '+cast(DATEPART(minute, EDT) as varchar(4))
		    +', '+cast(DATEPART(second, EDT) as varchar(4)) 
		    + ') ],' --+ char(10)
    FROM	@tJobRunTime ;

    INSERT INTO ##tSQLJobTimeline (HTML) 
    SELECT '	]);

	    var options = 
	    {
		    timeline: 	{ 
					    groupByRowLabel: true,
					    colorByRowLabel: false,
					    singleColor: false,
					    rowLabelStyle: {fontName: ''Helvetica'', fontSize: 14 },
					    barLabelStyle: {fontName: ''Helvetica'', fontSize: 14 }					
					    }
	    };

	    chart.draw(dataTable, options);
    }
	    </script>
	    <font face="Helvetica" size="3" >'
	    + 'Job timeline on: ' + @@SERVERNAME
	    + ' from '+CONVERT(VARCHAR(20), @StartDT, 120)
	    + ' until '+CONVERT(VARCHAR(20), @EndDT, 120)
	    + CASE WHEN @pMinRuntimeInSec = 0 THEN '' ELSE ' (hiding jobs with runtime < '+CAST(@pMinRuntimeInSec AS VARCHAR(10))+' seconds)' END
	    + '</font> <div id="JobTimeline" style="width: 1885px; height: 900px;"></div>
         </body>';

    SELECT  @query = 'SET NOCOUNT ON; SELECT html FROM ##tSQLJobTimeline',
            @attach_query_result_as_file = 1,
            @body = 'Please find SQL Job timeline attached.'
            ;
END 

EXEC msdb.dbo.sp_send_dbmail	
	@profile_name = @pEmailProfileName,
	@recipients = @pEmailRecipients,
	@subject = 'LazyDBA: Job timeline',
	@body = @body,
	@body_format = 'HTML', -- or TEXT
	@importance = 'HIGH', --Low Normal High
	@execute_query_database = 'master',
	@query_result_header = 1,
	@query = @query,
	@query_result_no_padding = 1,  -- prevent SQL adding padding spaces in the result
	--@query_no_truncate= 1,       -- mutually exclusive with @query_result_no_padding 
	@attach_query_result_as_file = @attach_query_result_as_file,
	@query_attachment_filename= @filename

END