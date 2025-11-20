Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Create Windows DHCP and DNS Server"
$form.Width = 450
$form.Height = 650
$form.StartPosition = "CenterScreen"

# Create a list to store scopes
$scopesList = New-Object System.Collections.ArrayList

# Server IP Label and TextBox
$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Text = "Server IP:"
$labelServer.Top = 20
$labelServer.Left = 20
$labelServer.Width = 150
$form.Controls.Add($labelServer)

$textServer = New-Object System.Windows.Forms.TextBox
$textServer.Top = 20
$textServer.Left = 180
$textServer.Width = 220
$form.Controls.Add($textServer)

$labelDnsForwarder = New-Object System.Windows.Forms.Label
$labelDnsForwarder.Text = "DNS Forwarder:"
$labelDnsForwarder.Top = 60
$labelDnsForwarder.Left = 20
$labelDnsForwarder.Width = 150
$form.Controls.Add($labelDnsForwarder)

$textDnsForwarder = New-Object System.Windows.Forms.TextBox
$textDnsForwarder.Top = 60
$textDnsForwarder.Left = 180
$textDnsForwarder.Width = 220
$textDnsForwarder.Text = "8.8.8.8"
$form.Controls.Add($textDnsForwarder)

# Scopes Section Header
$labelScopesHeader = New-Object System.Windows.Forms.Label
$labelScopesHeader.Text = "DHCP Scopes:"
$labelScopesHeader.Top = 100
$labelScopesHeader.Left = 20
$labelScopesHeader.Width = 150
$labelScopesHeader.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelScopesHeader)

# ListBox to display added scopes
$listBoxScopes = New-Object System.Windows.Forms.ListBox
$listBoxScopes.Top = 130
$listBoxScopes.Left = 20
$listBoxScopes.Width = 380
$listBoxScopes.Height = 100
$form.Controls.Add($listBoxScopes)

# Add Scope Button
$buttonAddScope = New-Object System.Windows.Forms.Button
$buttonAddScope.Text = "Add Scope"
$buttonAddScope.Top = 240
$buttonAddScope.Left = 20
$buttonAddScope.Width = 120
$form.Controls.Add($buttonAddScope)

# Remove Scope Button
$buttonRemoveScope = New-Object System.Windows.Forms.Button
$buttonRemoveScope.Text = "Remove Selected"
$buttonRemoveScope.Top = 240
$buttonRemoveScope.Left = 150
$buttonRemoveScope.Width = 120
$form.Controls.Add($buttonRemoveScope)

# DNS Domain Suffix
$labelDnsSuffix = New-Object System.Windows.Forms.Label
$labelDnsSuffix.Text = "DNS Domain Suffix:"
$labelDnsSuffix.Top = 280
$labelDnsSuffix.Left = 20
$labelDnsSuffix.Width = 150
$form.Controls.Add($labelDnsSuffix)

$textDnsSuffix = New-Object System.Windows.Forms.TextBox
$textDnsSuffix.Top = 280
$textDnsSuffix.Left = 180
$textDnsSuffix.Width = 220
$textDnsSuffix.Text = "corp.example.local"
$form.Controls.Add($textDnsSuffix)

# Username Label and TextBox (hidden initially)
$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username:"
$labelUser.Top = 320
$labelUser.Left = 20
$labelUser.Width = 150
$labelUser.Visible = $false
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Top = 320
$textUser.Left = 180
$textUser.Width = 220
$textUser.Visible = $false
$form.Controls.Add($textUser)

# Password Label and TextBox (hidden initially)
$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Top = 360
$labelPass.Left = 20
$labelPass.Width = 150
$labelPass.Visible = $false
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.Top = 360
$textPass.Left = 180
$textPass.Width = 220
$textPass.UseSystemPasswordChar = $true
$textPass.Visible = $false
$form.Controls.Add($textPass)

# Create Server Button
$buttonCreate = New-Object System.Windows.Forms.Button
$buttonCreate.Text = "Create DHCP & DNS Server"
$buttonCreate.Top = 410
$buttonCreate.Left = 125
$buttonCreate.Width = 180
$buttonCreate.Enabled = $false
$form.Controls.Add($buttonCreate)

# Result Label
$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Top = 450
$resultLabel.Left = 20
$resultLabel.Width = 400
$resultLabel.Height = 150
$resultLabel.AutoSize = $false
$form.Controls.Add($resultLabel)

# Show username/password fields and enable button when server IP is filled
$updateFields = {
    if ($textServer.Text) {
        $labelUser.Visible = $true
        $textUser.Visible = $true
        $labelPass.Visible = $true
        $textPass.Visible = $true
        $buttonCreate.Enabled = $true
    } else {
        $labelUser.Visible = $false
        $textUser.Visible = $false
        $labelPass.Visible = $false
        $textPass.Visible = $false
        $buttonCreate.Enabled = $false
    }
}
$textServer.Add_TextChanged($updateFields)

# Add Scope Button Click Event
$buttonAddScope.Add_Click({
    # Create a new form for scope input
    $scopeForm = New-Object System.Windows.Forms.Form
    $scopeForm.Text = "Add DHCP Scope"
    $scopeForm.Width = 400
    $scopeForm.Height = 400
    $scopeForm.StartPosition = "CenterParent"

    # Scope Name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text = "Scope Name:"
    $lblName.Top = 20
    $lblName.Left = 20
    $lblName.Width = 120
    $scopeForm.Controls.Add($lblName)

    $txtName = New-Object System.Windows.Forms.TextBox
    $txtName.Top = 20
    $txtName.Left = 150
    $txtName.Width = 200
    $txtName.Text = "Office LAN"
    $scopeForm.Controls.Add($txtName)

    # Start IP
    $lblStart = New-Object System.Windows.Forms.Label
    $lblStart.Text = "Start IP:"
    $lblStart.Top = 60
    $lblStart.Left = 20
    $lblStart.Width = 120
    $scopeForm.Controls.Add($lblStart)

    $txtStart = New-Object System.Windows.Forms.TextBox
    $txtStart.Top = 60
    $txtStart.Left = 150
    $txtStart.Width = 200
    $txtStart.Text = "192.168.10.50"
    $scopeForm.Controls.Add($txtStart)

    # End IP
    $lblEnd = New-Object System.Windows.Forms.Label
    $lblEnd.Text = "End IP:"
    $lblEnd.Top = 100
    $lblEnd.Left = 20
    $lblEnd.Width = 120
    $scopeForm.Controls.Add($lblEnd)

    $txtEnd = New-Object System.Windows.Forms.TextBox
    $txtEnd.Top = 100
    $txtEnd.Left = 150
    $txtEnd.Width = 200
    $txtEnd.Text = "192.168.10.200"
    $scopeForm.Controls.Add($txtEnd)

    # Subnet Mask
    $lblMask = New-Object System.Windows.Forms.Label
    $lblMask.Text = "Subnet Mask:"
    $lblMask.Top = 140
    $lblMask.Left = 20
    $lblMask.Width = 120
    $scopeForm.Controls.Add($lblMask)

    $txtMask = New-Object System.Windows.Forms.TextBox
    $txtMask.Top = 140
    $txtMask.Left = 150
    $txtMask.Width = 200
    $txtMask.Text = "255.255.255.0"
    $scopeForm.Controls.Add($txtMask)

    # Gateway
    $lblGateway = New-Object System.Windows.Forms.Label
    $lblGateway.Text = "Gateway:"
    $lblGateway.Top = 180
    $lblGateway.Left = 20
    $lblGateway.Width = 120
    $scopeForm.Controls.Add($lblGateway)

    $txtGateway = New-Object System.Windows.Forms.TextBox
    $txtGateway.Top = 180
    $txtGateway.Left = 150
    $txtGateway.Width = 200
    $txtGateway.Text = "192.168.10.1"
    $scopeForm.Controls.Add($txtGateway)

    # DNS Server
    $lblDns = New-Object System.Windows.Forms.Label
    $lblDns.Text = "DNS Server:"
    $lblDns.Top = 220
    $lblDns.Left = 20
    $lblDns.Width = 120
    $scopeForm.Controls.Add($lblDns)

    $txtDns = New-Object System.Windows.Forms.TextBox
    $txtDns.Top = 220
    $txtDns.Left = 150
    $txtDns.Width = 200
    $txtDns.Text = "192.168.10.10"
    $scopeForm.Controls.Add($txtDns)

    # Lease Duration
    $lblLease = New-Object System.Windows.Forms.Label
    $lblLease.Text = "Lease Duration (Days):"
    $lblLease.Top = 260
    $lblLease.Left = 20
    $lblLease.Width = 120
    $scopeForm.Controls.Add($lblLease)

    $txtLease = New-Object System.Windows.Forms.TextBox
    $txtLease.Top = 260
    $txtLease.Left = 150
    $txtLease.Width = 200
    $txtLease.Text = "8"
    $scopeForm.Controls.Add($txtLease)

    # OK Button
    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Add"
    $btnOK.Top = 310
    $btnOK.Left = 150
    $btnOK.Width = 80
    $scopeForm.Controls.Add($btnOK)

    # Cancel Button
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Top = 310
    $btnCancel.Left = 240
    $btnCancel.Width = 80
    $scopeForm.Controls.Add($btnCancel)

    $btnOK.Add_Click({
        if ($txtName.Text -and $txtStart.Text -and $txtEnd.Text -and $txtMask.Text -and $txtGateway.Text -and $txtDns.Text -and $txtLease.Text) {
            $scope = @{
                Name = $txtName.Text
                StartIP = $txtStart.Text
                EndIP = $txtEnd.Text
                SubnetMask = $txtMask.Text
                Gateway = $txtGateway.Text
                DnsServer = $txtDns.Text
                LeaseDuration = $txtLease.Text
            }
            $scopesList.Add($scope) | Out-Null
            $listBoxScopes.Items.Add("$($scope.Name) - $($scope.StartIP) to $($scope.EndIP)")
            $scopeForm.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Validation Error")
        }
    })

    $btnCancel.Add_Click({
        $scopeForm.Close()
    })

    $scopeForm.ShowDialog()
})

# Remove Scope Button Click Event
$buttonRemoveScope.Add_Click({
    if ($listBoxScopes.SelectedIndex -ge 0) {
        $index = $listBoxScopes.SelectedIndex
        $scopesList.RemoveAt($index)
        $listBoxScopes.Items.RemoveAt($index)
    }
})

# Create Server Button Click Event
$buttonCreate.Add_Click({
    $serverIP = $textServer.Text
    $dnsForwarder = $textDnsForwarder.Text
    $dnsSuffix = $textDnsSuffix.Text
    $username = $textUser.Text
    $password = $textPass.Text

    if (-not $serverIP -or -not $username -or -not $password) {
        $resultLabel.Text = "Please fill in Server IP, Username, and Password."
        return
    }

    if ($scopesList.Count -eq 0) {
        $resultLabel.Text = "Please add at least one DHCP scope."
        return
    }

    $resultLabel.Text = "Configuring DHCP and DNS... Please wait."
    $form.Refresh()

    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

    try {
        $session = New-PSSession -ComputerName $serverIP -Credential $cred -ErrorAction Stop
        
        Invoke-Command -Session $session -ScriptBlock {
            param($dnsForwarder, $scopes, $dnsSuffix)
            
            function Ensure-Module {
                param([string]$ModuleName)
                if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
                    Install-WindowsFeature RSAT -ErrorAction SilentlyContinue | Out-Null
                }
                Import-Module $ModuleName -ErrorAction Stop
            }

            # Install DNS and DHCP roles
            Write-Host "Installing DNS and DHCP Server roles..."
            $dns = Install-WindowsFeature -Name DNS -IncludeManagementTools -ErrorAction Stop
            $dhcp = Install-WindowsFeature -Name DHCP -IncludeManagementTools -ErrorAction Stop

            if ($dns.Success -and $dhcp.Success) {
                Write-Host "DNS and DHCP roles installed successfully."
            } else {
                throw "Failed to install DNS/DHCP roles."
            }

            # Configure DNS
            Write-Host "Configuring DNS..."
            Ensure-Module -ModuleName DNSServer

            if ($dnsForwarder) {
                try {
                    $existingForwarders = (Get-DnsServerForwarder -ErrorAction SilentlyContinue).IPAddress.IPAddressToString
                } catch {
                    $existingForwarders = @()
                }

                if ($existingForwarders -notcontains $dnsForwarder) {
                    Add-DnsServerForwarder -IPAddress $dnsForwarder -ErrorAction Stop
                    Write-Host "Added DNS forwarder: $dnsForwarder"
                }
            }

            # Configure DHCP
            Ensure-Module -ModuleName DHCPServer

            # Authorize DHCP in AD (if domain-joined)
            try {
                $domainJoined = (Get-WmiObject Win32_ComputerSystem).PartOfDomain
                if ($domainJoined) {
                    Write-Host "Authorizing DHCP server in Active Directory..."
                    $serverIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object -First 1).IPAddress
                    Add-DhcpServerInDC -DnsName $env:COMPUTERNAME -IPAddress $serverIp -ErrorAction SilentlyContinue
                    Write-Host "DHCP server authorized."
                }
            } catch {
                Write-Host "Note: Could not authorize in AD (may not be domain-joined)"
            }

            # Create DHCP Scopes
            foreach ($scope in $scopes) {
                Write-Host "`nCreating DHCP scope: $($scope.Name)..."
                $existingScope = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $scope.Name }
                
                if (-not $existingScope) {
                    Add-DhcpServerv4Scope `
                        -Name $scope.Name `
                        -StartRange $scope.StartIP `
                        -EndRange $scope.EndIP `
                        -SubnetMask $scope.SubnetMask `
                        -State Active `
                        -LeaseDuration (New-TimeSpan -Days ([int]$scope.LeaseDuration)) `
                        -ErrorAction Stop
                    Write-Host "Scope '$($scope.Name)' created."
                } else {
                    Write-Host "Scope '$($scope.Name)' already exists, skipping."
                    continue
                }

                # Set DHCP options for this scope
                $scopeId = (Get-DhcpServerv4Scope | Where-Object Name -eq $scope.Name).ScopeId
                
                # Router option
                Set-DhcpServerv4OptionValue -ScopeId $scopeId -Router $scope.Gateway -ErrorAction Stop
                Write-Host "  Set router: $($scope.Gateway)"

                # DNS servers and domain suffix
                $dnsArray = @($scope.DnsServer)
                Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsServer $dnsArray -DnsDomain $dnsSuffix -ErrorAction Stop
                Write-Host "  Set DNS: $($scope.DnsServer), Domain: $dnsSuffix"
            }

            # Start services
            Set-Service -Name DNS -StartupType Automatic
            Start-Service -Name DNS
            Set-Service -Name DHCPServer -StartupType Automatic
            Start-Service -Name DHCPServer

            Write-Host "`n========================================="
            Write-Host "DHCP and DNS configuration complete!"
            Write-Host "Total scopes created: $($scopes.Count)"
            Write-Host "========================================="
            
        } -ArgumentList $dnsForwarder, $scopesList.ToArray(), $dnsSuffix

        Remove-PSSession -Session $session
        $resultLabel.Text = "Success! DHCP and DNS configured.`n$($scopesList.Count) scope(s) created."
        
    } catch {
        $resultLabel.Text = "Error: $($_.Exception.Message)"
        Write-Host "Full error: $_"
    }
})

$form.ShowDialog()
$form.Dispose()