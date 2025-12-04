$cred = Get-Credential
$serverIP = Read-Host("Enter the server IP address")
$session = New-PSSession -ComputerName $serverIP -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {

}