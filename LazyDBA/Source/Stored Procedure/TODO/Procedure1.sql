SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 10%;">SP Name</th>' +
            N'<th style="width: 3%;">Avg IO</th>' +
            N'<th style="width: 2%;">Execution Count</th>' +
            N'<th style="width: 85%;">Query Text</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Avg IO] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL([Query Text],''),'"','') 
                    FROM #tCachedQueriesByIOCostList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';  
        ;


SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;" >SP Name</th>' +
            N'<th style="width: 5%;"  >Total Worker Time</th>' +
            N'<th style="width: 5%;"  >Avg Worker Time</th>' +
            N'<th style="width: 5%;"  >Execution Count</th>' +
            N'<th style="width: 5%;"  >Calls/Minute</th>' +
            N'<th style="width: 5%;"  >Total Elapsed Time</th>' +
            N'<th style="width: 5%;"  >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;" >Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByCPUCostList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

        
SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%; ">Execution Count</th>' +
            N'<th style="width: 5%; ">Calls/Minute</th>' +
            N'<th style="width: 5%; ">Avg Worker Time</th>' +
            N'<th style="width: 5%; ">Total Worker Time</th>' +
            N'<th style="width: 5%; ">Total Elapsed Time</th>' +
            N'<th style="width: 5%; ">Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByExecCntList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';


SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Avg Worker Time</th>' +
            N'<th style="width: 5%;" >Total Worker Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Worker Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByExecTimeList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Min Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 5%;" >Max Elapsed Time</th>' +
            N'<th style="width: 5%;" >Last Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Min Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Max Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Last Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByExecTimeVariableList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';  

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Logical Reads</th>' +
            N'<th style="width: 5%;" >Avg Logical Reads</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Logical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Logical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByLogicalReadsList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   


SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Logical Writes</th>' +
            N'<th style="width: 5%;" >Avg Logical Writes</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Calls/Minute</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Logical Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Logical Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Calls/Minute] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByLogicalWritesList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   


SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 40%;">SP Name</th>' +
            N'<th style="width: 5%;" >Total Physical Reads</th>' +
            N'<th style="width: 5%;" >Avg Physical Reads</th>' +
            N'<th style="width: 5%;" >Execution Count</th>' +
            N'<th style="width: 5%;" >Total Logical Reads</th>' +
            N'<th style="width: 5%;" >Total Elapsed Time</th>' +
            N'<th style="width: 5%;" >Avg Elapsed Time</th>' +
            N'<th style="width: 10%;">Cached Time</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([SP Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Total Physical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Physical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Execution Count] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Logical Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Avg Elapsed Time] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(CONVERT(NVARCHAR,ISNULL([Cached Time],''),121),'"','')
                    FROM #tCachedSPByPhysicalReadsList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 15%;">Table Name</th>' +
            N'<th style="width: 40%;">Index Name</th>' +
            N'<th style="width: 5%;" >Is Disabled</th>' +
            N'<th style="width: 5%;" >Is Hypothetical</th>' +
            N'<th style="width: 5%;" >Has Filter</th>' +
            N'<th style="width: 5%;" >Fill Factor</th>' +
            N'<th style="width: 5%;" >Total Writes</th>' +
            N'<th style="width: 5%;" >Total Reads</th>' +
            N'<th style="width: 5%;" >Difference</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL([Table Name],''),'"',''),'',      
                           td=REPLACE(ISNULL([Index Name],''),'"',''),'',      
                           td=REPLACE(ISNULL(CAST([Is Disabled] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Is Hypothetical] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Has Filter] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Fill Factor] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Writes] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Total Reads] AS NVARCHAR(MAX)),''),'"',''),'',
                           td=REPLACE(ISNULL(CAST([Difference] AS NVARCHAR(MAX)),''),'"','')
                    FROM #tPossibleBadIndexesList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>'; 

SET @pHTML =
    N'<table>' + 
        N'<tr>'+
            N'<th style="width: 5%;" >Index Advantage</th>' +
            N'<th style="width: 10%;">Last User Seek Date</th>' +
            N'<th style="width: 20%;">Equality Columns</th>' +
            N'<th style="width: 20%;">Inequality Columns</th>' +
            N'<th style="width: 20%;">Included Columns</th>' +
            N'<th style="width: 5%;" >Unique Compiles</th>' +
            N'<th style="width: 5%;" >User Seeks</th>' +
            N'<th style="width: 5%;" >Avg Total User Costs</th>' +
            N'<th style="width: 5%;" >Avg User Impact</th>' +
            N'<th style="width: 10%;">Table Name</th>' +
            N'<th style="width: 5%;" >Table Rows</th>' +
        N'</tr>' +
                CAST ( ( 
                    SELECT  
                           td=REPLACE(ISNULL(CAST([Index Advantage] AS NVARCHAR(MAX)),''),'"',''),'',      
                           td=REPLACE(CONVERT(VARCHAR,ISNULL([Last User Seek Date],''),121),'"',''),'', 
                           td=REPLACE(ISNULL([Equality Columns],''),'"',''),'', 
                           td=REPLACE(ISNULL([Inequality Columns],''),'"',''),'', 
                           td=REPLACE(ISNULL([Included Columns],''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([Unique Compiles] AS NVARCHAR(MAX)),''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([User Seeks] AS NVARCHAR(MAX)),''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([Avg Total User Costs] AS NVARCHAR(MAX)),''),'"',''),'',                       
                           td=REPLACE(ISNULL(CAST([Avg User Impact] AS NVARCHAR(MAX)),''),'"',''),'', 
                           td=REPLACE(ISNULL([Table Name],''),'"',''),'', 
                           td=REPLACE(ISNULL(CAST([Table Rows] AS NVARCHAR(MAX)),''),'"','')
                    FROM #tPossibleNewIndexesByAdvantageList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   


SET @pHTML =
    N'<table>' + 
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
                    FROM #tWaitStatsList 
                    FOR XML PATH('tr'), TYPE 
                ) AS NVARCHAR(MAX) ) +
        N'</table>';   


DECLARE @body VARCHAR(1000) = 'No info found...',
        @query VARCHAR(4000) = '',
        @attach_query_result_as_file BIT = 0,
        @filename NVARCHAR(100) = 'LazyDBA report on ' + CONVERT(NVARCHAR,GETDATE(),23) + '.html',
        @char CHAR(2) = CHAR(13)+CHAR(10),
        @Id INT,
        @ReportName NVARCHAR(100),
        @HTML VARCHAR(MAX),
        @ReportDate DATETIME2 = GETDATE();

IF OBJECT_ID('tempdb..##tMail') IS NOT NULL DROP TABLE ##tMail;
CREATE TABLE ##tMail (Id INT IDENTITY(1,1), HTML VARCHAR(MAX) NULL) ;

IF OBJECT_ID('tempdb..##tOutput') IS NOT NULL DROP TABLE ##tOutput;
CREATE TABLE ##tOutput (Id INT IDENTITY(1,1), ReportName VARCHAR(100), HTML VARCHAR(MAX) NULL) ;

IF EXISTS (SELECT 1 FROM ##tOutput) BEGIN
    -- (Split into multiple inserts because the default text result setting is 256 chars)
    -- header
    INSERT INTO ##tMail 
    SELECT 
                      N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
+ CHAR(13)+CHAR(10) + N'<html xmlns="http://www.w3.org/1999/xhtml">'
+ CHAR(13)+CHAR(10) + N'    <head>'
+ CHAR(13)+CHAR(10) + N'        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
+ CHAR(13)+CHAR(10) + N'        <link rel="stylesheet" type="text/css" />'
+ CHAR(13)+CHAR(10) + N'        <title> ' + @filename + ' </title>'
+ CHAR(13)+CHAR(10) + N'        <style>'
+ CHAR(13)+CHAR(10) + N'            #slider {'
+ CHAR(13)+CHAR(10) + N'                width: 100%;'
+ CHAR(13)+CHAR(10) + N'                color: #66666;'
+ CHAR(13)+CHAR(10) + N'                font-family: Helvetica;'
+ CHAR(13)+CHAR(10) + N'                font-size: 20px;'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N'            .header {'
+ CHAR(13)+CHAR(10) + N'                border: 1px solid #cccccc;'
+ CHAR(13)+CHAR(10) + N'                padding: 8px;'
+ CHAR(13)+CHAR(10) + N'                margin-top: 5px;'
+ CHAR(13)+CHAR(10) + N'                cursor: pointer;'
+ CHAR(13)+CHAR(10) + N'                text-align: center;'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N'            .header:hover {'
+ CHAR(13)+CHAR(10) + N'                color: #666666;'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N'            .content {'
+ CHAR(13)+CHAR(10) + N'                overflow: hidden;'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N'            .text {'
+ CHAR(13)+CHAR(10) + N'                width: 2000;'
+ CHAR(13)+CHAR(10) + N'                border: 1px solid #cccccc;'
+ CHAR(13)+CHAR(10) + N'                border-top: none;'
+ CHAR(13)+CHAR(10) + N'                padding: 5px;'
+ CHAR(13)+CHAR(10) + N'                text-align: left;'
+ CHAR(13)+CHAR(10) + N'                background: #eeeeee;'
+ CHAR(13)+CHAR(10) + N'                font-size: 14px;'
+ CHAR(13)+CHAR(10) + N'            }' 
+ CHAR(13)+CHAR(10) + N'            .content table {'
+ CHAR(13)+CHAR(10) + N'                border-collapse: collapse;'
+ CHAR(13)+CHAR(10) + N'                border-spacing: 0px;'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N'            .content table td,' 
+ CHAR(13)+CHAR(10) + N'            .content table th {'
+ CHAR(13)+CHAR(10) + N'                border: 1px black solid;'
+ CHAR(13)+CHAR(10) + N'                border-collapse: collapse;'
+ CHAR(13)+CHAR(10) + N'                padding: 2px;'
+ CHAR(13)+CHAR(10) + N'            }' 
+ CHAR(13)+CHAR(10) + N'            .content table tr:nth-child(2n){'
+ CHAR(13)+CHAR(10) + N'                background-color: #D4D4D4;'
+ CHAR(13)+CHAR(10) + N'            }' 
+ CHAR(13)+CHAR(10) + N'        </style>' 
+ CHAR(13)+CHAR(10) + N'        <script type="text/javascript">'
+ CHAR(13)+CHAR(10) + N'            var array = new Array();'
+ CHAR(13)+CHAR(10) + N'            var speed = 10;'
+ CHAR(13)+CHAR(10) + N'            var timer = 10;' 
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'            function slider(target,showfirst) {'
+ CHAR(13)+CHAR(10) + N'                var slider = document.getElementById(target);'
+ CHAR(13)+CHAR(10) + N'                var divs = slider.getElementsByTagName(''div'');'
+ CHAR(13)+CHAR(10) + N'                var divslength = divs.length;'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'                for(i = 0; i < divslength; i++) {'
+ CHAR(13)+CHAR(10) + N'                    var div = divs[i];'
+ CHAR(13)+CHAR(10) + N'                    var divid = div.id;'
+ CHAR(13)+CHAR(10) + N'                    if(divid.indexOf("header") != -1) {'
+ CHAR(13)+CHAR(10) + N'                        div.onclick = new Function("processClick(this)");'
+ CHAR(13)+CHAR(10) + N'                    }'
+ CHAR(13)+CHAR(10) + N'                    else if(divid.indexOf("content") != -1) {'
+ CHAR(13)+CHAR(10) + N'                        var section = divid.replace(''-content'','''');'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'                        array.push(section);'
+ CHAR(13)+CHAR(10) + N'                        div.maxh = div.offsetHeight;'
+ CHAR(13)+CHAR(10) + N'                        if(showfirst == 1 && i == 1) {'
+ CHAR(13)+CHAR(10) + N'                            div.style.display = ''block'';'
+ CHAR(13)+CHAR(10) + N'                        }'
+ CHAR(13)+CHAR(10) + N'                        else {'
+ CHAR(13)+CHAR(10) + N'                            div.style.display = ''none'';'
+ CHAR(13)+CHAR(10) + N'                        }'
+ CHAR(13)+CHAR(10) + N'                    }'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'            function processClick(div) {'
+ CHAR(13)+CHAR(10) + N'                var catlength = array.length;'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'                for(i = 0; i < catlength; i++) {'
+ CHAR(13)+CHAR(10) + N'                    var section = array[i];'
+ CHAR(13)+CHAR(10) + N'                    var head = document.getElementById(section + ''-header'');'
+ CHAR(13)+CHAR(10) + N'                    var cont = section + ''-content'';'
+ CHAR(13)+CHAR(10) + N'                    var contdiv = document.getElementById(cont);'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'                    clearInterval(contdiv.timer);'
+ CHAR(13)+CHAR(10) + N'                    if(head == div && contdiv.style.display == ''none'') {'
+ CHAR(13)+CHAR(10) + N'                        contdiv.style.height = ''0px'';'
+ CHAR(13)+CHAR(10) + N'                        contdiv.style.display = ''block'';'
+ CHAR(13)+CHAR(10) + N'                        initSlide(cont,1);'
+ CHAR(13)+CHAR(10) + N'                    }'
+ CHAR(13)+CHAR(10) + N'                    else if(contdiv.style.display == ''block'') {'
+ CHAR(13)+CHAR(10) + N'                        initSlide(cont,-1);'
+ CHAR(13)+CHAR(10) + N'                    }'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'            function initSlide(id,dir) {'
+ CHAR(13)+CHAR(10) + N'                var cont = document.getElementById(id);'
+ CHAR(13)+CHAR(10) + N'                var maxh = cont.maxh;'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'                cont.direction = dir;'
+ CHAR(13)+CHAR(10) + N'                cont.timer = setInterval("slide(''" + id + "'')", timer);'
+ CHAR(13)+CHAR(10) + N'            }'

INSERT INTO ##tMail
SELECT 
 CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'            function slide(id) {'
+ CHAR(13)+CHAR(10) + N'                var cont = document.getElementById(id);'
+ CHAR(13)+CHAR(10) + N'                var maxh = cont.maxh;'
+ CHAR(13)+CHAR(10) + N'                var currheight = cont.offsetHeight;'
+ CHAR(13)+CHAR(10) + N'                var dist;'
+ CHAR(13)+CHAR(10) + N''
+ CHAR(13)+CHAR(10) + N'                if(cont.direction == 1) {'
+ CHAR(13)+CHAR(10) + N'                    dist = (Math.round((maxh - currheight) / speed));'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'                else {dist = (Math.round(currheight / speed));'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'                if(dist <= 1) {'
+ CHAR(13)+CHAR(10) + N'                    dist = 1;'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'                cont.style.height = currheight + (dist * cont.direction) + ''px'';'
+ CHAR(13)+CHAR(10) + N'                cont.style.opacity = currheight / cont.maxh;'
+ CHAR(13)+CHAR(10) + N'                cont.style.filter = ''alpha(opacity='' + (currheight * 100 / cont.maxh) + '')'';'
+ CHAR(13)+CHAR(10) + N'                if(currheight < 2 && cont.direction != 1) {'
+ CHAR(13)+CHAR(10) + N'                    cont.style.display = ''none'';'
+ CHAR(13)+CHAR(10) + N'                    clearInterval(cont.timer);'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'                else if(currheight > (maxh - 2) && cont.direction == 1) {'
+ CHAR(13)+CHAR(10) + N'                    clearInterval(cont.timer);'
+ CHAR(13)+CHAR(10) + N'                }'
+ CHAR(13)+CHAR(10) + N'            }'
+ CHAR(13)+CHAR(10) + N'        </script>'
+ CHAR(13)+CHAR(10) + N'    </head>'
+ CHAR(13)+CHAR(10) + N'    <body onload="slider(''slider'',0)">'
+ CHAR(13)+CHAR(10) + N'        <div id="slider">';

    -- data
    DECLARE cur CURSOR FAST_FORWARD FOR  
    SELECT Id, ReportName, HTML 
    FROM ##tOutput
    ORDER BY Id;

    OPEN cur   
    FETCH NEXT FROM cur INTO @Id, @ReportName, @HTML    

    WHILE @@FETCH_STATUS = 0   
    BEGIN   
        INSERT INTO ##tMail SELECT '<div class="header" id="' + CAST(@id AS VARCHAR) +'-header">' + @ReportName + '</div><div class="content" id="' + CAST(@Id AS VARCHAR) +'-content">'
        INSERT INTO ##tMail SELECT '    <div class="text">' + ISNULL(@html,'NO DATA') +'</div></div>';
        FETCH NEXT FROM cur INTO @Id, @ReportName, @HTML 
    END   

    CLOSE cur;
    DEALLOCATE cur;
    
    -- footer
    INSERT INTO ##tMail
    SELECT '</div> </body> </html>';

    SELECT  @query = 'set nocount on; SELECT html FROM ##tMail ORDER BY ID',
            @attach_query_result_as_file = 1,
            @body = 'Please find detailed report attached.'
            ;
END  


IF @pDebugMode = 0 BEGIN
    EXEC msdb.dbo.sp_send_dbmail	
	    @profile_name = @pEmailProfileName,
	    @recipients = @pEmailRecipients,
	    @subject = 'LazyDBA: Email notification',
	    @body = @body,
	    @body_format = 'HTML', -- or TEXT
	    @importance = 'HIGH', --Low Normal High
	    @execute_query_database = 'master',
	    -- @query_result_header = 1,
        @query_result_width = 32767,
	    @query = @query,
	    --@query_result_no_padding = 1,  -- prevent SQL adding padding spaces in the result
	    --@query_no_truncate = 1,       -- mutually exclusive with @query_result_no_padding 
	    @attach_query_result_as_file = @attach_query_result_as_file,
	    @query_attachment_filename = @filename;
END 
ELSE EXEC (@query);

IF OBJECT_ID('tempdb..##tMail') IS NOT NULL DROP TABLE ##tMail;
IF OBJECT_ID('tempdb..##tOutput') IS NOT NULL DROP TABLE ##tOutput;
