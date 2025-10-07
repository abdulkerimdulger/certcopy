# Certificate Copier

A bash script for macOS that automatically manages certificate files. It finds the latest `certs*.zip` file in your Downloads folder (supports various browser suffixes) and copies its certificates to your specified directory.

## Features

- Automatically finds the latest `certs*.zip` file in Downloads (supports various browser suffixes like certs-2.zip, certs(65).zip, etc.)
- Cleans target directory and copies new certificates
- Interactive setup on first run
- Secure handling of temporary files
- Easy-to-use command for ZSH shell

## Installation

One-command installation:
```bash
bash cert_copier.sh --install
```

This will:
1. Add the `certcopy` command to your ZSH shell
2. Show setup instructions

## Usage

Basic commands:
```bash
certcopy              # Copy certificates
certcopy --config     # Show current settings
certcopy --reset      # Reset settings
certcopy --help       # Show all commands
```

On first run:
1. You'll be asked for the target directory path
2. Settings will be saved to `~/.cert_copier_config`
3. Certificates will be copied

On subsequent runs:
1. Latest `certs*.zip` file is found in Downloads (by creation date)
2. Certificates are extracted to a temporary directory
3. Target directory is cleaned
4. New certificates are copied
5. Temporary files are cleaned up
6. Success message shows which file was used

## Supported File Names

The script supports various browser download naming patterns:

- `certs.zip` (no suffix)
- `certs-2.zip` (Safari style)
- `certs(65).zip` (Firefox style)
- `certs-anything.zip` (other browsers)
- Any file starting with `certs` and ending with `.zip`

The script automatically selects the **most recently created** file.

## Configuration

- Config file: `~/.cert_copier_config`
- Command shortcut: `certcopy` (for ZSH)
- Source files: `~/Downloads/certs*.zip` (latest by creation date)

## Requirements

- macOS
- ZSH shell
- `unzip` command (pre-installed on macOS) 