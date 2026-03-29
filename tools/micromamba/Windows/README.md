Windows `micromamba` local fallback
===================================

Place `micromamba-win-64.exe` in this directory when you want Windows deployment
to reuse a repo-local binary instead of downloading over HTTPS.

Expected filename:

- `micromamba-win-64.exe`

Behavior:

- During PowerShell bootstrap, MSE checks `MSE_MICROMAMBA_EXE_PATH` first.
- If that variable is not set, MSE then checks this repo path:
  `tools/micromamba/Windows/micromamba-win-64.exe`
- If the file exists, it is copied to:
  `%USERPROFILE%\AppData\Local\micromamba\micromamba.exe`

This is mainly for Windows hosts that can browse normally but fail command-line
TLS downloads.
