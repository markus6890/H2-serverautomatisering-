function Configure-RemoteServer {
    param($ServerIP, $Username, $Password, $DnsForwarder, $DnsSuffix, $Scopes, $DnsZones)

    $secure = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($Username, $secure)

    if (-not (Test-Connection -ComputerName $ServerIP -Count 1 -Quiet)) {
        return "Host unreachable. Cannot configure."
    }

    try {
        $result = Invoke-Command -ComputerName $ServerIP -Credential $cred -ErrorAction Stop -ArgumentList ($DnsForwarder, $DnsSuffix, $Scopes, $DnsZones) -ScriptBlock {
            param($dnsForwarder, $dnsSuffix, $scopes, $dnsZones)
            $needInstallDNS = $false
            $needInstallDHCP = $true
            $log = @()

            # Ensure DNS and DHCP features installed
            try {
                $dns = Get-WindowsFeature -Name DNS
                if (-not $dns.Installed -and $needInstallDNS) {
                    Install-WindowsFeature -Name DNS -IncludeManagementTools -ErrorAction Stop
                    $log += "Installed DNS role."
                } else { $log += "DNS already installed." }
            } catch { $log += "DNS install/check failed: $($_.Exception.Message)" }

            try {
                $dhcp = Get-WindowsFeature -Name DHCP
                if (-not $dhcp.Installed -and $needInstallDHCP) {
                    Install-WindowsFeature -Name DHCP -IncludeManagementTools -ErrorAction Stop
                    $log += "Installed DHCP role."
                } else { $log += "DHCP already installed." }
            } catch { $log += "DHCP install/check failed: $($_.Exception.Message)" }

            # Configure DNS forwarder if provided
            if ($dnsForwarder) {
                if (Get-Command -Name Set-DnsServerForwarder -ErrorAction SilentlyContinue) {
                    try {
                        Set-DnsServerForwarder -IPAddress $dnsForwarder -PassThru -ErrorAction Stop
                        $log += "Configured DNS forwarder: $dnsForwarder"
                    } catch { $log += "Failed to set DNS forwarder: $($_.Exception.Message)" }
                } else {
                    $log += "DNS forwarder cmdlet not available on this server."
                }
            }

            # Create DNS zones (basic primary zones) if provided
            if ($dnsZones) {
                foreach ($z in $dnsZones) {
                    try {
                        if ($z.ZoneClass -eq 'Reverse') {
                            $zoneName = $z.ReverseName
                            if (-not $zoneName) { continue }
                            if (-not (Get-DnsServerZone -Name $zoneName -ErrorAction SilentlyContinue)) {
                                Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$($zoneName).dns" -ErrorAction Stop
                                $log += "Created reverse zone: $($zoneName) (from $($z.Network))"
                            } else {
                                $log += "Reverse zone exists: $($zoneName)"
                            }
                        } else {
                            $zoneName = $z.Name
                            if (-not $zoneName) { continue }
                            if (-not (Get-DnsServerZone -Name $zoneName -ErrorAction SilentlyContinue)) {
                                Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$($zoneName).dns" -ErrorAction Stop
                                $log += "Created forward zone: $($zoneName)"
                            } else {
                                $log += "Forward zone exists: $($zoneName)"
                            }
                        }

                        if ($z.DynamicUpdate) {
                            try {
                                if ($z.ZoneClass -ne 'Reverse') {
                                    Set-DnsServerZone -Name $zoneName -DynamicUpdate $z.DynamicUpdate -ErrorAction Stop
                                    $log += "Set dynamic update $($z.DynamicUpdate) for zone $($zoneName)"
                                }
                            } catch {
                                $log += "Failed to set dynamic update for $($zoneName): $($_.Exception.Message)"
                            }
                        }
                    } catch {
                        $nameOrRev = if ($z.Name) { $z.Name } else { $z.ReverseName }
                        $log += "Failed to create zone $($nameOrRev): $($_.Exception.Message)"
                    }
                }
            }

            # Add DHCP scopes - expects scopes as strings; parsing may be required in real usage
            if ($scopes) {
                foreach ($s in $scopes) {
                    try {

                        $existingScope = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where-Object {
                            $_.Name -eq $s.Name -or ($_.StartRange -eq $s.StartIP -and $_.EndRange -eq $s.EndIP)
                        }

                        if ($existingScope) {
                            $log += "Scope '$($s.Name)' already exists (ScopeId: $($existingScope.ScopeId)). Skipping creation."
                            continue
                        }

                        Add-DhcpServerv4Scope `
                            -Name $s.Name `
                            -StartRange $s.StartIP `
                            -EndRange $s.EndIP `
                            -SubnetMask $s.SubnetMask `
                            -State 'Active' `
                            -LeaseDuration (New-TimeSpan -Days ([int]$s.LeaseDuration)) `
                            -ErrorAction Stop

                        $scopeId = (Get-DhcpServerv4Scope | Where-Object Name -eq $s.Name).ScopeId

                        Set-DhcpServerv4OptionValue -ScopeId $scopeId -Router $s.Gateway -ErrorAction Stop
                        $log += "Set gateway for scope $($s.Name): $($s.Gateway)"

                        $dnsArray = @($s.DnsServer)
                        Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsServer $dnsArray -ErrorAction Stop
                        $log += "Set DNS server for scope $($s.Name): $($s.DnsServer)"

                        if ($s.Exclusions -and $s.Exclusions.Count -gt 0) {
                            foreach ($excl in $s.Exclusions) {
                                if($excl -match '-') {
                                    $parts = $excl -split '-'
                                    $startExcl = $parts[0].Trim()
                                    $endExcl = $parts[1].Trim()
                                    Add-DhcpServerv4ExclusionRange -ScopeId $scopeId -StartRange $startExcl -EndRange $endExcl -ErrorAction Stop
                                    continue
                                }
                                Add-DhcpServerv4ExclusionRange -ScopeId $scopeId -StartRange $excl -EndRange $excl -ErrorAction Stop
                            }
                            $log += "Added exclusions to scope $($s.Name): $($s.Exclusions -join ', ')"
                        }
                        $log += "Requested DHCP scope: $s"
                    } catch {
                        $log += "Error processing scope ${s}: $($_.Exception.Message)"
                    }
                }
            }

            return $log
        }

        # return array of log lines to the UI
        return $result
    }
    catch {
        return "Configure failed: $($_.Exception.Message)"
    }
}
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