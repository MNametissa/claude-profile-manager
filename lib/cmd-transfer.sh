# Transfer commands: rename, export, import, diff

cmd_rename() {
    local old_name="$1"
    local new_name="$2"
    if [[ -z "$old_name" || -z "$new_name" ]]; then
        echo "Usage: claude-profiles rename <old-name> <new-name>" >&2
        return 1
    fi

    require_profile "$old_name" || return 1
    require_no_profile "$new_name" || return 1

    mv "$(profile_dir "$old_name")" "$(profile_dir "$new_name")"
    echo "✓ Renamed '$old_name' to '$new_name'"
}

cmd_export() {
    local profile_name="$1"
    local output_file="$2"
    if [[ -z "$profile_name" ]]; then
        echo "Usage: claude-profiles export <profile-name> [output-file]" >&2
        return 1
    fi

    require_profile "$profile_name" || return 1

    [[ -z "$output_file" ]] && output_file="claude-profile-$profile_name-$(date +%Y%m%d).zip"

    local config_dir="$(profile_dir "$profile_name")"
    local orig_dir="$(pwd)"

    # Create zip excluding credentials
    (cd "$CLAUDE_PROFILES_DIR" && zip -rq "$orig_dir/$output_file" ".claude-$profile_name" \
        -x ".claude-$profile_name/.credentials.json" \
        -x ".claude-$profile_name/statsig/*") 2>/dev/null

    echo "✓ Exported '$profile_name' to $output_file"
    echo "  (credentials excluded)"
    echo ""
    echo "Standalone usage (without profile manager):"
    echo "  unzip $output_file -d ~"
    echo "  CLAUDE_CONFIG_DIR=~/.claude-$profile_name claude"
}

cmd_import() {
    local input_file="$1"
    local new_name="$2"
    if [[ -z "$input_file" ]]; then
        echo "Usage: claude-profiles import <file.zip> [new-name]" >&2
        return 1
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "File not found: $input_file" >&2
        return 1
    fi

    local archived_name=$(unzip -l "$input_file" 2>/dev/null | awk 'NR==4 {print $4}' | sed 's|/.*||' | sed 's|\.claude-||')
    local target_name="${new_name:-$archived_name}"

    require_no_profile "$target_name" || {
        echo "  claude-profiles import $input_file <new-name>" >&2
        return 1
    }

    unzip -q "$input_file" -d "$CLAUDE_PROFILES_DIR" 2>/dev/null

    if [[ -n "$new_name" && "$new_name" != "$archived_name" ]]; then
        mv "$(profile_dir "$archived_name")" "$(profile_dir "$target_name")"
    fi

    echo "✓ Imported profile '$target_name'"
    echo "  Run: claude -u $target_name"
}

cmd_diff() {
    local profile1="$1"
    local profile2="$2"
    if [[ -z "$profile1" || -z "$profile2" ]]; then
        echo "Usage: claude-profiles diff <profile1> <profile2>" >&2
        return 1
    fi

    require_profile "$profile1" || return 1
    require_profile "$profile2" || return 1

    local dir1="$(profile_dir "$profile1")"
    local dir2="$(profile_dir "$profile2")"

    echo "Comparing '$profile1' vs '$profile2'"
    echo ""

    echo "=== settings.json ==="
    if [[ -f "$dir1/settings.json" && -f "$dir2/settings.json" ]]; then
        diff --color=auto "$dir1/settings.json" "$dir2/settings.json" || true
    elif [[ -f "$dir1/settings.json" ]]; then
        echo "Only in $profile1"
    elif [[ -f "$dir2/settings.json" ]]; then
        echo "Only in $profile2"
    else
        echo "(neither has settings.json)"
    fi
    echo ""

    echo "=== CLAUDE.md ==="
    if [[ -f "$dir1/CLAUDE.md" && -f "$dir2/CLAUDE.md" ]]; then
        diff --color=auto "$dir1/CLAUDE.md" "$dir2/CLAUDE.md" || true
    elif [[ -f "$dir1/CLAUDE.md" ]]; then
        echo "Only in $profile1"
    elif [[ -f "$dir2/CLAUDE.md" ]]; then
        echo "Only in $profile2"
    else
        echo "(neither has CLAUDE.md)"
    fi
}
