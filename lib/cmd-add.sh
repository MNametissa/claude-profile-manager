# Add profile command

cmd_add() {
    local profile_name="$1"
    if [[ -z "$profile_name" ]]; then
        echo "Usage: claude-profiles add <profile-name>" >&2
        return 1
    fi

    require_no_profile "$profile_name" || return 1

    local config_dir="$(profile_dir "$profile_name")"
    mkdir -p "$config_dir"

    cat > "$config_dir/settings.json" << 'EOF'
{
  "alwaysThinkingEnabled": false
}
EOF

    if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
        echo "Copy global instructions from default profile? [Y/n]"
        read -r response
        if [[ -z "$response" || "$response" =~ ^[Yy] ]]; then
            cp "$HOME/.claude/CLAUDE.md" "$config_dir/CLAUDE.md"
            echo "Copied CLAUDE.md to new profile"
        fi
    fi

    echo "✓ Created profile: $profile_name"
    echo "  Location: $config_dir"
    echo ""
    echo "Next steps:"
    echo "  1. Run: claude -u $profile_name"
    echo "  2. Authenticate with your account"
}
