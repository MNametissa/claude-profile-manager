#!/bin/bash
# Claude Profile Manager Installer
# Installs the profile manager globally for the current user

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER="$SCRIPT_DIR/claude-profile-manager.sh"
INSTALL_DIR="$HOME/.local/share/claude-profile-manager"
INSTALL_SCRIPT="$INSTALL_DIR/claude-profile-manager.sh"

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
echo ""

# Check if profile manager script exists
if [[ ! -f "$PROFILE_MANAGER" ]]; then
    echo "Error: Profile manager script not found at $PROFILE_MANAGER" >&2
    exit 1
fi

# Check if old embedded installation exists
if grep -q "# Claude Profile Manager - START" "$SHELL_RC" 2>/dev/null; then
    echo "⚠️  Old embedded installation detected in $SHELL_RC"
    echo "   Run: bash $(dirname "$0")/clean.sh"
    echo ""
    exit 1
fi

# Check if source line already exists
if grep -q "source.*claude-profile-manager.sh" "$SHELL_RC" 2>/dev/null; then
    echo "Source line already present in $SHELL_RC"
else
    echo "Adding source line to $SHELL_RC..."
    cat >> "$SHELL_RC" << EOF

# Claude Profile Manager
[[ -f "$INSTALL_SCRIPT" ]] && source "$INSTALL_SCRIPT"
EOF
    echo "✓ Source line added"
fi

# Install scripts to ~/.local/share
echo "Installing scripts to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/examples/agents"
mkdir -p "$INSTALL_DIR/examples/skills"
cp "$PROFILE_MANAGER" "$INSTALL_SCRIPT"
[[ -f "$SCRIPT_DIR/install.sh" ]] && cp "$SCRIPT_DIR/install.sh" "$INSTALL_DIR/install.sh"
[[ -f "$SCRIPT_DIR/clean.sh" ]] && cp "$SCRIPT_DIR/clean.sh" "$INSTALL_DIR/clean.sh"
[[ -d "$SCRIPT_DIR/lib" ]] && cp "$SCRIPT_DIR/lib/"*.sh "$INSTALL_DIR/lib/"
[[ -d "$SCRIPT_DIR/examples/agents" ]] && cp "$SCRIPT_DIR/examples/agents/"*.md "$INSTALL_DIR/examples/agents/" 2>/dev/null || true
[[ -d "$SCRIPT_DIR/examples/skills" ]] && cp "$SCRIPT_DIR/examples/skills/"*.md "$INSTALL_DIR/examples/skills/" 2>/dev/null || true
chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null || true

echo ""
echo "✓ Installed successfully!"
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

# Ask to reload now
read -p "Reload shell now? [Y/n] " -n 1 -r
echo
if [[ -z $REPLY ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Reloading..."
    source "$SHELL_RC"
    echo ""
    echo "✓ Shell reloaded! Claude Profile Manager is ready to use."
    echo ""
    echo "Try: claude-profiles help"
else
    echo ""
    echo "Remember to run: source $SHELL_RC"
fi
