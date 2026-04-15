#!/bin/bash
# Claude Profile Manager Installer
# Installs the profile manager globally for the current user
#
# Usage:
#   Local:  bash install.sh
#   Remote: curl -fsSL https://raw.githubusercontent.com/MNametissa/claude-profile-manager/main/install.sh | bash

set -e

REPO_URL="https://github.com/MNametissa/claude-profile-manager"
RAW_URL="https://raw.githubusercontent.com/MNametissa/claude-profile-manager/main"
INSTALL_DIR="$HOME/.local/share/claude-profile-manager"

# Detect if running from repo or remote
if [[ -f "$(dirname "${BASH_SOURCE[0]:-$0}")/claude-profile-manager.sh" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    INSTALL_MODE="local"
else
    INSTALL_MODE="remote"
fi

# Detect shell
SHELL_RC=""
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo "Warning: Could not detect shell type. Defaulting to .bashrc"
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

echo "=================================="
echo "Claude Profile Manager Installer"
echo "=================================="
echo ""
echo "Detected shell: $SHELL_NAME"
echo "Config file: $SHELL_RC"
echo "Install location: $INSTALL_DIR"
echo "Install mode: $INSTALL_MODE"
echo ""

# Check if old embedded installation exists
if grep -q "# Claude Profile Manager - START" "$SHELL_RC" 2>/dev/null; then
    echo "Warning: Old embedded installation detected in $SHELL_RC"
    echo "Cleaning up old installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/# Claude Profile Manager - START/,/# Claude Profile Manager - END/d' "$SHELL_RC"
    else
        sed -i '/# Claude Profile Manager - START/,/# Claude Profile Manager - END/d' "$SHELL_RC"
    fi
    echo "Old installation removed."
    echo ""
fi

# Create install directory
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/examples/agents"
mkdir -p "$INSTALL_DIR/examples/skills"

# Download or copy files
if [[ "$INSTALL_MODE" == "remote" ]]; then
    echo "Downloading from GitHub..."

    # Download main script
    curl -fsSL "$RAW_URL/claude-profile-manager.sh" -o "$INSTALL_DIR/claude-profile-manager.sh"

    # Download lib files
    for file in config.sh utils.sh claude-wrapper.sh completions.sh \
                cmd-add.sh cmd-default.sh cmd-help.sh cmd-info.sh \
                cmd-link.sh cmd-list.sh cmd-permissions.sh cmd-remove.sh \
                cmd-share.sh cmd-system.sh cmd-transfer.sh; do
        curl -fsSL "$RAW_URL/lib/$file" -o "$INSTALL_DIR/lib/$file" 2>/dev/null || true
    done

    # Download example files
    curl -fsSL "$RAW_URL/examples/agents/dev-rules.md" -o "$INSTALL_DIR/examples/agents/dev-rules.md" 2>/dev/null || true

    echo "Download complete."
else
    echo "Copying from local repository..."
    cp "$SCRIPT_DIR/claude-profile-manager.sh" "$INSTALL_DIR/"
    [[ -f "$SCRIPT_DIR/install.sh" ]] && cp "$SCRIPT_DIR/install.sh" "$INSTALL_DIR/"
    [[ -f "$SCRIPT_DIR/clean.sh" ]] && cp "$SCRIPT_DIR/clean.sh" "$INSTALL_DIR/"
    [[ -d "$SCRIPT_DIR/lib" ]] && cp "$SCRIPT_DIR/lib/"*.sh "$INSTALL_DIR/lib/"
    [[ -d "$SCRIPT_DIR/examples/agents" ]] && cp "$SCRIPT_DIR/examples/agents/"*.md "$INSTALL_DIR/examples/agents/" 2>/dev/null || true
    [[ -d "$SCRIPT_DIR/examples/skills" ]] && cp "$SCRIPT_DIR/examples/skills/"*.md "$INSTALL_DIR/examples/skills/" 2>/dev/null || true
fi

chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null || true

# Add source line to shell config
INSTALL_SCRIPT="$INSTALL_DIR/claude-profile-manager.sh"
if grep -q "source.*claude-profile-manager.sh" "$SHELL_RC" 2>/dev/null; then
    echo "Source line already present in $SHELL_RC"
else
    echo "Adding source line to $SHELL_RC..."
    cat >> "$SHELL_RC" << EOF

# Claude Profile Manager
[[ -f "$INSTALL_SCRIPT" ]] && source "$INSTALL_SCRIPT"
EOF
    echo "Source line added."
fi

echo ""
echo "Installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Reload your shell:"
echo "     source $SHELL_RC"
echo ""
echo "  2. Create profiles:"
echo "     claude-profiles add work"
echo "     claude-profiles add team1"
echo ""
echo "  3. Use profiles:"
echo "     claude -u work"
echo "     claude -u team1"
echo ""
echo "  4. View all commands:"
echo "     claude-profiles help"
echo ""
echo "=================================="
