# Default profile command

cmd_default() {
    local profile_name="$1"
    if [[ -z "$profile_name" ]]; then
        echo "Current default: $CLAUDE_DEFAULT_PROFILE"
        echo "Usage: claude-profiles default <profile-name>"
        return 0
    fi

    require_profile "$profile_name" || return 1

    local shell_rc="$HOME/.bashrc"
    [[ -n "$ZSH_VERSION" ]] && shell_rc="$HOME/.zshrc"

    echo "Set '$profile_name' as default profile? [Y/n]"
    read -r response
    if [[ -z "$response" || "$response" =~ ^[Yy] ]]; then
        export CLAUDE_DEFAULT_PROFILE="$profile_name"
        echo "✓ Default profile set to: $profile_name (for this session)"
        echo ""
        echo "To make permanent, add to $shell_rc:"
        echo "  export CLAUDE_DEFAULT_PROFILE=\"$profile_name\""
    fi
}
