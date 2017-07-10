CREATE TABLE [dbo].[Configuration]
(
	ConfigurationId		INT IDENTITY(1,1) NOT NULL CONSTRAINT pkConfiguration PRIMARY KEY CLUSTERED,
	ConfigurationType	NVARCHAR(50) NOT NULL,
	ConfigurationItem	NVARCHAR(100) NOT NULL,
	ConfigurationValue	NVARCHAR(512) NOT NULL
)
