# powershell
# File: `DHCP 2.ps1`
Add-Type -AssemblyName Microsoft.VisualBasic

# dot-source the UI builder (adjust path if needed)
. .\UI.ps1
if ($PSVersionTable.PSVersion -and $PSScriptRoot) {
    $scriptDir = $PSScriptRoot
} else {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
. (Join-Path $scriptDir 'ExclusionsEditor.ps1')
. (Join-Path $scriptDir 'Configure-RemoteServer.ps1')

# Build UI and get controls
$ui = New-ServerConfigForm

# Show username/password fields and enable buttons when server IP is filled
$ui.TextServer.Add_TextChanged({
    if ($ui.TextServer.Text) {
        $ui.LabelUser.Visible = $true
        $ui.TextUser.Visible = $true
        $ui.LabelPass.Visible = $true
        $ui.TextPass.Visible = $true
        $ui.ButtonCreate.Enabled = $true
        $ui.ButtonCheckInstall.Enabled = $true
    } else {
        $ui.LabelUser.Visible = $false
        $ui.TextUser.Visible = $false
        $ui.LabelPass.Visible = $false
        $ui.TextPass.Visible = $false
        $ui.ButtonCreate.Enabled = $false
        $ui.ButtonCheckInstall.Enabled = $false
    }
})

# Simple helper to append log
function Append-Log([string]$line) {
    $ui.TextStatus.AppendText(($line) + "`r`n")
}
$scopesList = New-Object System.Collections.ArrayList
$dnsZonesList = New-Object System.Collections.ArrayList

function Get-ExclusionCount {
    param($scope)
    if ($null -ne $scope -and $scope.Exclusions) { return $scope.Exclusions.Count } else { return 0 }
}
function Format-ZoneDisplay($z) {
    if ($z.ZoneClass -eq 'Reverse') {
        return "REV: $($z.ReverseName -or $z.Network) - $($z.ZoneType) [Repl: $($z.Replication)] [Dyn: $($z.DynamicUpdate)]"
    } else {
        return "$($z.Name) - $($z.ZoneType) [Repl: $($z.Replication)] [Dyn: $($z.DynamicUpdate)]"
    }
}

function Show-ZoneEditor {
    param([PSCustomObject]$Zone)

    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $form = New-Object System.Windows.Forms.Form
    $form.Text = if ($Zone) { "Edit DNS Zone" } else { "Add DNS Zone" }
    $form.Width = 480; $form.Height = 320; $form.StartPosition = "CenterParent"

    $lblClass = New-Object System.Windows.Forms.Label
    $lblClass.Text = "Zone Class:"; $lblClass.Top = 20; $lblClass.Left = 10; $lblClass.Width = 120
    $form.Controls.Add($lblClass)
    $cmbClass = New-Object System.Windows.Forms.ComboBox
    $cmbClass.Top = 20; $cmbClass.Left = 140; $cmbClass.Width = 300
    $cmbClass.DropDownStyle = 'DropDownList'
    $cmbClass.Items.AddRange(@("Forward","Reverse"))
    $form.Controls.Add($cmbClass)

    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text = "Zone Name (forward):"; $lblName.Top = 60; $lblName.Left = 10; $lblName.Width = 120
    $form.Controls.Add($lblName)
    $txtName = New-Object System.Windows.Forms.TextBox
    $txtName.Top = 60; $txtName.Left = 140; $txtName.Width = 300
    $form.Controls.Add($txtName)

    $lblNetwork = New-Object System.Windows.Forms.Label
    $lblNetwork.Text = "Network (CIDR or base IP) for reverse:"; $lblNetwork.Top = 100; $lblNetwork.Left = 10; $lblNetwork.Width = 300
    $form.Controls.Add($lblNetwork)
    $txtNetwork = New-Object System.Windows.Forms.TextBox
    $txtNetwork.Top = 100; $txtNetwork.Left = 140; $txtNetwork.Width = 300
    $form.Controls.Add($txtNetwork)

    $lblType = New-Object System.Windows.Forms.Label
    $lblType.Text = "Zone Type:"; $lblType.Top = 140; $lblType.Left = 10; $lblType.Width = 120
    $form.Controls.Add($lblType)
    $cmbType = New-Object System.Windows.Forms.ComboBox
    $cmbType.Top = 140; $cmbType.Left = 140; $cmbType.Width = 300
    $cmbType.DropDownStyle = 'DropDownList'
    $cmbType.Items.AddRange(@("Primary","Secondary"))
    $form.Controls.Add($cmbType)

    $lblRepl = New-Object System.Windows.Forms.Label
    $lblRepl.Text = "Replication:"; $lblRepl.Top = 180; $lblRepl.Left = 10; $lblRepl.Width = 120
    $form.Controls.Add($lblRepl)
    $cmbRepl = New-Object System.Windows.Forms.ComboBox
    $cmbRepl.Top = 180; $cmbRepl.Left = 140; $cmbRepl.Width = 300
    $cmbRepl.DropDownStyle = 'DropDownList'
    $cmbRepl.Items.AddRange(@("Forest","Domain","None"))
    $form.Controls.Add($cmbRepl)

    $lblDyn = New-Object System.Windows.Forms.Label
    $lblDyn.Text = "Dynamic Update:"; $lblDyn.Top = 220; $lblDyn.Left = 10; $lblDyn.Width = 120
    $form.Controls.Add($lblDyn)
    $cmbDyn = New-Object System.Windows.Forms.ComboBox
    $cmbDyn.Top = 220; $cmbDyn.Left = 140; $cmbDyn.Width = 300
    $cmbDyn.DropDownStyle = 'DropDownList'
    $cmbDyn.Items.AddRange(@("Secure","NonsecureAndSecure","None"))
    $form.Controls.Add($cmbDyn)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "OK"; $btnOK.Top = 260; $btnOK.Left = 140; $btnOK.Width = 120
    $form.Controls.Add($btnOK)
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"; $btnCancel.Top = 260; $btnCancel.Left = 280; $btnCancel.Width = 120
    $form.Controls.Add($btnCancel)

    # init
    if ($Zone) {
        $cmbClass.SelectedItem = $Zone.ZoneClass
        $txtName.Text = $Zone.Name
        $txtNetwork.Text = $Zone.Network
        $cmbType.SelectedItem = $Zone.ZoneType
        $cmbRepl.SelectedItem = $Zone.Replication
        $cmbDyn.SelectedItem = $Zone.DynamicUpdate
    } else {
        $cmbClass.SelectedIndex = 0
        $cmbType.SelectedIndex = 0
        $cmbRepl.SelectedIndex = 1
        $cmbDyn.SelectedIndex = 0
    }

    # toggle visibility
    $toggleForClass = {
        if ($cmbClass.SelectedItem -eq 'Reverse') {
            $lblName.Visible = $false; $txtName.Visible = $false
            $lblNetwork.Visible = $true; $txtNetwork.Visible = $true
        } else {
            $lblName.Visible = $true; $txtName.Visible = $true
            $lblNetwork.Visible = $false; $txtNetwork.Visible = $false
        }
    }
    $cmbClass.Add_SelectedIndexChanged($toggleForClass)
    & $toggleForClass

    # helper to compute reverse zone name (supports /8,/16,/24 or plain base IP or already an in-addr.arpa name)
    function Convert-ToReverseZoneName([string]$input) {
        if (-not $input) { return $null }
        $s = $input.Trim()
        if ($s -match 'in-addr\.arpa$') { return $s.TrimEnd('.') }
        if ($s -match '^(?:\d{1,3}\.){3}\d{1,3}(?:\/\d{1,2})?$') {
            if ($s -match '^(?<ip>(?:\d{1,3}\.){3}\d{1,3})\/(?<mask>\d{1,2})$') {
                $ip = $matches.ip; $mask = [int]$matches.mask
            } elseif ($s -match '^(?<ip>(?:\d{1,3}\.){3}\d{1,3})$') {
                $ip = $matches.ip; $mask = 24
            } else { return $null }
            $octets = $ip.Split('.')
            switch ($mask) {
                8 { return "$($octets[0]).in-addr.arpa" }
                16 { return "$($octets[1]).$($octets[0]).in-addr.arpa" }
                24 { return "$($octets[2]).$($octets[1]).$($octets[0]).in-addr.arpa" }
                default { return $null }
            }
        }
        return $null
    }

    $btnOK.Add_Click({
        if ($cmbClass.SelectedItem -eq 'Forward') {
            if (-not $txtName.Text.Trim()) { [System.Windows.Forms.MessageBox]::Show("Zone name required for forward zone.","Validation"); return }
            $zoneObj = [PSCustomObject]@{
                ZoneClass = 'Forward'
                Name = $txtName.Text.Trim()
                Network = $null
                ReverseName = $null
                ZoneType = $cmbType.SelectedItem
                Replication = $cmbRepl.SelectedItem
                DynamicUpdate = $cmbDyn.SelectedItem
            }
            $form.Tag = $zoneObj; $form.Close(); return
        } else {
            $rev = Convert-ToReverseZoneName $txtNetwork.Text.Trim()
            if (-not $rev) { [System.Windows.Forms.MessageBox]::Show("Enter network as CIDR (e.g. 192.168.10.0/24), base IP (192.168.10.0) or reverse zone name (10.168.192.in-addr.arpa). Supported masks: /8,/16,/24.","Validation"); return }
            $zoneObj = [PSCustomObject]@{
                ZoneClass = 'Reverse'
                Name = $null
                Network = $txtNetwork.Text.Trim()
                ReverseName = $rev
                ZoneType = $cmbType.SelectedItem
                Replication = $cmbRepl.SelectedItem
                DynamicUpdate = $cmbDyn.SelectedItem
            }
            $form.Tag = $zoneObj; $form.Close(); return
        }
    })

    $btnCancel.Add_Click({ $form.Tag = $null; $form.Close() })
    [void]$form.ShowDialog()
    return $form.Tag
}

# DNS zone handlers
$ui.BtnAddZone.Add_Click({
    $newZone = Show-ZoneEditor -Zone $null
    if ($newZone) {
        $dnsZonesList.Add($newZone) | Out-Null
        $ui.ListBoxDnsZones.Items.Add((Format-ZoneDisplay $newZone)) | Out-Null
        Append-Log "Added DNS zone: $($newZone.Name)"
    }
})

$ui.BtnEditZone.Add_Click({
    $idx = $ui.ListBoxDnsZones.SelectedIndex
    if ($idx -ge 0 -and $idx -lt $dnsZonesList.Count) {
        $current = $dnsZonesList[$idx]
        $edited = Show-ZoneEditor -Zone $current
        if ($edited) {
            $dnsZonesList[$idx] = $edited
            $ui.ListBoxDnsZones.Items[$idx] = (Format-ZoneDisplay $edited)
            Append-Log "Edited DNS zone: $($edited.Name)"
        }
    } else {
        Append-Log "No DNS zone selected to edit."
    }
})

$ui.BtnRemoveZone.Add_Click({
    if ($ui.ListBoxDnsZones.SelectedIndex -ge 0) {
        for ($i = $ui.ListBoxDnsZones.SelectedIndices.Count - 1; $i -ge 0; $i--) {
            $idx = $ui.ListBoxDnsZones.SelectedIndices[$i]
            $removed = $ui.ListBoxDnsZones.Items[$idx]
            $ui.ListBoxDnsZones.Items.RemoveAt($idx)
            if ($idx -lt $dnsZonesList.Count) { $dnsZonesList.RemoveAt($idx) }
            Append-Log "Removed DNS zone: $removed"
        }
    } else {
        Append-Log "No DNS zone selected to remove."
    }
})

# DHCP scope handlers

$ui.BtnAddScope.Add_Click({

    function Add-LabelTextBoxLocal($top, $labelText, [string]$default) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $labelText
        $lbl.Top = $top; $lbl.Left = 10; $lbl.Width = 120
        $scopeForm.Controls.Add($lbl)

        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Top = $top; $txt.Left = 140; $txt.Width = 240
        if ($default) { $txt.Text = $default }
        $scopeForm.Controls.Add($txt)
        return $txt
    }

    $scopeForm = New-Object System.Windows.Forms.Form
    $scopeForm.Text = "Add DHCP Scope"
    $scopeForm.Width = 420
    $scopeForm.Height = 460
    $scopeForm.StartPosition = "CenterParent"

    $txtName = Add-LabelTextBoxLocal 20 "Scope Name:" "Office LAN"
    $txtStart = Add-LabelTextBoxLocal 60 "Start IP:" "192.168.10.50"
    $txtEnd = Add-LabelTextBoxLocal 100 "End IP:" "192.168.10.200"
    $txtMask = Add-LabelTextBoxLocal 140 "Subnet Mask:" "255.255.255.0"
    $txtGateway = Add-LabelTextBoxLocal 180 "Gateway:" "192.168.10.1"
    $txtDns = Add-LabelTextBoxLocal 220 "DNS Server:" "192.168.10.10"
    $txtLease = Add-LabelTextBoxLocal 260 "Lease Duration (Days):" "8"

    # Exclusions button + label to show count
    $btnExclusions = New-Object System.Windows.Forms.Button
    $btnExclusions.Text = "Exclusions..."
    $btnExclusions.Top = 300; $btnExclusions.Left = 140; $btnExclusions.Width = 120
    $scopeForm.Controls.Add($btnExclusions)

    $lblExCount = New-Object System.Windows.Forms.Label
    $lblExCount.Text = "Excluded: 0"
    $lblExCount.Top = 304; $lblExCount.Left = 270; $lblExCount.Width = 120
    $scopeForm.Controls.Add($lblExCount)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Add"; $btnOK.Top = 340; $btnOK.Left = 140; $btnOK.Width = 100
    $scopeForm.Controls.Add($btnOK)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"; $btnCancel.Top = 340; $btnCancel.Left = 260; $btnCancel.Width = 100
    $scopeForm.Controls.Add($btnCancel)

    $state = [PSCustomObject]@{ Exclusions = @() }

    $state.Exclusions = @()
    $lblExCount.Text = "Excluded: $($state.Exclusions.Count)"
    $btnExclusions.Add_Click({
        $res = Show-ExclusionsEditor -Initial $state.Exclusions
        if ($res -ne $null) {
            if ($res.Count -eq 1 -and ($res[0] -is [System.Array])) { $res = $res[0] }
            $state.Exclusions = @($res)
            $lblExCount.Text = "Excluded: $($state.Exclusions.Count)"
        }
    })

    $btnOK.Add_Click({
        $ipv4 = '^\s*(?:25[0-5]|2[0-4]\d|1?\d{1,2})(?:\.(?:25[0-5]|2[0-4]\d|1?\d{1,2})){3}\s*$'
        if (-not $txtName.Text.Trim()) { [System.Windows.Forms.MessageBox]::Show("Enter scope name.","Validation"); return }
        foreach ($ctrl in @($txtStart,$txtEnd,$txtMask,$txtGateway,$txtDns)) {
            if (-not ($ctrl.Text -match $ipv4)) {
                [System.Windows.Forms.MessageBox]::Show("Invalid IP format in one of the fields.`nPlease use dotted IPv4.","Validation")
                return
            }
        }
        if (-not ([int]::TryParse($txtLease.Text,[ref]0))) {
            [System.Windows.Forms.MessageBox]::Show("Lease must be an integer number of days.","Validation"); return
        }

        $scope = @{
            Name = $txtName.Text
            StartIP = $txtStart.Text
            EndIP = $txtEnd.Text
            SubnetMask = $txtMask.Text
            Gateway = $txtGateway.Text
            DnsServer = $txtDns.Text
            LeaseDuration = $txtLease.Text
            Exclusions = $state.Exclusions
        }

        $scopesList.Add($scope) | Out-Null
        $exCount = Get-ExclusionCount $scope
        $exListText = if ($exCount -gt 0) { ($scope.Exclusions -join ',') } else { '<none>' }
        $ui.ListBoxScopes.Items.Add("$($scope.Name) - $($scope.StartIP) to $($scope.EndIP) [excl: $exCount => $exListText]") | Out-Null
        Append-Log "Added DHCP scope: $($scope.Name) ($($scope.StartIP) - $($scope.EndIP)) exclusions: $exCount"

        $scopeForm.Close()
    })

    $btnCancel.Add_Click({ $scopeForm.Close() })
    $scopeForm.ShowDialog()
})

# --- Edit Scope handler (opens same form prefilled, including exclusions) ---
$ui.BtnEditScope.Add_Click({
    $idx = $ui.ListBoxScopes.SelectedIndex
    if ($idx -lt 0 -or $idx -ge $scopesList.Count) { Append-Log "No DHCP scope selected to edit."; return }

    $current = $scopesList[$idx]

    function Add-LabelTextBoxLocal2($top, $labelText, $value) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $labelText
        $lbl.Top = $top; $lbl.Left = 10; $lbl.Width = 120
        $scopeForm.Controls.Add($lbl)
        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Top = $top; $txt.Left = 140; $txt.Width = 240
        $txt.Text = $value
        $scopeForm.Controls.Add($txt)
        return $txt
    }

    $scopeForm = New-Object System.Windows.Forms.Form
    $scopeForm.Text = "Edit DHCP Scope"
    $scopeForm.Width = 420
    $scopeForm.Height = 460
    $scopeForm.StartPosition = "CenterParent"

    $txtName = Add-LabelTextBoxLocal2 20 "Scope Name:" $current.Name
    $txtStart = Add-LabelTextBoxLocal2 60 "Start IP:" $current.StartIP
    $txtEnd = Add-LabelTextBoxLocal2 100 "End IP:" $current.EndIP
    $txtMask = Add-LabelTextBoxLocal2 140 "Subnet Mask:" $current.SubnetMask
    $txtGateway = Add-LabelTextBoxLocal2 180 "Gateway:" $current.Gateway
    $txtDns = Add-LabelTextBoxLocal2 220 "DNS Server:" $current.DnsServer
    $txtLease = Add-LabelTextBoxLocal2 260 "Lease Duration (Days):" $current.LeaseDuration

    $btnExclusions = New-Object System.Windows.Forms.Button
    $btnExclusions.Text = "Exclusions..."
    $btnExclusions.Top = 300; $btnExclusions.Left = 140; $btnExclusions.Width = 120
    $scopeForm.Controls.Add($btnExclusions)

    $lblExCount = New-Object System.Windows.Forms.Label
    $lblExCount.Text = "Excluded: 0"
    $lblExCount.Top = 304; $lblExCount.Left = 270; $lblExCount.Width = 120
    $scopeForm.Controls.Add($lblExCount)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Save"; $btnOK.Top = 340; $btnOK.Left = 140; $btnOK.Width = 100
    $scopeForm.Controls.Add($btnOK)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"; $btnCancel.Top = 340; $btnCancel.Left = 260; $btnCancel.Width = 100
    $scopeForm.Controls.Add($btnCancel)

    $state = [PSCustomObject]@{ Exclusions = @() }
    if ($current.Exclusions) {
        # defensively unwrap nested arrays if present
        if ($current.Exclusions.Count -eq 1 -and ($current.Exclusions[0] -is [System.Array])) {
            $state.Exclusions = $current.Exclusions[0]
        } else {
            $state.Exclusions = $current.Exclusions
        }
    }
    $lblExCount.Text = "Excluded: $($state.Exclusions.Count)"

    $btnExclusions.Add_Click({
        $res = Show-ExclusionsEditor -Initial $state.Exclusions
        if ($res -ne $null) {
            if ($res.Count -eq 1 -and ($res[0] -is [System.Array])) { $res = $res[0] }
            $state.Exclusions = @($res)
            $lblExCount.Text = "Excluded: $($state.Exclusions.Count)"
        }
    })

    $btnOK.Add_Click({
        $ipv4 = '^\s*(?:25[0-5]|2[0-4]\d|1?\d{1,2})(?:\.(?:25[0-5]|2[0-4]\d|1?\d{1,2})){3}\s*$'
        if (-not $txtName.Text.Trim()) { [System.Windows.Forms.MessageBox]::Show("Enter scope name.","Validation"); return }
        foreach ($ctrl in @($txtStart,$txtEnd,$txtMask,$txtGateway,$txtDns)) {
            if (-not ($ctrl.Text -match $ipv4)) {
                [System.Windows.Forms.MessageBox]::Show("Invalid IP format in one of the fields.`nPlease use dotted IPv4.","Validation")
                return
            }
        }
        if (-not ([int]::TryParse($txtLease.Text,[ref]0))) {
            [System.Windows.Forms.MessageBox]::Show("Lease must be an integer number of days.","Validation"); return
        }

        $edited = @{
            Name = $txtName.Text
            StartIP = $txtStart.Text
            EndIP = $txtEnd.Text
            SubnetMask = $txtMask.Text
            Gateway = $txtGateway.Text
            DnsServer = $txtDns.Text
            LeaseDuration = $txtLease.Text
            Exclusions = $state.Exclusions
        }

        $scopesList[$idx] = $edited
        $exCount = Get-ExclusionCount $edited
        $exListText = if ($exCount -gt 0) { ($edited.Exclusions -join ',') } else { '<none>' }
        $ui.ListBoxScopes.Items[$idx] = "$($edited.Name) - $($edited.StartIP) to $($edited.EndIP) [excl: $exCount => $exListText]"
        Append-Log "Edited DHCP scope: $($edited.Name) ($($edited.StartIP) - $($edited.EndIP)) exclusions: $exCount"
        $scopeForm.Close()
    })

    $btnCancel.Add_Click({ $scopeForm.Close() })
    $scopeForm.ShowDialog()
})

$ui.BtnRemoveScope.Add_Click({
    if ($ui.ListBoxScopes.SelectedIndex -ge 0) {
        for ($i = $ui.ListBoxScopes.SelectedIndices.Count - 1; $i -ge 0; $i--) {
            $idx = $ui.ListBoxScopes.SelectedIndices[$i]
            $removedItem = $ui.ListBoxScopes.Items[$idx]
            $ui.ListBoxScopes.Items.RemoveAt($idx)
            if ($idx -lt $scopesList.Count) { $scopesList.RemoveAt($idx) }
            Append-Log "Removed DHCP scope: $removedItem"
        }
    } else {
        Append-Log "No DHCP scope selected to remove."
    }
})
# Placeholder functions (paste your real remote logic here)
# powershell
function Get-RemoteInstallStatus {
    param($ServerIP, $Username, $Password)
    # build credential
    $secure = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($Username, $secure)

    if (-not (Test-Connection -ComputerName $ServerIP -Count 1 -Quiet)) {
        return @{
            DnsInstalled = $false
            DhcpInstalled = $false
            DnsStatus = $null
            DhcpStatus = $null
            DnsZoneCount = 0
            DhcpScopeCount = 0
            DhcpAuthorized = $false
            Message = "Host unreachable (ICMP failed). Check network/hostname."
        }
    }

    try {
        $res = Invoke-Command -ComputerName $ServerIP -Credential $cred -ErrorAction Stop -ScriptBlock {
            # On remote: check features and basic objects
            $dnsFeature = Get-WindowsFeature -Name DNS -ErrorAction SilentlyContinue
            $dhcpFeature = Get-WindowsFeature -Name DHCP -ErrorAction SilentlyContinue

            $zones = @()
            if (Get-Command -Name Get-DnsServerZone -ErrorAction SilentlyContinue) {
                $zones = (Get-DnsServerZone -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty ZoneName
            }

            $scopes = @()
            if (Get-Command -Name Get-DhcpServerv4Scope -ErrorAction SilentlyContinue) {
                $scopes = (Get-DhcpServerv4Scope -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty Name
            }

            $authorized = $false
            if (Get-Command -Name Get-DhcpServerInDC -ErrorAction SilentlyContinue) {
                try { $authorized = (Get-DhcpServerInDC -ErrorAction SilentlyContinue) -ne $null } catch { $authorized = $false }
            }

            return @{
                DnsInstalled = ($dnsFeature -and $dnsFeature.Installed)
                DhcpInstalled = ($dhcpFeature -and $dhcpFeature.Installed)
                DnsStatus = if ($dnsFeature) { $dnsFeature.DisplayName } else { $null }
                DhcpStatus = if ($dhcpFeature) { $dhcpFeature.DisplayName } else { $null }
                DnsZoneCount = $zones.Count
                DhcpScopeCount = $scopes.Count
                DhcpAuthorized = $authorized
                Message = "OK"
            }
        }

        # remote returns hashtable-like object — convert to hashtable if needed
        return @{
            DnsInstalled = $res.DnsInstalled
            DhcpInstalled = $res.DhcpInstalled
            DnsStatus = $res.DnsStatus
            DhcpStatus = $res.DhcpStatus
            DnsZoneCount = $res.DnsZoneCount
            DhcpScopeCount = $res.DhcpScopeCount
            DhcpAuthorized = $res.DhcpAuthorized
            Message = "Connected and queried successfully."
        }
    }
    catch {
        return @{
            DnsInstalled = $false
            DhcpInstalled = $false
            DnsStatus = $null
            DhcpStatus = $null
            DnsZoneCount = 0
            DhcpScopeCount = 0
            DhcpAuthorized = $false
            Message = "Invoke-Command failed: $($_.Exception.Message)"
        }
    }
}



# Wire Check Installation button
$ui.ButtonCheckInstall.Add_Click({
    $serverIP = $ui.TextServer.Text
    $username = $ui.TextUser.Text
    $password = $ui.TextPass.Text

    if (-not $serverIP -or -not $username -or -not $password) {
        $ui.LabelInstallStatus.Text = "Please fill in Server IP, Username, and Password."
        $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }

    $ui.LabelInstallStatus.Text = "Checking installation status..."
    $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Blue
    $ui.Form.Refresh()

    $status = Get-RemoteInstallStatus -ServerIP $serverIP -Username $username -Password $password

    if ($status.DnsInstalled -and $status.DhcpInstalled) {
        $ui.LabelInstallStatus.Text = "Both DNS and DHCP installed."
        $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Green
    } elseif ($status.DnsInstalled -or $status.DhcpInstalled) {
        $ui.LabelInstallStatus.Text = "Partial install detected."
        $ui.LabelInstallStatus.Text += " DNS: $($status.DnsInstalled), DHCP: $($status.DhcpInstalled)."
        $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Orange
    } else {
        $ui.LabelInstallStatus.Text = $status.Message
        $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Red
    }
})

# Wire Configure Server button (collect lists and forwarder/suffix)
$ui.ButtonCreate.Add_Click({
    $serverIP = $ui.TextServer.Text
    $username = $ui.TextUser.Text
    $password = $ui.TextPass.Text

    if (-not $serverIP -or -not $username -or -not $password) {
        Append-Log "Server, username and password are required."
        return
    }

    $ui.LabelInstallStatus.Text = "Configuring server... Please wait."
    $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Blue
    $ui.Form.Refresh()

    $dnsZones = @()
    for ($i=0; $i -lt $ui.ListBoxDnsZones.Items.Count; $i++) { $dnsZones += $ui.ListBoxDnsZones.Items[$i] }

    # Use the actual scope objects (so Exclusions property is preserved)
    $scopes = $scopesList
    Write-Host "scopelist " $scopes

    $dnsForwarder = $ui.TextDnsForwarder.Text
    $dnsSuffix = $ui.TextDnsSuffix.Text

    $result = Configure-RemoteServer -ServerIP $serverIP -Username $username -Password $password -DnsForwarder $dnsForwarder -DnsSuffix $dnsSuffix -Scopes $scopes -DnsZones $dnsZones

    if ($result -is [array]) { $ui.LabelInstallStatus.Text = ($result -join "`n") } else { $ui.LabelInstallStatus.Text = $result }
    $ui.LabelInstallStatus.ForeColor = [System.Drawing.Color]::Green
    Append-Log "Configure result: $result"
})

# Show the form
$ui.Form.ShowDialog()
$ui.Form.Dispose()