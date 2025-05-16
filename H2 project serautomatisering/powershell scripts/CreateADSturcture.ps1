$cred = Get-Credential
$session = New-PSSession -ComputerName "10.14.2.56" -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {

    function CreateOU {

        $ADUserPath = Read-Host("Enter the OU path (e.g., OU=TestOU,DC=example,DC=com)")
        $dcParts = ($ADUserPath -split ",") | Where-Object { $_ -like "DC=*" }
        $dcOnly = ($dcParts -join ",")
        #Write-Host("DC Only: $dcOnly") -ForegroundColor Green
        if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ADUserPath)") {
            Write-Host "OU already exists: $ADUserPath" -ForegroundColor Yellow
            return
        }
        $ADUserParts = ($ADUserPath -split ",") | Where-Object { $_ -notlike "DC=*" }
        $ADUserPath = ($ADUserParts -join ",")


        $ouParts = $ADUserPath -split ","
        $currentPath = $dcOnly
        foreach ($ouPart in ($ouParts | Sort-Object -Descending)) {
            #Write-Host("Current OU part: $ouPart") -ForegroundColor Gray
            #Write-Host("Current Path: $currentPath") -ForegroundColor Gray
            if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouPart,$currentPath)")) {
                #Write-Host("OU does not exist: $ouPart") -ForegroundColor DarkMagenta
                $ouName = $ouPart -replace "OU=", ""
                try {

                    #Write-Host("OU Name : $ouName") -ForegroundColor DarkMagenta
                    New-ADOrganizationalUnit -Name $ouName -Path $currentPath -NotProtected
                    #Write-Host("OU created: $ouName") -ForegroundColor Green
                }
                catch {
                    Write-Host("Failed to create OU: $ouName") -ForegroundColor Red
                    Write-Host("Error: $_") -ForegroundColor Red
                    return
                }

            }
            $currentPath = "$ouPart,$currentPath"

        }
        Write-Host("OU created successfully: $ADUserPath") -ForegroundColor Green
        Write-Host("With no Errors") -ForegroundColor Green

    }
    CreateOU;
}