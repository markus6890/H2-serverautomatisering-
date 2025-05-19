Add-Type -AssemblyName System.Windows.Forms

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Create AD Structure"
$form.Width = 400
$form.Height = 300

# Server IP Label and TextBox
$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Text = "Server IP:"
$labelServer.Top = 20
$labelServer.Left = 20
$form.Controls.Add($labelServer)

$textServer = New-Object System.Windows.Forms.TextBox
$textServer.Top = 20
$textServer.Left = 120
$textServer.Width = 220
$form.Controls.Add($textServer)

# OU Path Label and TextBox
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = "OU Path:"
$labelOU.Top = 60
$labelOU.Left = 20
$form.Controls.Add($labelOU)

$textOU = New-Object System.Windows.Forms.TextBox
$textOU.Top = 60
$textOU.Left = 120
$textOU.Width = 220
$form.Controls.Add($textOU)

# Username Label and TextBox (hidden initially)
$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username:"
$labelUser.Top = 100
$labelUser.Left = 20
$labelUser.Visible = $false
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Top = 100
$textUser.Left = 120
$textUser.Width = 220
$textUser.Visible = $false
$form.Controls.Add($textUser)

# Password Label and TextBox (hidden initially)
$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Top = 140
$labelPass.Left = 20
$labelPass.Visible = $false
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.Top = 140
$textPass.Left = 120
$textPass.Width = 220
$textPass.UseSystemPasswordChar = $true
$textPass.Visible = $false
$form.Controls.Add($textPass)

# Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Create OU"
$button.Top = 180
$button.Left = 120
$button.Width = 120
$button.Enabled = $false
$form.Controls.Add($button)

# Result Label
$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Top = 220
$resultLabel.Left = 20
$resultLabel.Width = 350
$form.Controls.Add($resultLabel)

# Show username/password fields and enable button when both fields are filled
$updateFields = {
    if ($textServer.Text -and $textOU.Text) {
        $labelUser.Visible = $true
        $textUser.Visible = $true
        $labelPass.Visible = $true
        $textPass.Visible = $true
        $button.Enabled = $true
    } else {
        $labelUser.Visible = $false
        $textUser.Visible = $false
        $labelPass.Visible = $false
        $textPass.Visible = $false
        $button.Enabled = $false
    }
}
$textServer.Add_TextChanged($updateFields)
$textOU.Add_TextChanged($updateFields)

$button.Add_Click({
    $serverIP = $textServer.Text
    $ouPath = $textOU.Text
    $username = $textUser.Text
    $password = $textPass.Text

    if (-not $serverIP -or -not $ouPath -or -not $username -or -not $password) {
        $resultLabel.Text = "Please fill in all fields."
        return
    }
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($username, $securePass)
    try {
        $session = New-PSSession -ComputerName $serverIP -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false
        Invoke-Command -Session $session -ScriptBlock {
            param($ouPath)
            function CreateOU {
                $ADUserPath = $ouPath
                $dcParts = ($ADUserPath -split ",") | Where-Object { $_ -like "DC=*" }
                $dcOnly = ($dcParts -join ",")
                if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ADUserPath)") {
                    Write-Host "OU already exists: $ADUserPath"
                    return
                }
                $ADUserParts = ($ADUserPath -split ",") | Where-Object { $_ -notlike "DC=*" }
                $ADUserPath = ($ADUserParts -join ",")
                $ouParts = $ADUserPath -split ","
                $currentPath = $dcOnly
                foreach ($ouPart in ($ouParts | Sort-Object -Descending)) {
                    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouPart,$currentPath)")) {
                        $ouName = $ouPart -replace "OU=", ""
                        try {
                            New-ADOrganizationalUnit -Name $ouName -Path $currentPath -ProtectedFromAccidentalDeletion $False
                        } catch {
                            Write-Host "Failed to create OU: $ouName"
                            Write-Host "Error: $_"
                            return
                        }
                    }
                    $currentPath = "$ouPart,$currentPath"
                }
                Write-Host "OU created successfully: $ADUserPath"
            }
            CreateOU
        } -ArgumentList $ouPath
        $resultLabel.Text = "OU creation attempted. Check output window for details."
    } catch {
        $resultLabel.Text = "Error: $_"
    }
})

$form.Add_FormClosing({ [System.Environment]::Exit(0) })
$form.ShowDialog()