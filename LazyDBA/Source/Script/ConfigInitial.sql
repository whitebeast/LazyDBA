SET NOCOUNT ON;
PRINT 'Populate Config table...'
DECLARE @tConfig TABLE 
(
	ConfigItem	NVARCHAR(100) NOT NULL,
	ConfigValue	NVARCHAR(512) NOT NULL
);

INSERT INTO @tConfig
(
    ConfigItem,
    ConfigValue
)
SELECT N'Email profile name',N'Log events notification' UNION ALL
SELECT N'Email recipients',N'mark.herasimovich@itechart-group.com' UNION ALL
--SELECT N'Report frequency',N'7' UNION ALL
SELECT N'History table pruning period',N'120' UNION ALL
SELECT '',''

INSERT INTO dbo._Config 
    (
        ConfigItem,
        ConfigValue
    )
SELECT  t.ConfigItem,
        t.ConfigValue
FROM    @tConfig AS t
LEFT JOIN dbo._Config c ON c.ConfigItem = t.ConfigItem AND c.ConfigValue = t.ConfigValue
WHERE c.ConfigItem IS NULL
GO    
    