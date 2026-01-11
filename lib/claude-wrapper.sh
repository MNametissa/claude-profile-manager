# Main claude wrapper function

claude() {
    local profile="$CLAUDE_DEFAULT_PROFILE"
    local claude_args=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--user)
                if [[ -n "$2" && "$2" != -* ]]; then
                    profile="$2"
                    shift 2
                else
                    echo "Error: -u/--user requires a profile name" >&2
                    return 1
                fi
                ;;
            *)
                claude_args+=("$1")
                shift
                ;;
        esac
    done

    local config_dir="$(profile_dir "$profile")"

    if [[ ! -d "$config_dir" ]]; then
        echo "Error: Profile '$profile' not found at $config_dir" >&2
        echo "Available profiles:" >&2
        claude-profiles list >&2
        echo "" >&2
        echo "Create it with: claude-profiles add $profile" >&2
        return 1
    fi

    echo "→ Claude profile: $profile"
    CLAUDE_CONFIG_DIR="$config_dir" command claude "${claude_args[@]}"
}

export -f claude
