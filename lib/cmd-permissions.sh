# Permission management commands

cmd_permissions() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    local settings_file="$config_dir/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        echo "No settings.json for profile '$profile_name'"
        echo "Run: claude-profiles permissions-init $profile_name"
        return 1
    fi

    echo "Permissions for '$profile_name':"
    echo ""

    if command -v jq &> /dev/null; then
        echo "ALLOW:"
        jq -r '.permissions.allow // [] | .[]' "$settings_file" 2>/dev/null | sed 's/^/  ✓ /' || echo "  (none)"
        echo ""
        echo "DENY:"
        jq -r '.permissions.deny // [] | .[]' "$settings_file" 2>/dev/null | sed 's/^/  ✗ /' || echo "  (none)"
        echo ""
        echo "ASK:"
        jq -r '.permissions.ask // [] | .[]' "$settings_file" 2>/dev/null | sed 's/^/  ? /' || echo "  (none)"
    else
        cat "$settings_file"
    fi
}

cmd_allow() {
    local rule="$1"
    local profile_name="${2:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$rule" ]]; then
        echo "Usage: claude-profiles allow <rule> [profile]" >&2
        echo ""
        echo "Examples:"
        echo "  claude-profiles allow 'Bash(npm *)'"
        echo "  claude-profiles allow 'Bash(git *)'"
        echo "  claude-profiles allow 'Edit(/src/**)'"
        echo "  claude-profiles allow 'WebSearch'"
        return 1
    fi

    _add_permission "allow" "$rule" "$profile_name"
}

cmd_deny() {
    local rule="$1"
    local profile_name="${2:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$rule" ]]; then
        echo "Usage: claude-profiles deny <rule> [profile]" >&2
        echo ""
        echo "Examples:"
        echo "  claude-profiles deny 'Bash(rm -rf *)'"
        echo "  claude-profiles deny 'Bash(sudo *)'"
        echo "  claude-profiles deny 'Edit(//etc/**)'"
        return 1
    fi

    _add_permission "deny" "$rule" "$profile_name"
}

cmd_ask() {
    local rule="$1"
    local profile_name="${2:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$rule" ]]; then
        echo "Usage: claude-profiles ask <rule> [profile]" >&2
        return 1
    fi

    _add_permission "ask" "$rule" "$profile_name"
}

cmd_unallow() {
    local rule="$1"
    local profile_name="${2:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$rule" ]]; then
        echo "Usage: claude-profiles unallow <rule> [profile]" >&2
        return 1
    fi

    _remove_permission "allow" "$rule" "$profile_name"
}

cmd_undeny() {
    local rule="$1"
    local profile_name="${2:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$rule" ]]; then
        echo "Usage: claude-profiles undeny <rule> [profile]" >&2
        return 1
    fi

    _remove_permission "deny" "$rule" "$profile_name"
}

cmd_permissions_init() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    local settings_file="$config_dir/settings.json"

    if [[ -f "$settings_file" ]]; then
        # Ensure permissions object exists
        if command -v jq &> /dev/null; then
            local tmp=$(mktemp)
            jq '. + {permissions: (.permissions // {allow: [], deny: [], ask: []})}' "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"
        fi
    else
        cat > "$settings_file" << 'EOF'
{
  "permissions": {
    "allow": [],
    "deny": [],
    "ask": []
  }
}
EOF
    fi

    echo "✓ Permissions initialized for '$profile_name'"
}

cmd_permissions_preset() {
    local preset="$1"
    local profile_name="${2:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$preset" ]]; then
        echo "Usage: claude-profiles permissions-preset <preset> [profile]" >&2
        echo ""
        echo "Available presets:"
        echo "  safe        Block dangerous commands (rm -rf, sudo, etc.)"
        echo "  dev         Common dev tools (git, npm, yarn, etc.)"
        echo "  readonly    Only read/search, no writes or commands"
        echo "  reset       Clear all permissions"
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local settings_file="$config_dir/settings.json"
    cmd_permissions_init "$profile_name" > /dev/null

    case "$preset" in
        safe)
            _set_permissions "$settings_file" '{
                "allow": [],
                "deny": [
                    "Bash(rm -rf *)",
                    "Bash(sudo *)",
                    "Bash(chmod 777 *)",
                    "Bash(mkfs *)",
                    "Bash(dd *)",
                    "Bash(> /dev/*)",
                    "Edit(//etc/**)",
                    "Edit(//usr/**)",
                    "Edit(//bin/**)",
                    "Edit(//sbin/**)",
                    "Edit(~/.bashrc)",
                    "Edit(~/.zshrc)",
                    "Edit(~/.profile)",
                    "Edit(~/.ssh/**)"
                ],
                "ask": []
            }'
            echo "✓ Applied 'safe' preset - dangerous commands blocked"
            ;;
        dev)
            _set_permissions "$settings_file" '{
                "allow": [
                    "Bash(git *)",
                    "Bash(npm *)",
                    "Bash(yarn *)",
                    "Bash(pnpm *)",
                    "Bash(node *)",
                    "Bash(python *)",
                    "Bash(pip *)",
                    "Bash(cargo *)",
                    "Bash(go *)",
                    "Bash(make *)",
                    "Bash(cmake *)",
                    "Bash(ls *)",
                    "Bash(cat *)",
                    "Bash(mkdir *)",
                    "Bash(cp *)",
                    "Bash(mv *)",
                    "WebSearch",
                    "Glob",
                    "Grep"
                ],
                "deny": [
                    "Bash(rm -rf /)",
                    "Bash(sudo *)",
                    "Edit(//etc/**)"
                ],
                "ask": [
                    "Bash(rm *)"
                ]
            }'
            echo "✓ Applied 'dev' preset - common dev tools allowed"
            ;;
        readonly)
            _set_permissions "$settings_file" '{
                "allow": [
                    "Read",
                    "Glob",
                    "Grep",
                    "WebSearch",
                    "Bash(ls *)",
                    "Bash(cat *)",
                    "Bash(head *)",
                    "Bash(tail *)",
                    "Bash(find *)",
                    "Bash(which *)",
                    "Bash(echo *)"
                ],
                "deny": [
                    "Edit",
                    "Write",
                    "Bash(rm *)",
                    "Bash(mv *)",
                    "Bash(cp *)",
                    "Bash(touch *)",
                    "Bash(mkdir *)",
                    "Bash(chmod *)",
                    "Bash(chown *)"
                ],
                "ask": []
            }'
            echo "✓ Applied 'readonly' preset - no modifications allowed"
            ;;
        reset)
            _set_permissions "$settings_file" '{
                "allow": [],
                "deny": [],
                "ask": []
            }'
            echo "✓ Permissions reset - all rules cleared"
            ;;
        *)
            echo "Unknown preset: $preset" >&2
            return 1
            ;;
    esac
}

# Helper: add permission to a list
_add_permission() {
    local list="$1"
    local rule="$2"
    local profile_name="$3"

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local settings_file="$config_dir/settings.json"
    cmd_permissions_init "$profile_name" > /dev/null

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for permission management" >&2
        return 1
    fi

    local tmp=$(mktemp)
    jq --arg rule "$rule" ".permissions.$list += [\$rule] | .permissions.$list |= unique" "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"

    echo "✓ Added to $list: $rule"
}

# Helper: remove permission from a list
_remove_permission() {
    local list="$1"
    local rule="$2"
    local profile_name="$3"

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local settings_file="$config_dir/settings.json"

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for permission management" >&2
        return 1
    fi

    local tmp=$(mktemp)
    jq --arg rule "$rule" ".permissions.$list -= [\$rule]" "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"

    echo "✓ Removed from $list: $rule"
}

# Helper: set full permissions object
_set_permissions() {
    local settings_file="$1"
    local permissions_json="$2"

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for permission management" >&2
        return 1
    fi

    local tmp=$(mktemp)
    jq --argjson perms "$permissions_json" '.permissions = $perms' "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"
}
