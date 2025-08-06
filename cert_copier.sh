#!/bin/bash

# Configuration
CONFIG_FILE="$HOME/.cert_copier_config"
DOWNLOADS_DIR="$HOME/Downloads"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# Function to show initial setup message
show_initial_setup() {
    echo
    echo "Certificate Copier - Installation Complete"
    echo "----------------------------------------"
    echo "✓ Shortcut 'certcopy' has been added to your shell"
    echo
    echo "You can now use these commands:"
    echo "   certcopy          # Copy certificates"
    echo "   certcopy --help   # Show all commands"
    echo
    echo "Note: You may need to open a new terminal to use the commands"
    echo
}

# Function to install the script
install_script() {
    local zshrc="$HOME/.zshrc"
    local alias_line="alias certcopy=\"$SCRIPT_PATH\""
    
    echo
    # Check if alias already exists
    if grep -q "alias certcopy=" "$zshrc" 2>/dev/null; then
        echo "✓ Shortcut 'certcopy' is already installed"
        echo
    else
        echo "" >> "$zshrc"
        echo "# Certificate Copier shortcut" >> "$zshrc"
        echo "$alias_line" >> "$zshrc"
        echo "✓ Installing shortcut 'certcopy'..."
        echo
    fi

    show_initial_setup
    exit 0
}

# Function to show usage
show_usage() {
    echo
    echo "Certificate Copier - Manage certificate files from Downloads"
    echo
    echo "Usage: certcopy [OPTIONS]"
    echo
    echo "Description:"
    echo "  Automatically finds the latest certs(XX).zip file in Downloads folder"
    echo "  and copies its contents to a configured target directory."
    echo
    echo "Options:"
    echo "  No options     Run the normal certificate copy process"
    echo "  --install      Install the script and add shortcut to shell"
    echo "  --config       Show current configuration status"
    echo "  --reset        Reset configuration and prompt for new target path"
    echo "  --help         Show this help message"
    echo
    echo "First Run:"
    echo "  First install the script:"
    echo "    bash $SCRIPT_PATH --install"
    echo
    echo "  Then use these commands:"
    echo "    certcopy              # Copy certificates from latest zip file"
    echo "    certcopy --config     # Show current settings"
    echo "    certcopy --reset      # Start fresh with new target path"
    echo
    echo "Configuration:"
    echo "  Config file: ~/.cert_copier_config"
    echo "  Command shortcut: 'certcopy' (added to ~/.zshrc)"
    echo "  Source files: ~/Downloads/certs(XX).zip"
    echo
}

# Function to show current configuration
show_config() {
    echo
    if [ -f "$CONFIG_FILE" ]; then
        echo "Current Configuration:"
        echo "--------------------"
        echo "Config file: $CONFIG_FILE"
        source "$CONFIG_FILE"
        if [ -n "$TARGET_PATH" ]; then
            echo "Target path: $TARGET_PATH"
            if [ -d "$TARGET_PATH" ]; then
                echo "Status: Directory exists"
                local file_count=$(ls -1 "$TARGET_PATH" | wc -l | tr -d ' ')
                echo "Files in target: $file_count"
            else
                echo "Status: Directory does not exist"
            fi
        else
            echo "Target path: Not set"
        fi
        echo
    else
        echo "No configuration file found at: $CONFIG_FILE"
        if [ "$1" = "show_only" ]; then
            echo "Run 'certcopy' without arguments to create a new configuration."
            echo
            exit 0
        fi
    fi
}

# Function to reset configuration
reset_config() {
    echo
    if [ -f "$CONFIG_FILE" ]; then
        rm "$CONFIG_FILE"
        echo "Configuration has been reset."
        echo "Next run will prompt for a new target path."
        echo
        exit 0
    else
        echo "No configuration file found. Nothing to reset."
        echo
        exit 0
    fi
}

# Function to validate and get target path
get_valid_target_path() {
    local input_path=""
    while [ -z "$input_path" ]; do
        echo
        read -p "Please enter the target path for certificates: " input_path
        
        # Remove leading/trailing whitespace
        input_path=$(echo "$input_path" | xargs)
        
        if [ -z "$input_path" ]; then
            echo "Error: Target path cannot be empty. Please try again."
            continue
        fi
        
        # Expand ~ if present
        input_path="${input_path/#\~/$HOME}"
        
        # Validate if path is absolute
        if [[ "$input_path" != /* ]]; then
            echo "Error: Please provide an absolute path (starting with /)."
            input_path=""
            continue
        fi
    done
    echo "$input_path"
}

# Function to create config file
create_config_file() {
    local target_path="$1"
    local config_dir=$(dirname "$CONFIG_FILE")
    
    # Ensure config directory exists
    mkdir -p "$config_dir"
    
    # Create config file with proper permissions
    echo "# Certificate Copier Configuration" > "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo
        echo "Error: Failed to create configuration file at $CONFIG_FILE"
        echo
        exit 1
    fi
    
    echo "TARGET_PATH=\"$target_path\"" >> "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo
        echo "Error: Failed to write to configuration file"
        rm -f "$CONFIG_FILE"
        echo
        exit 1
    fi
    
    # Set proper permissions
    chmod 600 "$CONFIG_FILE"
    
    echo
    echo "Configuration saved to $CONFIG_FILE"
    echo
}

# Function to prompt for target path
prompt_target_path() {
    echo
    echo "No configuration found. Initial setup required."
    local new_path
    new_path=$(get_valid_target_path)
    create_config_file "$new_path"
    TARGET_PATH="$new_path"
}

# Function to load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        if [ -z "$TARGET_PATH" ]; then
            prompt_target_path
        fi
    else
        prompt_target_path
    fi
    
    # Double check TARGET_PATH is set and valid
    if [ -z "$TARGET_PATH" ]; then
        echo
        echo "Error: Target path is not set. This should not happen."
        echo
        exit 1
    fi
}

# Function to find the latest certs zip file
find_latest_certs_zip() {
    local latest_zip
    # Find all matching files and sort by the number in parentheses
    latest_zip=$(find "$DOWNLOADS_DIR" -maxdepth 1 -name "certs(*).zip" | perl -ne 'if(/certs\((\d+)\)\.zip/){print "$1 $_"}' | sort -n | tail -n1 | cut -d" " -f2-)
    
    if [ -z "$latest_zip" ]; then
        echo
        echo "No certificate zip file found in Downloads directory."
        echo
        exit 1
    fi
    
    # Trim any whitespace
    latest_zip=$(echo "$latest_zip" | xargs)
    echo "$latest_zip"
}

# Clean target directory
clean_target_dir() {
    TARGET_PATH=$(echo "$TARGET_PATH" | tr -d '\n\r' | sed 's/\/\//\//g')
    
    if [ -z "$TARGET_PATH" ]; then
        echo "Error: Target path is not set"
        exit 1
    fi

    mkdir -p "$(dirname "$TARGET_PATH")"
    rm -rf "$TARGET_PATH"
    mkdir -p "$TARGET_PATH"
    chmod 755 "$TARGET_PATH"
}

# Parse command line arguments
if [ $# -gt 0 ]; then
    case $1 in
        --install)
            install_script
            exit 0
            ;;
        --reset)
            reset_config
            exit 0
            ;;
        --config)
            show_config "show_only"
            exit 0
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
fi

# Main execution
main() {
    load_config
    local certs_zip=$(find_latest_certs_zip)
    local temp_dir=$(mktemp -d)

    clean_target_dir
    
    unzip -q "$certs_zip" -d "$temp_dir" || {
        rm -rf "$temp_dir"
        echo "Error: Failed to unzip certificate file"
        exit 1
    }

    cp "$temp_dir"/* "$TARGET_PATH"/ 2>/dev/null || {
        rm -rf "$temp_dir"
        echo "Error: Failed to copy certificates"
        exit 1
    }

    rm -rf "$temp_dir"
    echo "Certificates installed successfully"
}

main "$@" 