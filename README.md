# Certificate Copier

A bash script for macOS that automatically manages certificate files. It finds the latest `certs(XX).zip` file in your Downloads folder and copies its certificates to your specified directory.

## Features

- Automatically finds the latest `certs(XX).zip` file in Downloads (based on version number)
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
1. Latest `certs(XX).zip` file is found in Downloads
2. Certificates are extracted to a temporary directory
3. Target directory is cleaned
4. New certificates are copied
5. Temporary files are cleaned up

## Configuration

- Config file: `~/.cert_copier_config`
- Command shortcut: `certcopy` (for ZSH)
- Source files: `~/Downloads/certs(XX).zip`

## Requirements

- macOS
- ZSH shell
- `unzip` command (pre-installed on macOS) 