DECLARE 
        @MailServer NVARCHAR(100) = N'smtp.gmail.com',
        @MailPort INT = 587,
        @AccountName NVARCHAR(100) = N'FindAndFollow.Notification@gmail.com',
        @UserName NVARCHAR(100) = N'FindAndFollow.Notification@gmail.com',
        @Password NVARCHAR(100) = N'VsKexibt!',
        @UseDefaultCredentials BIT = 0,
        @EnableSSL BIT = 1,

        @ProfileName NVARCHAR(100) = N'Notification Mailer',

        @OperatorName NVARCHAR(100) = N'DBA',
        @OperatorEmail NVARCHAR(100) = N'mark.herasimovich@itechart-group.com'        

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysmail_account AS sa WHERE NAME = @AccountName) BEGIN 
    PRINT 'Configuring Email account';
    EXECUTE msdb.dbo.sysmail_add_account_sp
            @account_name = @AccountName,
            @email_address = @AccountName,
            @display_name = N'Notification service',
            @description = N'',
            @mailserver_name = @MailServer,
            @port = @MailPort,
            @username = @UserName,
            @password = @Password,
            @use_default_credentials = @UseDefaultCredentials,
            @enable_ssl = @EnableSSL
END;    

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysmail_profile AS sp WHERE NAME = @ProfileName) BEGIN
    PRINT 'Configuring Email profile';	
    EXECUTE msdb.dbo.sysmail_add_profile_sp
            @profile_name = @ProfileName
    EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
            @profile_name = @ProfileName,
            @account_name = @AccountName,
            @sequence_number = 1;
    EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
            @profile_name = @ProfileName,
            @principal_id = 0,
            @is_default = 1;
END;

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysoperators AS s WHERE s.name = @OperatorName) BEGIN
    PRINT 'Configuring Email operator'
    EXEC msdb.dbo.sp_add_operator @name=@OperatorName, 
            @enabled=1, 
            @pager_days=0, 
            @email_address=@OperatorEmail
END;    
        
/*
DECLARE @AccountName VARCHAR(100) = 'FindAndFollow.Notification@gmail.com',
        @ProfileName VARCHAR(100) = 'FindAndFollow.Notification Mailer';

IF EXISTS (SELECT 1 FROM msdb.dbo.sysmail_account AS sa WHERE NAME = @AccountName) BEGIN
    PRINT 'Deleting Email account';                                                                                   	
    EXEC msdb.dbo.sysmail_delete_account_sp 
        @account_name = @AccountName
END;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile AS sp WHERE NAME = @ProfileName) BEGIN
    PRINT 'Deleting Email profile';
    EXEC msdb.dbo.sysmail_delete_profileaccount_sp 
        @profile_name = @ProfileName
        
    EXEC msdb.dbo.sysmail_delete_profile_sp
        @profile_name = @ProfileName
END;    

IF EXISTS (SELECT 1 FROM msdb.dbo.sysoperators AS s WHERE s.name = 'Administrator') BEGIN
    PRINT 'Deleting Email operator'
    EXEC msdb.dbo.sp_delete_operator @name = 'Administrator' ;
END;
 */