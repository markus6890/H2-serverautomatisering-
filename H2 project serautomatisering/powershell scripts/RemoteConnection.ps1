
$cred = Get-Credential
$session = New-PSSession -ComputerName "10.14.2.56" -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {
    function CreateOU {
        param (
        [String] $User,
            [String] $ADPath
        )

        # Construct the ADUserPath

        $ADUserPath = "$User,$ADPath".Replace(" ", "")



        if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ADUserPath)") {
            Write-Host "OU already exists: $ADUserPath" -ForegroundColor Yellow
            return
        }
        $ouParts = $User -split ","
        $currentPath = $ADPath
        foreach ($ouPart in ($ouParts | Sort-Object -Descending)) {

            Write-Host("Current OU part: $ouPart") -ForegroundColor Gray
            Write-Host("Current Path: $currentPath") -ForegroundColor Gray
            if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouPart,$currentPath)")) {
                Write-Host("OU does not exist: $ouPart") -ForegroundColor DarkMagenta
                $ouName = $ouPart -replace "OU=", ""
                try {

                    Write-Host("OU Name : $ouName") -ForegroundColor DarkMagenta
                    New-ADOrganizationalUnit -Name $ouName -Path $currentPath
                    Write-Host("OU created: $ouName") -ForegroundColor Green
                }
                catch {
                    Write-Host("Failed to create OU: $ouName") -ForegroundColor Red
                    Write-Host("Error: $_") -ForegroundColor Red
                    return
                }

            }
            $currentPath = "$ouPart,$currentPath"

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
        $ADPath = "OU=DystopianTech,DC=Markus,DC=ninja";
        foreach ($User in $ADUsers) {
            try {

                CreateOU -User $User.ou -ADPath $ADPath
                $ADUserPath = "$($User.ou),$ADPath".Replace(" ", "")
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
                Write-Host "Failed to create user $($User.username)" -ForegroundColor Red
                Write-Host "Error: $_" -ForegroundColor Red
            }
            finally {
                # Optional: Clean up or reset variables if needed
                $UserParams = $null
            }
        }
    }

    GetUsersFromCSV
}

