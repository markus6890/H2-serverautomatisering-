#ALL COMMENTS IS FOR MY GROUP MEMBERS UNDERSTANDING
#COPYRIGHT RIGHTS OF MARKUS HYGE DOMBROWSKI (NO CHAT GPT)
#Creates Folders and security groups following AGDLP best practice

$cred = Get-Credential
$dcIP = Read-Host("Enter the Domain Controller IP address")
$fileServerIP = Read-Host("Enter the File Server IP address")

# Create session to Domain Controller for AD operations
$dcSession = New-PSSession -ComputerName $dcIP -Credential $cred -Authentication Default -UseSSL:$false

# Create session to File Server for folder operations
$fileSession = New-PSSession -ComputerName $fileServerIP -Credential $cred -Authentication Default -UseSSL:$false

# Get input for folder and group configuration
$OULocation = Read-Host "Location (e.g., Ringsted,Global)"
$OUName = Read-Host "OU navn (e.g., Finance)"
$ADPath = "OU=$OUName,OU=$OULocation,DC=daddyco,DC=com"
$FolderName = Read-Host "mappe navn"
$FolderPath = Read-Host "skriv sti SKAL SKRIVES(default sti: \\DACFIL.daddyco.com\daddyco)"
$Domain = "daddyco"

$groupNames = Invoke-Command -Session $dcSession -ArgumentList $OUName, $FolderName, $ADPath -ScriptBlock {
    param($OUName, $FolderName, $ADPath)

    Import-Module ActiveDirectory

    # Check if "Rettigheder" OU exists inside the department OU, create if not
    $rettighedOUPath = "OU=Rettigheder,$ADPath"
    $rettighedOUExists = Get-ADOrganizationalUnit -Filter "Name -eq 'Rettigheder'" -SearchBase $ADPath -SearchScope OneLevel -ErrorAction SilentlyContinue

    if (-not $rettighedOUExists) {
        try {
            New-ADOrganizationalUnit -Name "Rettigheder" -Path $ADPath -ProtectedFromAccidentalDeletion $False
            Write-Host "Created OU: Rettigheder at $ADPath" -ForegroundColor Green
        } catch {
            Write-Host "Failed to create Rettigheder OU: $_" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "Rettigheder OU already exists at $ADPath" -ForegroundColor Yellow
    }
    $ADPath = $rettighedOUPath

    function Create-ADGroups {
        param($AccessType, $AccessTypeFullName)

        $DLGroupName = "$OUName-DL-$FolderName-$AccessType"

        $ADGroup = Get-ADGroup -Filter "Name -eq '$DLGroupName'" -SearchBase $ADPath -ErrorAction SilentlyContinue
        if($ADGroup -eq $null) {
            New-ADGroup -Name "$DLGroupName" `
                -SamAccountName "$DLGroupName" `
                -GroupCategory Security `
                -GroupScope DomainLocal `
                -DisplayName "$FolderName $AccessTypeFullName access" `
                -Path $ADPath `
                -Description "Members have $AccessTypeFullName access to $FolderName folder"

            Write-Host "Created Domain Local group: $DLGroupName" -ForegroundColor Green
        } else {
            Write-Host "Domain Local group already exists: $DLGroupName" -ForegroundColor Yellow
        }

        return $DLGroupName
    }

    # Create Domain Local groups for THIS folder
    $dlRWGroup = Create-ADGroups -AccessType "RW" -AccessTypeFullName "Read Write"
    $dlRGroup = Create-ADGroups -AccessType "R" -AccessTypeFullName "Read"

    # Check if Global groups exist (should be created once per OU)
    $globalRWGroup = "$OUName-G-RW"
    $globalRGroup = "$OUName-G-R"

    $globalRWExists = Get-ADGroup -Filter "Name -eq '$globalRWGroup'" -SearchBase $ADPath -ErrorAction SilentlyContinue
    $globalRExists = Get-ADGroup -Filter "Name -eq '$globalRGroup'" -SearchBase $ADPath -ErrorAction SilentlyContinue

    # Create Global groups if they don't exist (only happens first time for this OU)
    if (-not $globalRWExists) {
        New-ADGroup -Name $globalRWGroup `
            -SamAccountName $globalRWGroup `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "$OUName Read Write Users" `
            -Path $ADPath `
            -Description "Global group for all $OUName users with write access"
        Write-Host "Created Global group: $globalRWGroup" -ForegroundColor Cyan
    } else {
        Write-Host "Global group already exists: $globalRWGroup" -ForegroundColor Yellow
    }

    if (-not $globalRExists) {
        New-ADGroup -Name $globalRGroup `
            -SamAccountName $globalRGroup `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "$OUName Read Only Users" `
            -Path $ADPath `
            -Description "Global group for all $OUName users with read-only access"
        Write-Host "Created Global group: $globalRGroup" -ForegroundColor Cyan
    } else {
        Write-Host "Global group already exists: $globalRGroup" -ForegroundColor Yellow
    }

    # Add Global groups to Domain Local groups
    try {
        Add-ADGroupMember -Identity $dlRWGroup -Members $globalRWGroup -ErrorAction Stop
        Write-Host "Added $globalRWGroup to $dlRWGroup" -ForegroundColor Green
    } catch {
        Write-Host "Could not add $globalRWGroup to $dlRWGroup (may already be member)" -ForegroundColor Yellow
    }

    try {
        Add-ADGroupMember -Identity $dlRGroup -Members $globalRGroup -ErrorAction Stop
        Write-Host "Added $globalRGroup to $dlRGroup" -ForegroundColor Green
    } catch {
        Write-Host "Could not add $globalRGroup to $dlRGroup (may already be member)" -ForegroundColor Yellow
    }

    # Return group names for use in folder permissions
    return @{
        dlRWGroup = $dlRWGroup
        dlRGroup = $dlRGroup
        globalRWGroup = $globalRWGroup
        globalRGroup = $globalRGroup
    }
}

# STEP 2: Create folder and set permissions on File Server
Write-Host "`n=== Creating Folder and Setting Permissions on File Server ===" -ForegroundColor Cyan
Invoke-Command -Session $fileSession -ArgumentList $FolderPath, $FolderName, $Domain, $groupNames.dlRWGroup, $groupNames.dlRGroup -ScriptBlock {
    param($FolderPath, $FolderName, $Domain, $dlRWGroup, $dlRGroup)

    # Create the folder
    if (-not (Test-Path "$FolderPath\$FolderName")) {
        New-Item -Path $FolderPath -Name $FolderName -ItemType Directory
        Write-Host "`nCreated folder: $FolderPath\$FolderName" -ForegroundColor Green
    } else {
        Write-Host "`nFolder already exists: $FolderPath\$FolderName" -ForegroundColor Yellow
    }

    # Get current permissions
    $acl = Get-Acl -Path "$FolderPath\$FolderName"

    # Disable inheritance
    $acl.SetAccessRuleProtection($True, $False)

    # Create permission rules
    $ruleAdministrators = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

    $ruleDomainAdmin = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("$Domain\Domain Admins","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

    # AGDLP: Domain Local groups get the actual permissions
    $ruleR = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("$Domain\$dlRGroup","ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")

    $ruleRW = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("$Domain\$dlRWGroup","Modify", "ContainerInherit, ObjectInherit", "None", "Allow")

    # Add all rules
    $rules = $ruleAdministrators,$ruleDomainAdmin,$ruleR,$ruleRW

    foreach ($rule in $rules) {
        $acl.AddAccessRule($rule)
    }

    # Apply permissions
    $acl | Set-Acl -Path "$FolderPath\$FolderName"
    Write-Host "Permissions applied successfully" -ForegroundColor Green
}

Write-Host "`nAGDLP configuration complete!" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "- Global groups (shared across all $OUName folders): $($groupNames.globalRWGroup), $($groupNames.globalRGroup)" -ForegroundColor White
Write-Host "- Domain Local groups (specific to this folder): $($groupNames.dlRWGroup), $($groupNames.dlRGroup)" -ForegroundColor White
Write-Host "- Folder created: $FolderPath\$FolderName" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Add users to Global groups: $($groupNames.globalRWGroup) or $($groupNames.globalRGroup)" -ForegroundColor White
Write-Host "2. Users in Global groups automatically get access to ALL $OUName folders through AGDLP" -ForegroundColor White

# Clean up sessions
Remove-PSSession $dcSession
Remove-PSSession $fileSession