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
SELECT N'Email profile name','Log events notification' UNION ALL
SELECT N'Email recipients','mark.herasimovich@itechart-group.com' UNION ALL
SELECT N'Report frequency','7' UNION ALL
SELECT N'History table pruning period','120' 

INSERT INTO dbo.Config 
    (
        ConfigItem,
        ConfigValue
    )
SELECT  t.ConfigItem,
        t.ConfigValue
FROM    @tConfig AS t
LEFT JOIN dbo.Config c ON c.ConfigItem = t.ConfigItem AND c.ConfigValue = t.ConfigValue
WHERE c.ConfigItem IS NULL
    
    