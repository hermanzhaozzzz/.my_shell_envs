New-Item -ItemType SymbolicLink -Path $PROFILE -Target powershell\Microsoft.PowerShell_profile.ps1
New-Item -ItemType SymbolicLink -Path $HOME\.condarc -Target conda\condarc