# Remove profile command

cmd_remove() {
    local profile_name="$1"
    if [[ -z "$profile_name" ]]; then
        echo "Usage: claude-profiles remove <profile-name>" >&2
        return 1
    fi

    if [[ "$profile_name" == "$CLAUDE_DEFAULT_PROFILE" ]] && [[ -z "${FORCE_REMOVE}" ]]; then
        echo "Warning: Attempting to remove default profile '$CLAUDE_DEFAULT_PROFILE'" >&2
        echo "Set FORCE_REMOVE=1 if you're sure" >&2
        return 1
    fi

    require_profile "$profile_name" || return 1

    local config_dir="$(profile_dir "$profile_name")"

    echo "Remove profile '$profile_name'?"
    echo ""
    echo "  1) Remove completely (delete all data)"
    echo "  2) Keep data (only remove credentials)"
    echo "  3) Cancel"
    echo ""
    read -p "Choice [1/2/3]: " -r choice

    case "$choice" in
        1)
            rm -rf "$config_dir"
            echo "✓ Removed profile: $profile_name (all data deleted)"
            ;;
        2)
            rm -f "$config_dir/.credentials.json"
            rm -rf "$config_dir/statsig"
            rm -rf "$config_dir/todos"
            rm -rf "$config_dir/projects"
            echo "✓ Removed credentials for profile: $profile_name"
            echo "  Kept: settings.json, CLAUDE.md"
            ;;
        *)
            echo "Cancelled"
            ;;
    esac
}
