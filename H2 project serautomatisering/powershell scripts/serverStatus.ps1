$cred = Get-Credential
$serverIP = Read-Host("Enter the server IP address")
$session = New-PSSession -ComputerName $serverIP -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {
    function Get-ServerStatusCim
    {

        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        Write-Host "OS: $( $osInfo.Caption )"
        Write-Host "Version: $( $osInfo.Version )"
        Write-Host "Build: $( $osInfo.BuildNumber )"

        Write-Host("----------------------------------------")
        Write-Host "System Information:"
        $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty LoadPercentage
        $avgCpu = [math]::Round(($cpu | Measure-Object -Average).Average, 2)
        Write-Host "CPU Load: $avgCpu %"

        # RAM Usage
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)

        # Storage Usage
        $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
            [PSCustomObject]@{
                DeviceID = $_.DeviceID
                SizeGB = [math]::Round($_.Size / 1GB, 2)
                FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
                UsedGB = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
            }
        }

        Write-Host "CPU Load per core: $cpu %"
        Write-Host "RAM: $usedRAM GB used / $totalRAM GB total"
        Write-Host "Drives:"
        $drives | Format-Table -AutoSize


    }
    Get-ServerStatusCim;
}

