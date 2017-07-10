CREATE TABLE [dbo].[NotificationRecipient]
(
	NotificationRecipientsId INT IDENTITY(1,1) NOT NULL CONSTRAINT pkNotificationRecipient PRIMARY KEY CLUSTERED,
	NotificationName NVARCHAR(128) NOT NULL,
	RecipientList NVARCHAR(512) NOT NULL,
)
