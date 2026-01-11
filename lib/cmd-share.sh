# Agent and skill sharing commands

GLOBAL_AGENTS_DIR="$HOME/.claude-shared/agents"
GLOBAL_SKILLS_DIR="$HOME/.claude-shared/skills"
EXAMPLES_DIR="$CLAUDE_PM_DIR/examples"

# ─────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────

# Get directory for type (agent/skill) - sets $_type_dir and $_global_dir
_resolve_type_dirs() {
    local type="$1"
    local base_dir="$2"  # profile dir or empty for global-only

    case "$type" in
        agent|agents)
            _type_dir="${base_dir:+$base_dir/}agents"
            _global_dir="$GLOBAL_AGENTS_DIR"
            _example_dir="$EXAMPLES_DIR/agents"
            return 0
            ;;
        skill|skills)
            _type_dir="${base_dir:+$base_dir/}skills"
            _global_dir="$GLOBAL_SKILLS_DIR"
            _example_dir="$EXAMPLES_DIR/skills"
            return 0
            ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac
}

# List items in a directory
_list_items() {
    local dir="$1"
    local show_status="${2:-0}"

    if [[ ! -d "$dir" ]]; then
        echo "  (none)"
        return
    fi

    local found=0
    for f in "$dir"/*.md; do
        [[ -f "$f" ]] || continue
        found=1
        local name=$(basename "$f" .md)
        if [[ "$show_status" == "1" ]]; then
            local status="local"
            [[ -L "$f" ]] && status="shared"
            printf "  %-20s [%s]\n" "$name" "$status"
        else
            echo "  ● $name"
        fi
    done
    [[ $found -eq 0 ]] && echo "  (none)"
}

# ─────────────────────────────────────────────────────────────
# Commands
# ─────────────────────────────────────────────────────────────

cmd_examples() {
    echo "Available examples:"
    echo ""
    echo "Agents:"
    _list_items "$EXAMPLES_DIR/agents"
    echo ""
    echo "Skills:"
    _list_items "$EXAMPLES_DIR/skills"
}

cmd_agents() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    echo "Agents for '$profile_name':"
    echo ""
    _list_items "$config_dir/agents" 1
    echo ""
    echo "Global agents:"
    _list_items "$GLOBAL_AGENTS_DIR"
}

cmd_skills() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    echo "Skills for '$profile_name':"
    echo ""
    _list_items "$config_dir/skills" 1
    echo ""
    echo "Global skills:"
    _list_items "$GLOBAL_SKILLS_DIR"
}

cmd_show() {
    local type="$1" name="$2" profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles show <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    _resolve_type_dirs "$type" "$config_dir" || return 1

    local file=""
    [[ -f "$_type_dir/$name.md" ]] && file="$_type_dir/$name.md"
    [[ -z "$file" && -f "$_global_dir/$name.md" ]] && file="$_global_dir/$name.md"

    if [[ -z "$file" ]]; then
        echo "$type '$name' not found" >&2
        return 1
    fi

    echo "=== $name ($type) ==="
    [[ -L "$file" ]] && echo "Location: $(readlink -f "$file")" || echo "Location: $file"
    echo ""
    cat "$file"
}

cmd_install() {
    local type="$1" name="$2" target="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles install <agent|skill> <name> [profile|--global]" >&2
        echo ""
        cmd_examples
        return 1
    fi

    local target_dir target_label
    if [[ "$target" == "--global" || "$target" == "-g" ]]; then
        _resolve_type_dirs "$type" "" || return 1
        target_dir="$_global_dir"
        target_label="global"
    else
        local config_dir="$(profile_dir "$target")"
        require_profile "$target" || return 1
        _resolve_type_dirs "$type" "$config_dir" || return 1
        target_dir="$_type_dir"
        target_label="profile '$target'"
    fi

    local source_file="$_example_dir/$name.md"
    if [[ ! -f "$source_file" ]]; then
        echo "$type '$name' not found in examples" >&2
        echo ""
        cmd_examples
        return 1
    fi

    local target_file="$target_dir/$name.md"
    if [[ -e "$target_file" ]]; then
        echo "$type '$name' already exists in $target_label" >&2
        return 1
    fi

    mkdir -p "$target_dir"
    cp "$source_file" "$target_file"
    echo "✓ Installed $type '$name' to $target_label"
}

cmd_uninstall() {
    local type="$1" name="$2" profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles uninstall <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1
    _resolve_type_dirs "$type" "$config_dir" || return 1

    local target_file="$_type_dir/$name.md"
    if [[ ! -e "$target_file" ]]; then
        echo "$type '$name' not found in profile '$profile_name'" >&2
        return 1
    fi

    rm -f "$target_file"
    echo "✓ Uninstalled $type '$name' from profile '$profile_name'"
}

cmd_globalize() {
    local type="$1" name="$2" profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles globalize <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1
    _resolve_type_dirs "$type" "$config_dir" || return 1

    local source_file="$_type_dir/$name.md"
    local global_file="$_global_dir/$name.md"

    if [[ ! -f "$source_file" ]]; then
        echo "$type '$name' not found in profile '$profile_name'" >&2
        return 1
    fi
    if [[ -L "$source_file" ]]; then
        echo "$type '$name' is already shared" >&2
        return 1
    fi

    mkdir -p "$_global_dir"
    mv "$source_file" "$global_file"
    ln -s "$global_file" "$source_file"

    echo "✓ Made '$name' global"
    echo "  Location: $global_file"
}

cmd_localize() {
    local type="$1" name="$2" profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles localize <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1
    _resolve_type_dirs "$type" "$config_dir" || return 1

    local source_file="$_type_dir/$name.md"
    local global_file="$_global_dir/$name.md"

    if [[ ! -L "$source_file" ]]; then
        echo "$type '$name' is not shared (already local)" >&2
        return 1
    fi

    rm "$source_file"
    cp "$global_file" "$source_file"
    echo "✓ Made '$name' local to profile '$profile_name'"
}

cmd_share() {
    local type="$1" name="$2" profile_name="$3"

    if [[ -z "$type" || -z "$name" || -z "$profile_name" ]]; then
        echo "Usage: claude-profiles share <agent|skill> <name> <profile>" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1
    _resolve_type_dirs "$type" "$config_dir" || return 1

    local global_file="$_global_dir/$name.md"
    local target_file="$_type_dir/$name.md"

    if [[ ! -f "$global_file" ]]; then
        echo "Global $type '$name' not found" >&2
        return 1
    fi
    if [[ -e "$target_file" ]]; then
        echo "$type '$name' already exists in profile '$profile_name'" >&2
        return 1
    fi

    mkdir -p "$_type_dir"
    ln -s "$global_file" "$target_file"
    echo "✓ Shared '$name' with profile '$profile_name'"
}

cmd_unshare() {
    local type="$1" name="$2" profile_name="$3"

    if [[ -z "$type" || -z "$name" || -z "$profile_name" ]]; then
        echo "Usage: claude-profiles unshare <agent|skill> <name> <profile>" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1
    _resolve_type_dirs "$type" "$config_dir" || return 1

    local target_file="$_type_dir/$name.md"

    if [[ ! -L "$target_file" ]]; then
        echo "$type '$name' is not a shared link in profile '$profile_name'" >&2
        return 1
    fi

    rm "$target_file"
    echo "✓ Unshared '$name' from profile '$profile_name'"
}
