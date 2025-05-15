$cred = Get-Credential
$session = New-PSSession -ComputerName "10.14.2.56" -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {

    function BackupAD
    {
        $backupPath = "C:\ADBackup"
        $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $backupFile = "$backupPath\ADBackup_$timestamp.ldf"
        $logFile = "$backupPath\ADBackup_$timestamp.log"
        $domainName = Read-Host("Enter the domain name (e.g., example.com)")
        $domain = "DC=$($domainName -replace '\.', ',DC=')";
        Write-Host("Domain: $domain") -ForegroundColor Green


        # Create backup directory if it doesn't exist
        if (-not (Test-Path -Path $backupPath)) {
            New-Item -ItemType Directory -Path $backupPath
        }

        # Perform the backup
        try {
           wbadmin start systemstatebackup -backuptarget:$backupPath -quiet | Out-File $logFile
            Write-Host "Backup completed successfully. File: $backupFile" -ForegroundColor Green
        }
        catch {
            Write-Host "Backup failed: $_" -ForegroundColor Red
        }

    }
    BackupAD;
}