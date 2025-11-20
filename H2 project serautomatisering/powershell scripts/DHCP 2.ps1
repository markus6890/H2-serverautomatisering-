Add-Type -AssemblyName System.Windows.Forms

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Create Windows DHCP and DNS Server"
$form.Width = 450
$form.Height = 750
$form.StartPosition = "CenterScreen"

# Create a list to store scopes
$scopesList = New-Object System.Collections.ArrayList
# Create a list to store DNS zones
$dnsZonesList = New-Object System.Collections.ArrayList

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

# Check Installation Button
$buttonCheckInstall = New-Object System.Windows.Forms.Button
$buttonCheckInstall.Text = "Check Installation"
$buttonCheckInstall.Top = 60
$buttonCheckInstall.Left = 180
$buttonCheckInstall.Width = 140
$buttonCheckInstall.Enabled = $false
$form.Controls.Add($buttonCheckInstall)

# Installation Status Label
$labelInstallStatus = New-Object System.Windows.Forms.Label
$labelInstallStatus.Top = 90
$labelInstallStatus.Left = 20
$labelInstallStatus.Width = 380
$labelInstallStatus.Height = 40
$labelInstallStatus.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($labelInstallStatus)

# DNS Forwarder Label and TextBox
$labelDnsForwarder = New-Object System.Windows.Forms.Label
$labelDnsForwarder.Text = "DNS Forwarder:"
$labelDnsForwarder.Top = 140
$labelDnsForwarder.Left = 20
$labelDnsForwarder.Width = 150
$form.Controls.Add($labelDnsForwarder)

$textDnsForwarder = New-Object System.Windows.Forms.TextBox
$textDnsForwarder.Top = 140
$textDnsForwarder.Left = 180
$textDnsForwarder.Width = 220
$textDnsForwarder.Text = "8.8.8.8"
$form.Controls.Add($textDnsForwarder)

# DNS Zones Section Header
$labelDnsZonesHeader = New-Object System.Windows.Forms.Label
$labelDnsZonesHeader.Text = "DNS Lookup Zones:"
$labelDnsZonesHeader.Top = 180
$labelDnsZonesHeader.Left = 20
$labelDnsZonesHeader.Width = 150
$labelDnsZonesHeader.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelDnsZonesHeader)

# ListBox to display added DNS zones
$listBoxDnsZones = New-Object System.Windows.Forms.ListBox
$listBoxDnsZones.Top = 210
$listBoxDnsZones.Left = 20
$listBoxDnsZones.Width = 380
$listBoxDnsZones.Height = 60
$form.Controls.Add($listBoxDnsZones)

# Add DNS Zone Button
$buttonAddDnsZone = New-Object System.Windows.Forms.Button
$buttonAddDnsZone.Text = "Add DNS Zone"
$buttonAddDnsZone.Top = 280
$buttonAddDnsZone.Left = 20
$buttonAddDnsZone.Width = 120
$form.Controls.Add($buttonAddDnsZone)

# Remove DNS Zone Button
$buttonRemoveDnsZone = New-Object System.Windows.Forms.Button
$buttonRemoveDnsZone.Text = "Remove Selected"
$buttonRemoveDnsZone.Top = 280
$buttonRemoveDnsZone.Left = 150
$buttonRemoveDnsZone.Width = 120
$form.Controls.Add($buttonRemoveDnsZone)

# Scopes Section Header
$labelScopesHeader = New-Object System.Windows.Forms.Label
$labelScopesHeader.Text = "DHCP Scopes:"
$labelScopesHeader.Top = 320
$labelScopesHeader.Left = 20
$labelScopesHeader.Width = 150
$labelScopesHeader.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelScopesHeader)

# ListBox to display added scopes
$listBoxScopes = New-Object System.Windows.Forms.ListBox
$listBoxScopes.Top = 350
$listBoxScopes.Left = 20
$listBoxScopes.Width = 380
$listBoxScopes.Height = 80
$form.Controls.Add($listBoxScopes)

# Add Scope Button
$buttonAddScope = New-Object System.Windows.Forms.Button
$buttonAddScope.Text = "Add Scope"
$buttonAddScope.Top = 440
$buttonAddScope.Left = 20
$buttonAddScope.Width = 120
$form.Controls.Add($buttonAddScope)

# Remove Scope Button
$buttonRemoveScope = New-Object System.Windows.Forms.Button
$buttonRemoveScope.Text = "Remove Selected"
$buttonRemoveScope.Top = 440
$buttonRemoveScope.Left = 150
$buttonRemoveScope.Width = 120
$form.Controls.Add($buttonRemoveScope)

# DNS Domain Suffix
$labelDnsSuffix = New-Object System.Windows.Forms.Label
$labelDnsSuffix.Text = "DNS Domain Suffix:"
$labelDnsSuffix.Top = 480
$labelDnsSuffix.Left = 20
$labelDnsSuffix.Width = 150
$form.Controls.Add($labelDnsSuffix)

$textDnsSuffix = New-Object System.Windows.Forms.TextBox
$textDnsSuffix.Top = 480
$textDnsSuffix.Left = 180
$textDnsSuffix.Width = 220
$textDnsSuffix.Text = "corp.example.local"
$form.Controls.Add($textDnsSuffix)

# Username Label and TextBox (hidden initially)
$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username:"
$labelUser.Top = 520
$labelUser.Left = 20
$labelUser.Width = 150
$labelUser.Visible = $false
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Top = 520
$textUser.Left = 180
$textUser.Width = 220
$textUser.Visible = $false
$form.Controls.Add($textUser)

# Password Label and TextBox (hidden initially)
$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Top = 560
$labelPass.Left = 20
$labelPass.Width = 150
$labelPass.Visible = $false
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.Top = 560
$textPass.Left = 180
$textPass.Width = 220
$textPass.UseSystemPasswordChar = $true
$textPass.Visible = $false
$form.Controls.Add($textPass)

# Create/Configure Server Button
$buttonCreate = New-Object System.Windows.Forms.Button
$buttonCreate.Text = "Configure Server"
$buttonCreate.Top = 610
$buttonCreate.Left = 125
$buttonCreate.Width = 180
$buttonCreate.Enabled = $false
$form.Controls.Add($buttonCreate)

# Result Label
$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Top = 650
$resultLabel.Left = 20
$resultLabel.Width = 400
$resultLabel.Height = 80
$resultLabel.AutoSize = $false
$form.Controls.Add($resultLabel)

# Show username/password fields and enable buttons when server IP is filled
$updateFields = {
    if ($textServer.Text) {
        $labelUser.Visible = $true
        $textUser.Visible = $true
        $labelPass.Visible = $true
        $textPass.Visible = $true
        $buttonCreate.Enabled = $true
        $buttonCheckInstall.Enabled = $true
    } else {
        $labelUser.Visible = $false
        $textUser.Visible = $false
        $labelPass.Visible = $false
        $textPass.Visible = $false
        $buttonCreate.Enabled = $false
        $buttonCheckInstall.Enabled = $false
    }
}
$textServer.Add_TextChanged($updateFields)

# Check Installation Button Click Event
$buttonCheckInstall.Add_Click({
    $serverIP = $textServer.Text
    $username = $textUser.Text
    $password = $textPass.Text

    if (-not $serverIP -or -not $username -or -not $password) {
        $labelInstallStatus.Text = "Please fill in Server IP, Username, and Password."
        $labelInstallStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }

    $labelInstallStatus.Text = "Checking installation status..."
    $labelInstallStatus.ForeColor = [System.Drawing.Color]::Blue
    $form.Refresh()

    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

    try {
        $session = New-PSSession -ComputerName $serverIP -Credential $cred -ErrorAction Stop

        $status = Invoke-Command -Session $session -ScriptBlock {
            $dnsFeature = Get-WindowsFeature -Name DNS
            $dhcpFeature = Get-WindowsFeature -Name DHCP

            $result = @{
                DnsInstalled = $dnsFeature.Installed
                DhcpInstalled = $dhcpFeature.Installed
            }

            if ($dnsFeature.Installed) {
                $dnsService = Get-Service -Name DNS -ErrorAction SilentlyContinue
                $result.DnsStatus = $dnsService.Status
                $result.DnsStartType = $dnsService.StartType

                # Count existing zones
                $zones = Get-DnsServerZone -ErrorAction SilentlyContinue | Where-Object { -not $_.IsAutoCreated }
                $result.DnsZoneCount = $zones.Count
            }

            if ($dhcpFeature.Installed) {
                $dhcpService = Get-Service -Name DHCPServer -ErrorAction SilentlyContinue
                $result.DhcpStatus = $dhcpService.Status
                $result.DhcpStartType = $dhcpService.StartType

                # Count existing scopes
                $scopes = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue
                $result.DhcpScopeCount = $scopes.Count

                # Check authorization in AD
                try {
                    $authorized = Get-DhcpServerInDC -ErrorAction SilentlyContinue
                    $result.DhcpAuthorized = ($authorized -ne $null)
                } catch {
                    $result.DhcpAuthorized = $false
                }
            }

            return $result
        }

        Remove-PSSession -Session $session

        # Build status message
        $statusMessage = ""

        if ($status.DnsInstalled) {
            $statusMessage += "DNS: Installed ($($status.DnsStatus)) - $($status.DnsZoneCount) zones`n"
        } else {
            $statusMessage += "DNS: Not Installed`n"
        }

        if ($status.DhcpInstalled) {
            $statusMessage += "DHCP: Installed ($($status.DhcpStatus)) - $($status.DhcpScopeCount) scopes"
            if ($status.DhcpAuthorized) {
                $statusMessage += " [Authorized]"
            }
        } else {
            $statusMessage += "DHCP: Not Installed"
        }

        $labelInstallStatus.Text = $statusMessage

        # Change color based on installation status
        if ($status.DnsInstalled -and $status.DhcpInstalled) {
            $labelInstallStatus.ForeColor = [System.Drawing.Color]::Green
        } elseif ($status.DnsInstalled -or $status.DhcpInstalled) {
            $labelInstallStatus.ForeColor = [System.Drawing.Color]::Orange
        } else {
            $labelInstallStatus.ForeColor = [System.Drawing.Color]::Red
        }

    } catch {
        $labelInstallStatus.Text = "Error checking status: $($_.Exception.Message)"
        $labelInstallStatus.ForeColor = [System.Drawing.Color]::Red
    }
})

# Add DNS Zone Button Click Event
$buttonAddDnsZone.Add_Click({
    # Create a new form for DNS zone input
    $zoneForm = New-Object System.Windows.Forms.Form
    $zoneForm.Text = "Add DNS Lookup Zone"
    $zoneForm.Width = 400
    $zoneForm.Height = 250
    $zoneForm.StartPosition = "CenterParent"

    # Zone Name
    $lblZoneName = New-Object System.Windows.Forms.Label
    $lblZoneName.Text = "Zone Name:"
    $lblZoneName.Top = 20
    $lblZoneName.Left = 20
    $lblZoneName.Width = 120
    $zoneForm.Controls.Add($lblZoneName)

    $txtZoneName = New-Object System.Windows.Forms.TextBox
    $txtZoneName.Top = 20
    $txtZoneName.Left = 150
    $txtZoneName.Width = 200
    $txtZoneName.Text = "example.local"
    $zoneForm.Controls.Add($txtZoneName)

    # Zone Type
    $lblZoneType = New-Object System.Windows.Forms.Label
    $lblZoneType.Text = "Zone Type:"
    $lblZoneType.Top = 60
    $lblZoneType.Left = 20
    $lblZoneType.Width = 120
    $zoneForm.Controls.Add($lblZoneType)

    $comboZoneType = New-Object System.Windows.Forms.ComboBox
    $comboZoneType.Top = 60
    $comboZoneType.Left = 150
    $comboZoneType.Width = 200
    $comboZoneType.DropDownStyle = 'DropDownList'
    $comboZoneType.Items.AddRange(@("Primary", "Secondary"))
    $comboZoneType.SelectedIndex = 0
    $zoneForm.Controls.Add($comboZoneType)

    # Replication Scope (for Primary zones)
    $lblReplication = New-Object System.Windows.Forms.Label
    $lblReplication.Text = "Replication:"
    $lblReplication.Top = 100
    $lblReplication.Left = 20
    $lblReplication.Width = 120
    $zoneForm.Controls.Add($lblReplication)

    $comboReplication = New-Object System.Windows.Forms.ComboBox
    $comboReplication.Top = 100
    $comboReplication.Left = 150
    $comboReplication.Width = 200
    $comboReplication.DropDownStyle = 'DropDownList'
    $comboReplication.Items.AddRange(@("Forest", "Domain", "None"))
    $comboReplication.SelectedIndex = 1
    $zoneForm.Controls.Add($comboReplication)

    # Dynamic Update
    $lblDynamicUpdate = New-Object System.Windows.Forms.Label
    $lblDynamicUpdate.Text = "Dynamic Update:"
    $lblDynamicUpdate.Top = 140
    $lblDynamicUpdate.Left = 20
    $lblDynamicUpdate.Width = 120
    $zoneForm.Controls.Add($lblDynamicUpdate)

    $comboDynamicUpdate = New-Object System.Windows.Forms.ComboBox
    $comboDynamicUpdate.Top = 140
    $comboDynamicUpdate.Left = 150
    $comboDynamicUpdate.Width = 200
    $comboDynamicUpdate.DropDownStyle = 'DropDownList'
    $comboDynamicUpdate.Items.AddRange(@("Secure", "NonsecureAndSecure", "None"))
    $comboDynamicUpdate.SelectedIndex = 0
    $zoneForm.Controls.Add($comboDynamicUpdate)

    # OK Button
    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Add"
    $btnOK.Top = 180
    $btnOK.Left = 150
    $btnOK.Width = 80
    $zoneForm.Controls.Add($btnOK)

    # Cancel Button
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Top = 180
    $btnCancel.Left = 240
    $btnCancel.Width = 80
    $zoneForm.Controls.Add($btnCancel)

    $btnOK.Add_Click({
        if ($txtZoneName.Text) {
            $zone = @{
                Name = $txtZoneName.Text
                Type = $comboZoneType.SelectedItem
                Replication = $comboReplication.SelectedItem
                DynamicUpdate = $comboDynamicUpdate.SelectedItem
            }
            $dnsZonesList.Add($zone) | Out-Null
            $listBoxDnsZones.Items.Add("$($zone.Name) ($($zone.Type))")
            $zoneForm.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please enter a zone name.", "Validation Error")
        }
    })

    $btnCancel.Add_Click({
        $zoneForm.Close()
    })

    $zoneForm.ShowDialog()
})

# Remove DNS Zone Button Click Event
$buttonRemoveDnsZone.Add_Click({
    if ($listBoxDnsZones.SelectedIndex -ge 0) {
        $index = $listBoxDnsZones.SelectedIndex
        $dnsZonesList.RemoveAt($index)
        $listBoxDnsZones.Items.RemoveAt($index)
    }
})

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

# Configure Server Button Click Event
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

    $resultLabel.Text = "Configuring server... Please wait."
    $form.Refresh()

    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

    try {
        $session = New-PSSession -ComputerName $serverIP -Credential $cred -ErrorAction Stop

        $result = Invoke-Command -Session $session -ScriptBlock {
            param($dnsForwarder, $scopes, $dnsZones, $dnsSuffix)

            $output = @()

            function Ensure-Module {
                param([string]$ModuleName)
                if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
                    Install-WindowsFeature RSAT -ErrorAction SilentlyContinue | Out-Null
                }
                Import-Module $ModuleName -ErrorAction Stop
            }

            # Check if already installed
            $dnsInstalled = (Get-WindowsFeature -Name DNS).Installed
            $dhcpInstalled = (Get-WindowsFeature -Name DHCP).Installed

            $output += "========================================="
            $output += "Checking Installation Status..."
            $output += "========================================="

            # Install DNS if not installed
            if (-not $dnsInstalled) {
                $output += "DNS not installed. Installing DNS Server..."
                $dns = Install-WindowsFeature -Name DNS -IncludeManagementTools -ErrorAction Stop
                if ($dns.Success) {
                    $output += "DNS Server installed successfully."
                    $dnsInstalled = $true
                } else {
                    throw "Failed to install DNS Server."
                }
            } else {
                $output += "DNS Server already installed."
            }

            # Install DHCP if not installed
            if (-not $dhcpInstalled) {
                $output += "DHCP not installed. Installing DHCP Server..."
                $dhcp = Install-WindowsFeature -Name DHCP -IncludeManagementTools -ErrorAction Stop
                if ($dhcp.Success) {
                    $output += "DHCP Server installed successfully."
                    $dhcpInstalled = $true
                } else {
                    throw "Failed to install DHCP Server."
                }
            } else {
                $output += "DHCP Server already installed."
            }

            $output += ""
            $output += "========================================="
            $output += "Configuring DNS..."
            $output += "========================================="

            # Configure DNS
            Ensure-Module -ModuleName DNSServer

            # Configure DNS Forwarder
            if ($dnsForwarder) {
                try {
                    $existingForwarders = (Get-DnsServerForwarder -ErrorAction SilentlyContinue).IPAddress.IPAddressToString
                } catch {
                    $existingForwarders = @()
                }

                if ($existingForwarders -notcontains $dnsForwarder) {
                    Add-DnsServerForwarder -IPAddress $dnsForwarder -ErrorAction Stop
                    $output += "Added DNS forwarder: $dnsForwarder"
                } else {
                    $output += "DNS forwarder already exists: $dnsForwarder"
                }
            }

            # Create DNS Zones
            $zonesCreated = 0
            $zonesSkipped = 0
            foreach ($zone in $dnsZones) {
                $existingZone = Get-DnsServerZone -Name $zone.Name -ErrorAction SilentlyContinue

                if (-not $existingZone) {
                    try {
                        if ($zone.Type -eq "Primary") {
                            $replicationScope = switch ($zone.Replication) {
                                "Forest" { "Forest" }
                                "Domain" { "Domain" }
                                "None" { $null }
                            }

                            if ($replicationScope) {
                                Add-DnsServerPrimaryZone -Name $zone.Name -ReplicationScope $replicationScope -DynamicUpdate $zone.DynamicUpdate -ErrorAction Stop
                            } else {
                                Add-DnsServerPrimaryZone -Name $zone.Name -ZoneFile "$($zone.Name).dns" -DynamicUpdate $zone.DynamicUpdate -ErrorAction Stop
                            }
                        } else {
                            # For secondary zones, you'd need a master server
                            $output += "⚠ Secondary zone creation requires master server IP (skipped: $($zone.Name))"
                            continue
                        }
                        $output += " Created DNS zone: $($zone.Name) ($($zone.Type))"
                        $zonesCreated++
                    } catch {
                        $output += "Failed to create zone $($zone.Name): $_"
                    }
                } else {
                    $output += "DNS zone already exists: $($zone.Name)"
                    $zonesSkipped++
                }
            }

            $output += ""
            $output += "========================================="
            $output += "Configuring DHCP..."
            $output += "========================================="

            # Configure DHCP
            Ensure-Module -ModuleName DHCPServer

            # Authorize DHCP in AD (if domain-joined)
            try {
                $domainJoined = (Get-WmiObject Win32_ComputerSystem).PartOfDomain
                if ($domainJoined) {
                    $serverIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object -First 1).IPAddress

                    $alreadyAuth = Get-DhcpServerInDC -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -eq $serverIp }
                    if (-not $alreadyAuth) {
                        Add-DhcpServerInDC -DnsName $env:COMPUTERNAME -IPAddress $serverIp -ErrorAction SilentlyContinue
                        $output += "DHCP server authorized in Active Directory."
                    } else {
                        $output += "DHCP server already authorized in AD."
                    }
                }
            } catch {
                $output += "Not domain-joined, skipping AD authorization."
            }

            # Create DHCP Scopes
            $scopesCreated = 0
            $scopesSkipped = 0
            foreach ($scope in $scopes) {
                $existingScope = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $scope.Name }

                if (-not $existingScope) {
                    try {
                        Add-DhcpServerv4Scope `
                            -Name $scope.Name `
                            -StartRange $scope.StartIP `
                            -EndRange $scope.EndIP `
                            -SubnetMask $scope.SubnetMask `
                            -State Active `
                            -LeaseDuration (New-TimeSpan -Days ([int]$scope.LeaseDuration)) `
                            -ErrorAction Stop

                        # Set DHCP options for this scope
                        $scopeId = (Get-DhcpServerv4Scope | Where-Object Name -eq $scope.Name).ScopeId

                        # Router option
                        Set-DhcpServerv4OptionValue -ScopeId $scopeId -Router $scope.Gateway -ErrorAction Stop

                        # DNS servers and domain suffix
                        $dnsArray = @($scope.DnsServer)
                        Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsServer $dnsArray -DnsDomain $dnsSuffix -ErrorAction Stop

                        $output += "Created DHCP scope: $($scope.Name) ($($scope.StartIP) - $($scope.EndIP))"
                        $scopesCreated++
                    } catch {
                        $output += "Failed to create scope $($scope.Name): $_"
                    }
                } else {
                    $output += "DHCP scope already exists: $($scope.Name)"
                    $scopesSkipped++
                }
            }

            # Start services
            $output += ""
            $output += "Starting services..."
            Set-Service -Name DNS -StartupType Automatic
            Start-Service -Name DNS -ErrorAction SilentlyContinue
            Set-Service -Name DHCPServer -StartupType Automatic
            Start-Service -Name DHCPServer -ErrorAction SilentlyContinue
            $output += "DNS and DHCP services started."

            $output += ""
            $output += "========================================="
            $output += "Configuration Complete!"
            $output += "========================================="
            $output += "DNS Zones: $zonesCreated created, $zonesSkipped existing"
            $output += "DHCP Scopes: $scopesCreated created, $scopesSkipped existing"
            $output += "========================================="

            return ($output -join "`n")

        } -ArgumentList $dnsForwarder, $scopesList.ToArray(), $dnsZonesList.ToArray(), $dnsSuffix

        Remove-PSSession -Session $session
        $resultLabel.Text = $result
        $resultLabel.ForeColor = [System.Drawing.Color]::Green

    } catch {
        $resultLabel.Text = "Error: $($_.Exception.Message)"
        $resultLabel.ForeColor = [System.Drawing.Color]::Red
        Write-Host "Full error: $_"
    }
})

$form.ShowDialog()
$form.Dispose()