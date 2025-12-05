# powershell
# 1) See current package sources
Get-PackageSource

# 2) Install NuGet provider (if needed)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# 3) Register the official NuGet v3 source if missing
Register-PackageSource -Name NuGet -ProviderName NuGet -Location 'https://api.nuget.org/v3/index.json' -Trusted

# 4) Try Install-Package again (use -Source to force the api.nuget.org endpoint)
Install-Package -Name System.Data.SQLite.Core -ProviderName NuGet -Scope CurrentUser -Source 'https://api.nuget.org/v3/index.json' -Force

# Alternative (if you have .NET SDK and a project): from the project folder
dotnet add package System.Data.SQLite.Core

# Fallback: download package with nuget.exe and load the managed DLL manually
$nugetExe = Join-Path $env:TEMP 'nuget.exe'
Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $nugetExe
& $nugetExe install System.Data.SQLite.Core -OutputDirectory (Join-Path $env:USERPROFILE 'nuget-packages')
# find the managed DLL (example)
Get-ChildItem -Path (Join-Path $env:USERPROFILE 'nuget-packages') -Recurse -Filter 'System.Data.SQLite.dll' | Select-Object -First 1

# Once you have the DLL path, load it:
# Add-Type -Path `C:\path\to\System.Data.SQLite.dll`   # <-- replace with the actual DLL path found above
