# Vendored clashctl

This directory vendors the control plane from:

- Repository: `https://github.com/hermanzhaozzzz/clash-for-linux-install`
- Upstream base: `https://github.com/nelvko/clash-for-linux-install`
- Snapshot commit: `220cec8d6d8af46dcff7970d1eced10765f8698d`
- License: MIT, preserved in `LICENSE`

MSE uses `mse-deploy.sh` instead of the upstream installer so deploy is
idempotent, does not edit shell rc files, and does not overwrite subscriptions
or generated runtime state. Architecture-specific binaries are installed in
the repository `bin/`; downloads and mutable state stay under this directory in
Git-ignored `cache/` and `state/` directories.
