#!/bin/bash
# Removes old embedded Claude Profile Manager from shell config

set -e

# Detect shell
SHELL_RC=""
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

echo "Cleaning old Claude Profile Manager installation"
echo "Config file: $SHELL_RC"
echo ""

if ! grep -q "# Claude Profile Manager - START" "$SHELL_RC" 2>/dev/null; then
    echo "No old installation found."
    exit 0
fi

# Count lines before
lines_before=$(wc -l < "$SHELL_RC")

# Remove old embedded installation
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/# Claude Profile Manager - START/,/# Claude Profile Manager - END/d' "$SHELL_RC"
else
    sed -i '/# Claude Profile Manager - START/,/# Claude Profile Manager - END/d' "$SHELL_RC"
fi

# Count lines after
lines_after=$(wc -l < "$SHELL_RC")
lines_removed=$((lines_before - lines_after))

echo "✓ Removed $lines_removed lines from $SHELL_RC"
echo ""
echo "Now run: bash $(dirname "$0")/install.sh"
