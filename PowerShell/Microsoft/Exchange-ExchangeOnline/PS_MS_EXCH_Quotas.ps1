#Par DB - Exemples :
    "DB05","DB06" | Set-MailboxDatabase -ProhibitSendReceiveQuota 6GB -ProhibitSendQuota 5GB -IssueWarningQuota 4.8GB

    Set-MailboxDatabase DB07 -ProhibitSendReceiveQuota 12GB -ProhibitSendQuota 10GB -IssueWarningQuota 9.6GB

    Set-MailboxDatabase DB08 -ProhibitSendReceiveQuota 120GB -ProhibitSendQuota 100GB -IssueWarningQuota 96GB

    <# Ce qui donnerait :
        Get-MailboxDatabase | select name,issue*,prohibit*

        Name                          IssueWarningQuota             ProhibitSendReceiveQuota      ProhibitSendQuota
        ----                          -----------------             ------------------------      -----------------
        DB05                          4.8 GB (5,153,960,960 bytes)  6 GB (6,442,450,944 bytes)    5 GB (5,368,709,120 bytes)
        DB06                          4.8 GB (5,153,960,960 bytes)  6 GB (6,442,450,944 bytes)    5 GB (5,368,709,120 bytes)
        DB07                          9.6 GB (10,307,921,920 bytes) 12 GB (12,884,901,888 bytes)  10 GB (10,737,418,240 bytes)
        DB08                          96 GB (103,079,215,104 bytes) 120 GB (128,849,018,880 by... 100 GB (107,374,182,400 by...
    #>

#Par MBX - Exemple :
Set-Mailbox emma.gardner -UseDatabaseQuotaDefaults $false -IssueWarningQuota 15GB -ProhibitSendQuota 16GB -ProhibitSendReceiveQuota 20GB