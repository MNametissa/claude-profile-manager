# Info and usage commands

cmd_info() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    echo "Profile: $profile_name"
    echo "Location: $config_dir"
    echo ""

    if [[ -f "$config_dir/.credentials.json" ]]; then
        echo "Status: ● Authenticated"
        if command -v jq &> /dev/null; then
            local expires=$(jq -r '.claudeAiOauth.expiresAt' "$config_dir/.credentials.json" 2>/dev/null)
            if [[ -n "$expires" && "$expires" != "null" ]]; then
                local expires_date=$(date -d "@$((expires/1000))" "+%Y-%m-%d %H:%M" 2>/dev/null || date -r "$((expires/1000))" "+%Y-%m-%d %H:%M" 2>/dev/null)
                echo "Token expires: $expires_date"
            fi
        fi
    else
        echo "Status: ○ Not authenticated"
    fi
    echo ""

    echo "Context files:"
    local found_context=0
    if [[ -f "$config_dir/CLAUDE.md" ]]; then
        local lines=$(wc -l < "$config_dir/CLAUDE.md")
        echo "  ● $config_dir/CLAUDE.md ($lines lines)"
        found_context=1
    fi
    if [[ -f ".claude/CLAUDE.md" ]]; then
        local lines=$(wc -l < ".claude/CLAUDE.md")
        echo "  ● .claude/CLAUDE.md ($lines lines)"
        found_context=1
    fi
    if [[ -f "CLAUDE.md" ]]; then
        local lines=$(wc -l < "CLAUDE.md")
        echo "  ● ./CLAUDE.md ($lines lines)"
        found_context=1
    fi
    [[ $found_context -eq 0 ]] && echo "  (none)"
    echo ""

    if [[ -f "$config_dir/history.jsonl" ]]; then
        echo "Recent sessions:"
        tail -5 "$config_dir/history.jsonl" 2>/dev/null | while read -r line; do
            if command -v jq &> /dev/null; then
                local ts=$(echo "$line" | jq -r '.timestamp // empty' 2>/dev/null)
                local prompt=$(echo "$line" | jq -r '.prompt // empty' 2>/dev/null | head -c 50)
                if [[ -n "$ts" && -n "$prompt" ]]; then
                    local date_str=$(date -d "$ts" "+%m-%d %H:%M" 2>/dev/null || echo "$ts")
                    echo "  $date_str: $prompt..."
                fi
            fi
        done
        echo ""
    fi

    if command -v du &> /dev/null; then
        local size=$(du -sh "$config_dir" 2>/dev/null | cut -f1)
        echo "Disk usage: $size"
    fi
}

cmd_usage() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    echo "Disk usage for '$profile_name':"
    echo ""

    local total=$(du -sh "$config_dir" 2>/dev/null | cut -f1)

    for item in projects history.jsonl todos plans file-history debug statsig .credentials.json settings.json CLAUDE.md; do
        local path="$config_dir/$item"
        if [[ -e "$path" ]]; then
            local size=$(du -sh "$path" 2>/dev/null | cut -f1)
            printf "  %-20s %s\n" "$item" "$size"
        fi
    done

    echo ""
    echo "Total: $total"
}

cmd_current() {
    if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
        local profile_name="${CLAUDE_CONFIG_DIR##*/.claude-}"
        echo "Current active profile: $profile_name"
        echo "Config dir: $CLAUDE_CONFIG_DIR"
    else
        echo "Current profile: $CLAUDE_DEFAULT_PROFILE (default)"
        echo "Config dir: $(profile_dir "$CLAUDE_DEFAULT_PROFILE")"
    fi
}

cmd_path() {
    echo "$CLAUDE_INSTALL_DIR"
}
