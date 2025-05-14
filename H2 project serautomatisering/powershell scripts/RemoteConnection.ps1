
function GetUsersFromCSV{
    Import-Module ActiveDirectory

    $ADUsers = Import-Csv "C:\Users\krizo\Serverautomatisering\testemployees1.CSV" -Delimiter ";"
    $UPN = "Markus.ninja"
    $ADPath = "OU=Dystopian Tech,DC=Markus,DC=ninja";

    foreach ($User in $ADUsers) {
        try {
            $ADUserPath = "$($User.ou)$($ADPath)";
            if(Get-ADOrganizationalUnit -Filter "distinguishedName -ne '$ADUserPath'") {
                $ouParts = $User.ou -split ",(?=OU=)"
                $currentPath = $ADPath;
                foreach($ouPart in ($ouParts | Sort-Object -Descending)) {
                    if(Get-ADOrganizationalUnit -Filter "distinguishedName -ne '$currentPath'") {
                        $ouName = $ouPart -replace "OU=", "";
                        New-ADOrganizationalUnit -Name $ouName -Path $currentPath;
                        $currentPath = "OU=$ouName,$currentPath";
                    }

                }
            }
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
                PostalCode          = $Uder.zipcode
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