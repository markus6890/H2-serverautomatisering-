
#ALL COMMENTS IS FOR MY GROUP MEMBERS UNDERSTANDING
#COPYRIGHT RIGHTS OF MARKUS HYGE DOMBROWSKI (NO CHAT GPT)
#Creates Folders and security groups following AGDLP best practice

$OUName = Read-Host "OU navn (e.g., Finance)"
$ADPath = "OU=$OUName,DC=DOS,DC=space"
$FolderName = Read-Host "mappe navn"
$FolderPath = Read-Host "skriv sti SKAL SKRIVES(default sti: \\Filserver.DOS.space\File Share)"
$Domain = "DOS"

# AGDLP: Only create Domain Local groups per folder
# Admins should manually create Global groups per OU/Department once

#Function creates Domain Local groups for this specific folder
function Create-ADGroups {
    param($AccessType, $AccessTypeFullName)

    # Domain Local group name includes folder name (one per folder)
    $DLGroupName = "$OUName-DL-$FolderName-$AccessType"

    $ADobjects = Get-ADObject -SearchBase $ADPath -Filter "Name -eq '$DLGroupName'"
    if($ADobjects -eq $null) {
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

Write-Host "`nAGDLP configuration complete!" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "- Global groups (shared across all $OUName folders): $globalRWGroup, $globalRGroup" -ForegroundColor White
Write-Host "- Domain Local groups (specific to this folder): $dlRWGroup, $dlRGroup" -ForegroundColor White
Write-Host "- Folder created: $FolderPath\$FolderName" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Add users to Global groups: $globalRWGroup or $globalRGroup" -ForegroundColor White
Write-Host "2. Users in Global groups automatically get access to ALL $OUName folders through AGDLP" -ForegroundColor White