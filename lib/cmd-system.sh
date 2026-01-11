# System commands

cmd_self_uninstall() {
    echo "This will remove Claude Profile Manager."
    echo ""
    echo "Will remove:"
    echo "  - Source line from shell config"
    echo "  - $CLAUDE_INSTALL_DIR/"
    echo ""
    echo "Will NOT remove:"
    echo "  - Your profiles (~/.claude-*)"
    echo "  - Global agents/skills (~/.claude-shared/)"
    echo ""
    read -p "Continue? [y/N] " -r
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    # Detect shell config
    local shell_rc="$HOME/.bashrc"
    [[ -n "$ZSH_VERSION" || "$SHELL" == *"zsh"* ]] && shell_rc="$HOME/.zshrc"

    # Remove source line
    if grep -q "claude-profile-manager" "$shell_rc" 2>/dev/null; then
        sed -i '/# Claude Profile Manager/d' "$shell_rc"
        sed -i '/claude-profile-manager/d' "$shell_rc"
        echo "✓ Removed from $shell_rc"
    fi

    # Remove install directory
    if [[ -d "$CLAUDE_INSTALL_DIR" ]]; then
        rm -rf "$CLAUDE_INSTALL_DIR"
        echo "✓ Removed $CLAUDE_INSTALL_DIR"
    fi

    echo ""
    echo "✓ Uninstalled. Restart your shell or run: source $shell_rc"
    echo ""
    echo "Your profiles are still at ~/.claude-*"
    echo "To use them without the manager:"
    echo "  CLAUDE_CONFIG_DIR=~/.claude-<name> claude"
}
