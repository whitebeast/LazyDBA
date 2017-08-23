USE [msdb]
GO
:r .\System\SQLJob\CPUUsageMonitoringJob.sql
:r .\System\SQLJob\DatabaseMaintenanceJob.sql
:r .\System\SQLJob\DataCollectorJob.sql
GO

USE [$(ProjectName)]
GO
:r .\Script\ConfigInitial.sql
GO