
$cred = Get-Credential
$session = New-PSSession -ComputerName "10.14.2.56" -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {
    function CreateOU {
        param (
            $ADPath,
            $User
        )

        $ADUserPath = ",$($User) $($ADPath)";
        Write-Host("started Creating OU: $ADUserPath") -ForegroundColor Green;
        if(Get-ADOrganizationalUnit -Filter "distinguishedName -ne '$ADUserPath'") {
            $ouParts = $User -split ",";
            $currentPath = $ADPath;
            Write-Host("Current Path: $currentPath") -ForegroundColor Green;
            Write-Host("OU Parts: $ouParts") -ForegroundColor Green;
            foreach($ouPart in ($ouParts | Sort-Object -Descending)) {
                if(Get-ADOrganizationalUnit -Filter "distinguishedName -ne '$currentPath'") {
                    Write-Host("Creating OU: $ouPart") -ForegroundColor Green;
                    $ouName = $ouPart -replace "OU=", "";
                    New-ADOrganizationalUnit -Name $ouName -Path $currentPath;
                    $currentPath = "OU=$ouName,$currentPath";
                    Write-Host("OU created: $currentPath") -ForegroundColor Green;
                }
            }
        }
    }

    function GetUsersFromCSV
    {
        Import-Module ActiveDirectory
        if(Test-Path -Path "C:\Users\Administrator\Downloads\testemployees1.CSV") {
            Write-Host "File exists" -ForegroundColor Green;
        }
        else {
            Write-Host "File does not exist" -ForegroundColor Red;
            return;
        }
        $ADUsers = Import-Csv "C:\Users\Administrator\Downloads\testemployees1.CSV" -Delimiter ";"
        $UPN = "Markus.ninja"
        $ADPath = "OU=Dystopian Tech,DC=Markus,DC=ninja";

        foreach ($User in $ADUsers) {
            try {
                CreateOU($ADPath,$User.ou);
                $UserParams = @{
                    SamAccountName      = $User.username
                    UserprincipalName   = "$($User.username)@$UPN"
                    Name                = "$($User.firstname) $($User.lastname)"
                    GivenName           = $User.firstname
                    Surname             = $User.lastname
                    Initial             = $User.initials
                    Enabled             = $true
                    DisplayName         = "$($User.firstname) $($User.lastname)"
                    Path                = $ADUserPath
                    City                = $User.city
                    PostalCode          = $User.zipcode  # rettet 'Uder' til 'User'
                    Country             = $User.country
                    Company             = $User.company
                    State               = $User.state
                    StreetAddress       = $User.streetaddress
                    OfficePhone         = $User.telephone
                    EmailAddress        = $User.email
                    Title               = $User.jobtitle
                    Department          = $User.department
                    AccountPassword     = (ConvertTo-SecureString $User.password -AsPlainText -Force)
                    ChangePasswordAtLogon = $true
                }

                if (Get-ADUser -Filter "SamAccountName -eq '$($User.username)'") {
                    Write-Host "A user with username $($User.username) already exists in Active Directory." -ForegroundColor Magenta;
                }
                else {
                    New-ADUser @UserParams
                    Write-Host "The user $($User.username) is created." -ForegroundColor Green
                }
            }
            catch {
                Write-Host "Failed to create user $($User.username) - $_" -ForegroundColor Red
            }
        }
    }

    GetUsersFromCSV
}

