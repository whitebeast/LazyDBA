CREATE TABLE [dbo].[MaintenanceLog](
	[ActionText] [nvarchar](500) NOT NULL,
	[DateTime] [datetime2](7) NOT NULL,
	[ErrorMessage] [nvarchar](500) NULL
) 