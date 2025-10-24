

    #ALL COMMENTS IS FOR MY GROUP MEMBERS UNDERSTANDING
    #COPYRIGHT RIGHTS OF MARKUS HYGE DOMBROWSKI (NO CHAT GPT)
    #Creates Folders and security group to the folders
    $OUName = Read-Host "OU navn"
    $ADPath = "OU=$OUName,DC=DOS,DC=space"
    $FolderName = Read-Host "mappe navn"
    $FolderPath = Read-Host "skriv sti SKAL SKRIVES(default sti: \\Filserver.DOS.space\File Share)"
    $UserInputGroup = Read-Host "Domain type DL eller G"


    #Checks what Grouptype that was choosen
    $Grouptype = "DomainLocal"
    $GT = "DL"
    if($UserInputGroup -eq "G") {
        $Grouptype = "Global"
        $GT = "G"
    }
    $FullADGroupName = "$OUName-$GT-$FolderName"

    #Function creates the ADGroups when called
    function Create-ADGroups {
        param($AccessType, $AccessTypeFullName)

        $ADobjects = Get-adobject -SearchBase $ADPath  -Filter "Name -eq '$FullADGroupName-$AccessType'"
        if($ADobjects -eq $null) {
            New-ADGroup -Name "$FullADGroupName-$AccessType" `
	    -SamAccountName "$FullADGroupName-$AccessType" `
	    -GroupCategory Security `
	    -GroupScope $Grouptype `
	    -Displayname "$FolderName $AccessTypeFullName access" `
	    -Path $ADPath `
	-Description "Members of this group have $AccessTypeFullName access to $FolderName"
        }
    }

    #Calls the function to create the 2 different rules
    Create-ADGroups -AccessType "RW" -AccessTypeFullName "Read Write"

    Create-ADGroups -AccessType "R" -AccessTypeFullName "Read"

    #Creates the folder
    New-Item -Path $FolderPath -Name $FolderName -ItemType Directory

    #Gets the current list of permissions for the folder
    $acl = Get-Acl -Path "$FolderPath\$FolderName"

    #Gets the security groups we created
    Get-adobject -SearchBase $ADPath  -ldapfilter {(objectclass=group)}

    #gets the diffent permissions the folder needs
    $acl.SetAccessRuleProtection($True, $False)

    $ruleAdministrators = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

    $ruleDomainAdmin = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("$Domain\Domain Admins","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

    $ruleR = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("$Domain\$FullADGroupName-R","ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")

    $ruleRW = New-Object `
        System.Security.AccessControl.FileSystemAccessRule("$Domain\$FullADGroupName-RW","Modify", "ContainerInherit, ObjectInherit", "None", "Allow")

    #Adds the permissions to a list of permissions
    $rules = $ruleAdministrators,$ruleDomainAdmin,$ruleR,$ruleRW

    #Loops over all the perms in the list and adds them to the acl list
    foreach ($rule in $rules)
    {
        $acl.AddAccessRule($rule)
    }
    #Adds the new permission list to the folder
    $acl | Set-Acl -Path "$FolderPath\$FolderName"


