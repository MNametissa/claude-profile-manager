# List profiles command

cmd_list() {
    echo "Available Claude profiles:"
    echo ""
    for dir in "$CLAUDE_PROFILES_DIR"/.claude-*; do
        if [[ -d "$dir" ]]; then
            local profile_name="${dir##*/.claude-}"
            local is_default=""
            [[ "$profile_name" == "$CLAUDE_DEFAULT_PROFILE" ]] && is_default=" (default)"

            local auth_status="○"
            [[ -f "$dir/.credentials.json" ]] && auth_status="●"

            printf "  %s %s%s\n" "$auth_status" "$profile_name" "$is_default"
        fi
    done
    echo ""
    echo "Legend: ● authenticated | ○ not authenticated"
}
