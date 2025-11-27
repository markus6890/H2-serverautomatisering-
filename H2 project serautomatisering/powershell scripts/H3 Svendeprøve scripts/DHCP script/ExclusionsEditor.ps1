# powershell
# File: `ExclusionsEditor.ps1` (replace Show-ExclusionsEditor with this)
function Show-ExclusionsEditor {
    param([object[]]$Initial)

    $ipv4 = '^\s*(?:25[0-5]|2[0-4]\d|1?\d{1,2})(?:\.(?:25[0-5]|2[0-4]\d|1?\d{1,2})){3}\s*$'

    $exList = New-Object System.Collections.ArrayList

    # Flatten incoming Initial (handles nested arrays/arraylists)
    if ($Initial) {
        foreach ($item in $Initial) {
            if ($null -eq $item) { continue }
            if ($item -is [System.Array] -or ($item -is [System.Collections.IEnumerable] -and -not ($item -is [string]))) {
                foreach ($sub in $item) { $exList.Add($sub) | Out-Null }
            } else {
                $exList.Add($item) | Out-Null
            }
        }
    }

    # build form (unchanged)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Edit Exclusions"
    $form.Width = 480
    $form.Height = 360
    $form.StartPosition = "CenterParent"

    $lst = New-Object System.Windows.Forms.ListBox
    $lst.Top = 10; $lst.Left = 10; $lst.Width = 340; $lst.Height = 240
    $form.Controls.Add($lst)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Top = 260; $txt.Left = 10; $txt.Width = 340
    $form.Controls.Add($txt)

    $btnAdd = New-Object System.Windows.Forms.Button
    $btnAdd.Text = "Add IP"
    $btnAdd.Top = 260; $btnAdd.Left = 360; $btnAdd.Width = 90
    $form.Controls.Add($btnAdd)

    $btnAddRange = New-Object System.Windows.Forms.Button
    $btnAddRange.Text = "Add Range (start-end)"
    $btnAddRange.Top = 300; $btnAddRange.Left = 10; $btnAddRange.Width = 220
    $form.Controls.Add($btnAddRange)

    $btnEdit = New-Object System.Windows.Forms.Button
    $btnEdit.Text = "Edit"
    $btnEdit.Top = 300; $btnEdit.Left = 240; $btnEdit.Width = 80
    $form.Controls.Add($btnEdit)

    $btnRemove = New-Object System.Windows.Forms.Button
    $btnRemove.Text = "Remove"
    $btnRemove.Top = 300; $btnRemove.Left = 330; $btnRemove.Width = 80
    $form.Controls.Add($btnRemove)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "OK"
    $btnOK.Top = 300; $btnOK.Left = 420; $btnOK.Width = 40
    $form.Controls.Add($btnOK)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Top = 300; $btnCancel.Left = 470; $btnCancel.Width = 40
    $form.Controls.Add($btnCancel)

    # populate list from flattened $exList
    $exList | ForEach-Object { $lst.Items.Add($_) | Out-Null }

    $btnAdd.Add_Click({
        $val = $txt.Text.Trim()
        if (-not $val) { return }
        if ($val -match $ipv4) {
            if ($exList -notcontains $val) {
                $exList.Add($val) | Out-Null
                $lst.Items.Add($val) | Out-Null
                $txt.Clear()
            } else {
                [System.Windows.Forms.MessageBox]::Show("Entry already present.","Validation")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Enter a valid IPv4 address.","Validation")
        }
    })

    $btnAddRange.Add_Click({
        $val = $txt.Text.Trim()
        if (-not $val) { return }
        if ($val -match '^\s*([^-\s]+)\s*-\s*([^-\s]+)\s*$') {
            $a=$matches[1]; $b=$matches[2]
            if (($a -match $ipv4) -and ($b -match $ipv4)) {
                $entry = "$a-$b"
                if ($exList -notcontains $entry) {
                    $exList.Add($entry) | Out-Null
                    $lst.Items.Add($entry) | Out-Null
                    $txt.Clear()
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Range already present.","Validation")
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("Invalid start or end IP.","Validation")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Use `startIP-endIP` format to add a range.","Validation")
        }
    })

    $btnEdit.Add_Click({
        if ($lst.SelectedIndex -lt 0) { return }
        $sel = $lst.SelectedItem
        $input = [Microsoft.VisualBasic.Interaction]::InputBox("Edit exclusion (single IP or start-end):","Edit Exclusion",$sel)
        if ($input -and $input.Trim()) {
            $s = $input.Trim()
            if (($s -match $ipv4) -or ($s -match '^\s*([^-\s]+)\s*-\s*([^-\s]+)\s*$')) {
                $exList[$lst.SelectedIndex] = $s
                $lst.Items[$lst.SelectedIndex] = $s
            } else {
                [System.Windows.Forms.MessageBox]::Show("Invalid format.","Validation")
            }
        }
    })

    $btnRemove.Add_Click({
        if ($lst.SelectedIndex -lt 0) { return }
        $idx = $lst.SelectedIndex
        $exList.RemoveAt($idx)
        $lst.Items.RemoveAt($idx)
    })

    $btnOK.Add_Click({
        $form.Tag = $true
        $form.Close()
    })
    $btnCancel.Add_Click({
        $form.Tag = $false
        $form.Close()
    })

    [void]$form.ShowDialog()
    if ($form.Tag) {
        Write-Host "Exclusions updated. New list: " $exList.ToArray() $exList.Count
        return $exList.ToArray()
    } else {
        return $null
    }
}