# powershell
# File: `UI.ps1`
function New-ServerConfigForm {
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Create Windows DHCP and DNS Server"
    $form.Width = 520
    $form.Height = 820
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    # Server IP
    $labelServer = New-Object System.Windows.Forms.Label
    $labelServer.Text = "Server IP:"
    $labelServer.Top = 20; $labelServer.Left = 20; $labelServer.Width = 120
    $form.Controls.Add($labelServer)

    $textServer = New-Object System.Windows.Forms.TextBox
    $textServer.Top = 20; $textServer.Left = 150; $textServer.Width = 330
    $form.Controls.Add($textServer)

    # Credentials (hidden until server IP entered)
    $labelUser = New-Object System.Windows.Forms.Label
    $labelUser.Text = "Username:"
    $labelUser.Top = 60; $labelUser.Left = 20; $labelUser.Width = 120; $labelUser.Visible = $false
    $form.Controls.Add($labelUser)

    $textUser = New-Object System.Windows.Forms.TextBox
    $textUser.Top = 60; $textUser.Left = 150; $textUser.Width = 330; $textUser.Visible = $false
    $form.Controls.Add($textUser)

    $labelPass = New-Object System.Windows.Forms.Label
    $labelPass.Text = "Password:"
    $labelPass.Top = 100; $labelPass.Left = 20; $labelPass.Width = 120; $labelPass.Visible = $false
    $form.Controls.Add($labelPass)

    $textPass = New-Object System.Windows.Forms.TextBox
    $textPass.Top = 100; $textPass.Left = 150; $textPass.Width = 330; $textPass.UseSystemPasswordChar = $true; $textPass.Visible = $false
    $form.Controls.Add($textPass)

    # DNS forwarder and suffix
    $labelDnsForwarder = New-Object System.Windows.Forms.Label
    $labelDnsForwarder.Text = "DNS Forwarder:"
    $labelDnsForwarder.Top = 140; $labelDnsForwarder.Left = 20; $labelDnsForwarder.Width = 120
    $form.Controls.Add($labelDnsForwarder)

    $textDnsForwarder = New-Object System.Windows.Forms.TextBox
    $textDnsForwarder.Top = 140; $textDnsForwarder.Left = 150; $textDnsForwarder.Width = 330
    $form.Controls.Add($textDnsForwarder)

    $labelDnsSuffix = New-Object System.Windows.Forms.Label
    $labelDnsSuffix.Text = "DNS Suffix:"
    $labelDnsSuffix.Top = 180; $labelDnsSuffix.Left = 20; $labelDnsSuffix.Width = 120
    $form.Controls.Add($labelDnsSuffix)

    $textDnsSuffix = New-Object System.Windows.Forms.TextBox
    $textDnsSuffix.Top = 180; $textDnsSuffix.Left = 150; $textDnsSuffix.Width = 330
    $form.Controls.Add($textDnsSuffix)

    # Install status label
    $labelInstallStatus = New-Object System.Windows.Forms.Label
    $labelInstallStatus.Top = 220; $labelInstallStatus.Left = 20; $labelInstallStatus.Width = 460; $labelInstallStatus.Height = 40
    $labelInstallStatus.ForeColor = [System.Drawing.Color]::Blue
    $form.Controls.Add($labelInstallStatus)

    # DNS Zones list + buttons
    $groupZones = New-Object System.Windows.Forms.GroupBox
    $groupZones.Text = "DNS Zones"
    $groupZones.Top = 270; $groupZones.Left = 20; $groupZones.Width = 460; $groupZones.Height = 140
    $form.Controls.Add($groupZones)

    $listBoxDnsZones = New-Object System.Windows.Forms.ListBox
    $listBoxDnsZones.Top = 20; $listBoxDnsZones.Left = 10; $listBoxDnsZones.Width = 320; $listBoxDnsZones.Height = 100
    $groupZones.Controls.Add($listBoxDnsZones)

    $btnAddZone = New-Object System.Windows.Forms.Button
    $btnAddZone.Text = "Add"; $btnAddZone.Top = 20; $btnAddZone.Left = 340; $btnAddZone.Width = 100
    $groupZones.Controls.Add($btnAddZone)

    $btnRemoveZone = New-Object System.Windows.Forms.Button
    $btnRemoveZone.Text = "Remove"; $btnRemoveZone.Top = 55; $btnRemoveZone.Left = 340; $btnRemoveZone.Width = 100
    $groupZones.Controls.Add($btnRemoveZone)

    $btnEditZone = New-Object System.Windows.Forms.Button
    $btnEditZone.Text = "Edit"; $btnEditZone.Top = 90; $btnEditZone.Left = 340; $btnEditZone.Width = 100
    $groupZones.Controls.Add($btnEditZone)

    # DHCP Scopes list + buttons
    $groupScopes = New-Object System.Windows.Forms.GroupBox
    $groupScopes.Text = "DHCP Scopes"
    $groupScopes.Top = 420; $groupScopes.Left = 20; $groupScopes.Width = 460; $groupScopes.Height = 160
    $form.Controls.Add($groupScopes)

    $listBoxScopes = New-Object System.Windows.Forms.ListBox
    $listBoxScopes.Top = 20; $listBoxScopes.Left = 10; $listBoxScopes.Width = 320; $listBoxScopes.Height = 120
    $groupScopes.Controls.Add($listBoxScopes)

    $btnAddScope = New-Object System.Windows.Forms.Button
    $btnAddScope.Text = "Add"; $btnAddScope.Top = 20; $btnAddScope.Left = 340; $btnAddScope.Width = 100
    $groupScopes.Controls.Add($btnAddScope)

    $btnRemoveScope = New-Object System.Windows.Forms.Button
    $btnRemoveScope.Text = "Remove"; $btnRemoveScope.Top = 55; $btnRemoveScope.Left = 340; $btnRemoveScope.Width = 100
    $groupScopes.Controls.Add($btnRemoveScope)

    $btnEditScope = New-Object System.Windows.Forms.Button
    $btnEditScope.Text = "Edit"; $btnEditScope.Top = 90; $btnEditScope.Left = 340; $btnEditScope.Width = 100
    $groupScopes.Controls.Add($btnEditScope)

    # Buttons: check install and configure
    $buttonCheckInstall = New-Object System.Windows.Forms.Button
    $buttonCheckInstall.Text = "Check Installation"; $buttonCheckInstall.Top = 600; $buttonCheckInstall.Left = 60; $buttonCheckInstall.Width = 160; $buttonCheckInstall.Enabled = $false
    $form.Controls.Add($buttonCheckInstall)

    $buttonCreate = New-Object System.Windows.Forms.Button
    $buttonCreate.Text = "Configure Server"; $buttonCreate.Top = 600; $buttonCreate.Left = 260; $buttonCreate.Width = 160; $buttonCreate.Enabled = $false
    $form.Controls.Add($buttonCreate)

    # Status / log textbox (multiline)
    $labelLog = New-Object System.Windows.Forms.Label
    $labelLog.Text = "Output / Log:"
    $labelLog.Top = 650; $labelLog.Left = 20; $labelLog.Width = 120
    $form.Controls.Add($labelLog)

    $textStatus = New-Object System.Windows.Forms.TextBox
    $textStatus.Top = 675; $textStatus.Left = 20; $textStatus.Width = 460; $textStatus.Height = 90
    $textStatus.Multiline = $true
    $textStatus.ScrollBars = "Vertical"
    $textStatus.ReadOnly = $true
    $form.Controls.Add($textStatus)

    # Optional helper controls
    $chkAutoAuthorize = New-Object System.Windows.Forms.CheckBox
    $chkAutoAuthorize.Text = "Auto-authorize DHCP"; $chkAutoAuthorize.Top = 595; $chkAutoAuthorize.Left = 20; $chkAutoAuthorize.Width = 200
    $form.Controls.Add($chkAutoAuthorize)

    # Return controls as PSCustomObject for main script to wire events & logic
    $controls = [PSCustomObject]@{
        Form = $form
        TextServer = $textServer
        LabelUser = $labelUser
        TextUser = $textUser
        LabelPass = $labelPass
        TextPass = $textPass
        TextDnsForwarder = $textDnsForwarder
        TextDnsSuffix = $textDnsSuffix
        ButtonCheckInstall = $buttonCheckInstall
        ButtonCreate = $buttonCreate
        LabelInstallStatus = $labelInstallStatus
        ListBoxDnsZones = $listBoxDnsZones
        BtnAddZone = $btnAddZone
        BtnRemoveZone = $btnRemoveZone
        BtnEditZone = $btnEditZone
        ListBoxScopes = $listBoxScopes
        BtnAddScope = $btnAddScope
        BtnRemoveScope = $btnRemoveScope
        BtnEditScope = $btnEditScope
        TextStatus = $textStatus
        CheckAutoAuthorize = $chkAutoAuthorize
    }

    return $controls
}