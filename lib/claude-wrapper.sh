# Main claude wrapper function

claude() {
    # Pass through native Claude commands (install, update, help, etc.)
    # Only intercept interactive usage
    if [[ "$1" == "install" || "$1" == "update" || "$1" == "doctor" || "$1" == "--help" || "$1" == "-h" || "$1" == "--version" || "$1" == "-v" ]]; then
        command claude "$@"
        return $?
    fi

    local profile="$CLAUDE_DEFAULT_PROFILE"
    local claude_args=()
    local yolo_mode=false

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
            --yolo)
                yolo_mode=true
                shift
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

    # YOLO mode: skip all permissions for this session only
    if [[ "$yolo_mode" == true ]]; then
        echo "⚠ YOLO mode: skipping all permissions for this session"
        claude_args=("--dangerously-skip-permissions" "${claude_args[@]}")
    # Trusted profile: skip permissions permanently
    elif [[ -f "$config_dir/.trusted" ]]; then
        echo "⚠ Trusted profile: skipping all permissions"
        claude_args=("--dangerously-skip-permissions" "${claude_args[@]}")
    fi

    CLAUDE_CONFIG_DIR="$config_dir" command claude "${claude_args[@]}"
}

export -f claude
