# System commands

# ANSI colors
_RED='\033[0;31m'
_YELLOW='\033[0;33m'
_NC='\033[0m' # No Color

cmd_self_uninstall() {
    echo ""
    echo -e "${_RED}╔════════════════════════════════════════╗${_NC}"
    echo -e "${_RED}║           UNINSTALL WARNING            ║${_NC}"
    echo -e "${_RED}╚════════════════════════════════════════╝${_NC}"
    echo ""
    echo -e "${_RED}This will remove Claude Profile Manager.${_NC}"
    echo ""
    echo "Will be DELETED:"
    echo -e "  ${_RED}✗${_NC} Source line from shell config"
    echo -e "  ${_RED}✗${_NC} $CLAUDE_INSTALL_DIR/"
    echo ""
    echo "Will be KEPT:"
    echo "  ✓ Your profiles (~/.claude-*)"
    echo "  ✓ Global agents/skills (~/.claude-shared/)"
    echo ""

    # First confirmation
    echo -e "${_YELLOW}Are you sure you want to uninstall? [y/N]${_NC}"
    read -r
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    # Auto backup
    local backup_file="$HOME/claude-profile-manager-backup-$(date +%Y%m%d-%H%M%S).zip"
    echo ""
    echo "Creating backup..."
    if (cd "$CLAUDE_INSTALL_DIR/.." && zip -rq "$backup_file" "claude-profile-manager" 2>/dev/null); then
        echo "✓ Backup saved to: $backup_file"
    else
        echo -e "${_YELLOW}Warning: Could not create backup${_NC}"
    fi
    echo ""

    # Second confirmation
    echo -e "${_RED}╔════════════════════════════════════════╗${_NC}"
    echo -e "${_RED}║          FINAL CONFIRMATION            ║${_NC}"
    echo -e "${_RED}╚════════════════════════════════════════╝${_NC}"
    echo ""
    echo -e "${_RED}Type 'UNINSTALL' to confirm:${_NC}"
    read -r
    if [[ "$REPLY" != "UNINSTALL" ]]; then
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
    echo "✓ Uninstalled successfully"
    echo ""
    echo "Backup: $backup_file"
    echo ""
    echo "Your profiles are still at ~/.claude-*"
    echo "To use them without the manager:"
    echo "  CLAUDE_CONFIG_DIR=~/.claude-<name> claude"
    echo ""
    echo "Restart your shell or run: source $shell_rc"
}

cmd_trust() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    echo ""
    echo -e "${_RED}╔════════════════════════════════════════╗${_NC}"
    echo -e "${_RED}║           TRUST MODE WARNING           ║${_NC}"
    echo -e "${_RED}╚════════════════════════════════════════╝${_NC}"
    echo ""
    echo -e "${_RED}DANGER: This will skip ALL permission prompts!${_NC}"
    echo ""
    echo "Claude will be able to:"
    echo -e "  ${_RED}✗${_NC} Execute ANY bash command without asking"
    echo -e "  ${_RED}✗${_NC} Delete system files (rm -rf)"
    echo -e "  ${_RED}✗${_NC} Modify critical configs (/etc, ~/.bashrc)"
    echo -e "  ${_RED}✗${_NC} Run sudo commands"
    echo -e "  ${_RED}✗${_NC} Access sensitive files (~/.ssh)"
    echo ""
    echo "Risks:"
    echo "  • Data loss"
    echo "  • System corruption"
    echo "  • Security vulnerabilities"
    echo ""
    echo -e "${_YELLOW}Only enable trust mode if you:${_NC}"
    echo "  1. Fully understand the risks"
    echo "  2. Are working on non-critical systems"
    echo "  3. Have backups of important data"
    echo ""
    echo -e "${_YELLOW}Trust profile '$profile_name'? [y/N]${_NC}"
    read -r
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    touch "$config_dir/.trusted"
    echo ""
    echo -e "${_RED}⚠ Profile '$profile_name' is now TRUSTED${_NC}"
    echo "All permission prompts will be skipped."
    echo ""
    echo "To revert: claude-profiles untrust $profile_name"
}

cmd_untrust() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    if [[ ! -f "$config_dir/.trusted" ]]; then
        echo "Profile '$profile_name' is not trusted"
        return 0
    fi

    rm -f "$config_dir/.trusted"
    echo "✓ Profile '$profile_name' is now untrusted"
    echo "Permission prompts restored"
}
