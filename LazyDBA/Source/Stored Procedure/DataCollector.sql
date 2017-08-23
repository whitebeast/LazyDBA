CREATE PROCEDURE [dbo].[DataCollector]
    @pEmailProfileName NVARCHAR(100),
    @pEmailRecipients NVARCHAR(100)
AS
BEGIN

SET NOCOUNT ON;
DECLARE @body VARCHAR(1000) = 'No info found...',
        @query VARCHAR(4000) = '',
        @attach_query_result_as_file BIT = 0,
        @filename VARCHAR(100) = 'LazyDBA report on ' + CONVERT(NVARCHAR,GETDATE(),23) + '.html',
        @HTML_o NVARCHAR(MAX),
        @Id INT,
        @ReportName NVARCHAR(100),
        @HTML VARCHAR(MAX);

IF OBJECT_ID('tempdb..##tMail') IS NOT NULL DROP TABLE ##tMail;
CREATE TABLE ##tMail (Id INT IDENTITY(1,1), HTML VARCHAR(MAX) NULL) ;

IF OBJECT_ID('tempdb..##tOutput') IS NOT NULL DROP TABLE ##tOutput;
CREATE TABLE ##tOutput (Id INT IDENTITY(1,1), ReportName VARCHAR(100), HTML VARCHAR(MAX) NULL) ;

EXEC GetCachedQueriesByIOCostList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached queries (by IO cost)', @HTML_o;

EXEC GetCachedSPByCPUCostList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by CPU cost)', @HTML_o;

EXEC GetCachedSPByExecCntList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by execution count)', @HTML_o;

EXEC GetCachedSPByExecTimeList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by execution time)', @HTML_o;

EXEC GetCachedSPByExecTimeVariableList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by execution time - variable)', @HTML_o;

EXEC GetCachedSPByLogicalReadsList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by logical reads)', @HTML_o;

EXEC GetCachedSPByLogicalWritesList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by logical writes)', @HTML_o;

EXEC GetCachedSPByPhysicalReadsList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Cached stored procedures (by physical reads)', @HTML_o;

EXEC GetPossibleBadIndexesList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Possible Bad Indexes', @HTML_o;

EXEC GetPossibleNewIndexesByAdvantageList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Possible New Indexes (by advantage)', @HTML_o;

EXEC GetWaitStatsList @pHTML = @HTML_o OUTPUT;
INSERT INTO ##tOutput 
SELECT 'Wait Statistics', @HTML_o;

-- EXEC GetPossibleNewIndexesBySprocList;

-- EXEC GetSQLJobTimeline 1;

IF EXISTS (SELECT 1 FROM ##tOutput) BEGIN

    INSERT INTO ##tMail
    SELECT 
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
 <html xmlns="http://www.w3.org/1999/xhtml">
    <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" />
    <title>' + @filename + '</title>
    <style>
        #slider {
             width: 100%;
             color: #66666;
             font-family: Helvetica;
             font-size: 20px;
         }
        .header {
             border: 1px solid #cccccc;
             padding: 8px;
             margin-top: 5px;
             cursor: pointer;
             text-align: center;
         }
        .header:hover {
            color: #666666;
         }
        .content {
            overflow: hidden;
         }
        .text {
             width: 2000;
             border: 1px solid #cccccc;
             border-top: none;
             padding: 5px;
             text-align: left;
             background: #eeeeee;
             font-size: 14px;
         }
        .content table {
            border-collapse: collapse;
            border-spacing: 0px;
         }
        .content table td,
        .content table th {
            border: 1px black solid;
            border-collapse: collapse;
            padding: 2px;
         }
         .content table tr:nth-child(2n){
            background-color: #D4D4D4;
         }
    </style>
    <script type="text/javascript">
        var array = new Array();
        var speed = 10;
        var timer = 10;
 
        function slider(target,showfirst) {
         var slider = document.getElementById(target);
         var divs = slider.getElementsByTagName(''div'');
         var divslength = divs.length;
         for(i = 0; i < divslength; i++) {
         var div = divs[i];
         var divid = div.id;
         if(divid.indexOf("header") != -1) {
         div.onclick = new Function("processClick(this)");
         } else if(divid.indexOf("content") != -1) {
         var section = divid.replace(''-content'','''');
         array.push(section);
         div.maxh = div.offsetHeight;
         if(showfirst == 1 && i == 1) {
         div.style.display = ''block'';
         } else {
         div.style.display = ''none'';
         }
         }
         }
        }
 
        function processClick(div) {
         var catlength = array.length;
         for(i = 0; i < catlength; i++) {
         var section = array[i];
         var head = document.getElementById(section + ''-header'');
         var cont = section + ''-content'';
         var contdiv = document.getElementById(cont);
         clearInterval(contdiv.timer);
         if(head == div && contdiv.style.display == ''none'') {
         contdiv.style.height = ''0px'';
         contdiv.style.display = ''block'';
         initSlide(cont,1);
         } else if(contdiv.style.display == ''block'') {
         initSlide(cont,-1);
         }
         }
        }
 
        function initSlide(id,dir) {
         var cont = document.getElementById(id);
         var maxh = cont.maxh;
         cont.direction = dir;
         cont.timer = setInterval("slide(''" + id + "'')", timer);
        }
 
        function slide(id) {
         var cont = document.getElementById(id);
         var maxh = cont.maxh;
         var currheight = cont.offsetHeight;
         var dist;
         if(cont.direction == 1) {
         dist = (Math.round((maxh - currheight) / speed));
         } else {
         dist = (Math.round(currheight / speed));
         }
         if(dist <= 1) {
         dist = 1;
         }
         cont.style.height = currheight + (dist * cont.direction) + ''px'';
         cont.style.opacity = currheight / cont.maxh;
         cont.style.filter = ''alpha(opacity='' + (currheight * 100 / cont.maxh) + '')'';
         if(currheight < 2 && cont.direction != 1) {
         cont.style.display = ''none'';
         clearInterval(cont.timer);
         } else if(currheight > (maxh - 2) && cont.direction == 1) {
         clearInterval(cont.timer);
         }
        }
    </script></head><body onload="slider(''slider'',0)"><div id="slider">';

    DECLARE cur CURSOR FAST_FORWARD FOR  
    SELECT Id, ReportName, HTML 
    FROM ##tOutput
    ORDER BY Id;

    OPEN cur   
    FETCH NEXT FROM cur INTO @Id, @ReportName, @HTML    

    WHILE @@FETCH_STATUS = 0   
    BEGIN   
        INSERT INTO ##tMail
        SELECT '<div class="header" id="' + CAST(@id AS VARCHAR) +'-header">' + @ReportName + '</div><div class="content" id="' + CAST(@id AS VARCHAR) +'-content"><div class="text">' + ISNULL(@html,'NO DATA') +'</div></div>';
        FETCH NEXT FROM cur INTO @Id, @ReportName, @HTML 
    END   

    CLOSE cur;
    DEALLOCATE cur;
    
    INSERT INTO ##tMail
    SELECT '</div> </body> </html>';

    select  @query = 'set nocount on; SELECT html FROM ##tMail',
            @attach_query_result_as_file = 1,
            @body = 'Please find detailed report attached.'
            ;
END        

SELECT len(html), html FROM ##tMail order by id

/*
EXEC msdb.dbo.sp_send_dbmail	
	@profile_name = @pEmailProfileName,
	@recipients = @pEmailRecipients,
	@subject = 'LazyDBA: Email notification',
	@body = @body,
	@body_format = 'HTML', -- or TEXT
	@importance = 'HIGH', --Low Normal High
	@execute_query_database = 'master',
	@query_result_header = 1,
	@query = @query,
	@query_result_no_padding = 1,  -- prevent SQL adding padding spaces in the result
	--@query_no_truncate = 1,       -- mutually exclusive with @query_result_no_padding 
	@attach_query_result_as_file = @attach_query_result_as_file,
	@query_attachment_filename = @filename;
*/

IF OBJECT_ID('tempdb..##tMail') IS NOT NULL DROP TABLE ##tMail;
IF OBJECT_ID('tempdb..##tOutput') IS NOT NULL DROP TABLE ##tOutput;
   
END