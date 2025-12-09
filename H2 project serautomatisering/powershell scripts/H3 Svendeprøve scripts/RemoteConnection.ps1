
$cred = Get-Credential
$serverIP = Read-Host("Enter the server IP address")
$session = New-PSSession -ComputerName $serverIP -Credential $cred -Authentication Default -UseSSL:$false

$csvPath = "C:\Users\<User>\Downloads\ad_users_regional_names.csv"
if (-not (Test-Path -Path $csvPath)) {
    Write-Host "CSV file not found on local machine: $csvPath" -ForegroundColor Red
    exit
}

$ADUsers = Import-Csv $csvPath -Delimiter ";"
Write-Host "Loaded $($ADUsers.Count) users from CSV" -ForegroundColor Green

Invoke-Command -Session $session -ArgumentList (,$ADUsers) -ScriptBlock {
    param($ADUsers)


    function CreateOU {
        param (
            [String] $OUPath,
            [String] $ADPath
        )
        $ADUserPath = "$OUPath,$ADPath".Replace(" ", "")

        if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ADUserPath)") {
            Write-Host "OU already exists: $ADUserPath" -ForegroundColor Yellow
            return
        }
        $ouParts = $OUPath -split ","
        $currentPath = $ADPath

        [array]::Reverse($ouParts)

        foreach ($ouPart in $ouParts) {
            if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouPart,$currentPath)")) {
                $ouName = $ouPart -replace "OU=", ""
                try {
                    New-ADOrganizationalUnit -Name $ouName -Path $currentPath
                    Write-Host "Created OU: $ouName at $currentPath" -ForegroundColor Green
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

    function ProcessUsers {
        param($Users)

        #Importere ActiveDirectory lib
        Import-Module ActiveDirectory

        foreach ($User in $Users) {
            try {
                # Extract the base domain from the Path column (everything after the first OU)
                $pathParts = $User.Path -split ","
                $ouParts = $pathParts | Where-Object { $_ -like "OU=*" }
                $dcParts = $pathParts | Where-Object { $_ -like "DC=*" }
                $ADPath = ($dcParts -join ",")
                $ouPath = ($ouParts -join ",")

                # Create OU structure if needed
                if ($ouPath) {
                    CreateOU -OUPath $ouPath -ADPath $ADPath
                }

                $countryCode = $null
                if ($User.Country) {
                    $countryMap = @{
                        "Denmark" = "DK"
                        "Sweden" = "SE"
                        "Norway" = "NO"
                        "Finland" = "FI"
                        "Germany" = "DE"
                        "United States" = "US"
                        "United Kingdom" = "GB"
                        "France" = "FR"
                        "Spain" = "ES"
                        "Italy" = "IT"
                        "Netherlands" = "NL"
                        "Belgium" = "BE"
                        "Poland" = "PL"
                    }

                    if ($User.Country.Length -eq 2) {
                        $countryCode = $User.Country.ToUpper()
                    }

                    elseif ($countryMap.ContainsKey($User.Country)) {
                        $countryCode = $countryMap[$User.Country]
                        Write-Host "  Converted country '$($User.Country)' to '$countryCode' for user $($User.SamAccountName)" -ForegroundColor Cyan
                    }
                    else {
                        Write-Host "  WARNING: Unknown country '$($User.Country)' for user $($User.SamAccountName), skipping Country field" -ForegroundColor Yellow
                        $countryCode = $null
                    }
                }

                # Convert password string to SecureString
                $securePassword = ConvertTo-SecureString $User.AccountPassword -AsPlainText -Force

                # Convert ChangePasswordAtLogon string to boolean
                $changePassword = [System.Convert]::ToBoolean($User.ChangePasswordAtLogon)

                # Build user parameters using CSV column names directly
                $UserParams = @{
                    SamAccountName        = $User.SamAccountName
                    UserPrincipalName     = $User.UserPrincipalName
                    Name                  = $User.Name
                    GivenName             = $User.GivenName
                    Surname               = $User.Surname
                    Enabled               = [System.Convert]::ToBoolean($User.Enabled)
                    DisplayName           = $User.DisplayName
                    Path                  = $User.Path
                    AccountPassword       = $securePassword
                    ChangePasswordAtLogon = $changePassword
                }
                
                # Add optional fields only if they have valid values
                if ($User.Initial -and $User.Initial.Length -le 6) { 
                    $UserParams.Initials = $User.Initial 
                }
                if ($User.City) { $UserParams.City = $User.City }
                if ($User.PostalCode -and $User.PostalCode.Length -le 40) { 
                    $UserParams.PostalCode = $User.PostalCode 
                }
                if ($countryCode) { $UserParams.Country = $countryCode }
                if ($User.Company) { $UserParams.Company = $User.Company }
                if ($User.State) { $UserParams.State = $User.State }
                if ($User.StreetAddress) { $UserParams.StreetAddress = $User.StreetAddress }
                if ($User.OfficePhone) { $UserParams.OfficePhone = $User.OfficePhone }
                if ($User.EmailAddress) { $UserParams.EmailAddress = $User.EmailAddress }
                if ($User.Title) { $UserParams.Title = $User.Title }
                if ($User.Department) { $UserParams.Department = $User.Department }

                # Check if user already exists
                if (Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'") {
                    Write-Host "User $($User.SamAccountName) already exists in Active Directory." -ForegroundColor Magenta
                }
                else {
                    New-ADUser @UserParams
                    Write-Host "User $($User.SamAccountName) created successfully." -ForegroundColor Green
                }
            }
            catch {
                Write-Host "`nFailed to create user $($User.SamAccountName)" -ForegroundColor Red
                Write-Host "Error: $_" -ForegroundColor Red
            }
            finally {
                $UserParams = $null
            }
        }
    }

    ProcessUsers -Users $ADUsers
}