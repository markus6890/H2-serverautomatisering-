$user = "Edelhardt\ADbackupuser"
$password = ConvertTo-SecureString "Kode1234!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $password)
$session = New-PSSession -ComputerName "172.16.1.2" -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {

    function BackupAD
    {
        $backupPath = "\\Fil-srv\ADBackup"
        $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $logFile = "$backupPath\ADBackup_$timestamp.log"
        $domainName = "Edelhardts.no";
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