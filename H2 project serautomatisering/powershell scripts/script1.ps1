# PowerShell opgaver
# opgave 1
function opg1
{
    $Path = "C:\Users\Bruger\Documents\GitHub\H2-serverautomatisering-";
    New-Item -Path $Path -Name "oprettetfil.txt" -ItemType "File" -Value "Jeg har tilføjet text i filen da den blev oprettet" -WhatIf;
}

# opgave 2
function opg2
{
    Get-Process;

}
# opgave 3
function opg3
{
    $Password = Read-Host -AsSecureString;
    $usersettings = @{
        Name = 'Maya'
        Password = $Password
        FullName = 'Maya blob trorsen'
        Description = 'Accounnnnnt'
    }
    New-LocalUser @usersettings;

}

# opgave 4
function opg4
{
    robocopy C:\Users\Bruger\Documents\GitHub\H2-serverautomatisering- "C:\Users\Bruger\Documents\GitHub\H2-serverautomatisering-\backup" oprettetfil.txt /z

}

#opgave 5
function opg5
{
    Get-NetTCPConnection
}

#opgave 6
function opg6
{
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser;
    Get-ExecutionPolicy -List
}


#opgave 7
function opg7
{

}

#opgave 8
function opg8
{
    Get-AppxPackage;
}

#opgave 9
function opg9
{
    Get-EventLog -LogName System -EntryType Error;
}

#opgave 10
function opg10 {
    Start-Transcript -Path "C:\Users\Bruger\Documents\GitHub\H2-serverautomatisering-\Updatelog.txt" -Append

    try {
        winget upgrade --id Notepad++.Notepad++ --accept-source-agreements --accept-package-agreements
    } catch {
        Write-Output "Opdatering fejlede: $_"
    }

    Stop-Transcript

}

function opg11
{


    for ($i = 1; $i -lt 30; $i++) {
        Write-Host($i);
    }


}
opg11;