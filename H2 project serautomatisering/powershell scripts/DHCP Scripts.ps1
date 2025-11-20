Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Create Windows DHCP and DNS Server"
$form.Width = 450
$form.Height = 650
$form.StartPosition = "CenterScreen"

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

# DHCP Scope Name
$labelScopeName = New-Object System.Windows.Forms.Label
$labelScopeName.Text = "DHCP Scope Name:"
$labelScopeName.Top = 100
$labelScopeName.Left = 20
$labelScopeName.Width = 150
$form.Controls.Add($labelScopeName)

$textScopeName = New-Object System.Windows.Forms.TextBox
$textScopeName.Top = 100
$textScopeName.Left = 180
$textScopeName.Width = 220
$textScopeName.Text = "Office LAN"
$form.Controls.Add($textScopeName)

# DHCP Start IP
$labelStartIP = New-Object System.Windows.Forms.Label
$labelStartIP.Text = "DHCP Start IP:"
$labelStartIP.Top = 140
$labelStartIP.Left = 20
$labelStartIP.Width = 150
$form.Controls.Add($labelStartIP)

$textStartIP = New-Object System.Windows.Forms.TextBox
$textStartIP.Top = 140
$textStartIP.Left = 180
$textStartIP.Width = 220
$textStartIP.Text = "192.168.10.50"
$form.Controls.Add($textStartIP)

# DHCP End IP
$labelEndIP = New-Object System.Windows.Forms.Label
$labelEndIP.Text = "DHCP End IP:"
$labelEndIP.Top = 180
$labelEndIP.Left = 20
$labelEndIP.Width = 150
$form.Controls.Add($labelEndIP)

$textEndIP = New-Object System.Windows.Forms.TextBox
$textEndIP.Top = 180
$textEndIP.Left = 180
$textEndIP.Width = 220
$textEndIP.Text = "192.168.10.200"
$form.Controls.Add($textEndIP)

# Subnet Mask
$labelSubnetMask = New-Object System.Windows.Forms.Label
$labelSubnetMask.Text = "Subnet Mask:"
$labelSubnetMask.Top = 220
$labelSubnetMask.Left = 20
$labelSubnetMask.Width = 150
$form.Controls.Add($labelSubnetMask)

$textSubnetMask = New-Object System.Windows.Forms.TextBox
$textSubnetMask.Top = 220
$textSubnetMask.Left = 180
$textSubnetMask.Width = 220
$textSubnetMask.Text = "255.255.255.0"
$form.Controls.Add($textSubnetMask)

# Gateway/Router
$labelGateway = New-Object System.Windows.Forms.Label
$labelGateway.Text = "Gateway (Router):"
$labelGateway.Top = 260
$labelGateway.Left = 20
$labelGateway.Width = 150
$form.Controls.Add($labelGateway)

$textGateway = New-Object System.Windows.Forms.TextBox
$textGateway.Top = 260
$textGateway.Left = 180
$textGateway.Width = 220
$textGateway.Text = "192.168.10.1"
$form.Controls.Add($textGateway)

# DNS Server for DHCP
$labelDhcpDns = New-Object System.Windows.Forms.Label
$labelDhcpDns.Text = "DNS Server for DHCP:"
$labelDhcpDns.Top = 300
$labelDhcpDns.Left = 20
$labelDhcpDns.Width = 150
$form.Controls.Add($labelDhcpDns)

$textDhcpDns = New-Object System.Windows.Forms.TextBox
$textDhcpDns.Top = 300
$textDhcpDns.Left = 180
$textDhcpDns.Width = 220
$textDhcpDns.Text = "192.168.10.10"
$form.Controls.Add($textDhcpDns)

# DNS Domain Suffix
$labelDnsSuffix = New-Object System.Windows.Forms.Label
$labelDnsSuffix.Text = "DNS Domain Suffix:"
$labelDnsSuffix.Top = 340
$labelDnsSuffix.Left = 20
$labelDnsSuffix.Width = 150
$form.Controls.Add($labelDnsSuffix)

$textDnsSuffix = New-Object System.Windows.Forms.TextBox
$textDnsSuffix.Top = 340
$textDnsSuffix.Left = 180
$textDnsSuffix.Width = 220
$textDnsSuffix.Text = "corp.example.local"
$form.Controls.Add($textDnsSuffix)

# Lease Duration (Days)
$labelLeaseDuration = New-Object System.Windows.Forms.Label
$labelLeaseDuration.Text = "Lease Duration (Days):"
$labelLeaseDuration.Top = 380
$labelLeaseDuration.Left = 20
$labelLeaseDuration.Width = 150
$form.Controls.Add($labelLeaseDuration)

$textLeaseDuration = New-Object System.Windows.Forms.TextBox
$textLeaseDuration.Top = 380
$textLeaseDuration.Left = 180
$textLeaseDuration.Width = 220
$textLeaseDuration.Text = "8"
$form.Controls.Add($textLeaseDuration)

# Username Label and TextBox (hidden initially)
$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username:"
$labelUser.Top = 420
$labelUser.Left = 20
$labelUser.Width = 150
$labelUser.Visible = $false
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Top = 420
$textUser.Left = 180
$textUser.Width = 220
$textUser.Visible = $false
$form.Controls.Add($textUser)

# Password Label and TextBox (hidden initially)
$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Top = 460
$labelPass.Left = 20
$labelPass.Width = 150
$labelPass.Visible = $false
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.Top = 460
$textPass.Left = 180
$textPass.Width = 220
$textPass.UseSystemPasswordChar = $true
$textPass.Visible = $false
$form.Controls.Add($textPass)

# Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Create DHCP & DNS Server"
$button.Top = 510
$button.Left = 150
$button.Width = 150
$button.Enabled = $false
$form.Controls.Add($button)

# Result Label
$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Top = 550
$resultLabel.Left = 20
$resultLabel.Width = 400
$resultLabel.Height = 40
$form.Controls.Add($resultLabel)

$updateFields = {
    if ($textServer.Text) {
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