# Utility functions

profile_dir() {
    echo "$CLAUDE_PROFILES_DIR/.claude-$1"
}

profile_exists() {
    [[ -d "$(profile_dir "$1")" ]]
}

require_profile() {
    if ! profile_exists "$1"; then
        echo "Profile '$1' does not exist" >&2
        return 1
    fi
}

require_no_profile() {
    if profile_exists "$1"; then
        echo "Profile '$1' already exists" >&2
        return 1
    fi
}

list_profiles() {
    for dir in "$CLAUDE_PROFILES_DIR"/.claude-*; do
        [[ -d "$dir" ]] && basename "$dir" | sed 's/^\.claude-//'
    done
}
