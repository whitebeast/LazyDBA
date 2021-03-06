﻿SET NOCOUNT ON;
PRINT 'Populate Config table...'
DECLARE @tConfig TABLE 
(
	ConfigItem	NVARCHAR(100) NOT NULL,
	ConfigValue	NVARCHAR(MAX) NOT NULL
);

INSERT INTO @tConfig
(
    ConfigItem,
    ConfigValue
)
SELECT N'Email profile name',N'$(EmailProfile)' UNION ALL
SELECT N'Email recipients',N'$(EmailRecipients)' UNION ALL
SELECT N'Email HTML files dir', N'$(EmailHTMLFilesDir)' UNION ALL
--SELECT N'Report frequency',N'7' UNION ALL
SELECT N'Table pruning period (in days)',N'120' UNION ALL
SELECT 'Email Header',N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
+ CHAR(13)+CHAR(10) + N'<html xmlns="http://www.w3.org/1999/xhtml">'
+ CHAR(13)+CHAR(10) + N'    <head>'
+ CHAR(13)+CHAR(10) + N'        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
+ CHAR(13)+CHAR(10) + N'        <link rel="stylesheet" type="text/css" />'
+ CHAR(13)+CHAR(10) + N'        <title> ' + '<_Title_>' + ' </title>'
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
+ CHAR(13)+CHAR(10) + N'            }' UNION ALL
SELECT 'Email Header 2',
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
+ CHAR(13)+CHAR(10) + N'        <div id="slider">' UNION ALL
SELECT 'Email Footer', '        </div>'
+ CHAR(13)+CHAR(10) + N'    </body>' 
+ CHAR(13)+CHAR(10) + N'</html>'

INSERT INTO dbo._Config 
    (
        ConfigItem,
        ConfigValue
    )
SELECT  t.ConfigItem,
        t.ConfigValue
FROM    @tConfig AS t
LEFT JOIN dbo._Config c ON 
        c.ConfigItem = t.ConfigItem 
    AND c.ConfigValue = t.ConfigValue
WHERE   c.ConfigItem IS NULL
GO    
    