$cred = Get-Credential
$session = New-PSSession -ComputerName "10.14.2.56" -Port 4335 -Credential $cred -Authentication Default -UseSSL:$false

Invoke-Command -Session $session -ScriptBlock {



}