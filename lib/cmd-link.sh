# Resource linking commands for cross-profile sharing

SHARED_DIR="$HOME/.claude-shared"
SHARED_PROJECTS="$SHARED_DIR/projects"
SHARED_INSTRUCTIONS="$SHARED_DIR/CLAUDE.md"
SHARED_HISTORY="$SHARED_DIR/history.jsonl"
SHARED_TODOS="$SHARED_DIR/todos"

# ─────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────

_ensure_shared_dir() {
    mkdir -p "$SHARED_DIR"
}

_is_linked() {
    [[ -L "$1" ]]
}

_link_resource() {
    local resource_name="$1"
    local profile_path="$2"
    local shared_path="$3"
    local profile_name="$4"
    local is_dir="${5:-0}"

    if _is_linked "$profile_path"; then
        echo "$resource_name already linked for '$profile_name'"
        return 0
    fi

    _ensure_shared_dir

    # Initialize shared resource if it doesn't exist
    if [[ ! -e "$shared_path" ]]; then
        if [[ -e "$profile_path" ]]; then
            # Move existing to shared
            if [[ "$is_dir" == "1" ]]; then
                mv "$profile_path" "$shared_path"
            else
                mv "$profile_path" "$shared_path"
            fi
            echo "  Moved existing $resource_name to shared location"
        else
            # Create empty
            if [[ "$is_dir" == "1" ]]; then
                mkdir -p "$shared_path"
            else
                touch "$shared_path"
            fi
        fi
    else
        # Shared exists, backup local if present
        if [[ -e "$profile_path" ]]; then
            local backup="${profile_path}.backup-$(date +%Y%m%d-%H%M%S)"
            mv "$profile_path" "$backup"
            echo "  Backed up local $resource_name to $(basename "$backup")"
        fi
    fi

    # Create symlink
    ln -s "$shared_path" "$profile_path"
    echo "✓ Linked $resource_name for '$profile_name'"
}

_unlink_resource() {
    local resource_name="$1"
    local profile_path="$2"
    local shared_path="$3"
    local profile_name="$4"
    local is_dir="${5:-0}"

    if ! _is_linked "$profile_path"; then
        echo "$resource_name is not linked for '$profile_name'"
        return 0
    fi

    # Remove symlink
    rm "$profile_path"

    # Copy from shared to local
    if [[ -e "$shared_path" ]]; then
        if [[ "$is_dir" == "1" ]]; then
            cp -r "$shared_path" "$profile_path"
        else
            cp "$shared_path" "$profile_path"
        fi
    fi

    echo "✓ Unlinked $resource_name for '$profile_name' (copied to local)"
}

# ─────────────────────────────────────────────────────────────
# Instructions (CLAUDE.md)
# ─────────────────────────────────────────────────────────────

cmd_link_instructions() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _link_resource "instructions" "$config_dir/CLAUDE.md" "$SHARED_INSTRUCTIONS" "$profile_name" 0
}

cmd_unlink_instructions() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _unlink_resource "instructions" "$config_dir/CLAUDE.md" "$SHARED_INSTRUCTIONS" "$profile_name" 0
}

cmd_sync_instructions() {
    local source="$1"
    local target="$2"

    if [[ -z "$source" || -z "$target" ]]; then
        echo "Usage: claude-profiles sync-instructions <source-profile> <target-profile>" >&2
        return 1
    fi

    require_profile "$source" || return 1
    require_profile "$target" || return 1

    local source_file="$(profile_dir "$source")/CLAUDE.md"
    local target_file="$(profile_dir "$target")/CLAUDE.md"

    if [[ ! -f "$source_file" ]]; then
        echo "Source profile '$source' has no CLAUDE.md" >&2
        return 1
    fi

    cp "$source_file" "$target_file"
    echo "✓ Copied instructions from '$source' to '$target'"
}

# ─────────────────────────────────────────────────────────────
# Projects (conversations)
# ─────────────────────────────────────────────────────────────

cmd_link_projects() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _link_resource "projects" "$config_dir/projects" "$SHARED_PROJECTS" "$profile_name" 1
}

cmd_unlink_projects() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _unlink_resource "projects" "$config_dir/projects" "$SHARED_PROJECTS" "$profile_name" 1
}

# ─────────────────────────────────────────────────────────────
# History
# ─────────────────────────────────────────────────────────────

cmd_link_history() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _link_resource "history" "$config_dir/history.jsonl" "$SHARED_HISTORY" "$profile_name" 0
}

cmd_unlink_history() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _unlink_resource "history" "$config_dir/history.jsonl" "$SHARED_HISTORY" "$profile_name" 0
}

cmd_merge_history() {
    local profile1="$1"
    local profile2="$2"

    if [[ -z "$profile1" || -z "$profile2" ]]; then
        echo "Usage: claude-profiles merge-history <profile1> <profile2>" >&2
        echo "  Merges history from profile1 into profile2"
        return 1
    fi

    require_profile "$profile1" || return 1
    require_profile "$profile2" || return 1

    local hist1="$(profile_dir "$profile1")/history.jsonl"
    local hist2="$(profile_dir "$profile2")/history.jsonl"

    if [[ ! -f "$hist1" ]]; then
        echo "No history in '$profile1'" >&2
        return 1
    fi

    if [[ ! -f "$hist2" ]]; then
        cp "$hist1" "$hist2"
    else
        cat "$hist1" >> "$hist2"
        # Sort by timestamp if jq available
        if command -v jq &> /dev/null; then
            local tmp=$(mktemp)
            sort -u "$hist2" > "$tmp" && mv "$tmp" "$hist2"
        fi
    fi

    echo "✓ Merged history from '$profile1' into '$profile2'"
}

# ─────────────────────────────────────────────────────────────
# Todos
# ─────────────────────────────────────────────────────────────

cmd_link_todos() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _link_resource "todos" "$config_dir/todos" "$SHARED_TODOS" "$profile_name" 1
}

cmd_unlink_todos() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    _unlink_resource "todos" "$config_dir/todos" "$SHARED_TODOS" "$profile_name" 1
}

# ─────────────────────────────────────────────────────────────
# Permissions
# ─────────────────────────────────────────────────────────────

cmd_link_permissions() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    local shared_settings="$SHARED_DIR/settings.json"
    local profile_settings="$config_dir/settings.json"

    if _is_linked "$profile_settings"; then
        echo "Settings already linked for '$profile_name'"
        return 0
    fi

    _ensure_shared_dir

    if [[ ! -f "$shared_settings" ]]; then
        if [[ -f "$profile_settings" ]]; then
            cp "$profile_settings" "$shared_settings"
        else
            echo '{"permissions":{"allow":[],"deny":[],"ask":[]}}' > "$shared_settings"
        fi
    fi

    if [[ -f "$profile_settings" ]]; then
        mv "$profile_settings" "${profile_settings}.backup-$(date +%Y%m%d-%H%M%S)"
    fi

    ln -s "$shared_settings" "$profile_settings"
    echo "✓ Linked settings/permissions for '$profile_name'"
}

cmd_unlink_permissions() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    local shared_settings="$SHARED_DIR/settings.json"
    local profile_settings="$config_dir/settings.json"

    if ! _is_linked "$profile_settings"; then
        echo "Settings not linked for '$profile_name'"
        return 0
    fi

    rm "$profile_settings"
    [[ -f "$shared_settings" ]] && cp "$shared_settings" "$profile_settings"

    echo "✓ Unlinked settings/permissions for '$profile_name'"
}

cmd_sync_settings() {
    local source="$1"
    local target="$2"

    if [[ -z "$source" || -z "$target" ]]; then
        echo "Usage: claude-profiles sync-settings <source-profile> <target-profile>" >&2
        return 1
    fi

    require_profile "$source" || return 1
    require_profile "$target" || return 1

    local source_file="$(profile_dir "$source")/settings.json"
    local target_file="$(profile_dir "$target")/settings.json"

    if [[ ! -f "$source_file" ]]; then
        echo "Source profile '$source' has no settings.json" >&2
        return 1
    fi

    cp "$source_file" "$target_file"
    echo "✓ Copied settings from '$source' to '$target'"
}

# ─────────────────────────────────────────────────────────────
# Bulk operations
# ─────────────────────────────────────────────────────────────

cmd_link_all() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"

    require_profile "$profile_name" || return 1

    echo "Linking all resources for '$profile_name'..."
    echo ""
    cmd_link_instructions "$profile_name"
    cmd_link_projects "$profile_name"
    cmd_link_history "$profile_name"
    cmd_link_todos "$profile_name"
    echo ""
    echo "✓ All resources linked for '$profile_name'"
}

cmd_unlink_all() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"

    require_profile "$profile_name" || return 1

    echo "Unlinking all resources for '$profile_name'..."
    echo ""
    cmd_unlink_instructions "$profile_name"
    cmd_unlink_projects "$profile_name"
    cmd_unlink_history "$profile_name"
    cmd_unlink_todos "$profile_name"
    echo ""
    echo "✓ All resources unlinked for '$profile_name'"
}

cmd_link_status() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    echo "Link status for '$profile_name':"
    echo ""

    local resources=("CLAUDE.md:instructions" "projects:projects" "history.jsonl:history" "todos:todos" "settings.json:settings")

    for item in "${resources[@]}"; do
        local file="${item%%:*}"
        local name="${item##*:}"
        local path="$config_dir/$file"
        local status="local"
        local target=""

        if [[ -L "$path" ]]; then
            status="linked"
            target=" → $(readlink "$path")"
        elif [[ ! -e "$path" ]]; then
            status="absent"
        fi

        printf "  %-15s %s%s\n" "$name" "$status" "$target"
    done
}

# ─────────────────────────────────────────────────────────────
# Clone with linking
# ─────────────────────────────────────────────────────────────

cmd_clone() {
    local source="$1"
    local target="$2"
    local linked=false

    shift 2 2>/dev/null || true

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --linked|-l) linked=true; shift ;;
            *) shift ;;
        esac
    done

    if [[ -z "$source" || -z "$target" ]]; then
        echo "Usage: claude-profiles clone <source> <target> [--linked]" >&2
        echo ""
        echo "Options:"
        echo "  --linked, -l    Share resources via symlinks instead of copying"
        return 1
    fi

    require_profile "$source" || return 1
    require_no_profile "$target" || return 1

    local source_dir="$(profile_dir "$source")"
    local target_dir="$(profile_dir "$target")"

    # Create target profile directory
    mkdir -p "$target_dir"

    if [[ "$linked" == true ]]; then
        # Linked clone: use shared resources
        echo "Creating linked clone '$target' from '$source'..."

        # Copy credentials-related stuff (not shared)
        [[ -f "$source_dir/.credentials.json" ]] && echo "  (credentials not copied - authenticate separately)"

        # Create empty settings or copy
        if [[ -f "$source_dir/settings.json" ]]; then
            cp "$source_dir/settings.json" "$target_dir/settings.json"
        fi

        # Link shared resources
        cmd_link_instructions "$target" 2>/dev/null
        cmd_link_projects "$target" 2>/dev/null
        cmd_link_history "$target" 2>/dev/null
        cmd_link_todos "$target" 2>/dev/null

        echo ""
        echo "✓ Created linked profile '$target'"
        echo "  Shares: instructions, projects, history, todos"
    else
        # Regular clone: copy everything except credentials
        echo "Cloning '$source' to '$target'..."

        cp -r "$source_dir"/* "$target_dir"/ 2>/dev/null || true
        rm -f "$target_dir/.credentials.json"
        rm -rf "$target_dir/statsig"

        echo "✓ Cloned profile '$target' from '$source'"
        echo "  (credentials excluded - authenticate separately)"
    fi

    echo ""
    echo "Next: claude -u $target"
}
