USE [$(ProjectName)]
GO
:r .\Script\ConfigInitial.sql
GO

USE [msdb]
GO
:r .\Script\EmailProfile.sql
:r .\System\SQLJob\CPUUsageMonitoringJob.sql
:r .\System\SQLJob\DatabaseMaintenanceJob.sql
:r .\System\SQLJob\DataCollectorJob.sql
GO

